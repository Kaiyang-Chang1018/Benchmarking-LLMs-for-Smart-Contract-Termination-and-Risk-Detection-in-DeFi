/* SPDX-License-Identifier: Custom-License
*This contract is property of Destrier LLC. You are granted permission to use all functions of this contract intended for users. 
*However, copying, modifying, or distributing the code is strictly prohibited without explicit permission from the author.
*All rights reserved. Destrier LLC, registration number 20241316871 , Colorado , USA.*/

// File: contracts/SharedStructs.sol

pragma solidity ^0.8.0;
library SharedStructs {
    enum AssetType { Nickelium }
    enum PaymentMethod { Ether, USDT, USDC }

    struct Order {
        uint256 orderID;
        address payable user;
        uint256 price;
        uint256 amount;
        uint256 fulfilledAmount;
        AssetType assetType;
        PaymentMethod priceCurrency;
        bool authorizedBuyersOnly;
    }
}

// File: contracts/IEscrowHandler.sol


pragma solidity ^0.8.0;

interface IEscrowHandler {
    function escrowBalances(address user, SharedStructs.PaymentMethod paymentMethod) external view returns (uint256);
    function assetBalances(address user, uint256 assetType) external view returns (uint256);
    function updateEscrowBalance(address user, SharedStructs.PaymentMethod method, uint256 cost, bool increase) external payable;
    function getEscrowBalance(address user, SharedStructs.PaymentMethod method) external view returns (uint256) ;
    function getBuyOrdersEther() external view returns (SharedStructs.Order[] memory);
    function getBuyOrdersUSDT() external view returns (SharedStructs.Order[] memory);
    function getSellOrdersEther() external view returns (SharedStructs.Order[] memory);
    function getSellOrdersUSDT() external view returns (SharedStructs.Order[] memory);
    function getAssetBalance(address user, SharedStructs.AssetType assetType) external view returns (uint256);
    function setAssetBalance(address _user, SharedStructs.AssetType _assetType, uint256 _amount) external;
    function setEscrowBalance(address _user, SharedStructs.PaymentMethod _paymentMethod, uint256 _amount) external;
    function sellOrdersEtherLength() external view returns (uint);
    function sellOrdersUSDTLength() external view returns (uint);
    function buyOrdersEtherLength() external view returns (uint);
    function buyOrdersUSDTLength() external view returns (uint);
    function getSellOrdersEther(uint index) external view returns (SharedStructs.Order memory);
    function getSellOrdersUSDT(uint index) external view returns (SharedStructs.Order memory);
    function getBuyOrdersEther(uint index) external view returns (SharedStructs.Order memory);
    function getBuyOrdersUSDT(uint index) external view returns (SharedStructs.Order memory);
    function getHighestBuyOrderEther() external view returns (SharedStructs.Order memory);
    function getLowestSellOrderEther() external view returns (SharedStructs.Order memory);
    function getHighestBuyOrderUSDT() external view returns (SharedStructs.Order memory);
    function getLowestSellOrderUSDT() external view returns (SharedStructs.Order memory);
    function removeBuyOrderEther(uint256 index) external;
    function removeSellOrderEther(uint256 index) external;
    function removeBuyOrderUSDT(uint256 index) external;
    function removeSellOrderUSDT(uint256 index) external;
    function userRemoveOrder(uint256 orderID) external;
    function addBuyOrder(uint256 _orderID, address buyer, uint256 _price, uint256 _amount, SharedStructs.AssetType _assetType, SharedStructs.PaymentMethod _priceCurrency, bool authorizedBuyersOnly) external;
    function addSellOrder(uint256 _orderID, address seller, uint256 _price, uint256 _amount, SharedStructs.AssetType _assetType, SharedStructs.PaymentMethod _priceCurrency, bool authorizedBuyersOnly) external;
    function transferFromAsset(address seller, address payable buyer, uint256 amount) external;
    function changeBuyOrderPriceEther(address buyer, uint256 orderID, uint256 newPrice) external payable;
    function changeBuyOrderPriceUSDT(address buyer, uint256 orderID, uint256 newPrice) external;
    function changeSellOrderPriceEther(address seller, uint256 orderID, uint256 newPrice) external;
    function changeSellOrderPriceUSDT(address seller, uint256 orderID, uint256 newPrice) external;
    function setContracts( address _USDTAddress, address _nickeliumAddress, address _adminControl, address _customMultisig, address _facade) external;
    function approveUSDT(address adminControlAddress, uint256 transferAmount) external;
    function approveUSDC(address adminControlAddress, uint256 transferAmount) external;
    function updateOrderAmount(uint256 index, uint256 newAmount, bool isBuyOrder, bool isEther) external;
    function pause() external;
    function unpause() external;
}
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: contracts/ICentral.sol

pragma solidity ^0.8.0;


interface ICentral is IERC20 {
  function approveToken(address user, address spender, uint256 amount) external returns (bool);
  function setAuthorizedBuyer(address buyer, bool _status) external;
  function isAuthorizedBuyer(address buyer) external view returns (bool);
  function transferFromUser(address from, address to, uint256 amount) external returns (bool);
  function sendEther(address payable recipient) external payable;
  function releaseEther(address payable seller, uint amount) external;
  function revertEther(address sender, uint amount) external;
  function transfer(address _to, uint256 _value) external override returns (bool);
  function getNextOrderID() external returns (uint256);
  function setContracts( address _USDTAddress, address _escrowHandler, address _adminControl, address _balancesContract, address _multisig) external;
   function decimals() external view returns (uint8);
    function addNickeliumToStock(uint256 amountGrams) external;
    function getAvailableNickeliumStock() external returns(uint);
    function getContractBalanceEther() external view returns (uint);
    function placeBuyOrderEther(address buyer, uint256 _price, uint256 _amount) external payable ;
    function placeBuyOrderUSDT(address buyer, uint256 _price, uint256 _amount)  external ;
    function placeBuyOrderUSDC(address buyer, uint256 _price, uint256 _amount) external;
    function placeSellOrderEther(address seller, uint256 _price, uint256 _amount) external ;
    function placeSellOrderUSDT(address seller, uint256 _price, uint256 _amount) external ;
    function placeSellOrderUSDC(address seller, uint256 _price, uint256 _amount) external;
    function getEtherBalance(address account) external view returns (uint);
    function checkNickeliumBalance(address account) external view returns (uint256);
    function transferFromContract(address recipient, uint256 amount) external;
    function totalNickeliumInStock() external view returns (uint256);
        
}

// File: contracts/IAdminControl.sol
pragma solidity ^0.8.0;

interface IAdminControl {
    function matchOrders() external;
    function adminControl(address _user) external;
    function userRemoveOrder(address sender, uint256 orderID) external; 
    function pause() external ;
    function unpause() external;
    function setContracts( address _escrowHandler, address _USDTAddress, address _nickeliumAddress, address _multisig, address _facade ) external;

}
// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol


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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;





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

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: contracts/IUSDCorders.sol


pragma solidity ^0.8.0;


interface IUSDCorders {
    // View Functions
    function getBuyOrdersUSDC() external view returns (SharedStructs.Order[] memory);
    function getSellOrdersUSDC() external view returns (SharedStructs.Order[] memory);
    function sellOrdersUSDCLength() external view returns (uint);
    function buyOrdersUSDCLength() external view returns (uint);
    function getSellOrdersUSDC(uint index) external view returns (SharedStructs.Order memory);
    function getBuyOrdersUSDC(uint index) external view returns (SharedStructs.Order memory);
    function getHighestBuyOrderUSDC() external view returns (SharedStructs.Order memory);
    function getLowestSellOrderUSDC() external view returns (SharedStructs.Order memory);

    // State-modifying Functions
    function setAuthorizedAddress(address _address, bool _status) external;
    function setContracts(
        address _USDCAddress,
        address _nickeliumAddress,
        address _adminControl,
        address _escrowHandler,
        address _facade
    ) external;
    
    function approveUSDC(address adminControlAddress, uint256 transferAmount) external;

    function addBuyOrder(
        uint256 _orderID,
        address buyer,
        uint256 _price,
        uint256 _amount,
        SharedStructs.AssetType _assetType,
        SharedStructs.PaymentMethod _priceCurrency,
        bool authorizedBuyersOnly
    ) external;

    function addSellOrder(
        uint256 _orderID,
        address seller,
        uint256 _price,
        uint256 _amount,
        SharedStructs.AssetType _assetType,
        SharedStructs.PaymentMethod _priceCurrency,
        bool authorizedBuyersOnly
    ) external;

    function removeBuyOrderUSDC(uint256 index) external;
    function removeSellOrderUSDC(uint256 index) external;

    function changeBuyOrderPriceUSDC(address buyer, uint256 orderID, uint256 newPrice) external;
    function changeSellOrderPriceUSDC(address seller, uint256 orderID, uint256 newPrice) external;

    function updateOrderAmount(uint256 index, uint256 newAmount, bool isBuyOrder, bool isUSDC) external;

    function pause() external;
    function unpause() external;
}

// File: contracts/IBalances.sol


pragma solidity ^0.8.0;

interface IBalances {
    // Function to set an authorized address
    function setAuthorizedAddress(address _address, bool _status) external;

    // Function to update the balance of a user
    function updateBalance(address user, uint256 balance) external;

    // Function to set the balance directly
    function setBalance(address user, uint256 balance) external;

    // Function to migrate balances to a new contract
    function migrateBalances(address newContract) external;

    // Function to get all balances
    function getAllBalances() external view returns (address[] memory, uint256[] memory);

    // Function to get all user balances
    function getAllUserBalances() external view returns (address[] memory, uint256[] memory);

    // Function to get the balance of a specific user
    function getBalance(address user) external view returns (uint256);

    function setAuthorizedBuyerBackup(address buyer, bool _status) external;

    function getAuthorizedBuyersCount() external view returns (uint256);

    function getAuthorizedBuyerAtIndex(uint256 index) external view returns (address);

    function isAuthorizedBuyer(address buyer) external view returns (bool);

    // Function to pause the contract
    function pause() external;

    // Function to unpause the contract
    function unpause() external;
}

// File: contracts/Nickelium.sol

pragma solidity ^0.8.0;


contract Nickelium is ERC20 ,ReentrancyGuard, Pausable{
     mapping(address => bool) public authorizedAddresses;
     mapping(address => bool) public priceChanger;
     uint256 public LMEprice;
    ICentral public central;
    IEscrowHandler public escrowHandler;
    ICentral public iCentral;
    IAdminControl public adminControlContract;
    IERC20 public USDTContract;
    address public usdtContractAddress;
    address public admin;
    IERC20 public USDCContract;
    address public usdcContractAddress;
    IUSDCorders public usdcOrders;
    IBalances public balancesContract;
     mapping (address => mapping (address => uint256)) private _allowances;
  // Declare the owner state variable
    address public owner;
    uint256 public TokenUnitsStock; // Total units in stock
    uint256 public totalNickeliumInStock; // Total Nickelium in stock in grams
    
    
    constructor() ERC20("Nickelium", "NCL") {
        
        admin = msg.sender;
        authorizedAddresses[msg.sender] = true;
        priceChanger[msg.sender] = true;
          // Total amount of Nickelium in stock in grams
 totalNickeliumInStock = 11715938000; // 11715.9384 tons = 11715938000 grams

        // Initialize total wei in stock
    TokenUnitsStock = totalNickeliumInStock * 1000 / 100 ; // Total wei that the stock can produce
    }

    // decimals of Nickelium
    function decimals() public view virtual override(ERC20 ) returns (uint8) {
        return 3;
    }

    function setOwner(address newOwner) public onlyAuthorized {
        owner = newOwner;
    }

     // Function to allow only authorized users to update the suggested price
    function update_LME_price(uint256 _newPrice) public onlyPriceChanger {
        LMEprice = _newPrice;
    }

    // Function to read the suggested price - this will be visible on the Read tab in Etherscan
    function Daily_LME_Price() public view returns (uint256) {
        return LMEprice;
    }

    modifier onlyAuthorized() {
        require(authorizedAddresses[msg.sender], "Not authorized");
        _;
    }

    modifier onlyPriceChanger() {
        require(priceChanger[msg.sender], "Not authorized");
        _;
    }

    function setAuthorizedAddress(address _address, bool _status) public onlyAuthorized nonReentrant whenNotPaused {
        authorizedAddresses[_address] = _status;
    }

    function setPriceChanger(address _address, bool _status) public onlyAuthorized nonReentrant whenNotPaused {
        priceChanger[_address] = _status;
    }

    function setContracts(
        address _centralAddress,
        address _escrowHandlerAddress,
        address _adminControlAddress,
        address _usdtAddress,
        address _usdcAddress,
        address _usdcOrdersAddress,
        address _balancesContract
    ) public onlyAuthorized nonReentrant whenNotPaused {
        // Set Nickelium and its interface
        address payable payableCentralAddress = payable(_centralAddress);
        central = ICentral(payableCentralAddress);
        iCentral = ICentral(_centralAddress);

        // Set EscrowHandler
        escrowHandler = IEscrowHandler(_escrowHandlerAddress);

        // Set AdminControl
        adminControlContract = IAdminControl(_adminControlAddress);

        // Set USDTContract and address
        USDTContract = IERC20(_usdtAddress);
        usdtContractAddress = _usdtAddress;

        // Set USDCContract and address
    USDCContract = IERC20(_usdcAddress);  
    usdcContractAddress = _usdcAddress;   

    // Setting USDC Orders Contract
        usdcOrders = IUSDCorders(_usdcOrdersAddress);

        // Setting Balances Contract
        balancesContract = IBalances(_balancesContract);
    }

    // Fallback function to handle incoming Ether
    fallback() external payable {
        // Log an event or update state as needed
        emit EtherReceived(msg.sender, msg.value);
    }
     event EtherReceived(address indexed sender, uint256 amount);

     // add Nickelium  to stock in grams
  function addNickeliumToStock(uint256 amountGrams) public onlyAuthorized nonReentrant whenNotPaused {
   
    totalNickeliumInStock += amountGrams;

    // Update TokenUnitsStock based on the added Nickelium
    uint256 TokenUnits = amountGrams * 1e3 / 100 ;
    TokenUnitsStock += TokenUnits;
}
     
     function migrateBalances() public onlyAuthorized nonReentrant whenNotPaused {
        (address[] memory users, uint256[] memory userBalances) = balancesContract.getAllBalances();
        for (uint256 i = 0; i < users.length; i++) {
            mint(users[i], userBalances[i]);
        }
    }

    function mint(address account, uint256 TokenUnits) public onlyAuthorized nonReentrant whenNotPaused  {
    
    require(TokenUnitsStock >= TokenUnits, "Not enough wei in stock to mint coins");

       // Decrease the total wei in stock
    TokenUnitsStock -= TokenUnits;

    // Decrease the total Nickelium in stock based on the amount of coins being minted
    uint256 amountGrams = TokenUnits * 100 / 1e3; // Convert wei to grams (1 coin = 100 grams)
    totalNickeliumInStock -= amountGrams;

   // Convert units to tokens
    uint256 TokenAmount = TokenUnits ;

    // Mint the tokens (you can replace this with your actual minting logic)
    _mint(account, TokenAmount);
// Update the balances in the Balances contract
    balancesContract.updateBalance(account, balanceOf(account));
}

   function burn(uint256 amount) public nonReentrant whenNotPaused {
    address user = msg.sender; // Ensure that only the caller can burn their own tokens
    require(balanceOf(user) >= amount, "Insufficient balance to burn");

    // Burn the tokens
    _burn(user, amount);

    // Update the balances in the Balances contract
    balancesContract.updateBalance(user, balanceOf(user));

    // Increase the total Nickelium in stock based on the amount of coins being burned
    uint256 amountGrams = (amount * 100) / 1000; // Convert tokens to grams (1 coin = 100 grams)
    totalNickeliumInStock += amountGrams;

    // Increase the total wei in stock
    TokenUnitsStock += amount;
}



    function getAvailableNickeliumStock() public view returns (uint256) {
        return totalNickeliumInStock;
    }

    function checkNickeliumBalance(address account) public view returns (uint256) {
    return balanceOf(account);
}
    
function approveToken (address user, address spender, uint256 amount) public onlyAuthorized whenNotPaused returns (bool) {
    _approve(user, spender, amount);
    return true;
}


function transfer(address _to, uint256 amount) public nonReentrant whenNotPaused override(ERC20) returns (bool) {
    bool success = super.transfer(_to, amount);
    if (success) {
        balancesContract.updateBalance(msg.sender, balanceOf(msg.sender));
        balancesContract.updateBalance(_to, balanceOf(_to));
    }
    return success;
}

// This function wraps the internal _transfer tokens function
    function transferFromContract(address recipient, uint256 amount) external onlyAuthorized whenNotPaused {
    // Ensure only the EscrowHandler can call this function
    _transfer(address(this), recipient, amount);
    // Update balances in the Balances contract
    balancesContract.updateBalance(address(this), balanceOf(address(this)));
    balancesContract.updateBalance(recipient, balanceOf(recipient));
}

    function getBuyOrdersEther() public view returns (SharedStructs.Order[] memory) {
        return escrowHandler.getBuyOrdersEther();
    }

    // Fetch sell orders in Ether for all users
    function getSellOrdersEther() public view returns (SharedStructs.Order[] memory) {
        return escrowHandler.getSellOrdersEther();
    }

    // Fetch buy orders in USDT for all users
    function getBuyOrdersUSDT() public view returns (SharedStructs.Order[] memory) {
        return escrowHandler.getBuyOrdersUSDT();
    }

    // Fetch sell orders in USDT for all users
    function getSellOrdersUSDT() public view returns (SharedStructs.Order[] memory) {
        return escrowHandler.getSellOrdersUSDT();
    }

    function getBuyOrdersUSDC() external view returns (SharedStructs.Order[] memory) {
    return usdcOrders.getBuyOrdersUSDC();
}
  
  function getSellOrdersUSDC() external view returns (SharedStructs.Order[] memory) {
    return usdcOrders.getSellOrdersUSDC();
}

   
   function placeBuyOrderEther(uint256 _price, uint256 _amount) public payable nonReentrant whenNotPaused {
    central.placeBuyOrderEther{value: msg.value}(msg.sender, _price, _amount);
    }

    
    function placeBuyOrderUSDT(uint256 _price, uint256 _amount) public nonReentrant whenNotPaused {
    uint256 tokenDecimals = 1000; // Since your token has 3 decimals, 1 token = 1000 units
    uint256 actualAmount = _amount / tokenDecimals; // Convert units to actual tokens

    uint256 totalCost = _price * actualAmount; // Calculate the total cost in USDT
   
    // Transfer the total cost from the user's balance to the escrowHandler
    USDTContract.transferFrom(msg.sender, address(escrowHandler), totalCost);
    central.placeBuyOrderUSDT(msg.sender, _price, _amount);
    }

    function placeBuyOrderUSDC(uint256 _price, uint256 _amount) public nonReentrant whenNotPaused {
    uint256 tokenDecimals = 1000; 
    uint256 actualAmount = _amount / tokenDecimals; // Convert units to actual tokens

    uint256 totalCost = _price * actualAmount; // Calculate the total cost in USDC

    // Transfer the total cost from the user's balance to the escrowHandler
    USDCContract.transferFrom(msg.sender, address(escrowHandler), totalCost);

    central.placeBuyOrderUSDC(msg.sender, _price, _amount);
}

       
    function placeSellOrderEther( uint256 _price, uint256 _amount) public nonReentrant whenNotPaused {
        require(balanceOf(msg.sender) >= _amount, "Insufficient balance for the operation");
    require(_price * _amount / _price == _amount, "Potential overflow");
    bool success = transferFrom(msg.sender, address(this), _amount);
    require(success, "Token transfer failed");
        central.placeSellOrderEther(msg.sender , _price, _amount);
    }

    
    function placeSellOrderUSDT(uint256 _price, uint256 _amount) public nonReentrant whenNotPaused {
        require(balanceOf(msg.sender) >= _amount, "Insufficient balance for the operation");
    require(_price * _amount / _price == _amount, "Potential overflow");
    bool success = transferFrom(msg.sender, address(this), _amount);
    require(success, "Token transfer failed");
        central.placeSellOrderUSDT(msg.sender, _price, _amount);
    }

    function placeSellOrderUSDC(uint256 _price, uint256 _amount) public nonReentrant whenNotPaused {
        require(balanceOf(msg.sender) >= _amount, "Insufficient balance for the operation");
    require(_price * _amount / _price == _amount, "Potential overflow");
    bool success = transferFrom(msg.sender, address(this), _amount);
    require(success, "Token transfer failed");
    central.placeSellOrderUSDC(msg.sender, _price, _amount);
}

    function RemoveOrder(uint256 orderID) public nonReentrant whenNotPaused {
        adminControlContract.userRemoveOrder(msg.sender, orderID);
    }

    function changeBuyOrderPriceEther(uint256 orderID, uint256 newPrice) public payable nonReentrant whenNotPaused {
    escrowHandler.changeBuyOrderPriceEther{value: msg.value}(msg.sender, orderID, newPrice);
    }

    function changeBuyOrderPriceUSDT(uint256 orderID, uint256 newPrice) public nonReentrant whenNotPaused {
    // Retrieve all buy orders in USDT
    SharedStructs.Order[] memory buyOrders = escrowHandler.getBuyOrdersUSDT();
    
    // Iterate through the buy orders to find the one with the matching ID
    for (uint256 i = 0; i < buyOrders.length; i++) {
        if (buyOrders[i].orderID == orderID) {
            // Ensure only the owner of the order can change the price
            require(buyOrders[i].user == msg.sender, "Only the owner can change the price");

            uint256 remainingAmount = buyOrders[i].amount;
            uint256 oldCost = buyOrders[i].price * (remainingAmount / 1000);
            uint256 newCost = newPrice * (remainingAmount / 1000);

            // Handle additional cost if the new price is higher
            if (newCost > oldCost) {
                uint256 additionalCost = newCost - oldCost;
                require(
                    USDTContract.allowance(msg.sender, address(this)) >= additionalCost,
                    "Insufficient USDT allowance for price change"
                );
                USDTContract.transferFrom(msg.sender, address(escrowHandler), additionalCost);
            }

            // Call the EscrowHandler to update the order price
            escrowHandler.changeBuyOrderPriceUSDT(msg.sender, orderID, newPrice);
            break;
        }
    }
}
           
           function changeBuyOrderPriceUSDC(uint256 orderID, uint256 newPrice) public nonReentrant whenNotPaused {
    // Retrieve all buy orders in USDT
    SharedStructs.Order[] memory buyOrders = usdcOrders.getBuyOrdersUSDC();
    
    // Iterate through the buy orders to find the one with the matching ID
    for (uint256 i = 0; i < buyOrders.length; i++) {
        if (buyOrders[i].orderID == orderID) {
            // Ensure only the owner of the order can change the price
            require(buyOrders[i].user == msg.sender, "Only the owner can change the price");

            uint256 remainingAmount = buyOrders[i].amount;
            uint256 oldCost = buyOrders[i].price * (remainingAmount / 1000);
            uint256 newCost = newPrice * (remainingAmount / 1000);

            // Handle additional cost if the new price is higher
            if (newCost > oldCost) {
                uint256 additionalCost = newCost - oldCost;
                require(
                    USDCContract.allowance(msg.sender, address(this)) >= additionalCost,
                    "Insufficient USDT allowance for price change"
                );
                USDCContract.transferFrom(msg.sender, address(escrowHandler), additionalCost);
            }

            // Call the EscrowHandler to update the order price
            usdcOrders.changeBuyOrderPriceUSDC(msg.sender, orderID, newPrice);
            break;
        }
    }
}

       

    function changeSellOrderPriceEther(uint256 orderID, uint256 newPrice) public nonReentrant whenNotPaused {
        escrowHandler.changeSellOrderPriceEther(msg.sender, orderID, newPrice);
    }

    function changeSellOrderPriceUSDT(uint256 orderID, uint256 newPrice) public nonReentrant whenNotPaused {
        escrowHandler.changeSellOrderPriceUSDT(msg.sender, orderID, newPrice);
    }

    function changeSellOrderPriceUSDC(uint256 orderID, uint256 newPrice) public nonReentrant whenNotPaused {
        usdcOrders.changeSellOrderPriceUSDC(msg.sender, orderID, newPrice);
    }
    
    
    function getNickeliumBalance(address account) public view returns (uint256) {
    return balanceOf(account);
    }
    
    //With this the users can remove their orders at once.
    function removeAllOrders() public nonReentrant {
        adminControlContract.adminControl(msg.sender);
    }
  
    //Only admins can pause the contract for example for technical reasons.
    function pause() external whenNotPaused onlyAuthorized nonReentrant {
        _pause();
    }

    function unpause() external onlyAuthorized nonReentrant {
        _unpause();
    }

    }