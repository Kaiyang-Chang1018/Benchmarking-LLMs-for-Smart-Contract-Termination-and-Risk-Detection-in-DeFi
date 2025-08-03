// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./OwnablePermissions.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract OwnableBasic is OwnablePermissions, Ownable {
    function _requireCallerIsContractOwner() internal view virtual override {
        _checkOwner();
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract OwnablePermissions is Context {
    function _requireCallerIsContractOwner() internal view virtual;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../utils/CreatorTokenBase.sol";
import "../token/erc721/ERC721OpenZeppelin.sol";

/**
 * @title ERC721C
 * @author Limit Break, Inc.
 * @notice Extends OpenZeppelin's ERC721 implementation with Creator Token functionality, which
 *         allows the contract owner to update the transfer validation logic by managing a security policy in
 *         an external transfer validation security policy registry.  See {CreatorTokenTransferValidator}.
 */
abstract contract ERC721C is ERC721OpenZeppelin, CreatorTokenBase {

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(ICreatorToken).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @dev Ties the open-zeppelin _beforeTokenTransfer hook to more granular transfer validation logic
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize) internal virtual override {
        for (uint256 i = 0; i < batchSize;) {
            _validateBeforeTransfer(from, to, firstTokenId + i);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev Ties the open-zeppelin _afterTokenTransfer hook to more granular transfer validation logic
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize) internal virtual override {
        for (uint256 i = 0; i < batchSize;) {
            _validateAfterTransfer(from, to, firstTokenId + i);
            unchecked {
                ++i;
            }
        }
    }
}

/**
 * @title ERC721CInitializable
 * @author Limit Break, Inc.
 * @notice Initializable implementation of ERC721C to allow for EIP-1167 proxy clones.
 */
abstract contract ERC721CInitializable is ERC721OpenZeppelinInitializable, CreatorTokenBase {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(ICreatorToken).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @dev Ties the open-zeppelin _beforeTokenTransfer hook to more granular transfer validation logic
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize) internal virtual override {
        for (uint256 i = 0; i < batchSize;) {
            _validateBeforeTransfer(from, to, firstTokenId + i);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev Ties the open-zeppelin _afterTokenTransfer hook to more granular transfer validation logic
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize) internal virtual override {
        for (uint256 i = 0; i < batchSize;) {
            _validateAfterTransfer(from, to, firstTokenId + i);
            unchecked {
                ++i;
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../access/OwnableBasic.sol";
import "../../erc721c/ERC721C.sol";
import "../../programmable-royalties/BasicRoyalties.sol";

/**
 * @title ERC721CWithBasicRoyalties
 * @author Limit Break, Inc.
 * @notice Extension of ERC721C that adds basic royalties support.
 * @dev These contracts are intended for example use and are not intended for production deployments as-is.
 */
contract ERC721CWithBasicRoyalties is OwnableBasic, ERC721C, BasicRoyalties {

    constructor(
        address royaltyReceiver_,
        uint96 royaltyFeeNumerator_,
        string memory name_,
        string memory symbol_) 
        ERC721OpenZeppelin(name_, symbol_) 
        BasicRoyalties(royaltyReceiver_, royaltyFeeNumerator_) {
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721C, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }

    function safeMint(address to, uint256 tokenId) external {
        _safeMint(to, tokenId);
    }

    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public {
        _requireCallerIsContractOwner();
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) public {
        _requireCallerIsContractOwner();
        _setTokenRoyalty(tokenId, receiver, feeNumerator);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/ICreatorTokenTransferValidator.sol";

interface ICreatorToken {
    event TransferValidatorUpdated(address oldValidator, address newValidator);

    function getTransferValidator() external view returns (ICreatorTokenTransferValidator);
    function getSecurityPolicy() external view returns (CollectionSecurityPolicy memory);
    function getWhitelistedOperators() external view returns (address[] memory);
    function getPermittedContractReceivers() external view returns (address[] memory);
    function isOperatorWhitelisted(address operator) external view returns (bool);
    function isContractReceiverPermitted(address receiver) external view returns (bool);
    function isTransferAllowed(address caller, address from, address to) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IEOARegistry.sol";
import "./ITransferSecurityRegistry.sol";
import "./ITransferValidator.sol";

interface ICreatorTokenTransferValidator is ITransferSecurityRegistry, ITransferValidator, IEOARegistry {}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IEOARegistry is IERC165 {
    function isVerifiedEOA(address account) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../utils/TransferPolicy.sol";

interface ITransferSecurityRegistry {
    event AddedToAllowlist(AllowlistTypes indexed kind, uint256 indexed id, address indexed account);
    event CreatedAllowlist(AllowlistTypes indexed kind, uint256 indexed id, string indexed name);
    event ReassignedAllowlistOwnership(AllowlistTypes indexed kind, uint256 indexed id, address indexed newOwner);
    event RemovedFromAllowlist(AllowlistTypes indexed kind, uint256 indexed id, address indexed account);
    event SetAllowlist(AllowlistTypes indexed kind, address indexed collection, uint120 indexed id);
    event SetTransferSecurityLevel(address indexed collection, TransferSecurityLevels level);

    function createOperatorWhitelist(string calldata name) external returns (uint120);
    function createPermittedContractReceiverAllowlist(string calldata name) external returns (uint120);
    function reassignOwnershipOfOperatorWhitelist(uint120 id, address newOwner) external;
    function reassignOwnershipOfPermittedContractReceiverAllowlist(uint120 id, address newOwner) external;
    function renounceOwnershipOfOperatorWhitelist(uint120 id) external;
    function renounceOwnershipOfPermittedContractReceiverAllowlist(uint120 id) external;
    function setTransferSecurityLevelOfCollection(address collection, TransferSecurityLevels level) external;
    function setOperatorWhitelistOfCollection(address collection, uint120 id) external;
    function setPermittedContractReceiverAllowlistOfCollection(address collection, uint120 id) external;
    function addOperatorToWhitelist(uint120 id, address operator) external;
    function addPermittedContractReceiverToAllowlist(uint120 id, address receiver) external;
    function removeOperatorFromWhitelist(uint120 id, address operator) external;
    function removePermittedContractReceiverFromAllowlist(uint120 id, address receiver) external;
    function getCollectionSecurityPolicy(address collection) external view returns (CollectionSecurityPolicy memory);
    function getWhitelistedOperators(uint120 id) external view returns (address[] memory);
    function getPermittedContractReceivers(uint120 id) external view returns (address[] memory);
    function isOperatorWhitelisted(uint120 id, address operator) external view returns (bool);
    function isContractReceiverPermitted(uint120 id, address receiver) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../utils/TransferPolicy.sol";

interface ITransferValidator {
    function applyCollectionTransferPolicy(address caller, address from, address to) external view;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/common/ERC2981.sol";

/**
 * @title BasicRoyaltiesBase
 * @author Limit Break, Inc.
 * @dev Base functionality of an NFT mix-in contract implementing the most basic form of programmable royalties.
 */
abstract contract BasicRoyaltiesBase is ERC2981 {

    event DefaultRoyaltySet(address indexed receiver, uint96 feeNumerator);
    event TokenRoyaltySet(uint256 indexed tokenId, address indexed receiver, uint96 feeNumerator);

    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual override {
        super._setDefaultRoyalty(receiver, feeNumerator);
        emit DefaultRoyaltySet(receiver, feeNumerator);
    }

    function _setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) internal virtual override {
        super._setTokenRoyalty(tokenId, receiver, feeNumerator);
        emit TokenRoyaltySet(tokenId, receiver, feeNumerator);
    }
}

/**
 * @title BasicRoyalties
 * @author Limit Break, Inc.
 * @notice Constructable BasicRoyalties Contract implementation.
 */
abstract contract BasicRoyalties is BasicRoyaltiesBase {
    constructor(address receiver, uint96 feeNumerator) {
        _setDefaultRoyalty(receiver, feeNumerator);
    }
}

/**
 * @title BasicRoyaltiesInitializable
 * @author Limit Break, Inc.
 * @notice Initializable BasicRoyalties Contract implementation to allow for EIP-1167 clones. 
 */
abstract contract BasicRoyaltiesInitializable is BasicRoyaltiesBase {}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../../access/OwnablePermissions.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

abstract contract ERC721OpenZeppelinBase is ERC721 {

    // Token name
    string internal _contractName;

    // Token symbol
    string internal _contractSymbol;

    function name() public view virtual override returns (string memory) {
        return _contractName;
    }

    function symbol() public view virtual override returns (string memory) {
        return _contractSymbol;
    }

    function _setNameAndSymbol(string memory name_, string memory symbol_) internal {
        _contractName = name_;
        _contractSymbol = symbol_;
    }
}

abstract contract ERC721OpenZeppelin is ERC721OpenZeppelinBase {
    constructor(string memory name_, string memory symbol_) ERC721("", "") {
        _setNameAndSymbol(name_, symbol_);
    }
}

abstract contract ERC721OpenZeppelinInitializable is OwnablePermissions, ERC721OpenZeppelinBase {

    error ERC721OpenZeppelinInitializable__AlreadyInitializedERC721();

    /// @notice Specifies whether or not the contract is initialized
    bool private _erc721Initialized;

    /// @dev Initializes parameters of ERC721 tokens.
    /// These cannot be set in the constructor because this contract is optionally compatible with EIP-1167.
    function initializeERC721(string memory name_, string memory symbol_) public {
        _requireCallerIsContractOwner();

        if(_erc721Initialized) {
            revert ERC721OpenZeppelinInitializable__AlreadyInitializedERC721();
        }

        _erc721Initialized = true;

        _setNameAndSymbol(name_, symbol_);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../access/OwnablePermissions.sol";
import "../interfaces/ICreatorToken.sol";
import "../interfaces/ICreatorTokenTransferValidator.sol";
import "../utils/TransferValidation.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";

/**
 * @title CreatorTokenBase
 * @author Limit Break, Inc.
 * @notice CreatorTokenBase is an abstract contract that provides basic functionality for managing token 
 * transfer policies through an implementation of ICreatorTokenTransferValidator. This contract is intended to be used
 * as a base for creator-specific token contracts, enabling customizable transfer restrictions and security policies.
 *
 * <h4>Features:</h4>
 * <ul>Ownable: This contract can have an owner who can set and update the transfer validator.</ul>
 * <ul>TransferValidation: Implements the basic token transfer validation interface.</ul>
 * <ul>ICreatorToken: Implements the interface for creator tokens, providing view functions for token security policies.</ul>
 *
 * <h4>Benefits:</h4>
 * <ul>Provides a flexible and modular way to implement custom token transfer restrictions and security policies.</ul>
 * <ul>Allows creators to enforce policies such as whitelisted operators and permitted contract receivers.</ul>
 * <ul>Can be easily integrated into other token contracts as a base contract.</ul>
 *
 * <h4>Intended Usage:</h4>
 * <ul>Use as a base contract for creator token implementations that require advanced transfer restrictions and 
 *   security policies.</ul>
 * <ul>Set and update the ICreatorTokenTransferValidator implementation contract to enforce desired policies for the 
 *   creator token.</ul>
 */
abstract contract CreatorTokenBase is OwnablePermissions, TransferValidation, ICreatorToken {
    
    error CreatorTokenBase__InvalidTransferValidatorContract();
    error CreatorTokenBase__SetTransferValidatorFirst();

    address public constant DEFAULT_TRANSFER_VALIDATOR = address(0x0000721C310194CcfC01E523fc93C9cCcFa2A0Ac);
    TransferSecurityLevels public constant DEFAULT_TRANSFER_SECURITY_LEVEL = TransferSecurityLevels.One;
    uint120 public constant DEFAULT_OPERATOR_WHITELIST_ID = uint120(1);

    ICreatorTokenTransferValidator private transferValidator;

    /**
     * @notice Allows the contract owner to set the transfer validator to the official validator contract
     *         and set the security policy to the recommended default settings.
     * @dev    May be overridden to change the default behavior of an individual collection.
     */
    function setToDefaultSecurityPolicy() public virtual {
        _requireCallerIsContractOwner();
        setTransferValidator(DEFAULT_TRANSFER_VALIDATOR);
        ICreatorTokenTransferValidator(DEFAULT_TRANSFER_VALIDATOR).setTransferSecurityLevelOfCollection(address(this), DEFAULT_TRANSFER_SECURITY_LEVEL);
        ICreatorTokenTransferValidator(DEFAULT_TRANSFER_VALIDATOR).setOperatorWhitelistOfCollection(address(this), DEFAULT_OPERATOR_WHITELIST_ID);
    }

    /**
     * @notice Allows the contract owner to set the transfer validator to a custom validator contract
     *         and set the security policy to their own custom settings.
     */
    function setToCustomValidatorAndSecurityPolicy(
        address validator, 
        TransferSecurityLevels level, 
        uint120 operatorWhitelistId, 
        uint120 permittedContractReceiversAllowlistId) public {
        _requireCallerIsContractOwner();

        setTransferValidator(validator);

        ICreatorTokenTransferValidator(validator).
            setTransferSecurityLevelOfCollection(address(this), level);

        ICreatorTokenTransferValidator(validator).
            setOperatorWhitelistOfCollection(address(this), operatorWhitelistId);

        ICreatorTokenTransferValidator(validator).
            setPermittedContractReceiverAllowlistOfCollection(address(this), permittedContractReceiversAllowlistId);
    }

    /**
     * @notice Allows the contract owner to set the security policy to their own custom settings.
     * @dev    Reverts if the transfer validator has not been set.
     */
    function setToCustomSecurityPolicy(
        TransferSecurityLevels level, 
        uint120 operatorWhitelistId, 
        uint120 permittedContractReceiversAllowlistId) public {
        _requireCallerIsContractOwner();

        ICreatorTokenTransferValidator validator = getTransferValidator();
        if (address(validator) == address(0)) {
            revert CreatorTokenBase__SetTransferValidatorFirst();
        }

        validator.setTransferSecurityLevelOfCollection(address(this), level);
        validator.setOperatorWhitelistOfCollection(address(this), operatorWhitelistId);
        validator.setPermittedContractReceiverAllowlistOfCollection(address(this), permittedContractReceiversAllowlistId);
    }

    /**
     * @notice Sets the transfer validator for the token contract.
     *
     * @dev    Throws when provided validator contract is not the zero address and doesn't support 
     *         the ICreatorTokenTransferValidator interface. 
     * @dev    Throws when the caller is not the contract owner.
     *
     * @dev    <h4>Postconditions:</h4>
     *         1. The transferValidator address is updated.
     *         2. The `TransferValidatorUpdated` event is emitted.
     *
     * @param transferValidator_ The address of the transfer validator contract.
     */
    function setTransferValidator(address transferValidator_) public {
        _requireCallerIsContractOwner();

        bool isValidTransferValidator = false;

        if(transferValidator_.code.length > 0) {
            try IERC165(transferValidator_).supportsInterface(type(ICreatorTokenTransferValidator).interfaceId) 
                returns (bool supportsInterface) {
                isValidTransferValidator = supportsInterface;
            } catch {}
        }

        if(transferValidator_ != address(0) && !isValidTransferValidator) {
            revert CreatorTokenBase__InvalidTransferValidatorContract();
        }

        emit TransferValidatorUpdated(address(transferValidator), transferValidator_);

        transferValidator = ICreatorTokenTransferValidator(transferValidator_);
    }

    /**
     * @notice Returns the transfer validator contract address for this token contract.
     */
    function getTransferValidator() public view override returns (ICreatorTokenTransferValidator) {
        return transferValidator;
    }

    /**
     * @notice Returns the security policy for this token contract, which includes:
     *         Transfer security level, operator whitelist id, permitted contract receiver allowlist id.
     */
    function getSecurityPolicy() public view override returns (CollectionSecurityPolicy memory) {
        if (address(transferValidator) != address(0)) {
            return transferValidator.getCollectionSecurityPolicy(address(this));
        }

        return CollectionSecurityPolicy({
            transferSecurityLevel: TransferSecurityLevels.Zero,
            operatorWhitelistId: 0,
            permittedContractReceiversId: 0
        });
    }

    /**
     * @notice Returns the list of all whitelisted operators for this token contract.
     * @dev    This can be an expensive call and should only be used in view-only functions.
     */
    function getWhitelistedOperators() public view override returns (address[] memory) {
        if (address(transferValidator) != address(0)) {
            return transferValidator.getWhitelistedOperators(
                transferValidator.getCollectionSecurityPolicy(address(this)).operatorWhitelistId);
        }

        return new address[](0);
    }

    /**
     * @notice Returns the list of permitted contract receivers for this token contract.
     * @dev    This can be an expensive call and should only be used in view-only functions.
     */
    function getPermittedContractReceivers() public view override returns (address[] memory) {
        if (address(transferValidator) != address(0)) {
            return transferValidator.getPermittedContractReceivers(
                transferValidator.getCollectionSecurityPolicy(address(this)).permittedContractReceiversId);
        }

        return new address[](0);
    }

    /**
     * @notice Checks if an operator is whitelisted for this token contract.
     * @param operator The address of the operator to check.
     */
    function isOperatorWhitelisted(address operator) public view override returns (bool) {
        if (address(transferValidator) != address(0)) {
            return transferValidator.isOperatorWhitelisted(
                transferValidator.getCollectionSecurityPolicy(address(this)).operatorWhitelistId, operator);
        }

        return false;
    }

    /**
     * @notice Checks if a contract receiver is permitted for this token contract.
     * @param receiver The address of the receiver to check.
     */
    function isContractReceiverPermitted(address receiver) public view override returns (bool) {
        if (address(transferValidator) != address(0)) {
            return transferValidator.isContractReceiverPermitted(
                transferValidator.getCollectionSecurityPolicy(address(this)).permittedContractReceiversId, receiver);
        }

        return false;
    }

    /**
     * @notice Determines if a transfer is allowed based on the token contract's security policy.  Use this function
     *         to simulate whether or not a transfer made by the specified `caller` from the `from` address to the `to`
     *         address would be allowed by this token's security policy.
     *
     * @notice This function only checks the security policy restrictions and does not check whether token ownership
     *         or approvals are in place. 
     *
     * @param caller The address of the simulated caller.
     * @param from   The address of the sender.
     * @param to     The address of the receiver.
     * @return       True if the transfer is allowed, false otherwise.
     */
    function isTransferAllowed(address caller, address from, address to) public view override returns (bool) {
        if (address(transferValidator) != address(0)) {
            try transferValidator.applyCollectionTransferPolicy(caller, from, to) {
                return true;
            } catch {
                return false;
            }
        }
        return true;
    }

    /**
     * @dev Pre-validates a token transfer, reverting if the transfer is not allowed by this token's security policy.
     *      Inheriting contracts are responsible for overriding the _beforeTokenTransfer function, or its equivalent
     *      and calling _validateBeforeTransfer so that checks can be properly applied during token transfers.
     *
     * @dev Throws when the transfer doesn't comply with the collection's transfer policy, if the transferValidator is
     *      set to a non-zero address.
     *
     * @param caller  The address of the caller.
     * @param from    The address of the sender.
     * @param to      The address of the receiver.
     */
    function _preValidateTransfer(
        address caller, 
        address from, 
        address to, 
        uint256 /*tokenId*/, 
        uint256 /*value*/) internal virtual override {
        if (address(transferValidator) != address(0)) {
            transferValidator.applyCollectionTransferPolicy(caller, from, to);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

enum AllowlistTypes {
    Operators,
    PermittedContractReceivers
}

enum ReceiverConstraints {
    None,
    NoCode,
    EOA
}

enum CallerConstraints {
    None,
    OperatorWhitelistEnableOTC,
    OperatorWhitelistDisableOTC
}

enum StakerConstraints {
    None,
    CallerIsTxOrigin,
    EOA
}

enum TransferSecurityLevels {
    Zero,
    One,
    Two,
    Three,
    Four,
    Five,
    Six
}

struct TransferSecurityPolicy {
    CallerConstraints callerConstraints;
    ReceiverConstraints receiverConstraints;
}

struct CollectionSecurityPolicy {
    TransferSecurityLevels transferSecurityLevel;
    uint120 operatorWhitelistId;
    uint120 permittedContractReceiversId;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @title TransferValidation
 * @author Limit Break, Inc.
 * @notice A mix-in that can be combined with ERC-721 contracts to provide more granular hooks.
 * Openzeppelin's ERC721 contract only provides hooks for before and after transfer.  This allows
 * developers to validate or customize transfers within the context of a mint, a burn, or a transfer.
 */
abstract contract TransferValidation is Context {
    
    error ShouldNotMintToBurnAddress();

    /// @dev Inheriting contracts should call this function in the _beforeTokenTransfer function to get more granular hooks.
    function _validateBeforeTransfer(address from, address to, uint256 tokenId) internal virtual {
        bool fromZeroAddress = from == address(0);
        bool toZeroAddress = to == address(0);

        if(fromZeroAddress && toZeroAddress) {
            revert ShouldNotMintToBurnAddress();
        } else if(fromZeroAddress) {
            _preValidateMint(_msgSender(), to, tokenId, msg.value);
        } else if(toZeroAddress) {
            _preValidateBurn(_msgSender(), from, tokenId, msg.value);
        } else {
            _preValidateTransfer(_msgSender(), from, to, tokenId, msg.value);
        }
    }

    /// @dev Inheriting contracts should call this function in the _afterTokenTransfer function to get more granular hooks.
    function _validateAfterTransfer(address from, address to, uint256 tokenId) internal virtual {
        bool fromZeroAddress = from == address(0);
        bool toZeroAddress = to == address(0);

        if(fromZeroAddress && toZeroAddress) {
            revert ShouldNotMintToBurnAddress();
        } else if(fromZeroAddress) {
            _postValidateMint(_msgSender(), to, tokenId, msg.value);
        } else if(toZeroAddress) {
            _postValidateBurn(_msgSender(), from, tokenId, msg.value);
        } else {
            _postValidateTransfer(_msgSender(), from, to, tokenId, msg.value);
        }
    }

    /// @dev Optional validation hook that fires before a mint
    function _preValidateMint(address caller, address to, uint256 tokenId, uint256 value) internal virtual {}

    /// @dev Optional validation hook that fires after a mint
    function _postValidateMint(address caller, address to, uint256 tokenId, uint256 value) internal virtual {}

    /// @dev Optional validation hook that fires before a burn
    function _preValidateBurn(address caller, address from, uint256 tokenId, uint256 value) internal virtual {}

    /// @dev Optional validation hook that fires after a burn
    function _postValidateBurn(address caller, address from, uint256 tokenId, uint256 value) internal virtual {}

    /// @dev Optional validation hook that fires before a transfer
    function _preValidateTransfer(address caller, address from, address to, uint256 tokenId, uint256 value) internal virtual {}

    /// @dev Optional validation hook that fires after a transfer
    function _postValidateTransfer(address caller, address from, address to, uint256 tokenId, uint256 value) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC165.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.2) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual {}

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * WARNING: Anyone calling this MUST ensure that the balances remain consistent with the ownership. The invariant
     * being that for any address `a` the value returned by `balanceOf(a)` must be equal to the number of tokens such
     * that `ownerOf(tokenId)` is `a`.
     */
    // solhint-disable-next-line func-name-mixedcase
    function __unsafe_increaseBalance(address account, uint256 amount) internal {
        _balances[account] += amount;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
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
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/common/ERC2981.sol)

pragma solidity ^0.8.0;

import "../../interfaces/IERC2981.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the NFT Royalty Standard, a standardized way to retrieve royalty payment information.
 *
 * Royalty information can be specified globally for all token ids via {_setDefaultRoyalty}, and/or individually for
 * specific token ids via {_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * Royalty is specified as a fraction of sale price. {_feeDenominator} is overridable but defaults to 10000, meaning the
 * fee is specified in basis points by default.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 *
 * _Available since v4.5._
 */
abstract contract ERC2981 is IERC2981, ERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC2981
     */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view virtual override returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[_tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) / _feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    /**
     * @dev The denominator with which to interpret the fee set in {_setTokenRoyalty} and {_setDefaultRoyalty} as a
     * fraction of the sale price. Defaults to 10000 so fees are expressed in basis points, but may be customized by an
     * override.
     */
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");

        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Removes default royalty information.
     */
    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    /**
     * @dev Sets the royalty information for a specific token id, overriding the global default.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Resets royalty information for the token id back to the global default.
     */
    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
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
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
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
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
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
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
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
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Simple single owner authorization mixin.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/auth/Ownable.sol)
///
/// @dev Note:
/// This implementation does NOT auto-initialize the owner to `msg.sender`.
/// You MUST call the `_initializeOwner` in the constructor / initializer.
///
/// While the ownable portion follows
/// [EIP-173](https://eips.ethereum.org/EIPS/eip-173) for compatibility,
/// the nomenclature for the 2-step ownership handover may be unique to this codebase.
abstract contract Ownable {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The caller is not authorized to call the function.
    error Unauthorized();

    /// @dev The `newOwner` cannot be the zero address.
    error NewOwnerIsZeroAddress();

    /// @dev The `pendingOwner` does not have a valid handover request.
    error NoHandoverRequest();

    /// @dev Cannot double-initialize.
    error AlreadyInitialized();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           EVENTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ownership is transferred from `oldOwner` to `newOwner`.
    /// This event is intentionally kept the same as OpenZeppelin's Ownable to be
    /// compatible with indexers and [EIP-173](https://eips.ethereum.org/EIPS/eip-173),
    /// despite it not being as lightweight as a single argument event.
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    /// @dev An ownership handover to `pendingOwner` has been requested.
    event OwnershipHandoverRequested(address indexed pendingOwner);

    /// @dev The ownership handover to `pendingOwner` has been canceled.
    event OwnershipHandoverCanceled(address indexed pendingOwner);

    /// @dev `keccak256(bytes("OwnershipTransferred(address,address)"))`.
    uint256 private constant _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE =
        0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0;

    /// @dev `keccak256(bytes("OwnershipHandoverRequested(address)"))`.
    uint256 private constant _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE =
        0xdbf36a107da19e49527a7176a1babf963b4b0ff8cde35ee35d6cd8f1f9ac7e1d;

    /// @dev `keccak256(bytes("OwnershipHandoverCanceled(address)"))`.
    uint256 private constant _OWNERSHIP_HANDOVER_CANCELED_EVENT_SIGNATURE =
        0xfa7b8eab7da67f412cc9575ed43464468f9bfbae89d1675917346ca6d8fe3c92;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STORAGE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The owner slot is given by:
    /// `bytes32(~uint256(uint32(bytes4(keccak256("_OWNER_SLOT_NOT")))))`.
    /// It is intentionally chosen to be a high value
    /// to avoid collision with lower slots.
    /// The choice of manual storage layout is to enable compatibility
    /// with both regular and upgradeable contracts.
    bytes32 internal constant _OWNER_SLOT =
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff74873927;

    /// The ownership handover slot of `newOwner` is given by:
    /// ```
    ///     mstore(0x00, or(shl(96, user), _HANDOVER_SLOT_SEED))
    ///     let handoverSlot := keccak256(0x00, 0x20)
    /// ```
    /// It stores the expiry timestamp of the two-step ownership handover.
    uint256 private constant _HANDOVER_SLOT_SEED = 0x389a75e1;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     INTERNAL FUNCTIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Override to return true to make `_initializeOwner` prevent double-initialization.
    function _guardInitializeOwner() internal pure virtual returns (bool guard) {}

    /// @dev Initializes the owner directly without authorization guard.
    /// This function must be called upon initialization,
    /// regardless of whether the contract is upgradeable or not.
    /// This is to enable generalization to both regular and upgradeable contracts,
    /// and to save gas in case the initial owner is not the caller.
    /// For performance reasons, this function will not check if there
    /// is an existing owner.
    function _initializeOwner(address newOwner) internal virtual {
        if (_guardInitializeOwner()) {
            /// @solidity memory-safe-assembly
            assembly {
                let ownerSlot := _OWNER_SLOT
                if sload(ownerSlot) {
                    mstore(0x00, 0x0dc149f0) // `AlreadyInitialized()`.
                    revert(0x1c, 0x04)
                }
                // Clean the upper 96 bits.
                newOwner := shr(96, shl(96, newOwner))
                // Store the new value.
                sstore(ownerSlot, or(newOwner, shl(255, iszero(newOwner))))
                // Emit the {OwnershipTransferred} event.
                log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, 0, newOwner)
            }
        } else {
            /// @solidity memory-safe-assembly
            assembly {
                // Clean the upper 96 bits.
                newOwner := shr(96, shl(96, newOwner))
                // Store the new value.
                sstore(_OWNER_SLOT, newOwner)
                // Emit the {OwnershipTransferred} event.
                log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, 0, newOwner)
            }
        }
    }

    /// @dev Sets the owner directly without authorization guard.
    function _setOwner(address newOwner) internal virtual {
        if (_guardInitializeOwner()) {
            /// @solidity memory-safe-assembly
            assembly {
                let ownerSlot := _OWNER_SLOT
                // Clean the upper 96 bits.
                newOwner := shr(96, shl(96, newOwner))
                // Emit the {OwnershipTransferred} event.
                log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, sload(ownerSlot), newOwner)
                // Store the new value.
                sstore(ownerSlot, or(newOwner, shl(255, iszero(newOwner))))
            }
        } else {
            /// @solidity memory-safe-assembly
            assembly {
                let ownerSlot := _OWNER_SLOT
                // Clean the upper 96 bits.
                newOwner := shr(96, shl(96, newOwner))
                // Emit the {OwnershipTransferred} event.
                log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, sload(ownerSlot), newOwner)
                // Store the new value.
                sstore(ownerSlot, newOwner)
            }
        }
    }

    /// @dev Throws if the sender is not the owner.
    function _checkOwner() internal view virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // If the caller is not the stored owner, revert.
            if iszero(eq(caller(), sload(_OWNER_SLOT))) {
                mstore(0x00, 0x82b42900) // `Unauthorized()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Returns how long a two-step ownership handover is valid for in seconds.
    /// Override to return a different value if needed.
    /// Made internal to conserve bytecode. Wrap it in a public function if needed.
    function _ownershipHandoverValidFor() internal view virtual returns (uint64) {
        return 48 * 3600;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  PUBLIC UPDATE FUNCTIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Allows the owner to transfer the ownership to `newOwner`.
    function transferOwnership(address newOwner) public payable virtual onlyOwner {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(shl(96, newOwner)) {
                mstore(0x00, 0x7448fbae) // `NewOwnerIsZeroAddress()`.
                revert(0x1c, 0x04)
            }
        }
        _setOwner(newOwner);
    }

    /// @dev Allows the owner to renounce their ownership.
    function renounceOwnership() public payable virtual onlyOwner {
        _setOwner(address(0));
    }

    /// @dev Request a two-step ownership handover to the caller.
    /// The request will automatically expire in 48 hours (172800 seconds) by default.
    function requestOwnershipHandover() public payable virtual {
        unchecked {
            uint256 expires = block.timestamp + _ownershipHandoverValidFor();
            /// @solidity memory-safe-assembly
            assembly {
                // Compute and set the handover slot to `expires`.
                mstore(0x0c, _HANDOVER_SLOT_SEED)
                mstore(0x00, caller())
                sstore(keccak256(0x0c, 0x20), expires)
                // Emit the {OwnershipHandoverRequested} event.
                log2(0, 0, _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE, caller())
            }
        }
    }

    /// @dev Cancels the two-step ownership handover to the caller, if any.
    function cancelOwnershipHandover() public payable virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute and set the handover slot to 0.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, caller())
            sstore(keccak256(0x0c, 0x20), 0)
            // Emit the {OwnershipHandoverCanceled} event.
            log2(0, 0, _OWNERSHIP_HANDOVER_CANCELED_EVENT_SIGNATURE, caller())
        }
    }

    /// @dev Allows the owner to complete the two-step ownership handover to `pendingOwner`.
    /// Reverts if there is no existing ownership handover requested by `pendingOwner`.
    function completeOwnershipHandover(address pendingOwner) public payable virtual onlyOwner {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute and set the handover slot to 0.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, pendingOwner)
            let handoverSlot := keccak256(0x0c, 0x20)
            // If the handover does not exist, or has expired.
            if gt(timestamp(), sload(handoverSlot)) {
                mstore(0x00, 0x6f5e8818) // `NoHandoverRequest()`.
                revert(0x1c, 0x04)
            }
            // Set the handover slot to 0.
            sstore(handoverSlot, 0)
        }
        _setOwner(pendingOwner);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   PUBLIC READ FUNCTIONS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the owner of the contract.
    function owner() public view virtual returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := sload(_OWNER_SLOT)
        }
    }

    /// @dev Returns the expiry timestamp for the two-step ownership handover to `pendingOwner`.
    function ownershipHandoverExpiresAt(address pendingOwner)
        public
        view
        virtual
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute the handover slot.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, pendingOwner)
            // Load the handover slot.
            result := sload(keccak256(0x0c, 0x20))
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         MODIFIERS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Marks a function as only callable by the owner.
    modifier onlyOwner() virtual {
        _checkOwner();
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/*
!!!!!!!!!!!!!!!!~!!!!!!!!!!!!!!!!!!!!~!!!!!!!!!!!!!7!!!!!!!!!!!!!!!!!!!!~~!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!~!!!!~~!!!!!!!!!!!!!!!!!!!~G?~!!!!!!~!!!!!!!!!~~?7~!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~?J~~!!!!!!!!!~~!!!!!~!BY~!!!!!~!!!!!!!!!~!5G!~!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~7GG7~~!!!!!!~JJ~!!!!~!#G~!!!!~7B7~!!!!!~7GB!~!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~!5#Y!~!!!!!~?&J~!!!~!G5~!!!!~YP!~!!!!~?BB!~!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~J#B?~!!!!!~YY~~~~~~~~~~~~~~!!~~~~!~?#B7~!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!~~!!!!~~7GB7~!!!~~~~!777??????777!!!777!!~?Y!~!!!~~~!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!~77!~~!!!~~!!!~~!7?JJ?77!~~~~~~~!77?J?!7?J?!~~!!!~!YJ~!!!!!!!!~~~!!!!!!!!!!!
!!!!!!!!!!!!!!!~~~!!!!!!~75PY!~!!~~~~!7JJ7~:................::::~^~J7~!!!~55!~!!!!!~~~7J5J!!!!!!!!!!
!!!!!!!!!!!!!~!J?7!~~~~!!~~7Y?~!!!~~7J7^........................7^^?J!~~!!!~~!!!~~~7JPPY7~!!!!!!!!!!
!!!!!!!!~~!!!!!7J5P5Y?!~~~~~~~~~~~~J?:..........................~^..~??!~!!!!!~~!JPB5?!~~!!!!!!!!!!!
!!!!!!~!!!!!!!!~~~!?5GBGY?????????JJ:...........................~^....~J?~~!!~?PBGJ!~~!!!!!!!!!~!!!!
!!!!!!!!!!!!!!!!~!7?JJJJ?777!!!!777!!!!!!~~^^:..................~:.....:?J~!!~Y57~~~!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!~7Y7~^:...............:::^^~!!!!!~^::...........:~........?J~!!~~~~~~~~!!!!!!!!!!!!!!
!!!!!!!!!!!!~!!!Y:............................:^~!!!!~^:.......~..........J7~!!~~!7?Y?!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!J.................^~7?JYYYYJJ?7!^^^^~~!!~^:...^:..........^Y~!~7PGPY?!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!~7?:............:?PB#&&&&&&&&&&&##BG5Y?7!~~~~^:.............J7~~!?7~~~!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!~7?!:.........^B&&###############&&&&&#BPY?!~~:............77~!~~~!!!!!!!!!!!!!!!!!!
~!!!!!!!!!!!!!!!!~~7?7~:......?&#######################&&&##P?7~...........77~!!!!!!!!!!!!!!!!!!!!!!
~!!!!!!!!!!!!!!!!!!~~!7?7!^:. J&############################&&#GY^.........?!~!!!~!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!~!!!!!!~~~!77?7!5&###############################&&BY^......:J~!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!~~~~!!P&#################################&&#GG5?^.?7~!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~G&####################################&&&&BY?~!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~!B&########################################&#7~!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~7##########################################&B!~!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~?########################################&&G7~!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!~!!!!!!!~?###################################&&&##GJ!~!!!!!!!!!!!!!!!!!!~!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~7###&#############################&#5??7!~~~!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~Y&###&&&&&&&&&&#################&B?~~~~~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!~!!!!!!!!!!!!~~Y#&############################B7~~~!!!!!!!!!!!!!!!!!!!!!!~!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!~~~~~~!!~~75B&&&#######################&?~!77!~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!~!7JJ7!~!!!~~!JPB#&&&&&&&#############&&#^..:~?!~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!~~~~~~!~?G#&&#B?~!!!!~~~!7?Y5GGPPB########&&&#B5?:....~J!~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!~!?YJ?!~7#&####&B!~~~~~~~!!7?!^. ~B&###&&&#GY7~:.......~???~~!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!~~~?B&&&#BYJ&#####&BJJ7!77??JJ~:..^!GBB#&&BY7^...........~?7!?J!~~~!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!~~!77G&####&&###B###G55PPJY5Y??:...~J?777JB7:............^7?777!?J7!!~~~!!!!!!!!!!!!!!!!!!!!!
!!!!!!~!5B#####&&#BPY7^:^^!PGB###&&#B?...:?7?7!7!?~..........:~7?7!7777!Y?????!!~!~!!!!!!!!!!!~!!!!!
!!!!!!~P&#####BP?~:.... .^?#&#######&B:..^?!J?77!J!.......^!7??777777!!?Y7!777?J7~~!!!!!!!!!!!!!~!!!
!!!!!!~P&#####BGP?....^7P#&######&&#G5!...77YY!77!.....^!??777!!!!777?JJ777777!7?J!~!!!!!!!!!!!!!!!!
!!!!!!~!YB####B55#J:75#&&######&#PY?77!~~~?7777~~:...^7?7777777????J??7!77777777!?J~!!!!!!!!!!!!!!!!
!!!!!!!~~5&#######BB&&#########57!!!77...!?77!?~.~^^7?7!77777!YY7777!777777777777!J7~!!!!!!!!~!!!!!!
!!!!!!!!~5&########&#########&G!!77777..!?!?7777..!J7!7777777!?J!7777777777777777!J?~!!~!!!!!!!!!!!!
!!!!!!!!~Y&##################&P77777?!.7?!?7777J.!?!77777777!7JJ!77777777777777777J?~!!!!!!!!!!!!!!!
!!!!!!!!~!B&################&BYJ!7777???!7?777!JJ?!7777777!7JJ?!77777777777777777!J7~!!!!!!!!!!!!!!!
!!!!!!!!!~7G&###############BJJY?!77757!77?7777J?!77777!77JJ7!7J7777777777777777777J~!!!!!!!!!!!!!!!
!!!!!!!!!!~!Y##############B7?J7Y?!7!J?!777777??!7777!7?J?7!77!JJ!7777777777777777!Y7~!!!!!!!!!!!!!!
!!!!!!!!!!!~~P&###########&P!J?!7Y?77?Y!777777?!77777JJ?7!7777!?Y!7777777777777777!J?~!!!!!!!!!!!!!!

Contract by @backseats_eth
*/

import { ERC721OpenZeppelin } from "@limitbreak/creator-token-contracts/contracts/token/erc721/ERC721OpenZeppelin.sol";
import { Ownable } from 'solady/src/auth/Ownable.sol';

interface IUCCSoulbound {
    function mint(address to, uint tokenId, uint otherTokenId) external;
    function mintSpecial(address to, uint tokenId) external;
}

contract UCCSoulbound is IUCCSoulbound, Ownable, ERC721OpenZeppelin {

    // The address of the minting contract
    address public uncannyMinter;

    // The base URI for the token
    string public baseTokenURI;

    // The total supply of the collection
    uint public totalSupply;

    // The max supply of the collection
    uint public constant MAX_SUPPLY = 5_000;

    /// Errors

    error CantMintThatMany();
    error OnlyMinter();

    /// Modifier

    // Only the minter contract can mint
    modifier onlyMinter() {
        if (msg.sender != uncannyMinter) revert OnlyMinter();
        _;
    }

    /// Constructor

    constructor() ERC721OpenZeppelin("UCC Soulbound", "UCCS") {
        _initializeOwner(msg.sender);
    }

    /// Minting

    function mint(address _to, uint _tokenId, uint _otherTokenId) external onlyMinter() {
        if (totalSupply + 2 > MAX_SUPPLY) revert CantMintThatMany();

        unchecked { totalSupply += 2; }

        _mint(_to, _tokenId);
        _mint(_to, _otherTokenId);
    }

    function mintSpecial(address _to, uint _tokenId) external onlyMinter() {
        if (totalSupply + 1 > MAX_SUPPLY) revert CantMintThatMany();

        unchecked { ++totalSupply; }

        _mint(_to, _tokenId);
    }

    /// Virtual

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    /// Setters

    function setMinterAddress(address _newMinter) external onlyOwner {
        uncannyMinter = _newMinter;
    }

    // Sets the location of the metadata
    function setBaseURI(string calldata _uri) external onlyOwner {
        baseTokenURI = _uri;
    }

    // Changes the mint address that can call this contract
    function changeMinterAddress(address _newMinter) external onlyOwner {
        uncannyMinter = _newMinter;
    }

    /// Soulbound Override

    function transferFrom(address, address, uint) public pure override {
        revert("Soulbound: Disabled");
    }

    function safeTransferFrom(address, address, uint256, bytes memory) public virtual override {
        revert("Soulbound: Disabled");
    }

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/*
!!!!!!!!!!!!!!!!~!!!!!!!!!!!!!!!!!!!!~!!!!!!!!!!!!!7!!!!!!!!!!!!!!!!!!!!~~!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!~!!!!~~!!!!!!!!!!!!!!!!!!!~G?~!!!!!!~!!!!!!!!!~~?7~!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~?J~~!!!!!!!!!~~!!!!!~!BY~!!!!!~!!!!!!!!!~!5G!~!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~7GG7~~!!!!!!~JJ~!!!!~!#G~!!!!~7B7~!!!!!~7GB!~!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~!5#Y!~!!!!!~?&J~!!!~!G5~!!!!~YP!~!!!!~?BB!~!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~J#B?~!!!!!~YY~~~~~~~~~~~~~~!!~~~~!~?#B7~!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!~~!!!!~~7GB7~!!!~~~~!777??????777!!!777!!~?Y!~!!!~~~!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!~77!~~!!!~~!!!~~!7?JJ?77!~~~~~~~!77?J?!7?J?!~~!!!~!YJ~!!!!!!!!~~~!!!!!!!!!!!
!!!!!!!!!!!!!!!~~~!!!!!!~75PY!~!!~~~~!7JJ7~:................::::~^~J7~!!!~55!~!!!!!~~~7J5J!!!!!!!!!!
!!!!!!!!!!!!!~!J?7!~~~~!!~~7Y?~!!!~~7J7^........................7^^?J!~~!!!~~!!!~~~7JPPY7~!!!!!!!!!!
!!!!!!!!~~!!!!!7J5P5Y?!~~~~~~~~~~~~J?:..........................~^..~??!~!!!!!~~!JPB5?!~~!!!!!!!!!!!
!!!!!!~!!!!!!!!~~~!?5GBGY?????????JJ:...........................~^....~J?~~!!~?PBGJ!~~!!!!!!!!!~!!!!
!!!!!!!!!!!!!!!!~!7?JJJJ?777!!!!777!!!!!!~~^^:..................~:.....:?J~!!~Y57~~~!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!~7Y7~^:...............:::^^~!!!!!~^::...........:~........?J~!!~~~~~~~~!!!!!!!!!!!!!!
!!!!!!!!!!!!~!!!Y:............................:^~!!!!~^:.......~..........J7~!!~~!7?Y?!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!J.................^~7?JYYYYJJ?7!^^^^~~!!~^:...^:..........^Y~!~7PGPY?!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!~7?:............:?PB#&&&&&&&&&&&##BG5Y?7!~~~~^:.............J7~~!?7~~~!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!~7?!:.........^B&&###############&&&&&#BPY?!~~:............77~!~~~!!!!!!!!!!!!!!!!!!
~!!!!!!!!!!!!!!!!~~7?7~:......?&#######################&&&##P?7~...........77~!!!!!!!!!!!!!!!!!!!!!!
~!!!!!!!!!!!!!!!!!!~~!7?7!^:. J&############################&&#GY^.........?!~!!!~!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!~!!!!!!~~~!77?7!5&###############################&&BY^......:J~!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!~~~~!!P&#################################&&#GG5?^.?7~!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~G&####################################&&&&BY?~!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~!B&########################################&#7~!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~7##########################################&B!~!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~?########################################&&G7~!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!~!!!!!!!~?###################################&&&##GJ!~!!!!!!!!!!!!!!!!!!~!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~7###&#############################&#5??7!~~~!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~Y&###&&&&&&&&&&#################&B?~~~~~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!~!!!!!!!!!!!!~~Y#&############################B7~~~!!!!!!!!!!!!!!!!!!!!!!~!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!~~~~~~!!~~75B&&&#######################&?~!77!~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!~!7JJ7!~!!!~~!JPB#&&&&&&&#############&&#^..:~?!~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!~~~~~~!~?G#&&#B?~!!!!~~~!7?Y5GGPPB########&&&#B5?:....~J!~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!~!?YJ?!~7#&####&B!~~~~~~~!!7?!^. ~B&###&&&#GY7~:.......~???~~!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!~~~?B&&&#BYJ&#####&BJJ7!77??JJ~:..^!GBB#&&BY7^...........~?7!?J!~~~!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!~~!77G&####&&###B###G55PPJY5Y??:...~J?777JB7:............^7?777!?J7!!~~~!!!!!!!!!!!!!!!!!!!!!
!!!!!!~!5B#####&&#BPY7^:^^!PGB###&&#B?...:?7?7!7!?~..........:~7?7!7777!Y?????!!~!~!!!!!!!!!!!~!!!!!
!!!!!!~P&#####BP?~:.... .^?#&#######&B:..^?!J?77!J!.......^!7??777777!!?Y7!777?J7~~!!!!!!!!!!!!!~!!!
!!!!!!~P&#####BGP?....^7P#&######&&#G5!...77YY!77!.....^!??777!!!!777?JJ777777!7?J!~!!!!!!!!!!!!!!!!
!!!!!!~!YB####B55#J:75#&&######&#PY?77!~~~?7777~~:...^7?7777777????J??7!77777777!?J~!!!!!!!!!!!!!!!!
!!!!!!!~~5&#######BB&&#########57!!!77...!?77!?~.~^^7?7!77777!YY7777!777777777777!J7~!!!!!!!!~!!!!!!
!!!!!!!!~5&########&#########&G!!77777..!?!?7777..!J7!7777777!?J!7777777777777777!J?~!!~!!!!!!!!!!!!
!!!!!!!!~Y&##################&P77777?!.7?!?7777J.!?!77777777!7JJ!77777777777777777J?~!!!!!!!!!!!!!!!
!!!!!!!!~!B&################&BYJ!7777???!7?777!JJ?!7777777!7JJ?!77777777777777777!J7~!!!!!!!!!!!!!!!
!!!!!!!!!~7G&###############BJJY?!77757!77?7777J?!77777!77JJ7!7J7777777777777777777J~!!!!!!!!!!!!!!!
!!!!!!!!!!~!Y##############B7?J7Y?!7!J?!777777??!7777!7?J?7!77!JJ!7777777777777777!Y7~!!!!!!!!!!!!!!
!!!!!!!!!!!~~P&###########&P!J?!7Y?77?Y!777777?!77777JJ?7!7777!?Y!7777777777777777!J?~!!!!!!!!!!!!!!

Contract by @backseats_eth
*/

import "@limitbreak/creator-token-contracts/contracts/examples/erc721c/ERC721CWithBasicRoyalties.sol";

interface IUncanny {
    function mint(address _to) external;
    function mintSpecial(address _to, uint _tokenId) external;
    function paidMint(address _to, uint _amount) external;
}

// ERC721CWithBasicRoyalties contains OwnableBasic
contract Uncanny is IUncanny, ERC721CWithBasicRoyalties {

    // The address of the minting contract
    address public uncannyMinter;

    // The base URI for the token
    string public baseTokenURI;

    // The total supply of the collection
    uint public totalSupply;

    // The max supply of the collection
    uint public constant MAX_SUPPLY = 2_462;

    // A mapping of the new 1/1 ids
    mapping(uint => bool) public oneOfOneIds;

    /// Errors

    error ArrayEmpty();
    error CantMintThatMany();
    error OnlyMinter();

    /// Modifier

    // Only the minter contract can mint
    modifier onlyMinter() {
        if (msg.sender != uncannyMinter) revert OnlyMinter();
        _;
    }

    /// Constructor

    constructor(address _royaltyReceiver, uint96 _royaltyFeeNumerator)
    ERC721CWithBasicRoyalties(_royaltyReceiver, _royaltyFeeNumerator, "Uncanny", "UCC") {
        // Add all the numbers to the oneOfOneIds mapping with a value of true
        oneOfOneIds[1] = true;
        oneOfOneIds[5] = true;
        oneOfOneIds[12] = true;
        oneOfOneIds[90] = true;
        oneOfOneIds[152] = true;
        oneOfOneIds[262] = true;
        oneOfOneIds[513] = true;
        oneOfOneIds[535] = true;
        oneOfOneIds[587] = true;
        oneOfOneIds[592] = true;
        oneOfOneIds[609] = true;
        oneOfOneIds[618] = true;
        oneOfOneIds[665] = true;
        oneOfOneIds[688] = true;
        oneOfOneIds[708] = true;
        oneOfOneIds[766] = true;
        oneOfOneIds[773] = true;
        oneOfOneIds[808] = true;
        oneOfOneIds[810] = true;
        oneOfOneIds[816] = true;
        oneOfOneIds[822] = true;
        oneOfOneIds[920] = true;
        oneOfOneIds[933] = true;
        oneOfOneIds[954] = true;
        oneOfOneIds[976] = true;
        oneOfOneIds[998] = true;
        oneOfOneIds[1029] = true;
        oneOfOneIds[1052] = true;
        oneOfOneIds[1068] = true;
        oneOfOneIds[1074] = true;
        oneOfOneIds[1140] = true;
        oneOfOneIds[1153] = true;
        oneOfOneIds[1218] = true;
        oneOfOneIds[1220] = true;
        oneOfOneIds[1258] = true;
        oneOfOneIds[1279] = true;
        oneOfOneIds[1293] = true;
        oneOfOneIds[1327] = true;
        oneOfOneIds[1356] = true;
        oneOfOneIds[1417] = true;
        oneOfOneIds[1507] = true;
        oneOfOneIds[1513] = true;
        oneOfOneIds[1617] = true;
        oneOfOneIds[1636] = true;
        oneOfOneIds[1714] = true;
        oneOfOneIds[1715] = true;
        oneOfOneIds[1741] = true;
        oneOfOneIds[1757] = true;
        oneOfOneIds[1776] = true;
        oneOfOneIds[1816] = true;
        oneOfOneIds[1860] = true;
        oneOfOneIds[1894] = true;
        oneOfOneIds[1941] = true;
        oneOfOneIds[1955] = true;
        oneOfOneIds[1963] = true;
        oneOfOneIds[2002] = true;
        oneOfOneIds[2026] = true;
        oneOfOneIds[2048] = true;
        oneOfOneIds[2072] = true;
        oneOfOneIds[2073] = true;
        oneOfOneIds[2099] = true;
        oneOfOneIds[2153] = true;
        oneOfOneIds[2154] = true;
        oneOfOneIds[2177] = true;
        oneOfOneIds[2203] = true;
        oneOfOneIds[2215] = true;
        oneOfOneIds[2218] = true;
        oneOfOneIds[2248] = true;
        oneOfOneIds[2254] = true;
        oneOfOneIds[2353] = true;
        oneOfOneIds[2372] = true;
        oneOfOneIds[2375] = true;
        oneOfOneIds[2377] = true;
        oneOfOneIds[2447] = true;
        oneOfOneIds[2456] = true;
    }

    /// Minting

    function mint(address _to) public onlyMinter() {
        if (totalSupply + 1 > MAX_SUPPLY) revert CantMintThatMany();

        _regularMint(_to);
    }

    function mintSpecial(address _to, uint _tokenId) public onlyMinter() {
        if (totalSupply + 1 > MAX_SUPPLY) revert CantMintThatMany();

        unchecked { ++totalSupply; }

        _mint(_to, _tokenId);
    }

    function paidMint(address _to, uint _amount) public onlyMinter() {
        if (totalSupply + _amount > MAX_SUPPLY) revert CantMintThatMany();

        for (uint i; i < _amount;) {
            _regularMint(_to);
            unchecked { ++i; }
        }
    }

    function _regularMint(address _to) internal {
        unchecked { ++totalSupply; }

        uint tokenId = totalSupply;

        // Check if the next token is going to be a 1/1.
        // If so, increment the id by one so we don't accidentally mint that 1/1
        if (oneOfOneIds[tokenId]) {
            unchecked { ++tokenId; }
        }

        if (_ownerOf(tokenId) != address(0)) {
            unchecked { ++tokenId; }
        }

        _mint(_to, tokenId);
    }

    function maxSupply() public pure returns (uint) {
        return MAX_SUPPLY;
    }

    /// Virtual

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    /// Setters

    function setMinterAddress(address _newMinter) external onlyOwner {
        uncannyMinter = _newMinter;
    }

    // Sets the location of the metadata
    function setBaseURI(string calldata _uri) external onlyOwner {
        baseTokenURI = _uri;
    }

    // Changes the mint address that can call this contract
    function changeMinterAddress(address _newMinter) external onlyOwner {
        uncannyMinter = _newMinter;
    }

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/*
!!!!!!!!!!!!!!!!~!!!!!!!!!!!!!!!!!!!!~!!!!!!!!!!!!!7!!!!!!!!!!!!!!!!!!!!~~!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!~!!!!~~!!!!!!!!!!!!!!!!!!!~G?~!!!!!!~!!!!!!!!!~~?7~!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~?J~~!!!!!!!!!~~!!!!!~!BY~!!!!!~!!!!!!!!!~!5G!~!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~7GG7~~!!!!!!~JJ~!!!!~!#G~!!!!~7B7~!!!!!~7GB!~!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~!5#Y!~!!!!!~?&J~!!!~!G5~!!!!~YP!~!!!!~?BB!~!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~J#B?~!!!!!~YY~~~~~~~~~~~~~~!!~~~~!~?#B7~!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!~~!!!!~~7GB7~!!!~~~~!777??????777!!!777!!~?Y!~!!!~~~!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!~77!~~!!!~~!!!~~!7?JJ?77!~~~~~~~!77?J?!7?J?!~~!!!~!YJ~!!!!!!!!~~~!!!!!!!!!!!
!!!!!!!!!!!!!!!~~~!!!!!!~75PY!~!!~~~~!7JJ7~:................::::~^~J7~!!!~55!~!!!!!~~~7J5J!!!!!!!!!!
!!!!!!!!!!!!!~!J?7!~~~~!!~~7Y?~!!!~~7J7^........................7^^?J!~~!!!~~!!!~~~7JPPY7~!!!!!!!!!!
!!!!!!!!~~!!!!!7J5P5Y?!~~~~~~~~~~~~J?:..........................~^..~??!~!!!!!~~!JPB5?!~~!!!!!!!!!!!
!!!!!!~!!!!!!!!~~~!?5GBGY?????????JJ:...........................~^....~J?~~!!~?PBGJ!~~!!!!!!!!!~!!!!
!!!!!!!!!!!!!!!!~!7?JJJJ?777!!!!777!!!!!!~~^^:..................~:.....:?J~!!~Y57~~~!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!~7Y7~^:...............:::^^~!!!!!~^::...........:~........?J~!!~~~~~~~~!!!!!!!!!!!!!!
!!!!!!!!!!!!~!!!Y:............................:^~!!!!~^:.......~..........J7~!!~~!7?Y?!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!J.................^~7?JYYYYJJ?7!^^^^~~!!~^:...^:..........^Y~!~7PGPY?!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!~7?:............:?PB#&&&&&&&&&&&##BG5Y?7!~~~~^:.............J7~~!?7~~~!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!~7?!:.........^B&&###############&&&&&#BPY?!~~:............77~!~~~!!!!!!!!!!!!!!!!!!
~!!!!!!!!!!!!!!!!~~7?7~:......?&#######################&&&##P?7~...........77~!!!!!!!!!!!!!!!!!!!!!!
~!!!!!!!!!!!!!!!!!!~~!7?7!^:. J&############################&&#GY^.........?!~!!!~!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!~!!!!!!~~~!77?7!5&###############################&&BY^......:J~!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!~~~~!!P&#################################&&#GG5?^.?7~!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~G&####################################&&&&BY?~!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~!B&########################################&#7~!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~7##########################################&B!~!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~?########################################&&G7~!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!~!!!!!!!~?###################################&&&##GJ!~!!!!!!!!!!!!!!!!!!~!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!~7###&#############################&#5??7!~~~!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~Y&###&&&&&&&&&&#################&B?~~~~~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!~!!!!!!!!!!!!~~Y#&############################B7~~~!!!!!!!!!!!!!!!!!!!!!!~!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!~~~~~~!!~~75B&&&#######################&?~!77!~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!~!7JJ7!~!!!~~!JPB#&&&&&&&#############&&#^..:~?!~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!~~~~~~!~?G#&&#B?~!!!!~~~!7?Y5GGPPB########&&&#B5?:....~J!~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!~!?YJ?!~7#&####&B!~~~~~~~!!7?!^. ~B&###&&&#GY7~:.......~???~~!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!~~~?B&&&#BYJ&#####&BJJ7!77??JJ~:..^!GBB#&&BY7^...........~?7!?J!~~~!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!~~!77G&####&&###B###G55PPJY5Y??:...~J?777JB7:............^7?777!?J7!!~~~!!!!!!!!!!!!!!!!!!!!!
!!!!!!~!5B#####&&#BPY7^:^^!PGB###&&#B?...:?7?7!7!?~..........:~7?7!7777!Y?????!!~!~!!!!!!!!!!!~!!!!!
!!!!!!~P&#####BP?~:.... .^?#&#######&B:..^?!J?77!J!.......^!7??777777!!?Y7!777?J7~~!!!!!!!!!!!!!~!!!
!!!!!!~P&#####BGP?....^7P#&######&&#G5!...77YY!77!.....^!??777!!!!777?JJ777777!7?J!~!!!!!!!!!!!!!!!!
!!!!!!~!YB####B55#J:75#&&######&#PY?77!~~~?7777~~:...^7?7777777????J??7!77777777!?J~!!!!!!!!!!!!!!!!
!!!!!!!~~5&#######BB&&#########57!!!77...!?77!?~.~^^7?7!77777!YY7777!777777777777!J7~!!!!!!!!~!!!!!!
!!!!!!!!~5&########&#########&G!!77777..!?!?7777..!J7!7777777!?J!7777777777777777!J?~!!~!!!!!!!!!!!!
!!!!!!!!~Y&##################&P77777?!.7?!?7777J.!?!77777777!7JJ!77777777777777777J?~!!!!!!!!!!!!!!!
!!!!!!!!~!B&################&BYJ!7777???!7?777!JJ?!7777777!7JJ?!77777777777777777!J7~!!!!!!!!!!!!!!!
!!!!!!!!!~7G&###############BJJY?!77757!77?7777J?!77777!77JJ7!7J7777777777777777777J~!!!!!!!!!!!!!!!
!!!!!!!!!!~!Y##############B7?J7Y?!7!J?!777777??!7777!7?J?7!77!JJ!7777777777777777!Y7~!!!!!!!!!!!!!!
!!!!!!!!!!!~~P&###########&P!J?!7Y?77?Y!777777?!77777JJ?7!7777!?Y!7777777777777777!J?~!!!!!!!!!!!!!!

Contract by @backseats_eth
*/

import { IUCCSoulbound } from './UCCSoulbound.sol';
import { IUncanny } from './Uncanny.sol';
import { Ownable } from 'solady/src/auth/Ownable.sol';

interface IUncannyClubLegacy {
  function getApproved(uint256 tokenId) external view returns (address);
  function isApprovedForAll(address owner, address operator) external view returns (bool);
  function ownerOf(uint tokenId) external returns (address);
  function transferFrom(address from, address to, uint tokenId) external;
}

contract UncannyMinter is Ownable {

    // The address of the current collection on mainnet
    IUncannyClubLegacy public uncannyClubAddress;

    // The new soulbound collection address
    IUCCSoulbound public uccAddress;

    // The new Uncanny collection address
    IUncanny public uncannyAddress;

    // The address to withdraw any possibly funds to
    address public withdrawAddress;

    // The original Uncanny Club is an ERC721A so transferring to address(0)
    // doesn't work. This is a close 2nd.
    address burnAddress = 0x000000000000000000000000000000000000dEaD;

    // The price to mint, if enabled
    uint public mintPrice;

    // A toggle to change to a paid mint
    bool public paidMintEnabled;

    // A toggle to open and close the contract
    bool public contractIsOpen;

    // A mapping of the 1/1 ids to the 1/1 id in the new main contract
    mapping(uint oneOfOneId => uint newOneOfOneId) public specialIds;

    /// Errors

    error AmountTooHigh();
    error BurnAndMintDisabled();
    error CantBurnOneOfOneHere();
    error ContractIsClosed();
    error MustSendInIdsOfTwo();
    error NotAOneOfOne();
    error NotApprovedToBurn();
    error NotYourToken();
    error PaidMintClosed();
    error SetWithdrawAddress();
    error WithdrawFailed();
    error WrongPrice();

    /// Modifier

    modifier enabled() {
        if (!contractIsOpen) revert ContractIsClosed();
        _;
    }

    /// Contructor

    constructor(
        address _uncannyClubAddress,
        address _uccAddress,
        address _uncannyAddress
    ) {
        _initializeOwner(msg.sender);

        uncannyClubAddress = IUncannyClubLegacy(_uncannyClubAddress);
        uccAddress = IUCCSoulbound(_uccAddress);
        uncannyAddress = IUncanny(_uncannyAddress);

        // Register the 75 1/1 ids from the old main contract for checking later
        specialIds[48]   = 1279;
        specialIds[83]   = 1507;
        specialIds[136]  = 2177;
        specialIds[274]  = 2048;
        specialIds[498]  = 2026;
        specialIds[520]  = 2153;
        specialIds[739]  = 810;
        specialIds[950]  = 2072;
        specialIds[989]  = 2154;
        specialIds[1010] = 822;
        specialIds[1058] = 998;
        specialIds[1151] = 1776;
        specialIds[1185] = 2203;
        specialIds[1214] = 1258;
        specialIds[1299] = 152;
        specialIds[1334] = 2215;
        specialIds[1385] = 665;
        specialIds[1415] = 2372;
        specialIds[1519] = 920;
        specialIds[1629] = 2002;
        specialIds[1721] = 1052;
        specialIds[1773] = 1963;
        specialIds[1837] = 954;
        specialIds[1937] = 688;
        specialIds[1954] = 1068;
        specialIds[1961] = 1417;
        specialIds[2057] = 2254;
        specialIds[2207] = 1816;
        specialIds[2208] = 12;
        specialIds[2326] = 2248;
        specialIds[2375] = 2218;
        specialIds[2471] = 592;
        specialIds[2653] = 2456;
        specialIds[2678] = 535;
        specialIds[2995] = 1741;
        specialIds[3085] = 1636;
        specialIds[3086] = 1941;
        specialIds[3279] = 1220;
        specialIds[3317] = 2099;
        specialIds[3332] = 1513;
        specialIds[3375] = 1327;
        specialIds[3377] = 1715;
        specialIds[3390] = 1757;
        specialIds[3392] = 1356;
        specialIds[3418] = 933;
        specialIds[3456] = 2073;
        specialIds[3618] = 816;
        specialIds[3623] = 773;
        specialIds[3678] = 1140;
        specialIds[3703] = 587;
        specialIds[3753] = 1;
        specialIds[3785] = 1894;
        specialIds[3916] = 976;
        specialIds[3990] = 1955;
        specialIds[3996] = 1293;
        specialIds[4069] = 262;
        specialIds[4245] = 513;
        specialIds[4280] = 2447;
        specialIds[4317] = 1617;
        specialIds[4318] = 618;
        specialIds[4355] = 1074;
        specialIds[4505] = 708;
        specialIds[4510] = 1029;
        specialIds[4551] = 5;
        specialIds[4632] = 1860;
        specialIds[4651] = 2375;
        specialIds[4657] = 808;
        specialIds[4667] = 766;
        specialIds[4698] = 90;
        specialIds[4704] = 2377;
        specialIds[4811] = 2353;
        specialIds[4824] = 1218;
        specialIds[4897] = 1153;
        specialIds[4945] = 609;
        specialIds[4979] = 1714;
    }

    function burnAndMint(uint[] calldata _tokenIds) public enabled() {
        if (paidMintEnabled) revert BurnAndMintDisabled();

        uint length = _tokenIds.length;
        if (length % 2 != 0) revert MustSendInIdsOfTwo();

        // Ensure the minter contract is approved to burn your tokens
        if (!uncannyClubAddress.isApprovedForAll(msg.sender, address(this)))
            revert NotApprovedToBurn();

        for (uint i; i < length;) {
            // Assign some ids we use in the loop
            uint tokenId = _tokenIds[i];
            uint otherTokenId = _tokenIds[i + 1];

            // Ensure you're not burning a 1/1
            if (specialIds[tokenId] > 0 || specialIds[otherTokenId] > 0) revert CantBurnOneOfOneHere(); // Use burnAndMintSpecial for that

            // Ensure you own both tokens
            if (uncannyClubAddress.ownerOf(tokenId) != msg.sender || uncannyClubAddress.ownerOf(otherTokenId) != msg.sender) revert NotYourToken();

            // // Burn both tokens
            uncannyClubAddress.transferFrom(msg.sender, burnAddress, tokenId);
            uncannyClubAddress.transferFrom(msg.sender, burnAddress, otherTokenId);

            // mint 2 ucc (soulbound)
            uccAddress.mint(msg.sender, tokenId, otherTokenId);

            // mint 1 in uncanny
            uncannyAddress.mint(msg.sender);

            // Increment the loop by 2 since we're doing this in pairs
            unchecked { i += 2; }
        }
    }

    function burnAndMintSpecial(uint _tokenId) public enabled() {
        if (paidMintEnabled) revert BurnAndMintDisabled();

        // Ensure _tokenId is a 1/1
        uint newOneOfOneId = specialIds[_tokenId];
        if (newOneOfOneId == 0) revert NotAOneOfOne();

        // Check approval
        if (
            uncannyClubAddress.isApprovedForAll(msg.sender, address(this)) == false &&
            uncannyClubAddress.getApproved(_tokenId) != address(this)
        ) revert NotApprovedToBurn();

        // Check ownership
        if (uncannyClubAddress.ownerOf(_tokenId) != msg.sender) revert NotYourToken();

        // Burn
        uncannyClubAddress.transferFrom(msg.sender, burnAddress, _tokenId);

        // Mint the 1/1 as a soulbound token
        uccAddress.mintSpecial(msg.sender, _tokenId);

        // Mint the new Uncanny 1/1 with new tokenId
        uncannyAddress.mintSpecial(msg.sender, newOneOfOneId);
    }

    function paidMint(uint _amount) public payable enabled() {
        if (!paidMintEnabled) revert PaidMintClosed();
        if (_amount > 10) revert AmountTooHigh();
        if (msg.value != mintPrice * _amount) revert WrongPrice();

        uncannyAddress.paidMint(msg.sender, _amount);
    }

    /// Setters

    // Opens and closes the contract
    function setContractIsOpen(bool _val) external onlyOwner {
        contractIsOpen = _val;
    }

    // Sets whether paid mint is enabled
    function setPaidMintEnabled(bool _enabled) external onlyOwner {
        paidMintEnabled = _enabled;
    }

    /// @dev make sure you run `setPaidMintEnabled` to `true` first
    function setMintPrice(uint _wei) external onlyOwner {
        mintPrice = _wei;
    }

    // Sets the withdraw address for the contract
    function setWithdrawAddress(address _withdrawAddress) external onlyOwner {
        withdrawAddress = _withdrawAddress;
    }

    /// Withdraw

    function withdraw() external onlyOwner {
        if (withdrawAddress == address(0)) revert SetWithdrawAddress();

        (bool success, ) = payable(withdrawAddress).call{value: address(this).balance}("");
        if (!success) revert WithdrawFailed();
    }

}