// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/AccessControl.sol)

pragma solidity ^0.8.20;

import {IAccessControl} from "./IAccessControl.sol";
import {Context} from "../utils/Context.sol";
import {ERC165} from "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    mapping(bytes32 role => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _roles[role].hasRole[account];
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        if (!hasRole(role, account)) {
            _roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` to `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        if (hasRole(role, account)) {
            _roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (access/IAccessControl.sol)

pragma solidity ^0.8.20;

/**
 * @dev External interface of AccessControl declared to support ERC-165 detection.
 */
interface IAccessControl {
    /**
     * @dev The `account` is missing a role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev The caller of a function is not the expected one.
     *
     * NOTE: Don't confuse with {AccessControlUnauthorizedAccount}.
     */
    error AccessControlBadConfirmation();

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call. This account bears the admin role (for the granted role).
     * Expected in cases where the role was granted using the internal {AccessControl-_grantRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC-721 compliant contract.
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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC-721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC-721
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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC-165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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
pragma solidity >=0.8.28;

import {IFluffySaleEscrow} from "./IFluffySaleEscrow.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @title FluffySaleEscrow
/// @author Archethect
/// @notice Escrow contract handling the creation, purchase, and finalization of Fluffy NFT whitelist sale offers
contract FluffySaleEscrow is AccessControl, IFluffySaleEscrow {
    /// @notice Role identifier for admin-only functions
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    /// @notice Denominator for calculating basis points (BPS)
    uint256 public constant BPS = 10000;

    /// @notice Fee percentage in BPS (default is 1000 → 10%)
    uint256 public feePercentageInBPS;
    /// @notice The receiver of the fee
    address public feeReceiver;
    /// @notice The Fluffy NFT contract implementing IERC721
    IERC721 public fluffyNFT;

    /// @notice Mapping of seller address to their offer
    mapping(address => Offer) public offers;
    /// @notice Tracks if a particular address is currently buying an offer
    mapping(address => bool) public isBuying;

    /**
     * @notice Constructor for FluffySaleEscrow
     * @dev Initializes admin role and sets default fee percentage
     * @param _admin The address with `ADMIN_ROLE` permissions
     * @param _feeReceiver The address to receive fees from sales
     */
    constructor(address _admin, address _feeReceiver) {
        if(_admin == address(0)) revert InvalidAddress();
        if(_feeReceiver == address(0)) revert InvalidAddress();

        _grantRole(ADMIN_ROLE, _admin);
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);

        feeReceiver = _feeReceiver;
        feePercentageInBPS = 1000;
    }

    /**
     * @notice Creates a new offer with a specified price
     * @dev Reverts if the caller is already buying or already has an active offer
     * @param price The asking price (in wei) for this offer
     */
    function createOffer(uint256 price) external {
        if(isBuying[msg.sender]) revert UserIsAlreadyBuying();
        if(offers[msg.sender].seller != address(0)) revert OfferAlreadyExists();
        offers[msg.sender] = Offer({
            seller: msg.sender,
            buyer: address(0),
            price: price,
            success: false
        });
        emit OfferCreated(msg.sender, price);
    }

    /**
     * @notice Reverts an existing offer
     * @dev Reverts if the offer has already been completed or if caller is not the seller
     *      Returns the buyer's funds if a buyer exists
     */
    function revertOffer() external {
        Offer memory offer = offers[msg.sender];
        if(offer.seller != msg.sender) revert NotOwner();
        if(offer.success) revert OfferAlreadyCompleted();
        delete offers[msg.sender];
        if(offer.buyer != address(0)) {
            if(
                address(fluffyNFT) != address(0) &&
                IERC721(fluffyNFT).balanceOf(offer.buyer) > 0
            ) revert FluffyNFTAlreadyMinted();
            isBuying[offer.buyer] = false;
            payable(offer.buyer).transfer(offer.price);
        }
        emit OfferReverted(msg.sender);
    }

    /**
     * @notice Allows a buyer to buy an existing offer
     * @dev The buyer must not already be buying and must send the correct payment
     * @param offerId The address of the seller whose offer is being bought
     */
    function buy(address offerId) external payable {
        Offer storage offer = offers[offerId];
        if(isBuying[msg.sender]) revert CanOnlyBuyOnce();
        if(
            address(fluffyNFT) != address(0) &&
            IERC721(fluffyNFT).balanceOf(msg.sender) > 0
        ) revert FluffyNFTAlreadyMinted();
        if(offer.seller == address(0)) revert NonExistingOffer();
        if(offer.buyer != address(0)) revert OfferAlreadyFilled();
        if(msg.value != offer.price) revert IncorrectPayment();
        offer.buyer = msg.sender;
        isBuying[msg.sender] = true;
        emit Bought(offerId, msg.sender);
    }

    /**
     * @notice Reverts a buyer’s purchase
     * @dev Caller must be the buyer, and the NFT must not have been minted yet
     * @param offerId The address of the seller's offer to revert
     */
    function revertBuy(address offerId) external {
        if(address(fluffyNFT) == address(0)) revert FluffyNFTNotSet();
        Offer storage offer = offers[offerId];
        if(offer.buyer != msg.sender) revert NotBuyer();
        if(offer.success) revert OfferAlreadyCompleted();
        if(IERC721(fluffyNFT).balanceOf(offer.buyer) > 0) revert FluffyNFTAlreadyMinted();
        isBuying[offer.buyer] = false;
        address buyer = offer.buyer;
        offer.buyer = address(0);
        (bool success,) = payable(buyer).call{value: offer.price}("");
        if(!success) revert TransferFailed();
        emit BuyReverted(offerId, msg.sender);
    }

    /**
     * @notice Completes a sale, transferring funds to seller and fee to feeReceiver
     * @dev The Fluffy NFT must already be minted to the buyer. Reverts if sale is already completed.
     * @param offerId The address of the seller’s offer to complete
     */
    function completeSale(address offerId) external {
        if(address(fluffyNFT) == address(0)) revert FluffyNFTNotSet();
        Offer storage offer = offers[offerId];
        if(offer.success) revert OfferAlreadyCompleted();
        if(IERC721(fluffyNFT).balanceOf(offer.buyer) == 0) revert FluffyNFTNotYetMinted();
        offer.success = true;
        uint256 fee = offer.price * feePercentageInBPS / BPS;
        (bool success1,) = payable(offer.seller).call{value: offer.price - fee}("");
        (bool success2,) = payable(feeReceiver).call{value: fee}("");
        if(!success1 || !success2) revert TransferFailed();
        emit SaleCompleted(offerId);
    }

    /**
     * @notice Sets the Fluffy NFT contract
     * @dev Restricted to accounts with `ADMIN_ROLE`
     * @param _fluffyNFT The address of the Fluffy NFT contract
     */
    function setFluffyNFT(address _fluffyNFT) external onlyRole(ADMIN_ROLE) {
        if(_fluffyNFT == address(0)) revert InvalidAddress();
        fluffyNFT = IERC721(_fluffyNFT);
    }

    /**
     * @notice Returns the offer struct for a given seller address
     * @param offerId The seller address for which the offer is retrieved
     * @return The Offer struct containing seller, buyer, price, and success status
     */
    function getOffer(address offerId) external view returns (Offer memory) {
        return offers[offerId];
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

/**
 * @title IFluffySaleEscrow
 * @author Archethect
 * @notice Interface for the FluffySaleEscrow contract
 */
interface IFluffySaleEscrow {
    /**
     * @notice Structure containing information about a sale offer
     * @param seller The address of the user listing the offer
     * @param buyer The address of the buyer who purchases the offer
     * @param price The price (in wei) of the offer
     * @param success Indicates whether the sale has been successfully completed
     */
    struct Offer {
        address seller;
        address buyer;
        uint256 price;
        bool success;
    }

    // ----------------------  Custom Errors  ----------------------

    /// @notice Thrown when an address is zero or invalid
    error InvalidAddress();

    /// @notice Thrown when a user tries to buy while already buying another offer
    error UserIsAlreadyBuying();

    /// @notice Thrown when an offer is created by a user who already has an active offer
    error OfferAlreadyExists();

    /// @notice Thrown when a non-owner tries to modify or revert an offer
    error NotOwner();

    /// @notice Thrown when an action is attempted on an offer that was already completed
    error OfferAlreadyCompleted();

    /// @notice Thrown when a user tries to buy while already holding another buy position
    error CanOnlyBuyOnce();

    /// @notice Thrown when an action is attempted on an offer that does not exist
    error NonExistingOffer();

    /// @notice Thrown when trying to buy an offer that is already filled by another buyer
    error OfferAlreadyFilled();

    /// @notice Thrown when the amount of ether sent does not match the required offer price
    error IncorrectPayment();

    /// @notice Thrown when the NFT address has not been set in the contract
    error FluffyNFTNotSet();

    /// @notice Thrown when a non-buyer attempts a buyer-only action
    error NotBuyer();

    /// @notice Thrown when the buyer already owns the Fluffy NFT (minted) and tries to revert
    error FluffyNFTAlreadyMinted();

    /// @notice Thrown when a transfer of ether fails
    error TransferFailed();

    /// @notice Thrown when a sale completion is attempted but the buyer has not yet minted/received the NFT
    error FluffyNFTNotYetMinted();

    // ----------------------  Events  ----------------------

    /**
     * @notice Emitted when a new offer is created
     * @param seller The address of the user who created the offer
     * @param price The price (in wei) set for the offer
     */
    event OfferCreated(address indexed seller, uint256 price);

    /**
     * @notice Emitted when an offer is reverted by the seller
     * @param seller The address of the seller who reverted the offer
     */
    event OfferReverted(address indexed seller);

    /**
     * @notice Emitted when a buyer buys into an existing offer
     * @param offerId The address of the seller’s offer
     * @param buyer The address of the buyer
     */
    event Bought(address indexed offerId, address indexed buyer);

    /**
     * @notice Emitted when a buyer reverts their buy
     * @param offerId The address of the seller’s offer
     * @param buyer The address of the buyer who reverted the purchase
     */
    event BuyReverted(address indexed offerId, address indexed buyer);

    /**
     * @notice Emitted when a sale is successfully completed
     * @param offerId The address of the seller’s offer
     */
    event SaleCompleted(address indexed offerId);

    // ----------------------  Functions  ----------------------

    /**
     * @notice Creates a new offer
     * @dev An offer cannot be created if the user is already buying or if one already exists for them
     * @param price The asking price (in wei) for the offer
     */
    function createOffer(uint256 price) external;

    /**
     * @notice Reverts an existing offer
     * @dev Only the owner of the offer can revert it
     *      If the offer had a buyer, that buyer’s funds are returned
     */
    function revertOffer() external;

    /**
     * @notice Allows a buyer to buy an existing offer
     * @dev The buyer must send the exact payment (in wei)
     *      A buyer can only buy once at a time
     * @param offerId The address of the seller's offer to buy
     */
    function buy(address offerId) external payable;

    /**
     * @notice Allows the buyer to revert their buy
     * @dev Only valid if the NFT has not been minted/transferred to the buyer
     * @param offerId The address of the seller's offer
     */
    function revertBuy(address offerId) external;

    /**
     * @notice Completes the sale if the buyer has minted/received the Fluffy NFT
     * @dev Distributes the payment minus fees to the seller, and the fee to the fee receiver
     * @param offerId The address of the seller's offer
     */
    function completeSale(address offerId) external;

    /**
     * @notice Sets the Fluffy NFT contract address (for checking ownership)
     * @dev Can only be called by an admin
     * @param _fluffyNFT The address of the Fluffy NFT contract
     */
    function setFluffyNFT(address _fluffyNFT) external;

    /**
     * @notice Retrieves an existing offer by seller address
     * @param offerId The address of the seller
     * @return An `Offer` struct containing all offer details
     */
    function getOffer(address offerId) external view returns (Offer memory);
}