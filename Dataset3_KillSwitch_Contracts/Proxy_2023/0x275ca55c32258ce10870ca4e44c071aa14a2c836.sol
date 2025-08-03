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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC1363.sol)

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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC4626.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
import {IERC20Metadata} from "../token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @dev Interface of the ERC-4626 "Tokenized Vault Standard", as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
 */
interface IERC4626 is IERC20, IERC20Metadata {
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /**
     * @dev Returns the address of the underlying token used for the Vault for accounting, depositing, and withdrawing.
     *
     * - MUST be an ERC-20 token contract.
     * - MUST NOT revert.
     */
    function asset() external view returns (address assetTokenAddress);

    /**
     * @dev Returns the total amount of the underlying asset that is “managed” by Vault.
     *
     * - SHOULD include any compounding that occurs from yield.
     * - MUST be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT revert.
     */
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /**
     * @dev Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be deposited into the Vault for the receiver,
     * through a deposit call.
     *
     * - MUST return a limited value if receiver is subject to some deposit limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of assets that may be deposited.
     * - MUST NOT revert.
     */
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their deposit at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of Vault shares that would be minted in a deposit
     *   call in the same transaction. I.e. deposit should return the same or more shares as previewDeposit if called
     *   in the same transaction.
     * - MUST NOT account for deposit limits like those returned from maxDeposit and should always act as though the
     *   deposit would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewDeposit SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Mints shares Vault shares to receiver by depositing exactly amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   deposit execution, and are accounted for during deposit.
     * - MUST revert if all of assets cannot be deposited (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of the Vault shares that can be minted for the receiver, through a mint call.
     * - MUST return a limited value if receiver is subject to some mint limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of shares that may be minted.
     * - MUST NOT revert.
     */
    function maxMint(address receiver) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their mint at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of assets that would be deposited in a mint call
     *   in the same transaction. I.e. mint should return the same or fewer assets as previewMint if called in the
     *   same transaction.
     * - MUST NOT account for mint limits like those returned from maxMint and should always act as though the mint
     *   would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewMint SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by minting.
     */
    function previewMint(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Mints exactly shares Vault shares to receiver by depositing amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the mint
     *   execution, and are accounted for during mint.
     * - MUST revert if all of shares cannot be minted (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be withdrawn from the owner balance in the
     * Vault, through a withdraw call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their withdrawal at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of Vault shares that would be burned in a withdraw
     *   call in the same transaction. I.e. withdraw should return the same or fewer shares as previewWithdraw if
     *   called
     *   in the same transaction.
     * - MUST NOT account for withdrawal limits like those returned from maxWithdraw and should always act as though
     *   the withdrawal would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewWithdraw SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Burns shares from owner and sends exactly assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   withdraw execution, and are accounted for during withdraw.
     * - MUST revert if all of assets cannot be withdrawn (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * Note that some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of Vault shares that can be redeemed from the owner balance in the Vault,
     * through a redeem call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST return balanceOf(owner) if owner is not subject to any withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxRedeem(address owner) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their redeemption at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of assets that would be withdrawn in a redeem call
     *   in the same transaction. I.e. redeem should return the same or more assets as previewRedeem if called in the
     *   same transaction.
     * - MUST NOT account for redemption limits like those returned from maxRedeem and should always act as though the
     *   redemption would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewRedeem SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by redeeming.
     */
    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Burns exactly shares from owner and sends assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   redeem execution, and are accounted for during redeem.
     * - MUST revert if all of shares cannot be redeemed (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * NOTE: some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC4626.sol)

pragma solidity ^0.8.20;

import {IERC20, IERC20Metadata, ERC20} from "../ERC20.sol";
import {SafeERC20} from "../utils/SafeERC20.sol";
import {IERC4626} from "../../../interfaces/IERC4626.sol";
import {Math} from "../../../utils/math/Math.sol";

/**
 * @dev Implementation of the ERC-4626 "Tokenized Vault Standard" as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
 *
 * This extension allows the minting and burning of "shares" (represented using the ERC-20 inheritance) in exchange for
 * underlying "assets" through standardized {deposit}, {mint}, {redeem} and {burn} workflows. This contract extends
 * the ERC-20 standard. Any additional extensions included along it would affect the "shares" token represented by this
 * contract and not the "assets" token which is an independent contract.
 *
 * [CAUTION]
 * ====
 * In empty (or nearly empty) ERC-4626 vaults, deposits are at high risk of being stolen through frontrunning
 * with a "donation" to the vault that inflates the price of a share. This is variously known as a donation or inflation
 * attack and is essentially a problem of slippage. Vault deployers can protect against this attack by making an initial
 * deposit of a non-trivial amount of the asset, such that price manipulation becomes infeasible. Withdrawals may
 * similarly be affected by slippage. Users can protect against this attack as well as unexpected slippage in general by
 * verifying the amount received is as expected, using a wrapper that performs these checks such as
 * https://github.com/fei-protocol/ERC4626#erc4626router-and-base[ERC4626Router].
 *
 * Since v4.9, this implementation introduces configurable virtual assets and shares to help developers mitigate that risk.
 * The `_decimalsOffset()` corresponds to an offset in the decimal representation between the underlying asset's decimals
 * and the vault decimals. This offset also determines the rate of virtual shares to virtual assets in the vault, which
 * itself determines the initial exchange rate. While not fully preventing the attack, analysis shows that the default
 * offset (0) makes it non-profitable even if an attacker is able to capture value from multiple user deposits, as a result
 * of the value being captured by the virtual shares (out of the attacker's donation) matching the attacker's expected gains.
 * With a larger offset, the attack becomes orders of magnitude more expensive than it is profitable. More details about the
 * underlying math can be found xref:erc4626.adoc#inflation-attack[here].
 *
 * The drawback of this approach is that the virtual shares do capture (a very small) part of the value being accrued
 * to the vault. Also, if the vault experiences losses, the users try to exit the vault, the virtual shares and assets
 * will cause the first user to exit to experience reduced losses in detriment to the last users that will experience
 * bigger losses. Developers willing to revert back to the pre-v4.9 behavior just need to override the
 * `_convertToShares` and `_convertToAssets` functions.
 *
 * To learn more, check out our xref:ROOT:erc4626.adoc[ERC-4626 guide].
 * ====
 */
abstract contract ERC4626 is ERC20, IERC4626 {
    using Math for uint256;

    IERC20 private immutable _asset;
    uint8 private immutable _underlyingDecimals;

    /**
     * @dev Attempted to deposit more assets than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxDeposit(address receiver, uint256 assets, uint256 max);

    /**
     * @dev Attempted to mint more shares than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxMint(address receiver, uint256 shares, uint256 max);

    /**
     * @dev Attempted to withdraw more assets than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxWithdraw(address owner, uint256 assets, uint256 max);

    /**
     * @dev Attempted to redeem more shares than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxRedeem(address owner, uint256 shares, uint256 max);

    /**
     * @dev Set the underlying asset contract. This must be an ERC20-compatible contract (ERC-20 or ERC-777).
     */
    constructor(IERC20 asset_) {
        (bool success, uint8 assetDecimals) = _tryGetAssetDecimals(asset_);
        _underlyingDecimals = success ? assetDecimals : 18;
        _asset = asset_;
    }

    /**
     * @dev Attempts to fetch the asset decimals. A return value of false indicates that the attempt failed in some way.
     */
    function _tryGetAssetDecimals(IERC20 asset_) private view returns (bool ok, uint8 assetDecimals) {
        (bool success, bytes memory encodedDecimals) = address(asset_).staticcall(
            abi.encodeCall(IERC20Metadata.decimals, ())
        );
        if (success && encodedDecimals.length >= 32) {
            uint256 returnedDecimals = abi.decode(encodedDecimals, (uint256));
            if (returnedDecimals <= type(uint8).max) {
                return (true, uint8(returnedDecimals));
            }
        }
        return (false, 0);
    }

    /**
     * @dev Decimals are computed by adding the decimal offset on top of the underlying asset's decimals. This
     * "original" value is cached during construction of the vault contract. If this read operation fails (e.g., the
     * asset has not been created yet), a default of 18 is used to represent the underlying asset's decimals.
     *
     * See {IERC20Metadata-decimals}.
     */
    function decimals() public view virtual override(IERC20Metadata, ERC20) returns (uint8) {
        return _underlyingDecimals + _decimalsOffset();
    }

    /** @dev See {IERC4626-asset}. */
    function asset() public view virtual returns (address) {
        return address(_asset);
    }

    /** @dev See {IERC4626-totalAssets}. */
    function totalAssets() public view virtual returns (uint256) {
        return _asset.balanceOf(address(this));
    }

    /** @dev See {IERC4626-convertToShares}. */
    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-convertToAssets}. */
    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-maxDeposit}. */
    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /** @dev See {IERC4626-maxMint}. */
    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /** @dev See {IERC4626-maxWithdraw}. */
    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return _convertToAssets(balanceOf(owner), Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-maxRedeem}. */
    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf(owner);
    }

    /** @dev See {IERC4626-previewDeposit}. */
    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-previewMint}. */
    function previewMint(uint256 shares) public view virtual returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Ceil);
    }

    /** @dev See {IERC4626-previewWithdraw}. */
    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Ceil);
    }

    /** @dev See {IERC4626-previewRedeem}. */
    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-deposit}. */
    function deposit(uint256 assets, address receiver) public virtual returns (uint256) {
        uint256 maxAssets = maxDeposit(receiver);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxDeposit(receiver, assets, maxAssets);
        }

        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);

        return shares;
    }

    /** @dev See {IERC4626-mint}. */
    function mint(uint256 shares, address receiver) public virtual returns (uint256) {
        uint256 maxShares = maxMint(receiver);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxMint(receiver, shares, maxShares);
        }

        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);

        return assets;
    }

    /** @dev See {IERC4626-withdraw}. */
    function withdraw(uint256 assets, address receiver, address owner) public virtual returns (uint256) {
        uint256 maxAssets = maxWithdraw(owner);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxWithdraw(owner, assets, maxAssets);
        }

        uint256 shares = previewWithdraw(assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return shares;
    }

    /** @dev See {IERC4626-redeem}. */
    function redeem(uint256 shares, address receiver, address owner) public virtual returns (uint256) {
        uint256 maxShares = maxRedeem(owner);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxRedeem(owner, shares, maxShares);
        }

        uint256 assets = previewRedeem(shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return assets;
    }

    /**
     * @dev Internal conversion function (from assets to shares) with support for rounding direction.
     */
    function _convertToShares(uint256 assets, Math.Rounding rounding) internal view virtual returns (uint256) {
        return assets.mulDiv(totalSupply() + 10 ** _decimalsOffset(), totalAssets() + 1, rounding);
    }

    /**
     * @dev Internal conversion function (from shares to assets) with support for rounding direction.
     */
    function _convertToAssets(uint256 shares, Math.Rounding rounding) internal view virtual returns (uint256) {
        return shares.mulDiv(totalAssets() + 1, totalSupply() + 10 ** _decimalsOffset(), rounding);
    }

    /**
     * @dev Deposit/mint common workflow.
     */
    function _deposit(address caller, address receiver, uint256 assets, uint256 shares) internal virtual {
        // If _asset is ERC-777, `transferFrom` can trigger a reentrancy BEFORE the transfer happens through the
        // `tokensToSend` hook. On the other hand, the `tokenReceived` hook, that is triggered after the transfer,
        // calls the vault, which is assumed not malicious.
        //
        // Conclusion: we need to do the transfer before we mint so that any reentrancy would happen before the
        // assets are transferred and before the shares are minted, which is a valid state.
        // slither-disable-next-line reentrancy-no-eth
        SafeERC20.safeTransferFrom(_asset, caller, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(caller, receiver, assets, shares);
    }

    /**
     * @dev Withdraw/redeem common workflow.
     */
    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal virtual {
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }

        // If _asset is ERC-777, `transfer` can trigger a reentrancy AFTER the transfer happens through the
        // `tokensReceived` hook. On the other hand, the `tokensToSend` hook, that is triggered before the transfer,
        // calls the vault, which is assumed not malicious.
        //
        // Conclusion: we need to do the transfer after the burn so that any reentrancy would happen after the
        // shares are burned and after the assets are transferred, which is a valid state.
        _burn(owner, shares);
        SafeERC20.safeTransfer(_asset, receiver, assets);

        emit Withdraw(caller, receiver, owner, assets, shares);
    }

    function _decimalsOffset() internal view virtual returns (uint8) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

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
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Multicall.sol)

pragma solidity ^0.8.20;

import {Address} from "./Address.sol";
import {Context} from "./Context.sol";

/**
 * @dev Provides a function to batch together multiple calls in a single external call.
 *
 * Consider any assumption about calldata validation performed by the sender may be violated if it's not especially
 * careful about sending transactions invoking {multicall}. For example, a relay address that filters function
 * selectors won't filter calls nested within a {multicall} operation.
 *
 * NOTE: Since 5.0.1 and 4.9.4, this contract identifies non-canonical contexts (i.e. `msg.sender` is not {_msgSender}).
 * If a non-canonical context is identified, the following self `delegatecall` appends the last bytes of `msg.data`
 * to the subcall. This makes it safe to use with {ERC2771Context}. Contexts that don't affect the resolution of
 * {_msgSender} are not propagated to subcalls.
 */
abstract contract Multicall is Context {
    /**
     * @dev Receives and executes a batch of function calls on this contract.
     * @custom:oz-upgrades-unsafe-allow-reachable delegatecall
     */
    function multicall(bytes[] calldata data) external virtual returns (bytes[] memory results) {
        bytes memory context = msg.sender == _msgSender()
            ? new bytes(0)
            : msg.data[msg.data.length - _contextSuffixLength():];

        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), bytes.concat(data[i], context));
        }
        return results;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/**
 * @dev Helper library for emitting standardized panic codes.
 *
 * ```solidity
 * contract Example {
 *      using Panic for uint256;
 *
 *      // Use any of the declared internal constants
 *      function foo() { Panic.GENERIC.panic(); }
 *
 *      // Alternatively
 *      function foo() { Panic.panic(Panic.GENERIC); }
 * }
 * ```
 *
 * Follows the list from https://github.com/ethereum/solidity/blob/v0.8.24/libsolutil/ErrorCodes.h[libsolutil].
 *
 * _Available since v5.1._
 */
// slither-disable-next-line unused-state
library Panic {
    /// @dev generic / unspecified error
    uint256 internal constant GENERIC = 0x00;
    /// @dev used by the assert() builtin
    uint256 internal constant ASSERT = 0x01;
    /// @dev arithmetic underflow or overflow
    uint256 internal constant UNDER_OVERFLOW = 0x11;
    /// @dev division or modulo by zero
    uint256 internal constant DIVISION_BY_ZERO = 0x12;
    /// @dev enum conversion error
    uint256 internal constant ENUM_CONVERSION_ERROR = 0x21;
    /// @dev invalid encoding in storage
    uint256 internal constant STORAGE_ENCODING_ERROR = 0x22;
    /// @dev empty array pop
    uint256 internal constant EMPTY_ARRAY_POP = 0x31;
    /// @dev array out of bounds access
    uint256 internal constant ARRAY_OUT_OF_BOUNDS = 0x32;
    /// @dev resource error (too large allocation or too large array)
    uint256 internal constant RESOURCE_ERROR = 0x41;
    /// @dev calling invalid internal function
    uint256 internal constant INVALID_INTERNAL_FUNCTION = 0x51;

    /// @dev Reverts with a panic code. Recommended to use with
    /// the internal constants with predefined codes.
    function panic(uint256 code) internal pure {
        assembly ("memory-safe") {
            mstore(0x00, 0x4e487b71)
            mstore(0x20, code)
            revert(0x1c, 0x24)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

import {Panic} from "../Panic.sol";
import {SafeCast} from "./SafeCast.sol";

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an success flag (no overflow).
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an success flag (no overflow).
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an success flag (no overflow).
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
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
     * @dev Returns the division of two unsigned integers, with a success flag (no division by zero).
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a success flag (no division by zero).
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Branchless ternary evaluation for `a ? b : c`. Gas costs are constant.
     *
     * IMPORTANT: This function may reduce bytecode size and consume less gas when used standalone.
     * However, the compiler may optimize Solidity ternary operations (i.e. `a ? b : c`) to only compute
     * one branch when needed, making this function more expensive.
     */
    function ternary(bool condition, uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            // branchless ternary works because:
            // b ^ (a ^ b) == a
            // b ^ 0 == b
            return b ^ ((a ^ b) * SafeCast.toUint(condition));
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return ternary(a > b, a, b);
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return ternary(a < b, a, b);
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
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }

        // The following calculation ensures accurate ceiling division without overflow.
        // Since a is non-zero, (a - 1) / b will not overflow.
        // The largest possible result occurs when (a - 1) / b is type(uint256).max,
        // but the largest value we can obtain is type(uint256).max - 1, which happens
        // when a = type(uint256).max and b = 1.
        unchecked {
            return SafeCast.toUint(a > 0) * ((a - 1) / b + 1);
        }
    }

    /**
     * @dev Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     *
     * Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2²⁵⁶ and mod 2²⁵⁶ - 1, then use
            // the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2²⁵⁶ + prod0.
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

            // Make sure the result is less than 2²⁵⁶. Also prevents denominator == 0.
            if (denominator <= prod1) {
                Panic.panic(ternary(denominator == 0, Panic.DIVISION_BY_ZERO, Panic.UNDER_OVERFLOW));
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

                // Flip twos such that it is 2²⁵⁶ / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2²⁵⁶. Now that denominator is an odd number, it has an inverse modulo 2²⁵⁶ such
            // that denominator * inv ≡ 1 mod 2²⁵⁶. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv ≡ 1 mod 2⁴.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2⁸
            inverse *= 2 - denominator * inverse; // inverse mod 2¹⁶
            inverse *= 2 - denominator * inverse; // inverse mod 2³²
            inverse *= 2 - denominator * inverse; // inverse mod 2⁶⁴
            inverse *= 2 - denominator * inverse; // inverse mod 2¹²⁸
            inverse *= 2 - denominator * inverse; // inverse mod 2²⁵⁶

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2²⁵⁶. Since the preconditions guarantee that the outcome is
            // less than 2²⁵⁶, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @dev Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        return mulDiv(x, y, denominator) + SafeCast.toUint(unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0);
    }

    /**
     * @dev Calculate the modular multiplicative inverse of a number in Z/nZ.
     *
     * If n is a prime, then Z/nZ is a field. In that case all elements are inversible, except 0.
     * If n is not a prime, then Z/nZ is not a field, and some elements might not be inversible.
     *
     * If the input value is not inversible, 0 is returned.
     *
     * NOTE: If you know for sure that n is (big) a prime, it may be cheaper to use Fermat's little theorem and get the
     * inverse using `Math.modExp(a, n - 2, n)`. See {invModPrime}.
     */
    function invMod(uint256 a, uint256 n) internal pure returns (uint256) {
        unchecked {
            if (n == 0) return 0;

            // The inverse modulo is calculated using the Extended Euclidean Algorithm (iterative version)
            // Used to compute integers x and y such that: ax + ny = gcd(a, n).
            // When the gcd is 1, then the inverse of a modulo n exists and it's x.
            // ax + ny = 1
            // ax = 1 + (-y)n
            // ax ≡ 1 (mod n) # x is the inverse of a modulo n

            // If the remainder is 0 the gcd is n right away.
            uint256 remainder = a % n;
            uint256 gcd = n;

            // Therefore the initial coefficients are:
            // ax + ny = gcd(a, n) = n
            // 0a + 1n = n
            int256 x = 0;
            int256 y = 1;

            while (remainder != 0) {
                uint256 quotient = gcd / remainder;

                (gcd, remainder) = (
                    // The old remainder is the next gcd to try.
                    remainder,
                    // Compute the next remainder.
                    // Can't overflow given that (a % gcd) * (gcd // (a % gcd)) <= gcd
                    // where gcd is at most n (capped to type(uint256).max)
                    gcd - remainder * quotient
                );

                (x, y) = (
                    // Increment the coefficient of a.
                    y,
                    // Decrement the coefficient of n.
                    // Can overflow, but the result is casted to uint256 so that the
                    // next value of y is "wrapped around" to a value between 0 and n - 1.
                    x - y * int256(quotient)
                );
            }

            if (gcd != 1) return 0; // No inverse exists.
            return ternary(x < 0, n - uint256(-x), uint256(x)); // Wrap the result if it's negative.
        }
    }

    /**
     * @dev Variant of {invMod}. More efficient, but only works if `p` is known to be a prime greater than `2`.
     *
     * From https://en.wikipedia.org/wiki/Fermat%27s_little_theorem[Fermat's little theorem], we know that if p is
     * prime, then `a**(p-1) ≡ 1 mod p`. As a consequence, we have `a * a**(p-2) ≡ 1 mod p`, which means that
     * `a**(p-2)` is the modular multiplicative inverse of a in Fp.
     *
     * NOTE: this function does NOT check that `p` is a prime greater than `2`.
     */
    function invModPrime(uint256 a, uint256 p) internal view returns (uint256) {
        unchecked {
            return Math.modExp(a, p - 2, p);
        }
    }

    /**
     * @dev Returns the modular exponentiation of the specified base, exponent and modulus (b ** e % m)
     *
     * Requirements:
     * - modulus can't be zero
     * - underlying staticcall to precompile must succeed
     *
     * IMPORTANT: The result is only valid if the underlying call succeeds. When using this function, make
     * sure the chain you're using it on supports the precompiled contract for modular exponentiation
     * at address 0x05 as specified in https://eips.ethereum.org/EIPS/eip-198[EIP-198]. Otherwise,
     * the underlying function will succeed given the lack of a revert, but the result may be incorrectly
     * interpreted as 0.
     */
    function modExp(uint256 b, uint256 e, uint256 m) internal view returns (uint256) {
        (bool success, uint256 result) = tryModExp(b, e, m);
        if (!success) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return result;
    }

    /**
     * @dev Returns the modular exponentiation of the specified base, exponent and modulus (b ** e % m).
     * It includes a success flag indicating if the operation succeeded. Operation will be marked as failed if trying
     * to operate modulo 0 or if the underlying precompile reverted.
     *
     * IMPORTANT: The result is only valid if the success flag is true. When using this function, make sure the chain
     * you're using it on supports the precompiled contract for modular exponentiation at address 0x05 as specified in
     * https://eips.ethereum.org/EIPS/eip-198[EIP-198]. Otherwise, the underlying function will succeed given the lack
     * of a revert, but the result may be incorrectly interpreted as 0.
     */
    function tryModExp(uint256 b, uint256 e, uint256 m) internal view returns (bool success, uint256 result) {
        if (m == 0) return (false, 0);
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            // | Offset    | Content    | Content (Hex)                                                      |
            // |-----------|------------|--------------------------------------------------------------------|
            // | 0x00:0x1f | size of b  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x20:0x3f | size of e  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x40:0x5f | size of m  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x60:0x7f | value of b | 0x<.............................................................b> |
            // | 0x80:0x9f | value of e | 0x<.............................................................e> |
            // | 0xa0:0xbf | value of m | 0x<.............................................................m> |
            mstore(ptr, 0x20)
            mstore(add(ptr, 0x20), 0x20)
            mstore(add(ptr, 0x40), 0x20)
            mstore(add(ptr, 0x60), b)
            mstore(add(ptr, 0x80), e)
            mstore(add(ptr, 0xa0), m)

            // Given the result < m, it's guaranteed to fit in 32 bytes,
            // so we can use the memory scratch space located at offset 0.
            success := staticcall(gas(), 0x05, ptr, 0xc0, 0x00, 0x20)
            result := mload(0x00)
        }
    }

    /**
     * @dev Variant of {modExp} that supports inputs of arbitrary length.
     */
    function modExp(bytes memory b, bytes memory e, bytes memory m) internal view returns (bytes memory) {
        (bool success, bytes memory result) = tryModExp(b, e, m);
        if (!success) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return result;
    }

    /**
     * @dev Variant of {tryModExp} that supports inputs of arbitrary length.
     */
    function tryModExp(
        bytes memory b,
        bytes memory e,
        bytes memory m
    ) internal view returns (bool success, bytes memory result) {
        if (_zeroBytes(m)) return (false, new bytes(0));

        uint256 mLen = m.length;

        // Encode call args in result and move the free memory pointer
        result = abi.encodePacked(b.length, e.length, mLen, b, e, m);

        assembly ("memory-safe") {
            let dataPtr := add(result, 0x20)
            // Write result on top of args to avoid allocating extra memory.
            success := staticcall(gas(), 0x05, dataPtr, mload(result), dataPtr, mLen)
            // Overwrite the length.
            // result.length > returndatasize() is guaranteed because returndatasize() == m.length
            mstore(result, mLen)
            // Set the memory pointer after the returned data.
            mstore(0x40, add(dataPtr, mLen))
        }
    }

    /**
     * @dev Returns whether the provided byte array is zero.
     */
    function _zeroBytes(bytes memory byteArray) private pure returns (bool) {
        for (uint256 i = 0; i < byteArray.length; ++i) {
            if (byteArray[i] != 0) {
                return false;
            }
        }
        return true;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * This method is based on Newton's method for computing square roots; the algorithm is restricted to only
     * using integer operations.
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        unchecked {
            // Take care of easy edge cases when a == 0 or a == 1
            if (a <= 1) {
                return a;
            }

            // In this function, we use Newton's method to get a root of `f(x) := x² - a`. It involves building a
            // sequence x_n that converges toward sqrt(a). For each iteration x_n, we also define the error between
            // the current value as `ε_n = | x_n - sqrt(a) |`.
            //
            // For our first estimation, we consider `e` the smallest power of 2 which is bigger than the square root
            // of the target. (i.e. `2**(e-1) ≤ sqrt(a) < 2**e`). We know that `e ≤ 128` because `(2¹²⁸)² = 2²⁵⁶` is
            // bigger than any uint256.
            //
            // By noticing that
            // `2**(e-1) ≤ sqrt(a) < 2**e → (2**(e-1))² ≤ a < (2**e)² → 2**(2*e-2) ≤ a < 2**(2*e)`
            // we can deduce that `e - 1` is `log2(a) / 2`. We can thus compute `x_n = 2**(e-1)` using a method similar
            // to the msb function.
            uint256 aa = a;
            uint256 xn = 1;

            if (aa >= (1 << 128)) {
                aa >>= 128;
                xn <<= 64;
            }
            if (aa >= (1 << 64)) {
                aa >>= 64;
                xn <<= 32;
            }
            if (aa >= (1 << 32)) {
                aa >>= 32;
                xn <<= 16;
            }
            if (aa >= (1 << 16)) {
                aa >>= 16;
                xn <<= 8;
            }
            if (aa >= (1 << 8)) {
                aa >>= 8;
                xn <<= 4;
            }
            if (aa >= (1 << 4)) {
                aa >>= 4;
                xn <<= 2;
            }
            if (aa >= (1 << 2)) {
                xn <<= 1;
            }

            // We now have x_n such that `x_n = 2**(e-1) ≤ sqrt(a) < 2**e = 2 * x_n`. This implies ε_n ≤ 2**(e-1).
            //
            // We can refine our estimation by noticing that the middle of that interval minimizes the error.
            // If we move x_n to equal 2**(e-1) + 2**(e-2), then we reduce the error to ε_n ≤ 2**(e-2).
            // This is going to be our x_0 (and ε_0)
            xn = (3 * xn) >> 1; // ε_0 := | x_0 - sqrt(a) | ≤ 2**(e-2)

            // From here, Newton's method give us:
            // x_{n+1} = (x_n + a / x_n) / 2
            //
            // One should note that:
            // x_{n+1}² - a = ((x_n + a / x_n) / 2)² - a
            //              = ((x_n² + a) / (2 * x_n))² - a
            //              = (x_n⁴ + 2 * a * x_n² + a²) / (4 * x_n²) - a
            //              = (x_n⁴ + 2 * a * x_n² + a² - 4 * a * x_n²) / (4 * x_n²)
            //              = (x_n⁴ - 2 * a * x_n² + a²) / (4 * x_n²)
            //              = (x_n² - a)² / (2 * x_n)²
            //              = ((x_n² - a) / (2 * x_n))²
            //              ≥ 0
            // Which proves that for all n ≥ 1, sqrt(a) ≤ x_n
            //
            // This gives us the proof of quadratic convergence of the sequence:
            // ε_{n+1} = | x_{n+1} - sqrt(a) |
            //         = | (x_n + a / x_n) / 2 - sqrt(a) |
            //         = | (x_n² + a - 2*x_n*sqrt(a)) / (2 * x_n) |
            //         = | (x_n - sqrt(a))² / (2 * x_n) |
            //         = | ε_n² / (2 * x_n) |
            //         = ε_n² / | (2 * x_n) |
            //
            // For the first iteration, we have a special case where x_0 is known:
            // ε_1 = ε_0² / | (2 * x_0) |
            //     ≤ (2**(e-2))² / (2 * (2**(e-1) + 2**(e-2)))
            //     ≤ 2**(2*e-4) / (3 * 2**(e-1))
            //     ≤ 2**(e-3) / 3
            //     ≤ 2**(e-3-log2(3))
            //     ≤ 2**(e-4.5)
            //
            // For the following iterations, we use the fact that, 2**(e-1) ≤ sqrt(a) ≤ x_n:
            // ε_{n+1} = ε_n² / | (2 * x_n) |
            //         ≤ (2**(e-k))² / (2 * 2**(e-1))
            //         ≤ 2**(2*e-2*k) / 2**e
            //         ≤ 2**(e-2*k)
            xn = (xn + a / xn) >> 1; // ε_1 := | x_1 - sqrt(a) | ≤ 2**(e-4.5)  -- special case, see above
            xn = (xn + a / xn) >> 1; // ε_2 := | x_2 - sqrt(a) | ≤ 2**(e-9)    -- general case with k = 4.5
            xn = (xn + a / xn) >> 1; // ε_3 := | x_3 - sqrt(a) | ≤ 2**(e-18)   -- general case with k = 9
            xn = (xn + a / xn) >> 1; // ε_4 := | x_4 - sqrt(a) | ≤ 2**(e-36)   -- general case with k = 18
            xn = (xn + a / xn) >> 1; // ε_5 := | x_5 - sqrt(a) | ≤ 2**(e-72)   -- general case with k = 36
            xn = (xn + a / xn) >> 1; // ε_6 := | x_6 - sqrt(a) | ≤ 2**(e-144)  -- general case with k = 72

            // Because e ≤ 128 (as discussed during the first estimation phase), we know have reached a precision
            // ε_6 ≤ 2**(e-144) < 1. Given we're operating on integers, then we can ensure that xn is now either
            // sqrt(a) or sqrt(a) + 1.
            return xn - SafeCast.toUint(xn > a / xn);
        }
    }

    /**
     * @dev Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && result * result < a);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        uint256 exp;
        unchecked {
            exp = 128 * SafeCast.toUint(value > (1 << 128) - 1);
            value >>= exp;
            result += exp;

            exp = 64 * SafeCast.toUint(value > (1 << 64) - 1);
            value >>= exp;
            result += exp;

            exp = 32 * SafeCast.toUint(value > (1 << 32) - 1);
            value >>= exp;
            result += exp;

            exp = 16 * SafeCast.toUint(value > (1 << 16) - 1);
            value >>= exp;
            result += exp;

            exp = 8 * SafeCast.toUint(value > (1 << 8) - 1);
            value >>= exp;
            result += exp;

            exp = 4 * SafeCast.toUint(value > (1 << 4) - 1);
            value >>= exp;
            result += exp;

            exp = 2 * SafeCast.toUint(value > (1 << 2) - 1);
            value >>= exp;
            result += exp;

            result += SafeCast.toUint(value > 1);
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
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 1 << result < value);
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
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 10 ** result < value);
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
        uint256 isGt;
        unchecked {
            isGt = SafeCast.toUint(value > (1 << 128) - 1);
            value >>= isGt * 128;
            result += isGt * 16;

            isGt = SafeCast.toUint(value > (1 << 64) - 1);
            value >>= isGt * 64;
            result += isGt * 8;

            isGt = SafeCast.toUint(value > (1 << 32) - 1);
            value >>= isGt * 32;
            result += isGt * 4;

            isGt = SafeCast.toUint(value > (1 << 16) - 1);
            value >>= isGt * 16;
            result += isGt * 2;

            result += SafeCast.toUint(value > (1 << 8) - 1);
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
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 1 << (result << 3) < value);
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SafeCast.sol)
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
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

library Constants {
    // WAD: Common unit, stands for "18 decimals"
    uint256 public constant WAD = 1e18;

    // RAY: Higher precision unit, "27 decimals"
    uint256 public constant RAY = 1e27;

    // Conversion factor from WAD to RAY
    uint256 public constant WAD_TO_RAY = 1e9;

    // Number of seconds in a day
    uint256 public constant SECONDS_PER_DAY = 1 days;

    // Number of seconds in a year (assuming 365 days)
    uint256 public constant SECONDS_PER_YEAR = 365 days;

    // Maximum value for uint256
    uint256 public constant MAX_UINT256 = type(uint256).max;

    // AAVE V3 POOL CONFIG DATA MASK

    uint256 internal constant ACTIVE_MASK =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF;
    uint256 internal constant FROZEN_MASK =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF;
    uint256 internal constant PAUSED_MASK =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFF;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {StorageSlot} from "./StorageSlot.sol";

/**
 * @dev Variant of {ReentrancyGuard} that uses transient storage.
 *
 * NOTE: This variant only works on networks where EIP-1153 is available.
 */
abstract contract ReentrancyGuardTransient {
    using StorageSlot for *;

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant REENTRANCY_GUARD_STORAGE =
        0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

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
        if (_reentrancyGuardEntered()) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        REENTRANCY_GUARD_STORAGE.asBoolean().tstore(true);
    }

    function _nonReentrantAfter() private {
        REENTRANCY_GUARD_STORAGE.asBoolean().tstore(false);
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return REENTRANCY_GUARD_STORAGE.asBoolean().tload();
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.24;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC-1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     // Define the slot. Alternatively, use the SlotDerivation library to derive the slot.
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
 *
 * Since version 5.1, this library also support writing and reading value types to and from transient storage.
 *
 *  * Example using transient storage:
 * ```solidity
 * contract Lock {
 *     // Define the slot. Alternatively, use the SlotDerivation library to derive the slot.
 *     bytes32 internal constant _LOCK_SLOT = 0xf4678858b2b588224636b8522b729e7722d32fc491da849ed75b3fdf3c84f542;
 *
 *     modifier locked() {
 *         require(!_LOCK_SLOT.asBoolean().tload());
 *
 *         _LOCK_SLOT.asBoolean().tstore(true);
 *         _;
 *         _LOCK_SLOT.asBoolean().tstore(false);
 *     }
 * }
 * ```
 *
 * TIP: Consider using this library along with {SlotDerivation}.
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

    struct Int256Slot {
        int256 value;
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
    function getAddressSlot(
        bytes32 slot
    ) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(
        bytes32 slot
    ) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(
        bytes32 slot
    ) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(
        bytes32 slot
    ) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Int256Slot` with member `value` located at `slot`.
     */
    function getInt256Slot(
        bytes32 slot
    ) internal pure returns (Int256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(
        bytes32 slot
    ) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(
        string storage store
    ) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(
        bytes32 slot
    ) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(
        bytes storage store
    ) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev UDVT that represent a slot holding a address.
     */
    type AddressSlotType is bytes32;

    /**
     * @dev Cast an arbitrary slot to a AddressSlotType.
     */
    function asAddress(bytes32 slot) internal pure returns (AddressSlotType) {
        return AddressSlotType.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a bool.
     */
    type BooleanSlotType is bytes32;

    /**
     * @dev Cast an arbitrary slot to a BooleanSlotType.
     */
    function asBoolean(bytes32 slot) internal pure returns (BooleanSlotType) {
        return BooleanSlotType.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a bytes32.
     */
    type Bytes32SlotType is bytes32;

    /**
     * @dev Cast an arbitrary slot to a Bytes32SlotType.
     */
    function asBytes32(bytes32 slot) internal pure returns (Bytes32SlotType) {
        return Bytes32SlotType.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a uint256.
     */
    type Uint256SlotType is bytes32;

    /**
     * @dev Cast an arbitrary slot to a Uint256SlotType.
     */
    function asUint256(bytes32 slot) internal pure returns (Uint256SlotType) {
        return Uint256SlotType.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a int256.
     */
    type Int256SlotType is bytes32;

    /**
     * @dev Cast an arbitrary slot to a Int256SlotType.
     */
    function asInt256(bytes32 slot) internal pure returns (Int256SlotType) {
        return Int256SlotType.wrap(slot);
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(AddressSlotType slot) internal view returns (address value) {
        /// @solidity memory-safe-assembly
        assembly {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(AddressSlotType slot, address value) internal {
        /// @solidity memory-safe-assembly
        assembly {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(BooleanSlotType slot) internal view returns (bool value) {
        /// @solidity memory-safe-assembly
        assembly {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(BooleanSlotType slot, bool value) internal {
        /// @solidity memory-safe-assembly
        assembly {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(Bytes32SlotType slot) internal view returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(Bytes32SlotType slot, bytes32 value) internal {
        /// @solidity memory-safe-assembly
        assembly {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(Uint256SlotType slot) internal view returns (uint256 value) {
        /// @solidity memory-safe-assembly
        assembly {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(Uint256SlotType slot, uint256 value) internal {
        /// @solidity memory-safe-assembly
        assembly {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(Int256SlotType slot) internal view returns (int256 value) {
        /// @solidity memory-safe-assembly
        assembly {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(Int256SlotType slot, int256 value) internal {
        /// @solidity memory-safe-assembly
        assembly {
            tstore(slot, value)
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IGovernanceRewardsManagerErrors
 * @notice Interface defining custom errors for the Governance Rewards Manager
 */
interface IGovernanceRewardsManagerErrors {
    /**
     * @notice Thrown when the caller is not the staking token
     * @dev Used to restrict certain functions to only be callable by the staking token contract
     */
    error InvalidCaller();

    /**
     * @notice Thrown when the stakeOnBehalfOf function is called (operation not supported)
     */
    error StakeOnBehalfOfNotSupported();

    /**
     * @notice Thrown when the UnstakeOnBehalfOfNotSupported function is called (operation not supported)
     */
    error UnstakeOnBehalfOfNotSupported();

    /**
     * @notice Thrown when the caller is not delegated
     */
    error NotDelegated();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IGovernanceRewardsManagerErrors} from "../errors/IGovernanceRewardsManagerErrors.sol";
import {IStakingRewardsManagerBase} from "@summerfi/rewards-contracts/interfaces/IStakingRewardsManagerBase.sol";

/**
 * @title IGovernanceRewardsManager
 * @notice Interface for the GovernanceRewardsManager contract
 * @dev Manages staking and distribution of multiple reward tokens
 */
interface IGovernanceRewardsManager is
    IStakingRewardsManagerBase,
    IGovernanceRewardsManagerErrors
{
    /**
     * @notice Returns the wrapped staking token
     * @return The wrapped staking token
     */
    function wrappedStakingToken() external view returns (address);

    /**
     * @notice Emitted when unstakeAndWithdrawOnBehalfOf is called (operation not supported)
     * @param owner The address that owns the staked tokens
     * @param receiver The address that would have received the unstaked tokens
     * @param amount The amount of tokens that was attempted to be unstaked
     */
    event UnstakeOnBehalfOfIgnored(
        address indexed owner,
        address indexed receiver,
        uint256 amount
    );

    /**
     * @notice Returns the balance of staked tokens for an account
     * @param account The address of the staker
     * @return The amount of tokens staked by the account
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @notice Updates the smoothed decay factor for an account
     * @param account The address to update the smoothed decay factor for
     */
    function updateSmoothedDecayFactor(address account) external;

    /**
     * @notice Calculates the smoothed decay factor for a given account without modifying state
     * @param account The address of the account to calculate for
     * @return The calculated smoothed decay factor
     */
    function calculateSmoothedDecayFactor(
        address account
    ) external view returns (uint256);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title Percentage
 * @author Roberto Cano
 * @notice Custom type for Percentage values with associated utility functions
 * @dev This contract defines a custom Percentage type and overloaded operators
 *      to perform arithmetic and comparison operations on Percentage values.
 */

/**
 * @dev Custom percentage type as uint256
 * @notice This type is used to represent percentage values with high precision
 */
type Percentage is uint256;

/**
 * @dev Overridden operators declaration for Percentage
 * @notice These operators allow for intuitive arithmetic and comparison operations
 *         on Percentage values
 */
using {
    add as +,
    subtract as -,
    multiply as *,
    divide as /,
    lessOrEqualThan as <=,
    lessThan as <,
    greaterOrEqualThan as >=,
    greaterThan as >,
    equalTo as ==
} for Percentage global;

/**
 * @dev The number of decimals used for the percentage
 *  This constant defines the precision of the Percentage type
 */
uint256 constant PERCENTAGE_DECIMALS = 18;

/**
 * @dev The factor used to scale the percentage
 *  This constant is used to convert between human-readable percentages
 *         and the internal representation
 */
uint256 constant PERCENTAGE_FACTOR = 10 ** PERCENTAGE_DECIMALS;

/**
 * @dev Percentage of 100% with the given `PERCENTAGE_DECIMALS`
 *  This constant represents 100% in the Percentage type
 */
Percentage constant PERCENTAGE_100 = Percentage.wrap(100 * PERCENTAGE_FACTOR);

/**
 * OPERATOR FUNCTIONS
 */

/**
 * @dev Adds two Percentage values
 * @param a The first Percentage value
 * @param b The second Percentage value
 * @return The sum of a and b as a Percentage
 */
function add(Percentage a, Percentage b) pure returns (Percentage) {
    return Percentage.wrap(Percentage.unwrap(a) + Percentage.unwrap(b));
}

/**
 * @dev Subtracts one Percentage value from another
 * @param a The Percentage value to subtract from
 * @param b The Percentage value to subtract
 * @return The difference between a and b as a Percentage
 */
function subtract(Percentage a, Percentage b) pure returns (Percentage) {
    return Percentage.wrap(Percentage.unwrap(a) - Percentage.unwrap(b));
}

/**
 * @dev Multiplies two Percentage values
 * @param a The first Percentage value
 * @param b The second Percentage value
 * @return The product of a and b as a Percentage, scaled appropriately
 */
function multiply(Percentage a, Percentage b) pure returns (Percentage) {
    return
        Percentage.wrap(
            (Percentage.unwrap(a) * Percentage.unwrap(b)) /
                Percentage.unwrap(PERCENTAGE_100)
        );
}

/**
 * @dev Divides one Percentage value by another
 * @param a The Percentage value to divide
 * @param b The Percentage value to divide by
 * @return The quotient of a divided by b as a Percentage, scaled appropriately
 */
function divide(Percentage a, Percentage b) pure returns (Percentage) {
    return
        Percentage.wrap(
            (Percentage.unwrap(a) * Percentage.unwrap(PERCENTAGE_100)) /
                Percentage.unwrap(b)
        );
}

/**
 * @dev Checks if one Percentage value is less than or equal to another
 * @param a The first Percentage value
 * @param b The second Percentage value
 * @return True if a is less than or equal to b, false otherwise
 */
function lessOrEqualThan(Percentage a, Percentage b) pure returns (bool) {
    return Percentage.unwrap(a) <= Percentage.unwrap(b);
}

/**
 * @dev Checks if one Percentage value is less than another
 * @param a The first Percentage value
 * @param b The second Percentage value
 * @return True if a is less than b, false otherwise
 */
function lessThan(Percentage a, Percentage b) pure returns (bool) {
    return Percentage.unwrap(a) < Percentage.unwrap(b);
}

/**
 * @dev Checks if one Percentage value is greater than or equal to another
 * @param a The first Percentage value
 * @param b The second Percentage value
 * @return True if a is greater than or equal to b, false otherwise
 */
function greaterOrEqualThan(Percentage a, Percentage b) pure returns (bool) {
    return Percentage.unwrap(a) >= Percentage.unwrap(b);
}

/**
 * @dev Checks if one Percentage value is greater than another
 * @param a The first Percentage value
 * @param b The second Percentage value
 * @return True if a is greater than b, false otherwise
 */
function greaterThan(Percentage a, Percentage b) pure returns (bool) {
    return Percentage.unwrap(a) > Percentage.unwrap(b);
}

/**
 * @dev Checks if two Percentage values are equal
 * @param a The first Percentage value
 * @param b The second Percentage value
 * @return True if a is equal to b, false otherwise
 */
function equalTo(Percentage a, Percentage b) pure returns (bool) {
    return Percentage.unwrap(a) == Percentage.unwrap(b);
}

/**
 * @dev Alias for equalTo function
 * @param a The first Percentage value
 * @param b The second Percentage value
 * @return True if a is equal to b, false otherwise
 */
function equals(Percentage a, Percentage b) pure returns (bool) {
    return Percentage.unwrap(a) == Percentage.unwrap(b);
}

/**
 * @dev Converts a uint256 value to a Percentage
 * @param value The uint256 value to convert
 * @return The input value as a Percentage
 */
function toPercentage(uint256 value) pure returns (Percentage) {
    return Percentage.wrap(value * PERCENTAGE_FACTOR);
}

/**
 * @dev Converts a Percentage value to a uint256
 * @param value The Percentage value to convert
 * @return The Percentage value as a uint256
 */
function fromPercentage(Percentage value) pure returns (uint256) {
    return Percentage.unwrap(value) / PERCENTAGE_FACTOR;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IStakingRewardsManagerBaseErrors} from "./IStakingRewardsManagerBaseErrors.sol";

/* @title IStakingRewardsManagerBase
 * @notice Interface for the Staking Rewards Manager contract
 * @dev Manages staking and distribution of multiple reward tokens
 */
interface IStakingRewardsManagerBase is IStakingRewardsManagerBaseErrors {
    // Views

    /* @notice Get the total amount of staked tokens
     * @return The total supply of staked tokens
     */
    function totalSupply() external view returns (uint256);

    /* @notice Get the staked balance of a specific account
     * @param account The address of the account to check
     * @return The staked balance of the account
     */
    function balanceOf(address account) external view returns (uint256);

    /* @notice Get the last time the reward was applicable for a specific reward token
     * @param rewardToken The address of the reward token
     * @return The timestamp of the last applicable reward time
     */
    function lastTimeRewardApplicable(
        address rewardToken
    ) external view returns (uint256);

    /* @notice Get the reward per token for a specific reward token
     * @param rewardToken The address of the reward token
     * @return The reward amount per staked token (WAD-scaled)
     * @dev Returns a WAD-scaled value (1e18) to maintain precision in calculations
     * @dev This value represents: (rewardRate * timeElapsed * WAD) / totalSupply
     */
    function rewardPerToken(
        address rewardToken
    ) external view returns (uint256);

    /* @notice Calculate the earned reward for an account and a specific reward token
     * @param account The address of the account
     * @param rewardToken The address of the reward token
     * @return The amount of reward tokens earned (not WAD-scaled)
     * @dev Calculated as: (balance * (rewardPerToken - userRewardPerTokenPaid)) / WAD + rewards
     */
    function earned(
        address account,
        address rewardToken
    ) external view returns (uint256);

    /* @notice Get the reward for the entire duration for a specific reward token
     * @param rewardToken The address of the reward token
     * @return The total reward amount for the duration (not WAD-scaled)
     * @dev Calculated as: (rewardRate * rewardsDuration) / WAD
     */
    function getRewardForDuration(
        address rewardToken
    ) external view returns (uint256);

    /* @notice Get the address of the staking token
     * @return The address of the staking token
     */
    function stakingToken() external view returns (address);

    /* @notice Get the reward token at a specific index
     * @param index The index of the reward token
     * @return The address of the reward token
     * @dev Reverts with IndexOutOfBounds if index >= rewardTokensLength()
     */
    function rewardTokens(uint256 index) external view returns (address);

    /* @notice Get the total number of reward tokens
     * @return The length of the reward tokens list
     */
    function rewardTokensLength() external view returns (uint256);

    /* @notice Check if a token is in the list of reward tokens
     * @param rewardToken The address to check
     * @return bool True if the token is a reward token, false otherwise
     */
    function isRewardToken(address rewardToken) external view returns (bool);

    // Mutative functions

    /* @notice Stake tokens for an account
     * @param amount The amount of tokens to stake
     */
    function stake(uint256 amount) external;

    /* @notice Stake tokens for an account on behalf of another account
     * @param receiver The address of the account to stake for
     * @param amount The amount of tokens to stake
     */
    function stakeOnBehalfOf(address receiver, uint256 amount) external;

    /* @notice Unstake staked tokens on behalf of another account
     * @param owner The address of the account to unstake from
     * @param amount The amount of tokens to unstake
     * @param claimRewards Whether to claim rewards before unstaking
     */
    function unstakeAndWithdrawOnBehalfOf(
        address owner,
        uint256 amount,
        bool claimRewards
    ) external;

    /* @notice Unstake staked tokens
     * @param amount The amount of tokens to unstake
     */
    function unstake(uint256 amount) external;

    /* @notice Claim accumulated rewards for all reward tokens */
    function getReward() external;

    /* @notice Claim accumulated rewards for a specific reward token
     * @param rewardToken The address of the reward token to claim
     */
    function getReward(address rewardToken) external;

    /* @notice Withdraw all staked tokens and claim rewards */
    function exit() external;

    // Admin functions

    /* @notice Notify the contract about new reward amount
     * @param rewardToken The address of the reward token
     * @param reward The amount of new reward (not WAD-scaled)
     * @param newRewardsDuration The duration for rewards distribution (only used when adding a new reward token)
     * @dev Internally sets rewardRate as (reward * WAD) / duration to maintain precision
     */
    function notifyRewardAmount(
        address rewardToken,
        uint256 reward,
        uint256 newRewardsDuration
    ) external;

    /* @notice Set the duration for rewards distribution
     * @param rewardToken The address of the reward token
     * @param _rewardsDuration The new duration for rewards
     */
    function setRewardsDuration(
        address rewardToken,
        uint256 _rewardsDuration
    ) external;

    /* @notice Removes a reward token from the list of reward tokens
     * @dev Can only be called by governor
     * @dev Can only be called after reward period is complete
     * @dev Can only be called if remaining balance is below dust threshold
     * @param rewardToken The address of the reward token to remove
     */
    function removeRewardToken(address rewardToken) external;

    // Events

    /* @notice Emitted when a new reward is added
     * @param rewardToken The address of the reward token
     * @param reward The amount of reward added
     */
    event RewardAdded(address indexed rewardToken, uint256 reward);

    /* @notice Emitted when tokens are staked
     * @param staker The address that provided the tokens for staking
     * @param receiver The address whose staking balance was updated
     * @param amount The amount of tokens added to the staking position
     */
    event Staked(
        address indexed staker,
        address indexed receiver,
        uint256 amount
    );

    /* @notice Emitted when tokens are unstaked
     * @param staker The address whose tokens were unstaked
     * @param receiver The address receiving the unstaked tokens
     * @param amount The amount of tokens unstaked
     */
    event Unstaked(
        address indexed staker,
        address indexed receiver,
        uint256 amount
    );

    /* @notice Emitted when tokens are withdrawn
     * @param user The address of the user that withdrew
     * @param amount The amount of tokens withdrawn
     */
    event Withdrawn(address indexed user, uint256 amount);

    /* @notice Emitted when rewards are paid out
     * @param user The address of the user receiving the reward
     * @param rewardToken The address of the reward token
     * @param reward The amount of reward paid
     */
    event RewardPaid(
        address indexed user,
        address indexed rewardToken,
        uint256 reward
    );

    /* @notice Emitted when the rewards duration is updated
     * @param rewardToken The address of the reward token
     * @param newDuration The new duration for rewards
     */
    event RewardsDurationUpdated(
        address indexed rewardToken,
        uint256 newDuration
    );

    /* @notice Emitted when a new reward token is added
     * @param rewardToken The address of the new reward token
     * @param rewardsDuration The duration for the new reward token
     */
    event RewardTokenAdded(address rewardToken, uint256 rewardsDuration);

    /* @notice Emitted when a reward token is removed
     * @param rewardToken The address of the reward token
     */
    event RewardTokenRemoved(address rewardToken);

    /* @notice Claims rewards for a specific account
     * @param account The address to claim rewards for
     */
    function getRewardFor(address account) external;

    /* @notice Claims rewards for a specific account and specific reward token
     * @param account The address to claim rewards for
     * @param rewardToken The address of the reward token to claim
     */
    function getRewardFor(address account, address rewardToken) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/* @title IStakingRewardsManagerBaseErrors
 * @notice Interface defining custom errors for the Staking Rewards Manager
 */
interface IStakingRewardsManagerBaseErrors {
    /* @notice Thrown when attempting to stake zero tokens */
    error CannotStakeZero();

    /* @notice Thrown when attempting to withdraw zero tokens */
    error CannotWithdrawZero();

    /* @notice Thrown when the provided reward amount is too high */
    error ProvidedRewardTooHigh();

    /* @notice Thrown when trying to set rewards before the current period is complete */
    error RewardPeriodNotComplete();

    /* @notice Thrown when there are no reward tokens set */
    error NoRewardTokens();

    /* @notice Thrown when trying to add a reward token that already exists */
    error RewardTokenAlreadyExists();

    /* @notice Thrown when setting an invalid rewards duration */
    error InvalidRewardsDuration();

    /* @notice Thrown when trying to interact with a reward token that hasn't been initialized */
    error RewardTokenNotInitialized();

    /* @notice Thrown when the reward amount is invalid for the given duration
     * @param rewardToken The address of the reward token
     * @param rewardsDuration The duration for which the reward is invalid
     */
    error InvalidRewardAmount(address rewardToken, uint256 rewardsDuration);

    /* @notice Thrown when trying to interact with the staking token before it's initialized */
    error StakingTokenNotInitialized();

    /* @notice Thrown when trying to remove a reward token that doesn't exist */
    error RewardTokenDoesNotExist();

    /* @notice Thrown when trying to change the rewards duration of a reward token */
    error CannotChangeRewardsDuration();

    /* @notice Thrown when a reward token still has a balance */
    error RewardTokenStillHasBalance(uint256 balance);

    /* @notice Thrown when the index is out of bounds */
    error IndexOutOfBounds();

    /* @notice Thrown when the rewards duration is zero */
    error RewardsDurationCannotBeZero();

    /* @notice Thrown when attempting to unstake zero tokens */
    error CannotUnstakeZero();

    /* @notice Thrown when the rewards duration is too long */
    error RewardsDurationTooLong();

    /**
     * @notice Thrown when the receiver is the zero address
     */
    error CannotStakeToZeroAddress();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title ISummerRewardsRedeemer
 * @author Summer.fi
 * @notice Interface for managing and distributing token rewards using Merkle proofs
 * @dev This contract enables efficient distribution of rewards to multiple users
 *      using Merkle trees. Each distribution is identified by an index and has its
 *      own Merkle root. Users can claim their rewards by providing proofs of inclusion.
 */
interface ISummerRewardsRedeemer {
    /// EVENTS
    event Claimed(address indexed user, uint256 indexed index, uint256 amount);
    event RootAdded(uint256 indexed index, bytes32 root);
    event RootRemoved(uint256 indexed index);

    /// ERRORS
    error InvalidRewardsToken(address token);
    error RootAlreadyAdded(uint256 index, bytes32 root);
    error UserCannotClaim(
        address user,
        uint256 index,
        uint256 amount,
        bytes32[] proof
    );
    error UserAlreadyClaimed(
        address user,
        uint256 index,
        uint256 amount,
        bytes32[] proof
    );
    error ClaimMultipleLengthMismatch(
        uint256[] indices,
        uint256[] amounts,
        bytes32[][] proofs
    );
    error ClaimMultipleEmpty(
        uint256[] indices,
        uint256[] amounts,
        bytes32[][] proofs
    );
    error CallerNotAdmiralsQuarters();

    /**
     * @notice Adds a new Merkle root for a distribution
     * @param index Unique identifier for the distribution
     * @param root Merkle root hash of the distribution
     */
    function addRoot(uint256 index, bytes32 root) external;

    /**
     * @notice Removes a Merkle root
     * @param index Distribution index to remove
     */
    function removeRoot(uint256 index) external;

    /**
     * @notice Gets the Merkle root for a distribution
     * @param index Distribution index to query
     * @return bytes32 The Merkle root hash
     */
    function getRoot(uint256 index) external view returns (bytes32);

    /**
     * @notice Checks if a user can claim from a distribution
     * @param user Address of the user to check
     * @param index Distribution index to check
     * @param amount Amount attempting to claim
     * @param proof Merkle proof to verify
     * @return bool True if claim is possible, false otherwise
     */
    function canClaim(
        address user,
        uint256 index,
        uint256 amount,
        bytes32[] memory proof
    ) external view returns (bool);

    /**
     * @notice Claims rewards for a single distribution
     * @param user Address of the user to claim for
     * @param index Distribution index to claim from
     * @param amount Amount of tokens to claim
     * @param proof Merkle proof verifying the claim
     */
    function claim(
        address user,
        uint256 index,
        uint256 amount,
        bytes32[] calldata proof
    ) external;

    /**
     * @notice Claims rewards from multiple distributions at once
     * @param user Address of the user to claim for
     * @param indices Array of distribution indices to claim from
     * @param amounts Array of amounts to claim from each distribution
     * @param proofs Array of Merkle proofs for each claim
     */
    function claimMultiple(
        address user,
        uint256[] calldata indices,
        uint256[] calldata amounts,
        bytes32[][] calldata proofs
    ) external;

    /**
     * @notice Claims rewards for multiple distributions at once
     * @param indices Array of distribution indices to claim from
     * @param amounts Array of amounts to claim from each distribution
     * @param proofs Array of Merkle proofs for each claim
     */
    function claimMultiple(
        uint256[] calldata indices,
        uint256[] calldata amounts,
        bytes32[][] calldata proofs
    ) external;

    /**
     * @notice Emergency withdrawal of tokens
     * @param token Address of token to withdraw
     * @param to Address to send tokens to
     * @param amount Amount of tokens to withdraw
     */
    function emergencyWithdraw(
        address token,
        address to,
        uint256 amount
    ) external;

    /**
     * @notice Checks if a user has already claimed from a distribution
     * @param user Address to check
     * @param index Distribution index to check
     * @return bool True if already claimed, false otherwise
     */
    function hasClaimed(
        address user,
        uint256 index
    ) external view returns (bool);

    /**
     * @notice Gets the timestamp when the contract was deployed
     * @return uint256 The deployment timestamp
     */
    function deployedAt() external view returns (uint256);

    /**
     * @notice Gets the token being distributed as rewards
     * @return IERC20 The rewards token
     */
    function rewardsToken() external view returns (IERC20);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {ReentrancyGuardTransient} from "@summerfi/dependencies/openzeppelin-next/ReentrancyGuardTransient.sol";

import {IAdmiralsQuarters} from "../interfaces/IAdmiralsQuarters.sol";
import {IFleetCommander} from "../interfaces/IFleetCommander.sol";

import {IFleetCommanderRewardsManager} from "../interfaces/IFleetCommanderRewardsManager.sol";
import {IHarborCommand} from "../interfaces/IHarborCommand.sol";

import {IAToken} from "../interfaces/aave-v3/IAtoken.sol";
import {IPoolV3} from "../interfaces/aave-v3/IPoolV3.sol";
import {IComet} from "../interfaces/compound-v3/IComet.sol";
import {IWETH} from "../interfaces/misc/IWETH.sol";
import {ConfigurationManaged} from "./ConfigurationManaged.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Constants} from "@summerfi/constants/Constants.sol";

import {ProtectedMulticall} from "./ProtectedMulticall.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IStakingRewardsManagerBase} from "@summerfi/rewards-contracts/interfaces/IStakingRewardsManagerBase.sol";
import {ISummerRewardsRedeemer} from "@summerfi/rewards-contracts/interfaces/ISummerRewardsRedeemer.sol";
import {IGovernanceRewardsManager} from "@summerfi/earn-gov-contracts/interfaces/IGovernanceRewardsManager.sol";

/**
 * @title AdmiralsQuarters
 * @dev A contract for managing deposits and withdrawals to/from FleetCommander contracts,
 *      with integrated swapping functionality using 1inch Router.
 * @notice This contract uses an OpenZeppelin nonReentrant modifier with transient storage for gas
 * efficiency.
 * @notice When it was developed the OpenZeppelin version was 5.0.2 ( hence the use of locally stored
 * ReentrancyGuardTransient )
 *
 * @dev How to use this contract:
 * 1. Deposit tokens: Use `depositTokens` to deposit ERC20 tokens into the contract.
 * 2. Withdraw tokens: Use `withdrawTokens` to withdraw deposited tokens.
 * 3. Enter a fleet: Use `enterFleet` to deposit tokens into a FleetCommander contract.
 * 4. Exit a fleet: Use `exitFleet` to withdraw tokens from a FleetCommander contract.
 * 5. Swap tokens: Use `swap` to exchange one token for another using the 1inch Router.
 * 6. Rescue tokens: Contract owner can use `rescueTokens` to withdraw any tokens stuck in the contract.
 *
 * @dev Multicall functionality:
 * This contract inherits from OpenZeppelin's Multicall, allowing multiple function calls to be batched into a single
 * transaction.
 * To use Multicall:
 * 1. Encode each function call you want to make as calldata.
 * 2. Pack these encoded function calls into an array of bytes.
 * 3. Call the `multicall` function with this array as the argument.
 *
 * Example Multicall usage:
 * bytes[] memory calls = new bytes[](2);
 * calls[0] = abi.encodeWithSelector(this.depositTokens.selector, tokenAddress, amount);
 * calls[1] = abi.encodeWithSelector(this.enterFleet.selector, fleetCommanderAddress, tokenAddress, amount);
 * (bool[] memory successes, bytes[] memory results) = this.multicall(calls);
 *
 * @dev Security considerations:
 * - All external functions are protected against reentrancy attacks.
 * - The contract uses OpenZeppelin's SafeERC20 for safe token transfers.
 * - Only the contract owner can rescue tokens.
 * - Ensure that the 1inch Router address provided in the constructor is correct and trusted.
 * - Since there is no data exchange between calls - make sure all the tokens are returned to the user
 */
contract AdmiralsQuarters is
    Ownable,
    ProtectedMulticall,
    ReentrancyGuardTransient,
    IAdmiralsQuarters,
    ConfigurationManaged
{
    using SafeERC20 for IERC20;
    using SafeERC20 for IAToken;

    address public immutable ONE_INCH_ROUTER;
    address public immutable NATIVE_PSEUDO_ADDRESS =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public immutable WRAPPED_NATIVE;

    constructor(
        address _oneInchRouter,
        address _configurationManager,
        address _wrappedNative
    ) Ownable(_msgSender()) ConfigurationManaged(_configurationManager) {
        if (_oneInchRouter == address(0)) revert InvalidRouterAddress();
        ONE_INCH_ROUTER = _oneInchRouter;
        if (_wrappedNative == address(0)) revert InvalidNativeTokenAddress();
        WRAPPED_NATIVE = _wrappedNative;
    }

    /// @inheritdoc IAdmiralsQuarters
    function depositTokens(
        IERC20 asset,
        uint256 amount
    ) external payable onlyMulticall nonReentrant {
        _validateToken(asset);
        _validateAmount(amount);

        if (address(asset) == NATIVE_PSEUDO_ADDRESS) {
            _validateNativeAmount(amount, address(this).balance);
            IWETH(WRAPPED_NATIVE).deposit{value: address(this).balance}();
        } else {
            _validateNativeAmount(0, address(this).balance);
            asset.safeTransferFrom(_msgSender(), address(this), amount);
        }
        emit TokensDeposited(_msgSender(), address(asset), amount);
    }

    /// @inheritdoc IAdmiralsQuarters
    function withdrawTokens(
        IERC20 asset,
        uint256 amount
    ) external payable onlyMulticall nonReentrant noNativeToken {
        _validateToken(asset);

        if (address(asset) == NATIVE_PSEUDO_ADDRESS) {
            if (amount == 0) {
                amount = IWETH(WRAPPED_NATIVE).balanceOf(address(this));
            }
            IWETH(WRAPPED_NATIVE).withdraw(amount);
            payable(_msgSender()).transfer(amount);
        } else {
            if (amount == 0) {
                amount = asset.balanceOf(address(this));
            }
            asset.safeTransfer(_msgSender(), amount);
        }

        emit TokensWithdrawn(_msgSender(), address(asset), amount);
    }

    /// @inheritdoc IAdmiralsQuarters
    function enterFleet(
        address fleetCommander,
        uint256 assets,
        address receiver
    )
        external
        payable
        onlyMulticall
        nonReentrant
        noNativeToken
        returns (uint256 shares)
    {
        _validateFleetCommander(fleetCommander);

        IFleetCommander fleet = IFleetCommander(fleetCommander);
        IERC20 fleetAsset = IERC20(fleet.asset());

        uint256 balance = fleetAsset.balanceOf(address(this));
        assets = assets == 0 ? balance : assets;
        receiver = receiver == address(0) ? _msgSender() : receiver;
        if (assets > balance) revert InsufficientOutputAmount();

        fleetAsset.forceApprove(address(fleet), assets);
        shares = fleet.deposit(assets, receiver);

        emit FleetEntered(receiver, fleetCommander, assets, shares);
    }

    /// @inheritdoc IAdmiralsQuarters
    function exitFleet(
        address fleetCommander,
        uint256 assets
    )
        external
        payable
        onlyMulticall
        nonReentrant
        noNativeToken
        returns (uint256 shares)
    {
        _validateFleetCommander(fleetCommander);

        IFleetCommander fleet = IFleetCommander(fleetCommander);

        assets = assets == 0 ? Constants.MAX_UINT256 : assets;

        shares = fleet.withdraw(assets, address(this), _msgSender());

        emit FleetExited(_msgSender(), fleetCommander, assets, shares);
    }

    /// @inheritdoc IAdmiralsQuarters
    function stake(
        address fleetCommander,
        uint256 shares
    ) external payable onlyMulticall nonReentrant noNativeToken {
        _validateFleetCommander(fleetCommander);

        IFleetCommander fleet = IFleetCommander(fleetCommander);
        address rewardsManager = fleet.getConfig().stakingRewardsManager;

        uint256 balance = IERC20(fleetCommander).balanceOf(address(this));
        shares = shares == 0 ? balance : shares;
        if (shares > balance) revert InsufficientOutputAmount();

        IERC20(fleetCommander).forceApprove(rewardsManager, shares);
        IFleetCommanderRewardsManager(rewardsManager).stakeOnBehalfOf(
            _msgSender(),
            shares
        );

        emit FleetSharesStaked(_msgSender(), fleetCommander, shares);
    }

    function unstakeAndWithdrawAssets(
        address fleetCommander,
        uint256 shares,
        bool claimRewards
    ) external onlyMulticall nonReentrant {
        _validateFleetCommander(fleetCommander);

        IFleetCommander fleet = IFleetCommander(fleetCommander);
        address rewardsManager = fleet.getConfig().stakingRewardsManager;

        shares = shares == 0
            ? IFleetCommanderRewardsManager(rewardsManager).balanceOf(
                _msgSender()
            )
            : shares;
        IFleetCommanderRewardsManager(rewardsManager)
            .unstakeAndWithdrawOnBehalfOf(_msgSender(), shares, claimRewards);

        emit FleetSharesUnstaked(_msgSender(), fleetCommander, shares);
    }

    /// @inheritdoc IAdmiralsQuarters
    function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 assets,
        uint256 minTokensReceived,
        bytes calldata swapCalldata
    )
        external
        payable
        onlyMulticall
        nonReentrant
        noNativeToken
        returns (uint256 swappedAmount)
    {
        _validateToken(fromToken);
        _validateToken(toToken);
        _validateAmount(assets);

        if (address(fromToken) == address(toToken)) {
            revert AssetMismatch();
        }
        swappedAmount = _swap(
            fromToken,
            toToken,
            assets,
            minTokensReceived,
            swapCalldata
        );

        emit Swapped(
            _msgSender(),
            address(fromToken),
            address(toToken),
            assets,
            swappedAmount
        );
    }

    /// @inheritdoc IAdmiralsQuarters
    function claimMerkleRewards(
        address user,
        uint256[] calldata indices,
        uint256[] calldata amounts,
        bytes32[][] calldata proofs,
        address rewardsRedeemer
    ) external onlyMulticall nonReentrant {
        _claimMerkleRewards(user, indices, amounts, proofs, rewardsRedeemer);
    }

    /// @inheritdoc IAdmiralsQuarters
    function claimGovernanceRewards(
        address govRewardsManager,
        address rewardToken
    ) external onlyMulticall nonReentrant {
        _claimGovernanceRewards(govRewardsManager, rewardToken);
    }

    /// @inheritdoc IAdmiralsQuarters
    function claimFleetRewards(
        address[] calldata fleetCommanders,
        address rewardToken
    ) external onlyMulticall nonReentrant {
        _claimFleetRewards(fleetCommanders, rewardToken);
    }

    /**
     * @dev Internal function to perform a token swap using 1inch
     * @param fromToken The token to swap from
     * @param toToken The token to swap to
     * @param assets The amount of fromToken to swap
     * @param minTokensReceived The minimum amount of toToken to receive after the swap
     * @param swapCalldata The 1inch swap calldata
     * @return swappedAmount The amount of toToken received from the swap
     */
    function _swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 assets,
        uint256 minTokensReceived,
        bytes calldata swapCalldata
    ) internal returns (uint256 swappedAmount) {
        uint256 balanceBefore = toToken.balanceOf(address(this));

        fromToken.forceApprove(ONE_INCH_ROUTER, assets);
        (bool success, ) = ONE_INCH_ROUTER.call(swapCalldata);
        if (!success) {
            revert SwapFailed();
        }

        uint256 balanceAfter = toToken.balanceOf(address(this));
        swappedAmount = balanceAfter - balanceBefore;

        if (swappedAmount < minTokensReceived) {
            revert InsufficientOutputAmount();
        }
    }

    function _validateFleetCommander(address fleetCommander) internal view {
        if (
            !IHarborCommand(harborCommand()).activeFleetCommanders(
                fleetCommander
            )
        ) {
            revert InvalidFleetCommander();
        }
    }

    function _validateToken(IERC20 token) internal pure {
        if (address(token) == address(0)) revert InvalidToken();
    }

    function _validateAmount(uint256 amount) internal pure {
        if (amount == 0) revert ZeroAmount();
    }

    function _validateNativeAmount(
        uint256 amount,
        uint256 msgValue
    ) internal pure {
        if (amount != msgValue) revert InvalidNativeAmount();
    }

    /// @inheritdoc IAdmiralsQuarters
    function rescueTokens(
        IERC20 token,
        address to,
        uint256 amount
    ) external onlyOwner {
        token.safeTransfer(to, amount);
        emit TokensRescued(address(token), to, amount);
    }

    /**
     * @dev Required to receive ETH when unwrapping WETH
     */
    receive() external payable {}

    /**
     * @dev Modifier to prevent native token usage
     * @dev This is used to prevent native token usage in the multicall function
     * @dev Inb methods that have to be payable, but are not the entry point for the user
     * @dev Adds 22 gas to the call
     */
    modifier noNativeToken() {
        if (address(this).balance > 0) revert NativeTokenNotAllowed();
        _;
    }

    /**
     * @dev Claims rewards from merkle distributor
     * @param user Address to claim rewards for
     * @param indices Array of merkle proof indices
     * @param amounts Array of merkle proof amounts
     * @param proofs Array of merkle proof data
     * @param rewardsRedeemer Address of the rewards redeemer contract
     */
    function _claimMerkleRewards(
        address user,
        uint256[] calldata indices,
        uint256[] calldata amounts,
        bytes32[][] calldata proofs,
        address rewardsRedeemer
    ) internal {
        if (rewardsRedeemer == address(0)) {
            revert InvalidRewardsRedeemer();
        }

        // We can now directly pass the arrays to the redeemer
        ISummerRewardsRedeemer(rewardsRedeemer).claimMultiple(
            user,
            indices,
            amounts,
            proofs
        );
    }

    /**
     * @dev Claims rewards from governance rewards manager
     * @param govRewardsManager Address of the governance rewards manager
     * @param rewardToken Address of the reward token to claim
     */
    function _claimGovernanceRewards(
        address govRewardsManager,
        address rewardToken
    ) internal {
        if (govRewardsManager == address(0)) {
            revert InvalidRewardsManager();
        }

        _validateToken(IERC20(rewardToken));

        // Claim rewards
        IGovernanceRewardsManager(govRewardsManager).getRewardFor(
            _msgSender(),
            rewardToken
        );
    }

    /**
     * @dev Claims rewards from fleet commanders
     * @param fleetCommanders Array of FleetCommander addresses
     * @param rewardToken Address of the reward token to claim
     */
    function _claimFleetRewards(
        address[] calldata fleetCommanders,
        address rewardToken
    ) internal {
        for (uint256 i = 0; i < fleetCommanders.length; ) {
            address fleetCommander = fleetCommanders[i];

            // Validate FleetCommander through HarborCommand
            _validateFleetCommander(fleetCommander);

            // Get rewards manager from FleetCommander and claim
            address rewardsManager = IFleetCommander(fleetCommander)
                .getConfig()
                .stakingRewardsManager;
            IFleetCommanderRewardsManager(rewardsManager).getRewardFor(
                _msgSender(),
                rewardToken
            );

            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc IAdmiralsQuarters
    function moveFromCompoundToAdmiralsQuarters(
        address cToken,
        uint256 assets
    ) external onlyMulticall nonReentrant {
        IComet token = IComet(cToken);
        address underlying = token.baseToken();

        // Get actual assets if 0 was passed
        assets = assets == 0 ? token.balanceOf(_msgSender()) : assets;

        // Calculate underlying assets
        token.withdrawFrom(_msgSender(), address(this), underlying, assets);

        emit CompoundPositionImported(_msgSender(), cToken, assets);
    }

    /// @inheritdoc IAdmiralsQuarters
    function moveFromAaveToAdmiralsQuarters(
        address aToken,
        uint256 assets
    ) external onlyMulticall nonReentrant {
        IAToken token = IAToken(aToken);
        IPoolV3 pool = IPoolV3(token.POOL());
        IERC20 underlying = IERC20(token.UNDERLYING_ASSET_ADDRESS());

        assets = assets == 0 ? token.balanceOf(_msgSender()) : assets;

        token.safeTransferFrom(_msgSender(), address(this), assets);
        pool.withdraw(address(underlying), assets, address(this));

        emit AavePositionImported(_msgSender(), aToken, assets);
    }

    /// @inheritdoc IAdmiralsQuarters
    function moveFromERC4626ToAdmiralsQuarters(
        address vault,
        uint256 shares
    ) external onlyMulticall nonReentrant {
        IERC4626 vaultToken = IERC4626(vault);

        // Get actual shares if 0 was passed
        shares = shares == 0 ? vaultToken.balanceOf(_msgSender()) : shares;

        vaultToken.redeem(shares, address(this), _msgSender());

        emit ERC4626PositionImported(_msgSender(), vault, shares);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IConfigurationManaged} from "../interfaces/IConfigurationManaged.sol";
import {IConfigurationManager} from "../interfaces/IConfigurationManager.sol";

/**
 * @title ConfigurationManaged
 * @notice Base contract for contracts that need to read from the ConfigurationManager
 * @custom:see IConfigurationManaged
 */
abstract contract ConfigurationManaged is IConfigurationManaged {
    IConfigurationManager public immutable configurationManager;

    /**
     * @notice Constructs the ConfigurationManaged contract
     * @param _configurationManager The address of the ConfigurationManager contract
     */
    constructor(address _configurationManager) {
        if (_configurationManager == address(0)) {
            revert ConfigurationManagerZeroAddress();
        }
        configurationManager = IConfigurationManager(_configurationManager);
    }

    /// @inheritdoc IConfigurationManaged
    function raft() public view virtual returns (address) {
        return configurationManager.raft();
    }

    /// @inheritdoc IConfigurationManaged
    function tipJar() public view virtual returns (address) {
        return configurationManager.tipJar();
    }

    /// @inheritdoc IConfigurationManaged
    function treasury() public view virtual returns (address) {
        return configurationManager.treasury();
    }

    /// @inheritdoc IConfigurationManaged
    function harborCommand() public view virtual returns (address) {
        return configurationManager.harborCommand();
    }

    /// @inheritdoc IConfigurationManaged
    function fleetCommanderRewardsManagerFactory()
        public
        view
        virtual
        returns (address)
    {
        return configurationManager.fleetCommanderRewardsManagerFactory();
    }
}
// SPDX-License-Identifier: BUSL-1.1
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Multicall.sol)

pragma solidity ^0.8.20;

import {Address, Context} from "@openzeppelin/contracts/utils/Multicall.sol";
import {StorageSlot} from "@summerfi/dependencies/openzeppelin-next/StorageSlot.sol";

/**
 * @dev Provides a function to batch together multiple calls in a single external call.
 *
 * Consider any assumption about calldata validation performed by the sender may be violated if it's not especially
 * careful about sending transactions invoking {multicall}. For example, a relay address that filters function
 * selectors won't filter calls nested within a {multicall} operation.
 *
 * NOTE: Since 5.0.1 and 4.9.4, this contract identifies non-canonical contexts (i.e. `msg.sender` is not {_msgSender}).
 * If a non-canonical context is identified, the following self `delegatecall` appends the last bytes of `msg.data`
 * to the subcall. This makes it safe to use with {ERC2771Context}. Contexts that don't affect the resolution of
 * {_msgSender} are not propagated to subcalls.
 */

abstract contract ProtectedMulticall is Context {
    using StorageSlot for *;

    error MulticallAlreadyInProgress();
    error NotMulticall();

    bytes32 constant CALLER_KEY = keccak256("admirals-quarters-caller");

    modifier onlyMulticall() {
        if (_getCaller() != _msgSender()) {
            revert NotMulticall();
        }
        _;
    }
    /**
     * @dev Receives and executes a batch of function calls on this contract.
     * @custom:oz-upgrades-unsafe-allow-reachable delegatecall
     */

    function multicall(
        bytes[] calldata data
    ) external payable returns (bytes[] memory results) {
        if (_getCaller() != address(0)) {
            revert MulticallAlreadyInProgress();
        }
        _setCaller(msg.sender);
        results = _multicall(data);
        _setCaller(address(0));
    }

    function _multicall(
        bytes[] calldata data
    ) internal returns (bytes[] memory results) {
        bytes memory context = msg.sender == _msgSender()
            ? new bytes(0)
            : msg.data[msg.data.length - _contextSuffixLength():];

        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(
                address(this),
                bytes.concat(data[i], context)
            );
        }
        return results;
    }

    function _setCaller(address caller) internal {
        CALLER_KEY.asAddress().tstore(caller);
    }

    function _getCaller() internal view returns (address) {
        return CALLER_KEY.asAddress().tload();
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IAdmiralsQuartersErrors
 * @dev This file contains custom error definitions for the AdmiralsQuarters contract.
 * @notice These custom errors provide more gas-efficient and informative error handling
 * compared to traditional require statements with string messages.
 */
interface IAdmiralsQuartersErrors {
    /**
     * @notice Thrown when a swap operation fails.
     */
    error SwapFailed();

    /**
     * @notice Thrown when there's a mismatch between expected and actual assets in an operation.
     */
    error AssetMismatch();

    /**
     * @notice Thrown when the output amount from an operation is less than the expected minimum.
     */
    error InsufficientOutputAmount();

    /**
     * @notice Thrown when an invalid FleetCommander address is provided or used.
     */
    error InvalidFleetCommander();

    /**
     * @notice Thrown when an invalid token address is provided or used.
     */
    error InvalidToken();

    /**
     * @notice Thrown when an unsupported swap function is called or referenced.
     */
    error UnsupportedSwapFunction();

    /**
     * @notice Thrown when there's a mismatch between expected and actual swap amounts.
     */
    error SwapAmountMismatch();

    /**
     * @notice Thrown when a reentrancy attempt is detected.
     */
    error ReentrancyGuard();

    /**
     * @notice Thrown when an operation is attempted with a zero amount where a non-zero amount is required.
     */
    error ZeroAmount();

    /**
     * @notice Thrown when an invalid router address is provided or used.
     */
    error InvalidRouterAddress();

    /**
     * @notice Thrown when the provided token does not match the expected token.
     */
    error TokenMismatch();

    /**
     * @notice Thrown when an invalid WETH address is provided or used.
     */
    error InvalidNativeTokenAddress();

    /**
     * @notice Thrown when the provided native amount does not match the expected native amount.
     */
    error InvalidNativeAmount();

    /**
     * @notice Thrown when native token is not allowed.
     */
    error NativeTokenNotAllowed();

    /**
     * @notice Thrown when the provided rewards redeemer is invalid.
     */
    error InvalidRewardsRedeemer();

    /**
     * @notice Thrown when the provided rewards manager is invalid.
     */
    error InvalidRewardsManager();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IArkConfigProviderErrors
 * @dev This file contains custom error definitions for the ArkConfigProvider contract.
 * @notice These custom errors provide more gas-efficient and informative error handling
 * compared to traditional require statements with string messages.
 */
interface IArkConfigProviderErrors {
    /**
     * @notice Thrown when attempting to deploy an Ark without specifying a configuration manager.
     */
    error CannotDeployArkWithoutConfigurationManager();

    /**
     * @notice Thrown when attempting to deploy an Ark without specifying a Raft address.
     */
    error CannotDeployArkWithoutRaft();

    /**
     * @notice Thrown when attempting to deploy an Ark without specifying a token address.
     */
    error CannotDeployArkWithoutToken();

    /**
     * @notice Thrown when attempting to deploy an Ark with an empty name.
     */
    error CannotDeployArkWithEmptyName();

    /**
     * @notice Thrown when an invalid vault address is provided.
     */
    error InvalidVaultAddress();

    /**
     * @notice Thrown when there's a mismatch between expected and actual assets in an ERC4626 operation.
     */
    error ERC4626AssetMismatch();

    /**
     * @notice Thrown when the max deposit percentage of TVL is greater than 100%.
     */
    error MaxDepositPercentageOfTVLTooHigh();

    /**
     * @notice Thrown when attempting to register a FleetCommander when one is already registered.
     */
    error FleetCommanderAlreadyRegistered();

    /**
     * @notice Thrown when attempting to unregister a FleetCommander by a non-registered address.
     */
    error FleetCommanderNotRegistered();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IArkErrors
 * @dev This file contains custom error definitions for the Ark contract.
 * @notice These custom errors provide more gas-efficient and informative error handling
 * compared to traditional require statements with string messages.
 */
interface IArkErrors {
    /**
     * @notice Thrown when attempting to remove a commander from an Ark that still has assets.
     */
    error CannotRemoveCommanderFromArkWithAssets();

    /**
     * @notice Thrown when trying to add a commander to an Ark that already has one.
     */
    error CannotAddCommanderToArkWithCommander();

    /**
     * @notice Thrown when attempting to use keeper data when it's not required.
     */
    error CannotUseKeeperDataWhenNotRequired();

    /**
     * @notice Thrown when keeper data is required but not provided.
     */
    error KeeperDataRequired();

    /**
     * @notice Thrown when invalid board data is provided.
     */
    error InvalidBoardData();

    /**
     * @notice Thrown when invalid disembark data is provided.
     */
    error InvalidDisembarkData();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IConfigurationManagerErrors
 * @dev This file contains custom error definitions for the ConfigurationManager contract.
 * @notice These custom errors provide more gas-efficient and informative error handling
 * compared to traditional require statements with string messages.
 */
interface IConfigurationManagerErrors {
    /**
     * @notice Thrown when an operation is attempted with a zero address where a non-zero address is required.
     */
    error ZeroAddress();
    /**
     * @notice Thrown when ConfigurationManager was already initialized.
     */
    error ConfigurationManagerAlreadyInitialized();

    /**
     * @notice Thrown when the Raft address is not set.
     */
    error RaftNotSet();

    /**
     * @notice Thrown when the TipJar address is not set.
     */
    error TipJarNotSet();

    /**
     * @notice Thrown when the Treasury address is not set.
     */
    error TreasuryNotSet();

    /**
     * @notice Thrown when constructor address is set to the zero address.
     */
    error AddressZero();

    /**
     * @notice Thrown when the HarborCommand address is not set.
     */
    error HarborCommandNotSet();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IFleetCommanderConfigProviderErrors
 * @dev This file contains custom error definitions for the FleetCommanderConfigProvider contract.
 * @notice These custom errors provide more gas-efficient and informative error handling
 * compared to traditional require statements with string messages.
 */
interface IFleetCommanderConfigProviderErrors {
    /**
     * @notice Thrown when an operation is attempted on a non-existent Ark
     * @param ark The address of the Ark that was not found
     */
    error FleetCommanderArkNotFound(address ark);

    /**
     * @notice Thrown when trying to remove an Ark that still has a non-zero deposit cap
     * @param ark The address of the Ark with a non-zero deposit cap
     */
    error FleetCommanderArkDepositCapGreaterThanZero(address ark);

    /**
     * @notice Thrown when attempting to remove an Ark that still holds assets
     * @param ark The address of the Ark with non-zero assets
     */
    error FleetCommanderArkAssetsNotZero(address ark);

    /**
     * @notice Thrown when trying to add an Ark that already exists in the system
     * @param ark The address of the Ark that already exists
     */
    error FleetCommanderArkAlreadyExists(address ark);

    /**
     * @notice Thrown when an invalid Ark address is provided (e.g., zero address)
     */
    error FleetCommanderInvalidArkAddress();

    /**
     * @notice Thrown when trying to set a StakingRewardsManager to the zero address
     */
    error FleetCommanderInvalidStakingRewardsManager();

    /**
     * @notice Thrown when trying to set a max rebalance operations to a value greater than the max allowed
     * @param newMaxRebalanceOperations The new max rebalance operations value
     */
    error FleetCommanderMaxRebalanceOperationsTooHigh(
        uint256 newMaxRebalanceOperations
    );

    /**
     * @notice Thrown when the asset of the Ark does not match the asset of the FleetCommander
     */
    error FleetCommanderAssetMismatch();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IFleetCommanderErrors
 * @dev This file contains custom error definitions for the FleetCommander contract.
 * @notice These custom errors provide more gas-efficient and informative error handling
 * compared to traditional require statements with string messages.
 */
interface IFleetCommanderErrors {
    /**
     * @notice Thrown when transfers are disabled.
     */
    error FleetCommanderTransfersDisabled();

    /**
     * @notice Thrown when an operation is attempted on an inactive Ark.
     * @param ark The address of the inactive Ark.
     */
    error FleetCommanderArkNotActive(address ark);

    /**
     * @notice Thrown when attempting to rebalance to an invalid Ark.
     * @param ark The address of the invalid Ark.
     * @param amount Amount of tokens added to target ark
     * @param effectiveDepositCap Effective deposit cap of the ark (minimum of % of fleet TVL or arbitrary ark deposit
     * cap)
     */
    error FleetCommanderEffectiveDepositCapExceeded(
        address ark,
        uint256 amount,
        uint256 effectiveDepositCap
    );

    /**
     * @notice Thrown when there is insufficient buffer for an operation.
     */
    error FleetCommanderInsufficientBuffer();

    /**
     * @notice Thrown when a rebalance operation is attempted with no actual operations.
     */
    error FleetCommanderRebalanceNoOperations();

    /**
     * @notice Thrown when a rebalance operation exceeds the maximum allowed number of operations.
     * @param operationsCount The number of operations attempted.
     */
    error FleetCommanderRebalanceTooManyOperations(uint256 operationsCount);

    /**
     * @notice Thrown when a rebalance amount for an Ark is zero.
     * @param ark The address of the Ark with zero rebalance amount.
     */
    error FleetCommanderRebalanceAmountZero(address ark);

    /**
     * @notice Thrown when a withdrawal amount exceeds the maximum buffer limit.
     */
    error WithdrawalAmountExceedsMaxBufferLimit();

    /**
     * @notice Thrown when an Ark's deposit cap is zero.
     * @param ark The address of the Ark with zero deposit cap.
     */
    error FleetCommanderArkDepositCapZero(address ark);

    /**
     * @notice Thrown when no funds were moved in an operation that expected fund movement.
     */
    error FleetCommanderNoFundsMoved();

    /**
     * @notice Thrown when there are no excess funds to perform an operation.
     */
    error FleetCommanderNoExcessFunds();

    /**
     * @notice Thrown when an invalid source Ark is specified for an operation.
     * @param ark The address of the invalid source Ark.
     */
    error FleetCommanderInvalidSourceArk(address ark);

    /**
     * @notice Thrown when an operation attempts to move more funds than available.
     */
    error FleetCommanderMovedMoreThanAvailable();

    /**
     * @notice Thrown when an unauthorized withdrawal is attempted.
     * @param caller The address attempting the withdrawal.
     * @param owner The address of the authorized owner.
     */
    error FleetCommanderUnauthorizedWithdrawal(address caller, address owner);

    /**
     * @notice Thrown when an unauthorized redemption is attempted.
     * @param caller The address attempting the redemption.
     * @param owner The address of the authorized owner.
     */
    error FleetCommanderUnauthorizedRedemption(address caller, address owner);

    /**
     * @notice Thrown when attempting to use rebalance on a buffer Ark.
     */
    error FleetCommanderCantUseRebalanceOnBufferArk();

    /**
     * @notice Thrown when attempting to use the maximum uint value for buffer adjustment from buffer.
     */
    error FleetCommanderCantUseMaxUintMovingFromBuffer();

    /**
     * @notice Thrown when a rebalance operation exceeds the maximum outflow for an Ark.
     * @param fromArk The address of the Ark from which funds are being moved.
     * @param amount The amount being moved.
     * @param maxRebalanceOutflow The maximum allowed outflow.
     */
    error FleetCommanderExceedsMaxOutflow(
        address fromArk,
        uint256 amount,
        uint256 maxRebalanceOutflow
    );

    /**
     * @notice Thrown when a rebalance operation exceeds the maximum inflow for an Ark.
     * @param fromArk The address of the Ark to which funds are being moved.
     * @param amount The amount being moved.
     * @param maxRebalanceInflow The maximum allowed inflow.
     */
    error FleetCommanderExceedsMaxInflow(
        address fromArk,
        uint256 amount,
        uint256 maxRebalanceInflow
    );

    /**
     * @notice Thrown when the staking rewards manager is not set.
     */
    error FleetCommanderStakingRewardsManagerNotSet();

    /**
     * @notice Thrown when user attempts to deposit/mint or withdraw/redeem 0 units
     */
    error FleetCommanderZeroAmount();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IHarborCommandErrors
 * @dev This file contains custom error definitions for the HarborCommand contract.
 * @notice These custom errors provide more gas-efficient and informative error handling
 * compared to traditional require statements with string messages.
 */
interface IHarborCommandErrors {
    /**
     * @notice Thrown when attempting to enlist a FleetCommander that is already enlisted
     * @param fleetCommander The address of the FleetCommander that was attempted to be enlisted
     */
    error FleetCommanderAlreadyEnlisted(address fleetCommander);

    /**
     * @notice Thrown when attempting to decommission a FleetCommander that is not currently enlisted
     * @param fleetCommander The address of the FleetCommander that was attempted to be decommissioned
     */
    error FleetCommanderNotEnlisted(address fleetCommander);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IAdmiralsQuartersEvents
 * @dev Interface for the events emitted by the AdmiralsQuarters contract.
 * @notice This interface defines the events that can be emitted during various operations
 * in the AdmiralsQuarters contract, such as token deposits, withdrawals, fleet interactions,
 * token swaps, and rescue operations.
 */
interface IAdmiralsQuartersEvents {
    /**
     * @dev Emitted when tokens are deposited into the AdmiralsQuarters.
     * @param user The address of the user who deposited the tokens.
     * @param token The address of the token that was deposited.
     * @param amount The amount of tokens that were deposited.
     */
    event TokensDeposited(
        address indexed user,
        address indexed token,
        uint256 amount
    );

    /**
     * @dev Emitted when tokens are withdrawn from the AdmiralsQuarters.
     * @param user The address of the user who withdrew the tokens.
     * @param token The address of the token that was withdrawn.
     * @param amount The amount of tokens that were withdrawn.
     */
    event TokensWithdrawn(
        address indexed user,
        address indexed token,
        uint256 amount
    );

    /**
     * @dev Emitted when a user enters a fleet with their tokens.
     * @param user The address of the user who entered the fleet.
     * @param fleetCommander The address of the FleetCommander contract.
     * @param inputAmount The amount of tokens the user input into the fleet.
     * @param sharesReceived The amount of shares the user received in return.
     */
    event FleetEntered(
        address indexed user,
        address indexed fleetCommander,
        uint256 inputAmount,
        uint256 sharesReceived
    );

    /**
     * @dev Emitted when a user exits a fleet, withdrawing their tokens.
     * @param user The address of the user who exited the fleet.
     * @param fleetCommander The address of the FleetCommander contract.
     * @param withdrawnAmount The amount of shares withdrawn from the fleet.
     * @param outputAmount The amount of tokens received in return.
     */
    event FleetExited(
        address indexed user,
        address indexed fleetCommander,
        uint256 withdrawnAmount,
        uint256 outputAmount
    );

    /**
     * @dev Emitted when a user stakes their fleet shares.
     * @param user The address of the user who staked their shares.
     * @param fleetCommander The address of the FleetCommander contract.
     * @param amount The amount of shares staked.
     */
    event FleetSharesStaked(
        address indexed user,
        address indexed fleetCommander,
        uint256 amount
    );

    /**
     * @dev Emitted when a user unstakes their fleet shares.
     * @param user The address of the user who unstaked their shares.
     * @param fleetCommander The address of the FleetCommander contract.
     * @param amount The amount of shares unstaked.
     */
    event FleetSharesUnstaked(
        address indexed user,
        address indexed fleetCommander,
        uint256 amount
    );

    /**
     * @dev Emitted when a token swap occurs.
     * @param user The address of the user who performed the swap.
     * @param fromToken The address of the token being swapped from.
     * @param toToken The address of the token being swapped to.
     * @param fromAmount The amount of tokens swapped from.
     * @param toAmount The amount of tokens received in the swap.
     */
    event Swapped(
        address indexed user,
        address indexed fromToken,
        address indexed toToken,
        uint256 fromAmount,
        uint256 toAmount
    );

    /**
     * @dev Emitted when tokens are rescued from the contract by the owner.
     * @param token The address of the token that was rescued.
     * @param to The address that received the rescued tokens.
     * @param amount The amount of tokens that were rescued.
     */
    event TokensRescued(
        address indexed token,
        address indexed to,
        uint256 amount
    );
    /**
     * @dev Emitted when a user's compound position is imported.
     * @param user The address of the user whose position is imported.
     * @param cToken The address of the cToken being imported.
     * @param amount The amount of tokens being imported.
     */
    event CompoundPositionImported(
        address indexed user,
        address indexed cToken,
        uint256 amount
    );

    /**
     * @dev Emitted when a user's aave position is imported.
     * @param user The address of the user whose position is imported.
     * @param aToken The address of the aToken being imported.
     * @param amount The amount of tokens being imported.
     */
    event AavePositionImported(
        address indexed user,
        address indexed aToken,
        uint256 amount
    );

    /**
     * @dev Emitted when a user's erc4626 position is imported.
     * @param user The address of the user whose position is imported.
     * @param vault The address of the vault being imported.
     * @param amount The amount of tokens being imported.
     */
    event ERC4626PositionImported(
        address indexed user,
        address indexed vault,
        uint256 amount
    );
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {Percentage} from "@summerfi/percentage-solidity/contracts/Percentage.sol";

/**
 * @title IArkConfigProviderEvents
 * @notice Interface for events emitted by ArkConfigProvider contracts
 */
interface IArkConfigProviderEvents {
    /**
     * @notice Emitted when the deposit cap of the Ark is updated
     * @param newCap The new deposit cap value
     */
    event DepositCapUpdated(uint256 newCap);

    /**
     * @notice Emitted when the maximum deposit percentage of TVL is updated
     * @param newMaxDepositPercentageOfTVL The new maximum deposit percentage of TVL
     */
    event MaxDepositPercentageOfTVLUpdated(
        Percentage newMaxDepositPercentageOfTVL
    );

    /**
     * @notice Emitted when the Raft address associated with the Ark is updated
     * @param newRaft The address of the new Raft
     */
    event RaftUpdated(address newRaft);

    /**
     * @notice Emitted when the maximum outflow limit for the Ark during rebalancing is updated
     * @param newMaxOutflow The new maximum amount that can be transferred out of the Ark during a rebalance
     */
    event MaxRebalanceOutflowUpdated(uint256 newMaxOutflow);

    /**
     * @notice Emitted when the maximum inflow limit for the Ark during rebalancing is updated
     * @param newMaxInflow The new maximum amount that can be transferred into the Ark during a rebalance
     */
    event MaxRebalanceInflowUpdated(uint256 newMaxInflow);

    /**
     * @notice Emitted when the Fleet Commander is registered
     * @param commander The address of the Fleet Commander
     */
    event FleetCommanderRegistered(address commander);

    /**
     * @notice Emitted when the Fleet Commander is unregistered
     * @param commander The address of the Fleet Commander
     */
    event FleetCommanderUnregistered(address commander);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IArkEvents
 * @notice Interface for events emitted by Ark contracts
 */
interface IArkEvents {
    /**
     * @notice Emitted when rewards are harvested from an Ark
     * @param rewardTokens The addresses of the harvested reward tokens
     * @param rewardAmounts The amounts of the harvested reward tokens
     */
    event ArkHarvested(
        address[] indexed rewardTokens,
        uint256[] indexed rewardAmounts
    );

    /**
     * @notice Emitted when tokens are boarded (deposited) into the Ark
     * @param commander The address of the FleetCommander initiating the boarding
     * @param token The address of the token being boarded
     * @param amount The amount of tokens boarded
     */
    event Boarded(address indexed commander, address token, uint256 amount);

    /**
     * @notice Emitted when tokens are disembarked (withdrawn) from the Ark
     * @param commander The address of the FleetCommander initiating the disembarking
     * @param token The address of the token being disembarked
     * @param amount The amount of tokens disembarked
     */
    event Disembarked(address indexed commander, address token, uint256 amount);

    /**
     * @notice Emitted when tokens are moved from one address to another
     * @param from Ark being boarded from
     * @param to Ark being boarded to
     * @param token The address of the token being moved
     * @param amount The amount of tokens moved
     */
    event Moved(
        address indexed from,
        address indexed to,
        address token,
        uint256 amount
    );

    /**
     * @notice Emitted when the Ark is poked and the share price is updated
     * @param currentPrice Current share price of the Ark
     * @param timestamp The timestamp of the poke
     */
    event ArkPoked(uint256 currentPrice, uint256 timestamp);

    /**
     * @notice Emitted when the Ark is swept
     * @param sweptTokens The addresses of the swept tokens
     * @param sweptAmounts The amounts of the swept tokens
     */
    event ArkSwept(
        address[] indexed sweptTokens,
        uint256[] indexed sweptAmounts
    );
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IConfigurationManagerEvents
 * @notice Interface for events emitted by the Configuration Manager
 */
interface IConfigurationManagerEvents {
    /**
     * @notice Emitted when the Raft address is updated
     * @param newRaft The address of the new Raft
     */
    event RaftUpdated(address oldRaft, address newRaft);

    /**
     * @notice Emitted when the tip jar address is updated
     * @param newTipJar The address of the new tip jar
     */
    event TipJarUpdated(address oldTipJar, address newTipJar);

    /**
     * @notice Emitted when the tip rate is updated
     * @param newTipRate The new tip rate value
     */
    event TipRateUpdated(uint8 oldTipRate, uint8 newTipRate);

    /**
     * @notice Emitted when the Treasury address is updated
     * @param newTreasury The address of the new Treasury
     */
    event TreasuryUpdated(address oldTreasury, address newTreasury);

    /**
     * @notice Emitted when the Harbor Command address is updated
     * @param oldHarborCommand The address of the old Harbor Command
     * @param newHarborCommand The address of the new Harbor Command
     */
    event HarborCommandUpdated(
        address oldHarborCommand,
        address newHarborCommand
    );

    /**
     * @notice Emitted when the Fleet Commander Rewards Manager Factory address is updated
     * @param oldFleetCommanderRewardsManagerFactory The address of the old Fleet Commander Rewards Manager Factory
     * @param newFleetCommanderRewardsManagerFactory The address of the new Fleet Commander Rewards Manager Factory
     */
    event FleetCommanderRewardsManagerFactoryUpdated(
        address oldFleetCommanderRewardsManagerFactory,
        address newFleetCommanderRewardsManagerFactory
    );
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

interface IFleetCommanderConfigProviderEvents {
    /**
     * @notice Emitted when the deposit cap is updated
     * @param newCap The new deposit cap value
     */
    event FleetCommanderDepositCapUpdated(uint256 newCap);
    /**
     * @notice Emitted when a new Ark is added
     * @param ark The address of the newly added Ark
     */
    event ArkAdded(address indexed ark);

    /**
     * @notice Emitted when an Ark is removed
     * @param ark The address of the removed Ark
     */
    event ArkRemoved(address indexed ark);
    /**
     * @notice Emitted when new minimum funds buffer balance is set
     * @param newBalance New minimum funds buffer balance
     */
    event FleetCommanderminimumBufferBalanceUpdated(uint256 newBalance);

    /**
     * @notice Emitted when new max allowed rebalance operations is set
     * @param newMaxRebalanceOperations Max allowed rebalance operations
     */
    event FleetCommanderMaxRebalanceOperationsUpdated(
        uint256 newMaxRebalanceOperations
    );

    /**
     * @notice Emitted when the staking rewards contract address is updated
     * @param newStakingRewards The address of the new staking rewards contract
     */
    event FleetCommanderStakingRewardsUpdated(address newStakingRewards);

    /**
     * @notice Emitted when the transfer enabled status is updated
     */
    event TransfersEnabled();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {RebalanceData} from "../types/FleetCommanderTypes.sol";

interface IFleetCommanderEvents {
    /* EVENTS */
    /**
     * @notice Emitted when a rebalance operation is completed
     * @param keeper The address of the keeper who initiated the rebalance
     * @param rebalances An array of RebalanceData structs detailing the rebalance operations
     */
    event Rebalanced(address indexed keeper, RebalanceData[] rebalances);

    /**
     * @notice Emitted when queued funds are committed
     * @param keeper The address of the keeper who committed the funds
     * @param prevBalance The previous balance before committing funds
     * @param newBalance The new balance after committing funds
     */
    event QueuedFundsCommitted(
        address indexed keeper,
        uint256 prevBalance,
        uint256 newBalance
    );

    /**
     * @notice Emitted when the funds queue is refilled
     * @param keeper The address of the keeper who initiated the queue refill
     * @param prevBalance The previous balance before refilling
     * @param newBalance The new balance after refilling
     */
    event FundsQueueRefilled(
        address indexed keeper,
        uint256 prevBalance,
        uint256 newBalance
    );

    /**
     * @notice Emitted when the minimum balance of the funds queue is updated
     * @param keeper The address of the keeper who updated the minimum balance
     * @param newBalance The new minimum balance
     */
    event MinFundsQueueBalanceUpdated(
        address indexed keeper,
        uint256 newBalance
    );

    /**
     * @notice Emitted when the fee address is updated
     * @param newAddress The new fee address
     */
    event FeeAddressUpdated(address newAddress);

    /**
     * @notice Emitted when the funds buffer balance is updated
     * @param user The address of the user who triggered the update
     * @param prevBalance The previous buffer balance
     * @param newBalance The new buffer balance
     */
    event FundsBufferBalanceUpdated(
        address indexed user,
        uint256 prevBalance,
        uint256 newBalance
    );

    /**
     * @notice Emitted when funds are withdrawn from Arks
     * @param owner The address of the owner who initiated the withdrawal
     * @param receiver The address of the receiver of the withdrawn funds
     * @param totalWithdrawn The total amount of funds withdrawn
     */
    event FleetCommanderWithdrawnFromArks(
        address indexed owner,
        address receiver,
        uint256 totalWithdrawn
    );

    /**
     * @notice Emitted when funds are redeemed from Arks
     * @param owner The address of the owner who initiated the redemption
     * @param receiver The address of the receiver of the redeemed funds
     * @param totalRedeemed The total amount of funds redeemed
     */
    event FleetCommanderRedeemedFromArks(
        address indexed owner,
        address receiver,
        uint256 totalRedeemed
    );
    /**
     * @notice Emitted when referee deposits into the FleetCommander
     * @param referee The address of the referee who was referred
     * @param referralCode The referral code of the referrer
     */
    event FleetCommanderReferral(
        address indexed referee,
        bytes indexed referralCode
    );
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IAdmiralsQuartersErrors} from "../errors/IAdmiralsQuartersErrors.sol";
import {IAdmiralsQuartersEvents} from "../events/IAdmiralsQuartersEvents.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title IAdmiralsQuarters
 * @notice Interface for the AdmiralsQuarters contract, which manages interactions with FleetCommanders and token swaps
 */
interface IAdmiralsQuarters is
    IAdmiralsQuartersEvents,
    IAdmiralsQuartersErrors
{
    /**
     * @notice Deposits tokens into the contract
     * @param asset The token to be deposited
     * @param amount The amount of tokens to deposit
     * @dev Emits a TokensDeposited event
     */
    function depositTokens(IERC20 asset, uint256 amount) external payable;

    /**
     * @notice Withdraws tokens from the contract
     * @param asset The token to be withdrawn
     * @param amount The amount of tokens to withdraw (0 for all)
     * @dev Emits a TokensWithdrawn event
     */
    function withdrawTokens(IERC20 asset, uint256 amount) external payable;

    /**
     * @notice Enters a FleetCommander by depositing tokens
     * @param fleetCommander The address of the FleetCommander contract
     * @param assets The amount of inputToken to be deposited (0 for all)
     * @param receiver The address to receive the shares
     * @return shares The number of shares received from the FleetCommander
     * @dev Emits a FleetEntered event
     */
    function enterFleet(
        address fleetCommander,
        uint256 assets,
        address receiver
    ) external payable returns (uint256 shares);

    /**
     * @notice Stakes shares in a FleetCommander
     * @dev If zero shares are provided, the full balance of the FleetCommander is staked
     * @param fleetCommander The address of the FleetCommander contract
     * @param shares The amount of shares to stake
     * @dev Emits a FleetSharesStaked event
     */
    function stake(address fleetCommander, uint256 shares) external payable;

    /**
     * @notice Unstakes shares from a FleetCommander and withdraws assets to user wallet
     * @dev If zero shares are provided, the full balance of the FleetCommander is unstaked
     * @param fleetCommander The address of the FleetCommander contract
     * @param shares The amount of shares to unstake
     * @param claimRewards Whether to claim rewards before unstaking
     * @dev Emits a FleetSharesUnstaked event
     */
    function unstakeAndWithdrawAssets(
        address fleetCommander,
        uint256 shares,
        bool claimRewards
    ) external;

    /**
     * @notice Exits a FleetCommander by withdrawing tokens
     * @param fleetCommander The address of the FleetCommander contract
     * @param assets The amount of shares to withdraw (0 for all)
     * @return shares The amount of assets received from the FleetCommander
     * @dev Emits a FleetExited event
     */
    function exitFleet(
        address fleetCommander,
        uint256 assets
    ) external payable returns (uint256 shares);

    /**
     * @notice Performs a token swap using 1inch Router
     * @param fromToken The token to swap from
     * @param toToken The token to swap to
     * @param amount The amount of fromToken to swap
     * @param minTokensReceived The minimum amount of toToken to receive after the swap
     * @param swapCalldata The calldata for the 1inch swap
     * @return swappedAmount The amount of toToken received after the swap
     * @dev Emits a Swapped event
     */
    function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 minTokensReceived,
        bytes calldata swapCalldata
    ) external payable returns (uint256 swappedAmount);

    /**
     * @notice Allows the owner to rescue any ERC20 tokens sent to the contract by mistake
     * @param token The address of the ERC20 token to rescue
     * @param to The address to send the rescued tokens to
     * @param amount The amount of tokens to rescue
     * @dev Can only be called by the contract owner
     * @dev Emits a TokensRescued event
     */
    function rescueTokens(IERC20 token, address to, uint256 amount) external;

    /**
     * @notice Imports a position from an ERC4626 vault to AdmiralsQuarters, has to be followed by a call to enter fleet
     * @dev If zero shares are provided, the full balance of the vault is imported
     * @dev needs approval from the user to withdraw on their behalf (e.g.
     * ERC4626Vault.approve(address(admiralsQuarters), type(uint256).max))
     * @param vault The address of the ERC4626 vault
     * @param shares The amount of vault tokens to import
     * @dev Emits an ERC4626PositionImported event
     */
    function moveFromERC4626ToAdmiralsQuarters(
        address vault,
        uint256 shares
    ) external;

    /**
     * @notice Imports a position from an Aave aToken to AdmiralsQuarters, has to be followed by a call to enter fleet
     * @dev If zero amount is provided, the full balance of the aToken is imported
     * @dev needs approval from the user to transfer from their wallet (e.g. aUSDC.approve(address(admiralsQuarters),
     * type(uint256).max))
     * @dev approval requires small buffer due to constant accrual of interest
     * @param aToken The address of the Aave aToken
     * @param amount The amount of tokens to import
     * @dev Emits an AavePositionImported event
     */
    function moveFromAaveToAdmiralsQuarters(
        address aToken,
        uint256 amount
    ) external;

    /**
     * @notice Imports a position from a Compound cToken to AdmiralsQuarters, has to be followed by a call to enter
     * fleet
     * @dev If zero amount is provided, the full balance of the cToken is imported
     * @dev needs approval from the user to withdraw on their behalf (e.g. cUSDC.allow(address(admiralsQuarters),true))
     *
     * @param cToken The address of the Compound cToken
     * @param amount The amount of tokens to import
     * @dev Emits a CompoundPositionImported event
     */
    function moveFromCompoundToAdmiralsQuarters(
        address cToken,
        uint256 amount
    ) external;

    /**
     * @notice Claims merkle rewards for a user
     * @param user Address to claim rewards for
     * @param indices Array of merkle proof indices
     * @param amounts Array of merkle proof amounts
     * @param proofs Array of merkle proof data
     * @param rewardsRedeemer Address of the rewards redeemer contract
     */
    function claimMerkleRewards(
        address user,
        uint256[] calldata indices,
        uint256[] calldata amounts,
        bytes32[][] calldata proofs,
        address rewardsRedeemer
    ) external;

    /**
     * @notice Claims governance rewards
     * @param govRewardsManager Address of the governance rewards manager
     * @param rewardToken Address of the reward token to claim
     */
    function claimGovernanceRewards(
        address govRewardsManager,
        address rewardToken
    ) external;

    /**
     * @notice Claims rewards from fleet commanders
     * @param fleetCommanders Array of FleetCommander addresses
     * @param rewardToken Address of the reward token to claim
     */
    function claimFleetRewards(
        address[] calldata fleetCommanders,
        address rewardToken
    ) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IArkErrors} from "../errors/IArkErrors.sol";

import {IArkEvents} from "../events/IArkEvents.sol";
import {IArkAccessManaged} from "./IArkAccessManaged.sol";
import {IArkConfigProvider} from "./IArkConfigProvider.sol";

/**
 * @title IArk
 * @notice Interface for the Ark contract, which manages funds and interacts with Rafts
 * @dev Inherits from IArkAccessManaged for access control and IArkEvents for event definitions
 */
interface IArk is
    IArkAccessManaged,
    IArkEvents,
    IArkErrors,
    IArkConfigProvider
{
    /**
     * @notice Returns the current underlying balance of the Ark
     * @return The total assets in the Ark, in token precision
     */
    function totalAssets() external view returns (uint256);

    /**
     * @notice Triggers a harvest operation to collect rewards
     * @param additionalData Optional bytes that might be required by a specific protocol to harvest
     * @return rewardTokens The reward token addresses
     * @return rewardAmounts The reward amounts
     */
    function harvest(
        bytes calldata additionalData
    )
        external
        returns (address[] memory rewardTokens, uint256[] memory rewardAmounts);

    /**
     * @notice Sweeps tokens from the Ark
     * @param tokens The tokens to sweep
     * @return sweptTokens The swept tokens
     * @return sweptAmounts The swept amounts
     */
    function sweep(
        address[] calldata tokens
    )
        external
        returns (address[] memory sweptTokens, uint256[] memory sweptAmounts);

    /**
     * @notice Deposits (boards) tokens into the Ark
     * @dev This function is called by the Fleet Commander to deposit assets into the Ark.
     *      It transfers tokens from the caller to this contract and then calls the internal _board function.
     * @param amount The amount of assets to board
     * @param boardData Additional data required for boarding, specific to the Ark implementation
     * @custom:security-note This function is only callable by authorized entities
     */
    function board(uint256 amount, bytes calldata boardData) external;

    /**
     * @notice Withdraws (disembarks) tokens from the Ark
     * @param amount The amount of tokens to withdraw
     * @param disembarkData Additional data that might be required by a specific protocol to withdraw funds
     */
    function disembark(uint256 amount, bytes calldata disembarkData) external;

    /**
     * @notice Moves tokens from one ark to another
     * @param amount The amount of tokens to move
     * @param receiver The address of the Ark the funds will be boarded to
     * @param boardData Additional data that might be required by a specific protocol to board funds
     * @param disembarkData Additional data that might be required by a specific protocol to disembark funds
     */
    function move(
        uint256 amount,
        address receiver,
        bytes calldata boardData,
        bytes calldata disembarkData
    ) external;

    /**
     * @notice Internal function to get the total assets that are withdrawable
     * @return uint256 The total assets that are withdrawable
     * @dev _withdrawableTotalAssets is an internal function that should be implemented by derived contracts to define
     * specific withdrawability logic
     * @dev the ark is withdrawable if it doesnt require keeper data and _isWithdrawable returns true
     */
    function withdrawableTotalAssets() external view returns (uint256);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IArkAccessManaged
 * @notice Extends the ProtocolAccessManaged contract with Ark specific AccessControl
 *         Used to specifically tie one FleetCommander to each Ark
 *
 * @dev One Ark specific role is defined:
 *   - Commander: is the fleet commander contract itself and couples an
 *        Ark to specific Fleet Commander
 *
 *   The Commander role is still declared on the access manager to centralise
 *   role definitions.
 */
interface IArkAccessManaged {}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IArkConfigProviderErrors} from "../errors/IArkConfigProviderErrors.sol";
import {IArkAccessManaged} from "./IArkAccessManaged.sol";

import {IArkConfigProviderEvents} from "../events/IArkConfigProviderEvents.sol";
import {ArkConfig} from "../types/ArkTypes.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Percentage} from "@summerfi/percentage-solidity/contracts/Percentage.sol";

/**
 * @title IArkConfigProvider
 * @notice Interface for configuration of Ark contracts
 * @dev Inherits from IArkAccessManaged for access control and IArkConfigProviderEvents for event definitions
 */
interface IArkConfigProvider is
    IArkAccessManaged,
    IArkConfigProviderErrors,
    IArkConfigProviderEvents
{
    /**
     * @notice Retrieves the current fleet config
     */
    function getConfig() external view returns (ArkConfig memory);

    /**
     * @dev Returns the name of the Ark.
     * @return The name of the Ark as a string.
     */
    function name() external view returns (string memory);

    /**
     * @notice Returns the details of the Ark
     * @return The details of the Ark as a string
     */
    function details() external view returns (string memory);

    /**
     * @notice Returns the deposit cap for this Ark
     * @return The maximum amount of tokens that can be deposited into the Ark
     */
    function depositCap() external view returns (uint256);

    /**
     * @notice Returns the maximum percentage of TVL that can be deposited into the Ark
     * @return The maximum percentage of TVL that can be deposited into the Ark
     */
    function maxDepositPercentageOfTVL() external view returns (Percentage);

    /**
     * @notice Returns the maximum amount that can be moved to this Ark in one rebalance
     * @return maximum amount that can be moved to this Ark in one rebalance
     */
    function maxRebalanceInflow() external view returns (uint256);

    /**
     * @notice Returns the maximum amount that can be moved from this Ark in one rebalance
     * @return maximum amount that can be moved from this Ark in one rebalance
     */
    function maxRebalanceOutflow() external view returns (uint256);

    /**
     * @notice Returns whether the Ark requires keeper data to board/disembark
     * @return true if the Ark requires keeper data, false otherwise
     */
    function requiresKeeperData() external view returns (bool);

    /**
     * @notice Returns the ERC20 token managed by this Ark
     * @return The IERC20 interface of the managed token
     */
    function asset() external view returns (IERC20);

    /**
     * @notice Returns the address of the Fleet commander managing the ark
     * @return address Address of Fleet commander managing the ark if a Commander is assigned, address(0) otherwise
     */
    function commander() external view returns (address);

    /**
     * @notice Sets a new maximum allocation for the Ark
     * @param newDepositCap The new maximum allocation amount
     */
    function setDepositCap(uint256 newDepositCap) external;

    /**
     * @notice Sets a new maximum deposit percentage of TVL for the Ark
     * @param newMaxDepositPercentageOfTVL The new maximum deposit percentage of TVL
     */
    function setMaxDepositPercentageOfTVL(
        Percentage newMaxDepositPercentageOfTVL
    ) external;

    /**
     * @notice Sets a new maximum amount that can be moved from the Ark in one rebalance
     * @param newMaxRebalanceOutflow The new maximum amount that can be moved from the Ark
     */
    function setMaxRebalanceOutflow(uint256 newMaxRebalanceOutflow) external;

    /**
     * @notice Sets a new maximum amount that can be moved to the Ark in one rebalance
     * @param newMaxRebalanceInflow The new maximum amount that can be moved to the Ark
     */
    function setMaxRebalanceInflow(uint256 newMaxRebalanceInflow) external;

    /**
     * @notice Registers the Fleet commander for the Ark
     * @dev This function is used to register the Fleet commander for the Ark
     * it's called by the FleetCommander when ark is added to the fleet
     */
    function registerFleetCommander() external;

    /**
     * @notice Unregisters the Fleet commander for the Ark
     * @dev This function is used to unregister the Fleet commander for the Ark
     * it's called by the FleetCommander when ark is removed from the fleet
     * all balance checks are done within the FleetCommander
     */
    function unregisterFleetCommander() external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IConfigurationManager} from "./IConfigurationManager.sol";

/**
 * @title IConfigurationManaged
 * @notice Interface for contracts that need to read from the ConfigurationManager
 * @dev This interface defines the standard methods for accessing configuration values
 *      from the ConfigurationManager. It should be implemented by contracts that
 *      need to read these configurations.
 */
interface IConfigurationManaged {
    /**
     * @notice Gets the address of the ConfigurationManager contract
     * @return The address of the ConfigurationManager contract
     */
    function configurationManager()
        external
        view
        returns (IConfigurationManager);

    /**
     * @notice Gets the address of the Raft contract
     * @return The address of the Raft contract
     */
    function raft() external view returns (address);

    /**
     * @notice Gets the address of the TipJar contract
     * @return The address of the TipJar contract
     */
    function tipJar() external view returns (address);

    /**
     * @notice Gets the address of the Treasury contract
     * @return The address of the Treasury contract
     */
    function treasury() external view returns (address);

    /**
     * @notice Gets the address of the HarborCommand contract
     * @return The address of the HarborCommand contract
     */
    function harborCommand() external view returns (address);

    /**
     * @notice Gets the address of the Fleet Commander Rewards Manager Factory contract
     * @return The address of the Fleet Commander Rewards Manager Factory contract
     */
    function fleetCommanderRewardsManagerFactory()
        external
        view
        returns (address);

    error ConfigurationManagerZeroAddress();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IConfigurationManagerErrors} from "../errors/IConfigurationManagerErrors.sol";
import {IConfigurationManagerEvents} from "../events/IConfigurationManagerEvents.sol";
import {ConfigurationManagerParams} from "../types/ConfigurationManagerTypes.sol";

/**
 * @title IConfigurationManager
 * @notice Interface for the ConfigurationManager contract, which manages system-wide parameters
 * @dev This interface defines the getters and setters for system-wide parameters
 */

interface IConfigurationManager is
    IConfigurationManagerEvents,
    IConfigurationManagerErrors
{
    /**
     * @notice Initialize the configuration with the given parameters
     * @param params The parameters to initialize the configuration with
     * @dev Can only be called by the governor
     */
    function initializeConfiguration(
        ConfigurationManagerParams memory params
    ) external;

    /**
     * @notice Get the address of the Raft contract
     * @return The address of the Raft contract
     * @dev This is where rewards and farmed tokens are sent for processing
     */
    function raft() external view returns (address);

    /**
     * @notice Get the current tip jar address
     * @return The current tip jar address
     * @dev This is the contract that owns tips and is responsible for
     *     dispensing them to claimants
     */
    function tipJar() external view returns (address);

    /**
     * @notice Get the current treasury address
     * @return The current treasury address
     *       @dev This is the contract that owns the treasury and is responsible for
     *      dispensing funds to the protocol's operations
     */
    function treasury() external view returns (address);

    /**
     * @notice Get the address of theHarbor command
     * @return The address of theHarbor command
     * @dev This is the contract that's the registry of all Fleet Commanders
     */
    function harborCommand() external view returns (address);

    /**
     * @notice Get the address of the Fleet Commander Rewards Manager Factory contract
     * @return The address of the Fleet Commander Rewards Manager Factory contract
     */
    function fleetCommanderRewardsManagerFactory()
        external
        view
        returns (address);

    /**
     * @notice Set a new address for the Raft contract
     * @param newRaft The new address for the Raft contract
     * @dev Can only be called by the governor
     */
    function setRaft(address newRaft) external;

    /**
     * @notice Set a new tip ar address
     * @param newTipJar The address of the new tip jar
     * @dev Can only be called by the governor
     */
    function setTipJar(address newTipJar) external;

    /**
     * @notice Set a new treasury address
     * @param newTreasury The address of the new treasury
     * @dev Can only be called by the governor
     */
    function setTreasury(address newTreasury) external;

    /**
     * @notice Set a new harbor command address
     * @param newHarborCommand The address of the new harbor command
     * @dev Can only be called by the governor
     */
    function setHarborCommand(address newHarborCommand) external;

    /**
     * @notice Set a new fleet commander rewards manager factory address
     * @param newFleetCommanderRewardsManagerFactory The address of the new fleet commander rewards manager factory
     * @dev Can only be called by the governor
     */
    function setFleetCommanderRewardsManagerFactory(
        address newFleetCommanderRewardsManagerFactory
    ) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IFleetCommanderErrors} from "../errors/IFleetCommanderErrors.sol";
import {IFleetCommanderEvents} from "../events/IFleetCommanderEvents.sol";
import {RebalanceData} from "../types/FleetCommanderTypes.sol";

import {IFleetCommanderConfigProvider} from "./IFleetCommanderConfigProvider.sol";
import {IERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {Percentage} from "@summerfi/percentage-solidity/contracts/Percentage.sol";

/**
 * @title IFleetCommander Interface
 * @notice Interface for the FleetCommander contract, which manages asset allocation across multiple Arks
 */
interface IFleetCommander is
    IERC4626,
    IFleetCommanderEvents,
    IFleetCommanderErrors,
    IFleetCommanderConfigProvider
{
    /**
     * @notice Returns the total assets that are currently withdrawable from the FleetCommander.
     * @dev If cached data is available, it will be used. Otherwise, it will be calculated on demand (and cached)
     * @return uint256 The total amount of assets that can be withdrawn.
     */
    function withdrawableTotalAssets() external view returns (uint256);

    /**
     * @notice Returns the total assets that are managed the FleetCommander.
     * @dev If cached data is available, it will be used. Otherwise, it will be calculated on demand (and cached)
     * @return uint256 The total amount of assets that can be withdrawn.
     */
    function totalAssets() external view returns (uint256);

    /**
     * @notice Returns the maximum amount of the underlying asset that can be withdrawn from the owner balance in the
     * Vault, directly from Buffer.
     * @param owner The address of the owner of the assets
     * @return uint256 The maximum amount that can be withdrawn.
     */
    function maxBufferWithdraw(address owner) external view returns (uint256);

    /**
     * @notice Returns the maximum amount of the underlying asset that can be redeemed from the owner balance in the
     * Vault, directly from Buffer.
     * @param owner The address of the owner of the assets
     * @return uint256 The maximum amount that can be redeemed.
     */
    function maxBufferRedeem(address owner) external view returns (uint256);

    /* FUNCTIONS - PUBLIC - USER */
    /**
     * @notice Deposits a specified amount of assets into the contract for a given receiver.
     * @param assets The amount of assets to be deposited.
     * @param receiver The address of the receiver who will receive the deposited assets.
     * @param referralCode An optional referral code that can be used for tracking or rewards.
     */
    function deposit(
        uint256 assets,
        address receiver,
        bytes memory referralCode
    ) external returns (uint256);

    /**
     * @notice Forces a withdrawal of assets from the FleetCommander
     * @param assets The amount of assets to forcefully withdraw
     * @param receiver The address that will receive the withdrawn assets
     * @param owner The address of the owner of the assets
     * @return shares The amount of shares redeemed
     */
    function withdrawFromArks(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256 shares);

    /**
     * @notice Withdraws a specified amount of assets from the FleetCommander
     * @dev This function first attempts to withdraw from the buffer. If the buffer doesn't have enough assets,
     *      it will withdraw from the arks. It also handles the case where the maximum possible amount is requested.
     * @param assets The amount of assets to withdraw. If set to type(uint256).max, it will withdraw the maximum
     * possible amount.
     * @param receiver The address that will receive the withdrawn assets
     * @param owner The address of the owner of the shares
     * @return shares The number of shares burned in exchange for the withdrawn assets
     */
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256 shares);

    /**
     * @notice Redeems a specified amount of shares from the FleetCommander
     * @dev This function first attempts to redeem from the buffer. If the buffer doesn't have enough assets,
     *      it will redeem from the arks. It also handles the case where the maximum possible amount is requested.
     * @param shares The number of shares to redeem. If set to type(uint256).max, it will redeem all shares owned by the
     * owner.
     * @param receiver The address that will receive the redeemed assets
     * @param owner The address of the owner of the shares
     * @return assets The amount of assets received in exchange for the redeemed shares
     */
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256 assets);

    /**
     * @notice Redeems shares for assets from the FleetCommander
     * @param shares The amount of shares to redeem
     * @param receiver  The address that will receive the assets
     * @param owner The address of the owner of the shares
     * @return assets The amount of assets forcefully withdrawn
     */
    function redeemFromArks(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256 assets);

    /**
     * @notice Redeems shares for assets directly from the Buffer
     * @param shares The amount of shares to redeem
     * @param receiver The address that will receive the assets
     * @param owner The address of the owner of the shares
     * @return assets The amount of assets redeemed
     */
    function redeemFromBuffer(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256 assets);

    /**
     * @notice Forces a withdrawal of assets directly from the Buffer
     * @param assets The amount of assets to withdraw
     * @param receiver The address that will receive the withdrawn assets
     * @param owner The address of the owner of the assets
     * @return shares The amount of shares redeemed
     */
    function withdrawFromBuffer(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256 shares);

    /**
     * @notice Accrues and distributes tips
     * @return uint256 The amount of tips accrued
     */
    function tip() external returns (uint256);

    /**
     * @notice Rebalances the assets across Arks, including buffer adjustments
     * @param data Array of RebalanceData structs
     * @dev RebalanceData struct contains:
     *      - fromArk: The address of the Ark to move assets from
     *      - toArk: The address of the Ark to move assets to
     *      - amount: The amount of assets to move
     *      - boardData: Additional data for the board operation
     *      - disembarkData: Additional data for the disembark operation
     * @dev Using type(uint256).max as the amount will move all assets from the fromArk to the toArk
     * @dev For standard rebalancing:
     *      - Operations cannot involve the buffer Ark directly
     * @dev For buffer adjustments:
     *      - type(uint256).max is only allowed when moving TO the buffer
     *      - When withdrawing FROM buffer, total amount cannot reduce balance below minFundsBufferBalance
     * @dev The number of operations in a single rebalance call is limited to MAX_REBALANCE_OPERATIONS
     * @dev Rebalance is subject to a cooldown period between calls
     * @dev Only callable by accounts with the Keeper role
     */
    function rebalance(RebalanceData[] calldata data) external;

    /* FUNCTIONS - EXTERNAL - GOVERNANCE */

    /**
     * @notice Sets a new tip rate for the FleetCommander
     * @dev Only callable by the governor
     * @dev The tip rate is set as a Percentage. Percentages use 18 decimals of precision
     *      For example, for a 5% rate, you'd pass 5 * 1e18 (5 000 000 000 000 000 000)
     * @param newTipRate The new tip rate as a Percentage
     */
    function setTipRate(Percentage newTipRate) external;

    /**
     * @notice Sets a new minimum pause time for the FleetCommander
     * @dev Only callable by the governor
     * @param newMinimumPauseTime The new minimum pause time in seconds
     */
    function setMinimumPauseTime(uint256 newMinimumPauseTime) external;

    /**
     * @notice Updates the rebalance cooldown period
     * @param newCooldown The new cooldown period in seconds
     */
    function updateRebalanceCooldown(uint256 newCooldown) external;

    /**
     * @notice Forces a rebalance operation
     * @param data Array of typed rebalance data struct
     * @dev has no cooldown enforced but only callable by privileged role
     */
    function forceRebalance(RebalanceData[] calldata data) external;

    /**
     * @notice Pauses the FleetCommander
     * @dev This function is used to pause the FleetCommander in case of critical issues or emergencies
     * @dev Only callable by the guardian or governor
     */
    function pause() external;

    /**
     * @notice Unpauses the FleetCommander
     * @dev This function is used to resume normal operations after a pause
     * @dev Only callable by the guardian or governor
     */
    function unpause() external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IFleetCommanderConfigProviderErrors} from "../errors/IFleetCommanderConfigProviderErrors.sol";

import {IFleetCommanderConfigProviderEvents} from "../events/IFleetCommanderConfigProviderEvents.sol";

import {FleetConfig} from "../types/FleetCommanderTypes.sol";
import {Percentage} from "@summerfi/percentage-solidity/contracts/Percentage.sol";

/**
 * @title IFleetCommander Interface
 * @notice Interface for the FleetCommander contract, which manages asset allocation across multiple Arks
 */
interface IFleetCommanderConfigProvider is
    IFleetCommanderConfigProviderErrors,
    IFleetCommanderConfigProviderEvents
{
    /**
     * @notice Retrieves the ark address at the specified index
     * @param index The index of the ark in the arks array
     * @return The address of the ark at the specified index
     */
    function arks(uint256 index) external view returns (address);

    /**
     * @notice Retrieves the arks currently linked to fleet (excluding the buffer ark)
     */
    function getActiveArks() external view returns (address[] memory);

    /**
     * @notice Retrieves the current fleet config
     */
    function getConfig() external view returns (FleetConfig memory);

    /**
     * @notice Retrieves the buffer ark address
     */
    function bufferArk() external view returns (address);

    /**
     * @notice Checks if the ark is part of the fleet or is the buffer ark
     * @param ark The address of the Ark
     * @return bool Returns true if the ark is active or the buffer ark, false otherwise.
     */
    function isArkActiveOrBufferArk(address ark) external view returns (bool);

    /* FUNCTIONS - EXTERNAL - GOVERNANCE */

    /**
     * @notice Adds a new Ark
     * @param ark The address of the new Ark
     */
    function addArk(address ark) external;

    /**
     * @notice Removes an existing Ark
     * @param ark The address of the Ark to remove
     */
    function removeArk(address ark) external;

    /**
     * @notice Sets a new deposit cap for Fleet
     * @param newDepositCap The new deposit cap
     */
    function setFleetDepositCap(uint256 newDepositCap) external;

    /**
     * @notice Sets a new deposit cap for an Ark
     * @param ark The address of the Ark
     * @param newDepositCap The new deposit cap
     */
    function setArkDepositCap(address ark, uint256 newDepositCap) external;

    /**
     * @notice Sets the max deposit percentage of TVL for an Ark
     * @param ark The address of the Ark
     * @param newMaxDepositPercentageOfTVL The new max deposit percentage of TVL
     */
    function setArkMaxDepositPercentageOfTVL(
        address ark,
        Percentage newMaxDepositPercentageOfTVL
    ) external;

    /**
     * @dev Sets the minimum buffer balance for the fleet commander.
     * @param newMinimumBalance The new minimum buffer balance to be set.
     */
    function setMinimumBufferBalance(uint256 newMinimumBalance) external;

    /**
     * @dev Sets the minimum number of allowe rebalance operations.
     * @param newMaxRebalanceOperations The new maximum allowed rebalance operations.
     */
    function setMaxRebalanceOperations(
        uint256 newMaxRebalanceOperations
    ) external;

    /**
     * @notice Sets the maxRebalanceOutflow for an Ark
     * @dev Only callable by the governor
     * @param ark The address of the Ark
     * @param newMaxRebalanceOutflow The new maxRebalanceOutflow value
     */
    function setArkMaxRebalanceOutflow(
        address ark,
        uint256 newMaxRebalanceOutflow
    ) external;

    /**
     * @notice Sets the maxRebalanceInflow for an Ark
     * @dev Only callable by the governor
     * @param ark The address of the Ark
     * @param newMaxRebalanceInflow The new maxRebalanceInflow value
     */
    function setArkMaxRebalanceInflow(
        address ark,
        uint256 newMaxRebalanceInflow
    ) external;

    /**
     * @notice Deploys and sets the staking rewards manager contract address
     */
    function updateStakingRewardsManager() external;

    /**
     * @notice Enables or disables transfers of fleet commander shares
     * @dev Only callable by the governor when not paused
     */
    function setFleetTokenTransferability() external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IStakingRewardsManagerBase} from "@summerfi/rewards-contracts/interfaces/IStakingRewardsManagerBase.sol";

/**
 * @title IFleetCommanderRewardsManager
 * @notice Interface for the FleetStakingRewardsManager contract
 * @dev Extends IStakingRewardsManagerBase with Fleet-specific functionality
 */
interface IFleetCommanderRewardsManager is IStakingRewardsManagerBase {
    /**
     * @notice Returns the address of the FleetCommander contract
     * @return The address of the FleetCommander
     */
    function fleetCommander() external view returns (address);

    /**
     * @notice Thrown when a non-AdmiralsQuarters contract tries
     * to unstake on behalf
     */
    error CallerNotAdmiralsQuarters();

    /**
     * @notice Thrown when AdmiralsQuarters tries to unstake for
     * someone other than msg.sender
     */
    error InvalidUnstakeRecipient();

    /* @notice Thrown when trying to add a staking token as a reward token */
    error CantAddStakingTokenAsReward();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IHarborCommandErrors} from "../errors/IHarborCommandErrors.sol";

/**
 * @title IHarborCommand
 * @notice Interface for the HarborCommand contract which manages FleetCommanders and TipJar
 * @dev This interface defines the external functions and events for HarborCommand
 */
interface IHarborCommand is IHarborCommandErrors {
    /**
     * @notice Enlists a new FleetCommander
     * @dev Only callable by the governor
     * @param _fleetCommander The address of the FleetCommander to enlist
     * @custom:error FleetCommanderAlreadyEnlisted Thrown if the FleetCommander is already enlisted
     */
    function enlistFleetCommander(address _fleetCommander) external;

    /**
     * @notice Decommissions an enlisted FleetCommander
     * @dev Only callable by the governor
     * @param _fleetCommander The address of the FleetCommander to decommission
     * @custom:error FleetCommanderNotEnlisted Thrown if the FleetCommander is not enlisted
     */
    function decommissionFleetCommander(address _fleetCommander) external;

    /**
     * @notice Retrieves the list of active FleetCommanders
     * @return An array of addresses representing the active FleetCommanders
     */
    function getActiveFleetCommanders()
        external
        view
        returns (address[] memory);

    /**
     * @notice Checks if a FleetCommander is currently active
     * @param _fleetCommander The address of the FleetCommander to check
     * @return bool True if the FleetCommander is active, false otherwise
     */
    function activeFleetCommanders(
        address _fleetCommander
    ) external view returns (bool);

    /**
     * @notice Retrieves the FleetCommander at a specific index in the list
     * @param index The index in the list of FleetCommanders
     * @return The address of the FleetCommander at the specified index
     */
    function fleetCommandersList(uint256 index) external view returns (address);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.15;

library DataTypes {
    struct ReserveData {
        //stores the reserve configuration
        ReserveConfigurationMap configuration;
        //the liquidity index. Expressed in ray
        uint128 liquidityIndex;
        //the current supply rate. Expressed in ray
        uint128 currentLiquidityRate;
        //variable borrow index. Expressed in ray
        uint128 variableBorrowIndex;
        //the current variable borrow rate. Expressed in ray
        uint128 currentVariableBorrowRate;
        //the current stable borrow rate. Expressed in ray
        uint128 currentStableBorrowRate;
        //timestamp of last update
        uint40 lastUpdateTimestamp;
        //the id of the reserve. Represents the position in the list of the active reserves
        uint16 id;
        //aToken address
        address aTokenAddress;
        //stableDebtToken address
        address stableDebtTokenAddress;
        //variableDebtToken address
        address variableDebtTokenAddress;
        //address of the interest rate strategy
        address interestRateStrategyAddress;
        //the current treasury balance, scaled
        uint128 accruedToTreasury;
        //the outstanding unbacked aTokens minted through the bridging feature
        uint128 unbacked;
        //the outstanding debt borrowed against this asset in isolation mode
        uint128 isolationModeTotalDebt;
    }

    struct ReserveConfigurationMap {
        //bit 0-15: LTV
        //bit 16-31: Liq. threshold
        //bit 32-47: Liq. bonus
        //bit 48-55: Decimals
        //bit 56: reserve is active
        //bit 57: reserve is frozen
        //bit 58: borrowing is enabled
        //bit 59: stable rate borrowing enabled
        //bit 60: asset is paused
        //bit 61: borrowing in isolation mode is enabled
        //bit 62-63: reserved
        //bit 64-79: reserve factor
        //bit 80-115 borrow cap in whole tokens, borrowCap == 0 => no cap
        //bit 116-151 supply cap in whole tokens, supplyCap == 0 => no cap
        //bit 152-167 liquidation protocol fee
        //bit 168-175 eMode category
        //bit 176-211 unbacked mint cap in whole tokens, unbackedMintCap == 0 => minting disabled
        //bit 212-251 debt ceiling for isolation mode with (ReserveConfiguration::DEBT_CEILING_DECIMALS) decimals
        //bit 252-255 unused
        uint256 data;
    }

    struct UserConfigurationMap {
        /**
         * @dev Bitmap of the users collaterals and borrows. It is divided in pairs of bits, one pair per asset.
         * The first bit indicates if an asset is used as collateral by the user, the second whether an
         * asset is borrowed by the user.
         */
        uint256 data;
    }

    struct EModeCategory {
        // each eMode category has a custom ltv and liquidation threshold
        uint16 ltv;
        uint16 liquidationThreshold;
        uint16 liquidationBonus;
        // each eMode category may or may not have a custom oracle to override the individual assets price oracles
        address priceSource;
        string label;
    }

    enum InterestRateMode {
        NONE,
        STABLE,
        VARIABLE
    }

    struct ReserveCache {
        uint256 currScaledVariableDebt;
        uint256 nextScaledVariableDebt;
        uint256 currPrincipalStableDebt;
        uint256 currAvgStableBorrowRate;
        uint256 currTotalStableDebt;
        uint256 nextAvgStableBorrowRate;
        uint256 nextTotalStableDebt;
        uint256 currLiquidityIndex;
        uint256 nextLiquidityIndex;
        uint256 currVariableBorrowIndex;
        uint256 nextVariableBorrowIndex;
        uint256 currLiquidityRate;
        uint256 currVariableBorrowRate;
        uint256 reserveFactor;
        ReserveConfigurationMap reserveConfiguration;
        address aTokenAddress;
        address stableDebtTokenAddress;
        address variableDebtTokenAddress;
        uint40 reserveLastUpdateTimestamp;
        uint40 stableDebtLastUpdateTimestamp;
    }

    struct ExecuteLiquidationCallParams {
        uint256 reservesCount;
        uint256 debtToCover;
        address collateralAsset;
        address debtAsset;
        address user;
        bool receiveAToken;
        address priceOracle;
        uint8 userEModeCategory;
        address priceOracleSentinel;
    }

    struct ExecuteSupplyParams {
        address asset;
        uint256 amount;
        address onBehalfOf;
        uint16 referralCode;
    }

    struct ExecuteBorrowParams {
        address asset;
        address user;
        address onBehalfOf;
        uint256 amount;
        InterestRateMode interestRateMode;
        uint16 referralCode;
        bool releaseUnderlying;
        uint256 maxStableRateBorrowSizePercent;
        uint256 reservesCount;
        address oracle;
        uint8 userEModeCategory;
        address priceOracleSentinel;
    }

    struct ExecuteRepayParams {
        address asset;
        uint256 amount;
        InterestRateMode interestRateMode;
        address onBehalfOf;
        bool useATokens;
    }

    struct ExecuteWithdrawParams {
        address asset;
        uint256 amount;
        address to;
        uint256 reservesCount;
        address oracle;
        uint8 userEModeCategory;
    }

    struct ExecuteSetUserEModeParams {
        uint256 reservesCount;
        address oracle;
        uint8 categoryId;
    }

    struct FinalizeTransferParams {
        address asset;
        address from;
        address to;
        uint256 amount;
        uint256 balanceFromBefore;
        uint256 balanceToBefore;
        uint256 reservesCount;
        address oracle;
        uint8 fromEModeCategory;
    }

    struct FlashloanParams {
        address receiverAddress;
        address[] assets;
        uint256[] amounts;
        uint256[] interestRateModes;
        address onBehalfOf;
        bytes params;
        uint16 referralCode;
        uint256 flashLoanPremiumToProtocol;
        uint256 flashLoanPremiumTotal;
        uint256 maxStableRateBorrowSizePercent;
        uint256 reservesCount;
        address addressesProvider;
        uint8 userEModeCategory;
        bool isAuthorizedFlashBorrower;
    }

    struct FlashloanSimpleParams {
        address receiverAddress;
        address asset;
        uint256 amount;
        bytes params;
        uint16 referralCode;
        uint256 flashLoanPremiumToProtocol;
        uint256 flashLoanPremiumTotal;
    }

    struct FlashLoanRepaymentParams {
        uint256 amount;
        uint256 totalPremium;
        uint256 flashLoanPremiumToProtocol;
        address asset;
        address receiverAddress;
        uint16 referralCode;
    }

    struct CalculateUserAccountDataParams {
        UserConfigurationMap userConfig;
        uint256 reservesCount;
        address user;
        address oracle;
        uint8 userEModeCategory;
    }

    struct ValidateBorrowParams {
        ReserveCache reserveCache;
        UserConfigurationMap userConfig;
        address asset;
        address userAddress;
        uint256 amount;
        InterestRateMode interestRateMode;
        uint256 maxStableLoanPercent;
        uint256 reservesCount;
        address oracle;
        uint8 userEModeCategory;
        address priceOracleSentinel;
        bool isolationModeActive;
        address isolationModeCollateralAddress;
        uint256 isolationModeDebtCeiling;
    }

    struct ValidateLiquidationCallParams {
        ReserveCache debtReserveCache;
        uint256 totalDebt;
        uint256 healthFactor;
        address priceOracleSentinel;
    }

    struct CalculateInterestRatesParams {
        uint256 unbacked;
        uint256 liquidityAdded;
        uint256 liquidityTaken;
        uint256 totalStableDebt;
        uint256 totalVariableDebt;
        uint256 averageStableBorrowRate;
        uint256 reserveFactor;
        address reserve;
        address aToken;
    }

    struct InitReserveParams {
        address asset;
        address aTokenAddress;
        address stableDebtAddress;
        address variableDebtAddress;
        address interestRateStrategyAddress;
        uint16 reservesCount;
        uint16 maxNumberReserves;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IAToken is IERC20 {
    /**
     * @dev Emitted during the transfer action
     * @param from The user whose tokens are being transferred
     * @param to The recipient
     * @param value The scaled amount being transferred
     * @param index The next liquidity index of the reserve
     */
    event BalanceTransfer(
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 index
    );

    function POOL() external view returns (address);

    /**
     * @notice Mints `amount` aTokens to `user`
     * @param caller The address performing the mint
     * @param onBehalfOf The address of the user that will receive the minted aTokens
     * @param amount The amount of tokens getting minted
     * @param index The next liquidity index of the reserve
     * @return `true` if the the previous balance of the user was 0
     */
    function mint(
        address caller,
        address onBehalfOf,
        uint256 amount,
        uint256 index
    ) external returns (bool);

    /**
     * @notice Burns aTokens from `user` and sends the equivalent amount of underlying to `receiverOfUnderlying`
     * @dev In some instances, the mint event could be emitted from a burn transaction
     * if the amount to burn is less than the interest that the user accrued
     * @param from The address from which the aTokens will be burned
     * @param receiverOfUnderlying The address that will receive the underlying
     * @param amount The amount being burned
     * @param index The next liquidity index of the reserve
     */
    function burn(
        address from,
        address receiverOfUnderlying,
        uint256 amount,
        uint256 index
    ) external;

    /**
     * @notice Mints aTokens to the reserve treasury
     * @param amount The amount of tokens getting minted
     * @param index The next liquidity index of the reserve
     */
    function mintToTreasury(uint256 amount, uint256 index) external;

    /**
     * @notice Transfers aTokens in the event of a borrow being liquidated, in case the liquidators reclaims the aToken
     * @param from The address getting liquidated, current owner of the aTokens
     * @param to The recipient
     * @param value The amount of tokens getting transferred
     */
    function transferOnLiquidation(
        address from,
        address to,
        uint256 value
    ) external;

    /**
     * @notice Transfers the underlying asset to `target`.
     * @dev Used by the Pool to transfer assets in borrow(), withdraw() and flashLoan()
     * @param target The recipient of the underlying
     * @param amount The amount getting transferred
     */
    function transferUnderlyingTo(address target, uint256 amount) external;

    /**
     * @notice Handles the underlying received by the aToken after the transfer has been completed.
     * @dev The default implementation is empty as with standard ERC20 tokens, nothing needs to be done after the
     * transfer is concluded. However in the future there may be aTokens that allow for example to stake the underlying
     * to receive LM rewards. In that case, `handleRepayment()` would perform the staking of the underlying asset.
     * @param user The user executing the repayment
     * @param onBehalfOf The address of the user who will get his debt reduced/removed
     * @param amount The amount getting repaid
     */
    function handleRepayment(
        address user,
        address onBehalfOf,
        uint256 amount
    ) external;

    /**
     * @notice Allow passing a signed message to approve spending
     * @dev implements the permit function as for
     * https://github.com/ethereum/EIPs/blob/8a34d644aacf0f9f8f00815307fd7dd5da07655f/EIPS/eip-2612.md
     * @param owner The owner of the funds
     * @param spender The spender
     * @param value The amount
     * @param deadline The deadline timestamp, type(uint256).max for max deadline
     * @param v Signature param
     * @param s Signature param
     * @param r Signature param
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
     * @notice Returns the address of the underlying asset of this aToken (E.g. WETH for aWETH)
     * @return The address of the underlying asset
     */
    function UNDERLYING_ASSET_ADDRESS() external view returns (address);

    /**
     * @notice Returns the address of the Aave treasury, receiving the fees on this aToken.
     * @return Address of the Aave treasury
     */
    function RESERVE_TREASURY_ADDRESS() external view returns (address);

    /**
     * @notice Get the domain separator for the token
     * @dev Return cached value if chainId matches cache, otherwise recomputes separator
     * @return The domain separator of the token at current chain
     */
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    /**
     * @notice Returns the nonce for owner.
     * @param owner The address of the owner
     * @return The nonce of the owner
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @notice Rescue and transfer tokens locked in this contract
     * @param token The address of the token
     * @param to The address of the recipient
     * @param amount The amount of token to transfer
     */
    function rescueTokens(address token, address to, uint256 amount) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.15;

interface IPoolAddressesProvider {
    /**
     * @dev Emitted when the market identifier is updated.
     * @param oldMarketId The old id of the market
     * @param newMarketId The new id of the market
     */
    event MarketIdSet(string indexed oldMarketId, string indexed newMarketId);

    /**
     * @dev Emitted when the pool is updated.
     * @param oldAddress The old address of the Pool
     * @param newAddress The new address of the Pool
     */
    event PoolUpdated(address indexed oldAddress, address indexed newAddress);

    /**
     * @dev Emitted when the pool configurator is updated.
     * @param oldAddress The old address of the PoolConfigurator
     * @param newAddress The new address of the PoolConfigurator
     */
    event PoolConfiguratorUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    /**
     * @dev Emitted when the price oracle is updated.
     * @param oldAddress The old address of the PriceOracle
     * @param newAddress The new address of the PriceOracle
     */
    event PriceOracleUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    /**
     * @dev Emitted when the ACL manager is updated.
     * @param oldAddress The old address of the ACLManager
     * @param newAddress The new address of the ACLManager
     */
    event ACLManagerUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    /**
     * @dev Emitted when the ACL admin is updated.
     * @param oldAddress The old address of the ACLAdmin
     * @param newAddress The new address of the ACLAdmin
     */
    event ACLAdminUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    /**
     * @dev Emitted when the price oracle sentinel is updated.
     * @param oldAddress The old address of the PriceOracleSentinel
     * @param newAddress The new address of the PriceOracleSentinel
     */
    event PriceOracleSentinelUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    /**
     * @dev Emitted when the pool data provider is updated.
     * @param oldAddress The old address of the PoolDataProvider
     * @param newAddress The new address of the PoolDataProvider
     */
    event PoolDataProviderUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    /**
     * @dev Emitted when a new proxy is created.
     * @param id The identifier of the proxy
     * @param proxyAddress The address of the created proxy contract
     * @param implementationAddress The address of the implementation contract
     */
    event ProxyCreated(
        bytes32 indexed id,
        address indexed proxyAddress,
        address indexed implementationAddress
    );

    /**
     * @dev Emitted when a new non-proxied contract address is registered.
     * @param id The identifier of the contract
     * @param oldAddress The address of the old contract
     * @param newAddress The address of the new contract
     */
    event AddressSet(
        bytes32 indexed id,
        address indexed oldAddress,
        address indexed newAddress
    );

    /**
     * @dev Emitted when the implementation of the proxy registered with id is updated
     * @param id The identifier of the contract
     * @param proxyAddress The address of the proxy contract
     * @param oldImplementationAddress The address of the old implementation contract
     * @param newImplementationAddress The address of the new implementation contract
     */
    event AddressSetAsProxy(
        bytes32 indexed id,
        address indexed proxyAddress,
        address oldImplementationAddress,
        address indexed newImplementationAddress
    );

    /**
     * @notice Returns the id of the Aave market to which this contract points to.
     * @return The market id
     *
     */
    function getMarketId() external view returns (string memory);

    /**
     * @notice Associates an id with a specific PoolAddressesProvider.
     * @dev This can be used to create an onchain registry of PoolAddressesProviders to
     * identify and validate multiple Aave markets.
     * @param newMarketId The market id
     */
    function setMarketId(string calldata newMarketId) external;

    /**
     * @notice Returns an address by its identifier.
     * @dev The returned address might be an EOA or a contract, potentially proxied
     * @dev It returns ZERO if there is no registered address with the given id
     * @param id The id
     * @return The address of the registered for the specified id
     */
    function getAddress(bytes32 id) external view returns (address);

    /**
     * @notice General function to update the implementation of a proxy registered with
     * certain `id`. If there is no proxy registered, it will instantiate one and
     * set as implementation the `newImplementationAddress`.
     * @dev IMPORTANT Use this function carefully, only for ids that don't have an explicit
     * setter function, in order to avoid unexpected consequences
     * @param id The id
     * @param newImplementationAddress The address of the new implementation
     */
    function setAddressAsProxy(
        bytes32 id,
        address newImplementationAddress
    ) external;

    /**
     * @notice Sets an address for an id replacing the address saved in the addresses map.
     * @dev IMPORTANT Use this function carefully, as it will do a hard replacement
     * @param id The id
     * @param newAddress The address to set
     */
    function setAddress(bytes32 id, address newAddress) external;

    /**
     * @notice Returns the address of the Pool proxy.
     * @return The Pool proxy address
     *
     */
    function getPool() external view returns (address);

    /**
     * @notice Updates the implementation of the Pool, or creates a proxy
     * setting the new `pool` implementation when the function is called for the first time.
     * @param newPoolImpl The new Pool implementation
     *
     */
    function setPoolImpl(address newPoolImpl) external;

    /**
     * @notice Returns the address of the PoolConfigurator proxy.
     * @return The PoolConfigurator proxy address
     *
     */
    function getPoolConfigurator() external view returns (address);

    /**
     * @notice Updates the implementation of the PoolConfigurator, or creates a proxy
     * setting the new `PoolConfigurator` implementation when the function is called for the first time.
     * @param newPoolConfiguratorImpl The new PoolConfigurator implementation
     *
     */
    function setPoolConfiguratorImpl(address newPoolConfiguratorImpl) external;

    /**
     * @notice Returns the address of the price oracle.
     * @return The address of the PriceOracle
     */
    function getPriceOracle() external view returns (address);

    /**
     * @notice Updates the address of the price oracle.
     * @param newPriceOracle The address of the new PriceOracle
     */
    function setPriceOracle(address newPriceOracle) external;

    /**
     * @notice Returns the address of the ACL manager.
     * @return The address of the ACLManager
     */
    function getACLManager() external view returns (address);

    /**
     * @notice Updates the address of the ACL manager.
     * @param newAclManager The address of the new ACLManager
     *
     */
    function setACLManager(address newAclManager) external;

    /**
     * @notice Returns the address of the ACL admin.
     * @return The address of the ACL admin
     */
    function getACLAdmin() external view returns (address);

    /**
     * @notice Updates the address of the ACL admin.
     * @param newAclAdmin The address of the new ACL admin
     */
    function setACLAdmin(address newAclAdmin) external;

    /**
     * @notice Returns the address of the price oracle sentinel.
     * @return The address of the PriceOracleSentinel
     */
    function getPriceOracleSentinel() external view returns (address);

    /**
     * @notice Updates the address of the price oracle sentinel.
     * @param newPriceOracleSentinel The address of the new PriceOracleSentinel
     *
     */
    function setPriceOracleSentinel(address newPriceOracleSentinel) external;

    /**
     * @notice Returns the address of the data provider.
     * @return The address of the DataProvider
     */
    function getPoolDataProvider() external view returns (address);

    /**
     * @notice Updates the address of the data provider.
     * @param newDataProvider The address of the new DataProvider
     *
     */
    function setPoolDataProvider(address newDataProvider) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.15;

import {DataTypes} from "./DataTypes.sol";
import {IPoolAddressesProvider} from "./IPoolAddressesProvider.sol";

interface IPoolV3 {
    /**
     * @dev Emitted on supply()
     * @param reserve The address of the underlying asset of the reserve
     * @param user The address initiating the supply
     * @param onBehalfOf The beneficiary of the supply, receiving the aTokens
     * @param amount The amount supplied
     * @param referralCode The referral code used
     */
    event Supply(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        uint256 amount,
        uint16 indexed referralCode
    );

    /**
     * @notice Supplies an `amount` of underlying asset into the reserve, receiving in return overlying aTokens.
     * - E.g. User supplies 100 USDC and gets in return 100 aUSDC
     * @param asset The address of the underlying asset to supply
     * @param amount The amount to be supplied
     * @param onBehalfOf The address that will receive the aTokens, same as msg.sender if the user
     *   wants to receive them on his own wallet, or a different address if the beneficiary of aTokens
     *   is a different wallet
     * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
     *   0 if the action is executed directly by the user, without any middle-man
     *
     */
    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    /**
     * @notice Withdraws an `amount` of underlying asset from the reserve, burning the equivalent aTokens owned
     * E.g. User has 100 aUSDC, calls withdraw() and receives 100 USDC, burning the 100 aUSDC
     * @param asset The address of the underlying asset to withdraw
     * @param amount The underlying amount to be withdrawn
     *   - Send the value type(uint256).max in order to withdraw the whole aToken balance
     * @param to The address that will receive the underlying, same as msg.sender if the user
     *   wants to receive it on his own wallet, or a different address if the beneficiary is a
     *   different wallet
     * @return The final amount withdrawn
     *
     */
    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);

    /**
     * @notice Returns the PoolAddressesProvider connected to this contract
     * @return The address of the PoolAddressesProvider
     */
    function ADDRESSES_PROVIDER()
        external
        view
        returns (IPoolAddressesProvider);

    /**
     * @notice Returns the state and configuration of the reserve
     * @param asset The address of the underlying asset of the reserve
     * @return The state and configuration data of the reserve
     */
    function getReserveData(
        address asset
    ) external view returns (DataTypes.ReserveData memory);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

interface IComet {
    event Supply(address indexed from, address indexed dst, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Withdraw(address indexed src, address indexed to, uint256 amount);

    event SupplyCollateral(
        address indexed from,
        address indexed dst,
        address indexed asset,
        uint256 amount
    );
    event TransferCollateral(
        address indexed from,
        address indexed to,
        address indexed asset,
        uint256 amount
    );
    event WithdrawCollateral(
        address indexed src,
        address indexed to,
        address indexed asset,
        uint256 amount
    );

    /// @notice Event emitted when a borrow position is absorbed by the protocol
    event AbsorbDebt(
        address indexed absorber,
        address indexed borrower,
        uint256 basePaidOut,
        uint256 usdValue
    );

    /// @notice Event emitted when a user's collateral is absorbed by the protocol
    event AbsorbCollateral(
        address indexed absorber,
        address indexed borrower,
        address indexed asset,
        uint256 collateralAbsorbed,
        uint256 usdValue
    );

    /// @notice Event emitted when a collateral asset is purchased from the protocol
    event BuyCollateral(
        address indexed buyer,
        address indexed asset,
        uint256 baseAmount,
        uint256 collateralAmount
    );

    /// @notice Event emitted when an action is paused/unpaused
    event PauseAction(
        bool supplyPaused,
        bool transferPaused,
        bool withdrawPaused,
        bool absorbPaused,
        bool buyPaused
    );

    /// @notice Event emitted when reserves are withdrawn by the governor
    event WithdrawReserves(address indexed to, uint256 amount);

    function allow(address spender, bool isAllowed) external;

    function borrowBalanceOf(address account) external view returns (uint256);

    function supply(address asset, uint256 amount) external;

    function withdraw(address asset, uint256 amount) external;

    function withdrawFrom(
        address from,
        address to,
        address asset,
        uint256 amount
    ) external;

    function getSupplyRate(uint256 utilization) external view returns (uint64);

    function getUtilization() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function baseToken() external view returns (address);

    function hasPermission(
        address owner,
        address manager
    ) external view returns (bool);

    function isWithdrawPaused() external view returns (bool);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
    function balanceOf(address) external view returns (uint256);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Percentage} from "@summerfi/percentage-solidity/contracts/Percentage.sol";

/**
 * @title ArkParams
 * @notice Constructor parameters for the Ark contract
 *
 *  @dev This struct is used to initialize an Ark contract with all necessary parameters
 */
struct ArkParams {
    /**
     * @notice The name of the Ark
     * @dev This should be a unique, human-readable identifier for the Ark
     */
    string name;
    /**
     * @notice Additional details about the Ark
     * @dev This can be used to store additional information about the Ark
     */
    string details;
    /**
     * @notice The address of the access manager contract
     * @dev This contract manages roles and permissions for the Ark
     */
    address accessManager;
    /**
     * @notice The address of the configuration manager contract
     * @dev This contract stores global configuration parameters
     */
    address configurationManager;
    /**
     * @notice The address of the ERC20 token managed by this Ark
     * @dev This is the underlying asset that the Ark will handle
     */
    address asset;
    /**
     * @notice The maximum amount of tokens that can be deposited into the Ark
     * @dev This cap helps to manage risk and exposure
     */
    uint256 depositCap;
    /**
     * @notice The maximum amount of tokens that can be moved from this Ark in a single transaction
     * @dev This limit helps to prevent large, sudden outflows
     */
    uint256 maxRebalanceOutflow;
    /**
     * @notice The maximum amount of tokens that can be moved to this Ark in a single transaction
     * @dev This limit helps to prevent large, sudden inflows
     */
    uint256 maxRebalanceInflow;
    /**
     * @notice Whether the Ark requires Keepr data to be passed in with rebalance transactions
     * @dev This flag is used to determine whether Keepr data is required for rebalance transactions
     */
    bool requiresKeeperData;
    /**
     * @notice The maximum percentage of Total Value Locked (TVL) that can be deposited into this Ark
     * @dev This value is represented as a percentage with 18 decimal places (1e18 = 100%)
     *      For example, 0.5e18 represents 50% of TVL
     */
    Percentage maxDepositPercentageOfTVL;
}

/**
 * @title ArkConfig
 * @notice Configuration of the Ark contract
 * @dev This struct stores the current configuration of an Ark, which can be updated during its lifecycle
 */
struct ArkConfig {
    /**
     * @notice The address of the commander (typically a FleetCommander contract)
     * @dev The commander has special permissions to manage the Ark
     */
    address commander;
    /**
     * @notice The address of the associated Raft contract
     * @dev The Raft contract handles reward distribution and other protocol-wide functions
     */
    address raft;
    /**
     * @notice The ERC20 token interface for the asset managed by this Ark
     * @dev This allows direct interaction with the token contract
     */
    IERC20 asset;
    /**
     * @notice The current maximum amount of tokens that can be deposited into the Ark
     * @dev This can be adjusted by the commander to manage capacity
     */
    uint256 depositCap;
    /**
     * @notice The current maximum amount of tokens that can be moved from this Ark in a single transaction
     * @dev This can be adjusted to manage liquidity and risk
     */
    uint256 maxRebalanceOutflow;
    /**
     * @notice The current maximum amount of tokens that can be moved to this Ark in a single transaction
     * @dev This can be adjusted to manage inflows and capacity
     */
    uint256 maxRebalanceInflow;
    /**
     * @notice The name of the Ark
     * @dev This is typically set at initialization and not changed
     */
    string name;
    /**
     * @notice Additional details about the Ark
     * @dev This can be used to store additional information about the Ark
     */
    string details;
    /**
     * @notice Whether the Ark requires Keeper data to be passed in with rebalance transactions
     * @dev This flag is used to determine whether Keeper data is required for rebalance transactions
     */
    bool requiresKeeperData;
    /**
     * @notice The maximum percentage of Total Value Locked (TVL) that can be deposited into this Ark
     * @dev This value is represented as a percentage with 18 decimal places (1e18 = 100%)
     *      For example, 0.5e18 represents 50% of TVL
     */
    Percentage maxDepositPercentageOfTVL;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @notice Initialization parameters for the ConfigurationManager contract
 */
struct ConfigurationManagerParams {
    address raft;
    address tipJar;
    address treasury;
    address harborCommand;
    address fleetCommanderRewardsManagerFactory;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IArk} from "../interfaces/IArk.sol";

import {IFleetCommanderRewardsManager} from "../interfaces/IFleetCommanderRewardsManager.sol";
import {Percentage} from "@summerfi/percentage-solidity/contracts/Percentage.sol";

/**
 * @notice Configuration parameters for the FleetCommander contract
 */
struct FleetCommanderParams {
    string name;
    string details;
    string symbol;
    address configurationManager;
    address accessManager;
    address asset;
    uint256 initialMinimumBufferBalance;
    uint256 initialRebalanceCooldown;
    uint256 depositCap;
    Percentage initialTipRate;
}

/**
 * @title FleetConfig
 * @notice Configuration parameters for the FleetCommander contract
 * @dev This struct encapsulates the mutable configuration settings of a FleetCommander.
 *      These parameters can be updated during the contract's lifecycle to adjust its behavior.
 */
struct FleetConfig {
    /**
     * @notice The buffer Ark associated with this FleetCommander
     * @dev This Ark is used as a temporary holding area for funds before they are allocated
     *      to other Arks or when they need to be quickly accessed for withdrawals.
     */
    IArk bufferArk;
    /**
     * @notice The minimum balance that should be maintained in the buffer Ark
     * @dev This value is used to ensure there's always a certain amount of funds readily
     *      available for withdrawals or rebalancing operations. It's denominated in the
     *      smallest unit of the underlying asset (e.g., wei for ETH).
     */
    uint256 minimumBufferBalance;
    /**
     * @notice The maximum total value of assets that can be deposited into the FleetCommander
     * @dev This cap helps manage the total assets under management and can be used to
     *      implement controlled growth strategies. It's denominated in the smallest unit
     *      of the underlying asset.
     */
    uint256 depositCap;
    /**
     * @notice The maximum number of rebalance operations in a single rebalance
     */
    uint256 maxRebalanceOperations;
    /**
     * @notice The address of the staking rewards contract
     */
    address stakingRewardsManager;
}

/**
 * @notice Data structure for the rebalance event
 * @param fromArk The address of the Ark from which assets are moved
 * @param toArk The address of the Ark to which assets are moved
 * @param amount The amount of assets being moved
 * @param boardData The data to be passed to the `board` function of the `toArk`
 * @param disembarkData The data to be passed to the `disembark` function of the `fromArk`
 * @dev if the `boardData` or `disembarkData` is not needed, it should be an empty byte array
 */
struct RebalanceData {
    address fromArk;
    address toArk;
    uint256 amount;
    bytes boardData;
    bytes disembarkData;
}

/**
 * @title ArkData
 * @dev Struct to store information about an Ark.
 * This struct holds the address of the Ark and the total assets it holds.
 * @dev used in the caching mechanism for the FleetCommander
 */
struct ArkData {
    /// @notice The address of the Ark.
    address arkAddress;
    /// @notice The total assets held by the Ark.
    uint256 totalAssets;
}