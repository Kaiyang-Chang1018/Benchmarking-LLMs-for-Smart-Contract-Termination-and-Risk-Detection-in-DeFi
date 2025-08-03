// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import { IERC20 } from "./interfaces/IERC20.sol";
import { IERC721 } from "./interfaces/IERC721.sol";
import { IERC1155 } from "./interfaces/IERC1155.sol";
import { IERC721Receiver } from "./interfaces/IERC721Receiver.sol";
import { IERC1155Receiver } from "./interfaces/IERC1155Receiver.sol";

import { IERC165 } from "./interfaces/IERC165.sol";
import { EscrowOwnable } from "./utils/EscrowOwnable.sol";
import { Context } from "./oz-simplified/Context.sol";
import { Initializable } from "./oz-simplified/Initializable.sol";

import { IEscrow } from "./interfaces/IEscrow.sol";

import { Errors } from "./library/errors/Errors.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Escrow is IEscrow, IERC165, IERC721Receiver, IERC1155Receiver, EscrowOwnable {
    struct PrizeToken {
        uint256 tokenId;
        address token;
        uint8 tokenType;
        uint16 quantity;
    }

    uint8 constant TYPE_ERC721 = 2;
    uint8 constant TYPE_ERC1155 = 3;

    IERC20 private _currencyContract;

    uint256 private _lastId;

    mapping(uint256 => PrizeToken[]) private _prizes;
    mapping(uint256 => address) private _claims;

    constructor(address currency) {
        // confirm currency is a contract
        if (currency.code.length == 0) {
            revert Errors.NotAContract();
        }
        _currencyContract = IERC20(currency);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165) returns (bool) {
        return (
            interfaceId == type(IEscrow).interfaceId
            || interfaceId == type(IERC721Receiver).interfaceId
            || interfaceId == type(IERC1155Receiver).interfaceId
            || interfaceId == type(IERC165).interfaceId
        );
    }

    function updateCurrency(address newCurrencyAddress) external onlyOwner {
       if (newCurrencyAddress.code.length == 0) {
            revert Errors.NotAContract();
        }
        _currencyContract = IERC20(newCurrencyAddress);
    }

    function currencyBalance() public view returns (uint256) {
        return _currencyContract.balanceOf(address(this));
    }

    function deposit(address spender, uint256 amount) public onlyAuthorized {
        _currencyContract.transferFrom(spender, address(this), amount);

        emit Deposit(amount, spender);
    }

    function withdraw(address recipient, uint256 amount) public onlyAuthorized {
        _currencyContract.transfer(recipient, amount);

        emit Withdrawal(amount, recipient);
    }

    function getPrizeInfo(uint256 claimId) public view returns (PrizeToken[] memory) {
        return _prizes[claimId];
    }

    function addPrize(
        address[] calldata tokens,
        uint256[] calldata tokenIds,
        uint8[] calldata tokenTypes,
        uint16[] calldata quantities
    ) public onlyAuthorized {
        uint256 arrayLength = tokens.length;
        if (
            arrayLength != tokenIds.length
            || arrayLength != tokenTypes.length
            || arrayLength != quantities.length
        ) {
            revert Errors.ArrayMismatch();
        }

        uint256 claimId = ++_lastId;

        for (uint256 i = 0; i < arrayLength;) {
            PrizeToken storage prize = _prizes[claimId].push();
            prize.token = tokens[i];
            prize.tokenId = tokenIds[i];
            prize.tokenType = tokenTypes[i];
            prize.quantity = quantities[i];

            unchecked {
                ++i;
            }
        }

        _transferPrize(claimId, msg.sender, address(this));

        emit PrizeAdded(claimId);
    }

    function removePrize(uint256 claimId, address to) public onlyAuthorized {
        _transferPrize(claimId, address(this), to);

        // delete the PrizeToken array to get a gas refund
        // iterating to delete each struct costs more than we save
        delete _prizes[claimId];

        emit PrizeRemoved(claimId, to);
    }

    function authorizeClaim(uint256 claimId, address claimant) public onlyAuthorized {
        if ( _prizes[ claimId ].length == 0) {
            revert Errors.AlreadyClaimed(claimId);
        }

        _claims[claimId] = claimant;

        emit ClaimAuthorized(claimId, claimant);
    }

    function authorizedClaimant(uint256 claimId) public view returns (address) {
        return _claims[claimId];
    }

    function claim(uint256 claimId, address destination) public {
        _claim(claimId, msg.sender, destination);
    }

    function claimFor(address claimant, uint256 claimId, address destination) onlyAuthorized public {
        _claim(claimId, claimant, destination);
    }

    function _claim(uint256 claimId, address claimant, address recipient) internal {
       if (claimant != _claims[claimId]) {
            revert Errors.BadSender(_claims[claimId], claimant);
        }

        _transferPrize(claimId, address(this), recipient);
        emit PrizeReceived(claimId, recipient);

        // cancel the authorization and receive a gas refund
        _claims[claimId] = address(0);

        // delete the PrizeToken array to get a gas refund
        // iterating to delete each struct costs more than we save
        delete _prizes[claimId];
    }

    function _transferPrize(uint256 claimId, address from, address to) internal {
        PrizeToken[] memory prize = _prizes[claimId];

        for (uint256 i = 0; i < prize.length;) {
            if (prize[i].tokenType == TYPE_ERC721) {
                IERC721 ct = IERC721(prize[i].token);
                ct.safeTransferFrom(from, to, prize[i].tokenId);
            } else if (prize[i].tokenType == TYPE_ERC1155) {
                IERC1155 ct = IERC1155(prize[i].token);
                ct.safeTransferFrom(from, to, prize[i].tokenId, prize[i].quantity, new bytes(0));
            } else {
                revert Errors.InvalidTokenType();
            }

            unchecked {
                ++i;
            }
        }
    }

    function onERC721Received(
        address, // operator,
        address from,
        uint256, // tokenId,
        bytes calldata // data
    ) public view returns (bytes4 selector) {
        // for safety, only allow transfer of ERC721 tokens from the banker
        if (banker() == from) {
            selector = IERC721Receiver.onERC721Received.selector;
        }
    }

    function onERC1155Received(
        address, // operator,
        address from,
        uint256, // id,
        uint256, // value,
        bytes calldata // data
    ) public view returns (bytes4 selector) {
        // for safety, only allow transfer of ERC1155 tokens from the banker
        if (banker() == from) {
            selector = IERC1155Receiver.onERC1155Received.selector;
        }
    }

    function onERC1155BatchReceived(
        address, // operator,
        address from,
        uint256[] calldata, // ids,
        uint256[] calldata, // values,
        bytes calldata // data
    ) public view returns (bytes4 selector) {
        // for safety, only allow transfer of ERC1155 tokens from the banker
        if (banker() == from) {
            selector = IERC1155Receiver.onERC1155BatchReceived.selector;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
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
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either
     * {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will
     * be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

interface IEscrow {
    event Withdrawal(uint256 indexed amount, address indexed withdrawer);
    event Deposit(uint256 indexed amount, address indexed depositer);
    event ClaimAuthorized(uint256 indexed claimId, address indexed claimant);
    event PrizeAdded(uint256 indexed claimId);
    event PrizeRemoved(uint256 indexed claimId, address indexed recipient);
    event PrizeReceived(uint256 indexed claimId, address indexed recipient);

    function currencyBalance() external returns (uint256);

    function deposit(address spender, uint256 amount) external;

    function withdraw(address recipient, uint256 amount) external;

    function authorizeClaim(uint256 claimId, address claimant) external;

    function claimFor(address claimant, uint256 claimId, address recipient) external;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.4 <0.9.0;

library Errors {
    error LinkError();
    error ArrayMismatch();
    error OutOfRange(uint256 value);
    error OutOfRangeSigned(int256 value);
    error UnsignedOverflow(uint256 value);
    error SignedOverflow(int256 value);
    error DuplicateCall();

    error NotAContract();
    error InterfaceNotSupported();
    error NotInitialized();
    error AlreadyInitialized();
    error BadSender(address expected, address caller);
    error AddressTarget(address target);
    error UserPermissions();

    error InvalidHash();
    error InvalidSignature();
    error InvalidSignatureLength();
    error InvalidSignatureS();

    error InsufficientBalance(uint256 available, uint256 required);
    error InsufficientSupply(uint256 supply, uint256 available, int256 requested);  // 0x5437b336
    error InsufficientAvailable(uint256 available, uint256 requested);
    error InvalidToken(uint256 tokenId);                                            // 0x925d6b18
    error TokenNotMintable(uint256 tokenId);
    error InvalidTokenType();

    error ERC1155Receiver();

    error ContractPaused();

    error PaymentFailed(uint256 amount);
    error IncorrectPayment(uint256 required, uint256 provided);                     // 0x0d35e921
	error TooManyForTransaction(uint256 mintLimit, uint256 amount);

    error AuctionInactive(uint256 auctionId);
    error AuctionActive(uint256 auctionId);
    error InvalidBid(uint256 auctionId, uint256 amount);
    error BidTooLow(uint256 auctionId, uint256 bid, uint256 minBid);
    error AuctionClosed(uint256 auctionId);
    error AuctionInExtendedBidding(uint256 auctionId);
    error AuctionAborted(uint256 auctionId);

    error AlreadyClaimed(uint256 lotId);
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;
import { Initializable } from "./Initializable.sol";

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
abstract contract Context is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

import { Errors } from "../library/errors/Errors.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // require(_initializing || !_initialized, "Initializable: contract is already initialized");
        if (!_initializing && _initialized) revert Errors.AlreadyInitialized();

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

import { Errors } from "../library/errors/Errors.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there are two accounts (an owner and a proxy) that can be granted exclusive
 * access to specific functions. Only the owner can set the proxy.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract EscrowOwnable {
    address private _owner;
    address private _proxy;
    address private _banker;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the current proxy.
     */
    function proxy() public view virtual returns (address) {
        return _proxy;
    }

    /**
     * @dev Returns the address of the current proxy.
     */
    function banker() public view virtual returns (address) {
        return _banker;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        if (owner() != msg.sender) revert Errors.UserPermissions();
        _;
    }

    /**
     * @dev Throws if called by any account other than the proxy or the owner.
     */
    modifier onlyAuthorized() {
        if (
            proxy() != msg.sender &&
            banker() != msg.sender &&
            owner() != msg.sender
        ) revert Errors.UserPermissions();
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) revert Errors.AddressTarget(newOwner);
        _setOwner(newOwner);
    }

    /**
     * @dev Sets the proxy for the contract to a new account (`newProxy`).
     * Can only be called by the current owner.
     */
    function setProxy(address newProxy) public virtual onlyOwner {
        _proxy = newProxy;
    }

    /**
     * @dev Sets the proxy for the contract to a new account (`newProxy`).
     * Can only be called by the current owner.
     */
    function setBanker(address newBanker) public virtual onlyOwner {
        _banker = newBanker;
    }

    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}