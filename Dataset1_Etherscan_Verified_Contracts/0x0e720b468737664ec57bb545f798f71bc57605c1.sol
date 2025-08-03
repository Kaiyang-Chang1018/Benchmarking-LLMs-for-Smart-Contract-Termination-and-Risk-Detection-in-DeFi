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

pragma solidity ^0.8.8;

import { IERC20Internal } from './IERC20Internal.sol';

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 is IERC20Internal {
    /**
     * @notice query the total minted token supply
     * @return token supply
     */
    function totalSupply() external view returns (uint256);

    /**
     * @notice query the token balance of given account
     * @param account address to query
     * @return token balance
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @notice query the allowance granted from given holder to given spender
     * @param holder approver of allowance
     * @param spender recipient of allowance
     * @return token allowance
     */
    function allowance(
        address holder,
        address spender
    ) external view returns (uint256);

    /**
     * @notice grant approval to spender to spend tokens
     * @dev prefer ERC20Extended functions to avoid transaction-ordering vulnerability (see https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729)
     * @param spender recipient of allowance
     * @param amount quantity of tokens approved for spending
     * @return success status (always true; otherwise function should revert)
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @notice transfer tokens to given recipient
     * @param recipient beneficiary of token transfer
     * @param amount quantity of tokens to transfer
     * @return success status (always true; otherwise function should revert)
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @notice transfer tokens to given recipient on behalf of given holder
     * @param holder holder of tokens prior to transfer
     * @param recipient beneficiary of token transfer
     * @param amount quantity of tokens to transfer
     * @return success status (always true; otherwise function should revert)
     */
    function transferFrom(
        address holder,
        address recipient,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title Partial ERC20 interface needed by internal functions
 */
interface IERC20Internal {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IReentrancyGuard {
    error ReentrancyGuard__ReentrantCall();
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IReentrancyGuard } from './IReentrancyGuard.sol';
import { ReentrancyGuardStorage } from './ReentrancyGuardStorage.sol';

/**
 * @title Utility contract for preventing reentrancy attacks
 */
abstract contract ReentrancyGuard is IReentrancyGuard {
    uint256 internal constant REENTRANCY_STATUS_LOCKED = 2;
    uint256 internal constant REENTRANCY_STATUS_UNLOCKED = 1;

    modifier nonReentrant() virtual {
        if (_isReentrancyGuardLocked()) revert ReentrancyGuard__ReentrantCall();
        _lockReentrancyGuard();
        _;
        _unlockReentrancyGuard();
    }

    /**
     * @notice returns true if the reentrancy guard is locked, false otherwise
     */
    function _isReentrancyGuardLocked() internal view virtual returns (bool) {
        return
            ReentrancyGuardStorage.layout().status == REENTRANCY_STATUS_LOCKED;
    }

    /**
     * @notice lock functions that use the nonReentrant modifier
     */
    function _lockReentrancyGuard() internal virtual {
        ReentrancyGuardStorage.layout().status = REENTRANCY_STATUS_LOCKED;
    }

    /**
     * @notice unlock functions that use the nonReentrant modifier
     */
    function _unlockReentrancyGuard() internal virtual {
        ReentrancyGuardStorage.layout().status = REENTRANCY_STATUS_UNLOCKED;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

library ReentrancyGuardStorage {
    struct Layout {
        uint256 status;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256('solidstate.contracts.storage.ReentrancyGuard');

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC20 } from '../../../interfaces/IERC20.sol';
import { IERC20Base } from './IERC20Base.sol';
import { ERC20BaseInternal } from './ERC20BaseInternal.sol';
import { ERC20BaseStorage } from './ERC20BaseStorage.sol';

/**
 * @title Base ERC20 implementation, excluding optional extensions
 */
abstract contract ERC20Base is IERC20Base, ERC20BaseInternal {
    /**
     * @inheritdoc IERC20
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply();
    }

    /**
     * @inheritdoc IERC20
     */
    function balanceOf(address account) external view returns (uint256) {
        return _balanceOf(account);
    }

    /**
     * @inheritdoc IERC20
     */
    function allowance(
        address holder,
        address spender
    ) external view returns (uint256) {
        return _allowance(holder, spender);
    }

    /**
     * @inheritdoc IERC20
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        return _approve(msg.sender, spender, amount);
    }

    /**
     * @inheritdoc IERC20
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool) {
        return _transfer(msg.sender, recipient, amount);
    }

    /**
     * @inheritdoc IERC20
     */
    function transferFrom(
        address holder,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        return _transferFrom(holder, recipient, amount);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC20BaseInternal } from './IERC20BaseInternal.sol';
import { ERC20BaseStorage } from './ERC20BaseStorage.sol';

/**
 * @title Base ERC20 internal functions, excluding optional extensions
 */
abstract contract ERC20BaseInternal is IERC20BaseInternal {
    /**
     * @notice query the total minted token supply
     * @return token supply
     */
    function _totalSupply() internal view virtual returns (uint256) {
        return ERC20BaseStorage.layout().totalSupply;
    }

    /**
     * @notice query the token balance of given account
     * @param account address to query
     * @return token balance
     */
    function _balanceOf(
        address account
    ) internal view virtual returns (uint256) {
        return ERC20BaseStorage.layout().balances[account];
    }

    /**
     * @notice query the allowance granted from given holder to given spender
     * @param holder approver of allowance
     * @param spender recipient of allowance
     * @return token allowance
     */
    function _allowance(
        address holder,
        address spender
    ) internal view virtual returns (uint256) {
        return ERC20BaseStorage.layout().allowances[holder][spender];
    }

    /**
     * @notice enable spender to spend tokens on behalf of holder
     * @param holder address on whose behalf tokens may be spent
     * @param spender recipient of allowance
     * @param amount quantity of tokens approved for spending
     * @return success status (always true; otherwise function should revert)
     */
    function _approve(
        address holder,
        address spender,
        uint256 amount
    ) internal virtual returns (bool) {
        if (holder == address(0)) revert ERC20Base__ApproveFromZeroAddress();
        if (spender == address(0)) revert ERC20Base__ApproveToZeroAddress();

        ERC20BaseStorage.layout().allowances[holder][spender] = amount;

        emit Approval(holder, spender, amount);

        return true;
    }

    /**
     * @notice decrease spend amount granted by holder to spender
     * @param holder address on whose behalf tokens may be spent
     * @param spender address whose allowance to decrease
     * @param amount quantity by which to decrease allowance
     */
    function _decreaseAllowance(
        address holder,
        address spender,
        uint256 amount
    ) internal {
        uint256 allowance = _allowance(holder, spender);

        if (amount > allowance) revert ERC20Base__InsufficientAllowance();

        unchecked {
            _approve(holder, spender, allowance - amount);
        }
    }

    /**
     * @notice mint tokens for given account
     * @param account recipient of minted tokens
     * @param amount quantity of tokens minted
     */
    function _mint(address account, uint256 amount) internal virtual {
        if (account == address(0)) revert ERC20Base__MintToZeroAddress();

        _beforeTokenTransfer(address(0), account, amount);

        ERC20BaseStorage.Layout storage l = ERC20BaseStorage.layout();
        l.totalSupply += amount;
        l.balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

    /**
     * @notice burn tokens held by given account
     * @param account holder of burned tokens
     * @param amount quantity of tokens burned
     */
    function _burn(address account, uint256 amount) internal virtual {
        if (account == address(0)) revert ERC20Base__BurnFromZeroAddress();

        _beforeTokenTransfer(account, address(0), amount);

        ERC20BaseStorage.Layout storage l = ERC20BaseStorage.layout();
        uint256 balance = l.balances[account];
        if (amount > balance) revert ERC20Base__BurnExceedsBalance();
        unchecked {
            l.balances[account] = balance - amount;
        }
        l.totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @notice transfer tokens from holder to recipient
     * @param holder owner of tokens to be transferred
     * @param recipient beneficiary of transfer
     * @param amount quantity of tokens transferred
     * @return success status (always true; otherwise function should revert)
     */
    function _transfer(
        address holder,
        address recipient,
        uint256 amount
    ) internal virtual returns (bool) {
        if (holder == address(0)) revert ERC20Base__TransferFromZeroAddress();
        if (recipient == address(0)) revert ERC20Base__TransferToZeroAddress();

        _beforeTokenTransfer(holder, recipient, amount);

        ERC20BaseStorage.Layout storage l = ERC20BaseStorage.layout();
        uint256 holderBalance = l.balances[holder];
        if (amount > holderBalance) revert ERC20Base__TransferExceedsBalance();
        unchecked {
            l.balances[holder] = holderBalance - amount;
        }
        l.balances[recipient] += amount;

        emit Transfer(holder, recipient, amount);

        return true;
    }

    /**
     * @notice transfer tokens to given recipient on behalf of given holder
     * @param holder holder of tokens prior to transfer
     * @param recipient beneficiary of token transfer
     * @param amount quantity of tokens to transfer
     * @return success status (always true; otherwise function should revert)
     */
    function _transferFrom(
        address holder,
        address recipient,
        uint256 amount
    ) internal virtual returns (bool) {
        _decreaseAllowance(holder, msg.sender, amount);

        _transfer(holder, recipient, amount);

        return true;
    }

    /**
     * @notice ERC20 hook, called before all transfers including mint and burn
     * @dev function should be overridden and new implementation must call super
     * @param from sender of tokens
     * @param to receiver of tokens
     * @param amount quantity of tokens transferred
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

library ERC20BaseStorage {
    struct Layout {
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
        uint256 totalSupply;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256('solidstate.contracts.storage.ERC20Base');

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC20 } from '../../../interfaces/IERC20.sol';
import { IERC20BaseInternal } from './IERC20BaseInternal.sol';

/**
 * @title ERC20 base interface
 */
interface IERC20Base is IERC20BaseInternal, IERC20 {

}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC20Internal } from '../../../interfaces/IERC20Internal.sol';

/**
 * @title ERC20 base interface
 */
interface IERC20BaseInternal is IERC20Internal {
    error ERC20Base__ApproveFromZeroAddress();
    error ERC20Base__ApproveToZeroAddress();
    error ERC20Base__BurnExceedsBalance();
    error ERC20Base__BurnFromZeroAddress();
    error ERC20Base__InsufficientAllowance();
    error ERC20Base__MintToZeroAddress();
    error ERC20Base__TransferExceedsBalance();
    error ERC20Base__TransferFromZeroAddress();
    error ERC20Base__TransferToZeroAddress();
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import "@solidstate/contracts/token/ERC20/base/ERC20Base.sol";

library EthscriptionsEscrowerStorage {
    struct Layout {
        mapping(address => mapping(bytes32 => uint256)) ethscriptionReceivedOnBlockNumber;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256(
            "ethscriptions.contracts.storage.EthscriptionsEscrowerStorage"
        );

    function s() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}

contract EthscriptionsEscrower {
    error EthscriptionNotDeposited();
    error EthscriptionAlreadyReceivedFromSender();
    error InvalidEthscriptionLength();
    error AdditionalCooldownRequired(uint256 additionalBlocksNeeded);

    event ethscriptions_protocol_TransferEthscriptionForPreviousOwner(
        address indexed previousOwner,
        address indexed recipient,
        bytes32 indexed id
    );

    event PotentialEthscriptionDeposited(
        address indexed owner,
        bytes32 indexed potentialEthscriptionId
    );

    event PotentialEthscriptionWithdrawn(
        address indexed owner,
        bytes32 indexed potentialEthscriptionId
    );

    uint256 public constant ETHSCRIPTION_TRANSFER_COOLDOWN_BLOCKS = 5;

    function _transferEthscription(
        address previousOwner,
        address to,
        bytes32 ethscriptionId
    ) internal virtual {
        _validateTransferEthscription(previousOwner, to, ethscriptionId);

        emit ethscriptions_protocol_TransferEthscriptionForPreviousOwner(
            previousOwner,
            to,
            ethscriptionId
        );

        _afterTransferEthscription(previousOwner, to, ethscriptionId);
    }

    function withdrawEthscription(bytes32 ethscriptionId) public virtual {
        _transferEthscription(msg.sender, msg.sender, ethscriptionId);

        emit PotentialEthscriptionWithdrawn(msg.sender, ethscriptionId);
    }

    function _onPotentialEthscriptionDeposit(
        address previousOwner,
        bytes memory userCalldata
    ) internal virtual {
        if (userCalldata.length != 32) revert InvalidEthscriptionLength();

        bytes32 potentialEthscriptionId = abi.decode(userCalldata, (bytes32));

        if (
            userEthscriptionPossiblyStored(
                previousOwner,
                potentialEthscriptionId
            )
        ) {
            revert EthscriptionAlreadyReceivedFromSender();
        }

        EthscriptionsEscrowerStorage.s().ethscriptionReceivedOnBlockNumber[
            previousOwner
        ][potentialEthscriptionId] = block.number;

        emit PotentialEthscriptionDeposited(
            previousOwner,
            potentialEthscriptionId
        );
    }

    function _validateTransferEthscription(
        address previousOwner,
        address to,
        bytes32 ethscriptionId
    ) internal view virtual {
        if (
            userEthscriptionDefinitelyNotStored(previousOwner, ethscriptionId)
        ) {
            revert EthscriptionNotDeposited();
        }

        uint256 blocksRemaining = blocksRemainingUntilValidTransfer(
            previousOwner,
            ethscriptionId
        );

        if (blocksRemaining != 0) {
            revert AdditionalCooldownRequired(blocksRemaining);
        }
    }

    function _afterTransferEthscription(
        address previousOwner,
        address to,
        bytes32 ethscriptionId
    ) internal virtual {
        delete EthscriptionsEscrowerStorage
            .s()
            .ethscriptionReceivedOnBlockNumber[previousOwner][ethscriptionId];
    }

    function blocksRemainingUntilValidTransfer(
        address previousOwner,
        bytes32 ethscriptionId
    ) public view virtual returns (uint256) {
        uint256 receivedBlockNumber = EthscriptionsEscrowerStorage
            .s()
            .ethscriptionReceivedOnBlockNumber[previousOwner][ethscriptionId];

        if (receivedBlockNumber == 0) {
            revert EthscriptionNotDeposited();
        }

        uint256 blocksPassed = block.number - receivedBlockNumber;

        return
            blocksPassed < ETHSCRIPTION_TRANSFER_COOLDOWN_BLOCKS
                ? ETHSCRIPTION_TRANSFER_COOLDOWN_BLOCKS - blocksPassed
                : 0;
    }

    function userEthscriptionDefinitelyNotStored(
        address owner,
        bytes32 ethscriptionId
    ) public view virtual returns (bool) {
        return
            EthscriptionsEscrowerStorage.s().ethscriptionReceivedOnBlockNumber[
                owner
            ][ethscriptionId] == 0;
    }

    function userEthscriptionPossiblyStored(
        address owner,
        bytes32 ethscriptionId
    ) public view virtual returns (bool) {
        return !userEthscriptionDefinitelyNotStored(owner, ethscriptionId);
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;
import "@solidstate/contracts/security/reentrancy_guard/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "solady/src/utils/SafeTransferLib.sol";
import "solady/src/utils/ECDSA.sol";
import "solady/src/utils/ERC1967FactoryConstants.sol";
import "./EthscriptionsEscrower.sol";

contract MemeScribeMarket is ReentrancyGuard, EthscriptionsEscrower, Ownable {
    using SafeTransferLib for address;
    using ECDSA for bytes32;

    constructor() Ownable(msg.sender) {
        // Your constructor logic here
    }

    uint public fee = 250; // 2.5%
    uint public constant FEE_DENOMINATOR = 10000;
    uint public feesAccumulated = 0;

    struct Listing {
        bool isForSale;
        bytes32 ethscriptionId;
        address seller;
        uint price;
    }

    mapping(bytes32 => Listing) public ethscriptionsOfferedForSale;

    event EthscriptionListed(
        bytes32 indexed ethscriptionId,
        uint price,
        address indexed seller
    );

    event EthscriptionDelisted(
        bytes32 indexed ethscriptionId,
        address indexed seller
    );

    event EthscriptionPurchased(
        bytes32 indexed ethscriptionId,
        uint price,
        address indexed seller,
        address indexed buyer
    );

    function listEthscription(
        bytes32 ethscriptionId,
        uint price
    ) external nonReentrant {
        _listEthscription(ethscriptionId, price);
    }

    function _listEthscription(bytes32 ethscriptionId, uint price) internal {
        require(
            !userEthscriptionDefinitelyNotStored(msg.sender, ethscriptionId),
            "Sender is not depositor"
        );

        ethscriptionsOfferedForSale[ethscriptionId] = Listing({
            isForSale: true,
            ethscriptionId: ethscriptionId,
            seller: msg.sender,
            price: price
        });

        emit EthscriptionListed(ethscriptionId, price, msg.sender);
    }

    function delistEthscription(bytes32 ethscriptionId) public nonReentrant {
        require(
            !userEthscriptionDefinitelyNotStored(msg.sender, ethscriptionId),
            "Sender is not depositor"
        );

        ethscriptionsOfferedForSale[ethscriptionId] = Listing(
            false,
            ethscriptionId,
            msg.sender,
            0
        );

        emit EthscriptionDelisted(ethscriptionId, msg.sender);
    }

    function batchListEthscriptions(
        bytes32[] memory ethscriptionIds,
        uint[] memory prices
    ) external nonReentrant {
        require(
            ethscriptionIds.length == prices.length,
            "Array lengths do not match"
        );

        for (uint i = 0; i < ethscriptionIds.length; i++) {
            _listEthscription(ethscriptionIds[i], prices[i]);
        }
    }

    function buyEthscription(
        bytes32 ethscriptionId,
        uint price
    ) public payable nonReentrant {
        _buyEthscription(ethscriptionId, price);
    }

    function _buyEthscription(bytes32 ethscriptionId, uint price) internal {
        Listing memory listing = ethscriptionsOfferedForSale[ethscriptionId];

        if (!listing.isForSale) revert("Ethscription is not for sale");

        if (msg.value != listing.price) revert("Not enough ether");

        address seller = listing.seller;

        if (seller == msg.sender) revert("Seller is buyer");

        ethscriptionsOfferedForSale[ethscriptionId] = Listing(
            false,
            ethscriptionId,
            msg.sender,
            0
        );

        _transferEthscription(seller, msg.sender, ethscriptionId);

        // send ether to seller
        uint feeAmount = (listing.price * fee) / FEE_DENOMINATOR;
        uint amountToSendtoSeller = listing.price - feeAmount;
        feesAccumulated += feeAmount;
        payable(seller).transfer(amountToSendtoSeller);

        emit EthscriptionPurchased(
            ethscriptionId,
            listing.price,
            seller,
            msg.sender
        );
    }

    function batchBuyEthscription(
        bytes32[] calldata ethscriptionIds,
        uint[] calldata prices
    ) external payable nonReentrant {
        require(
            ethscriptionIds.length == prices.length,
            "Array lengths do not match"
        );

        uint totalSalePrice = 0;
        for (uint i = 0; i < ethscriptionIds.length; i++) {
            _buyEthscription(ethscriptionIds[i], prices[i]);
            totalSalePrice += prices[i];
        }

        require(msg.value == totalSalePrice, "Incorrect total Ether sent");
    }

    function withdrawEthscription(bytes32 ethscriptionId) public override {
        require(
            !userEthscriptionDefinitelyNotStored(msg.sender, ethscriptionId),
            "Sender is not depositor"
        );

        // Withdraw ethscription
        super.withdrawEthscription(ethscriptionId);

        Listing memory listing = ethscriptionsOfferedForSale[ethscriptionId];
        // Check that the offer is valid
        if (listing.isForSale) {
            // Invalidate listing
            _invalidateListing(ethscriptionId);
        }
    }

    function _invalidateListing(bytes32 ethscriptionId) internal {
        ethscriptionsOfferedForSale[ethscriptionId] = Listing(
            false,
            ethscriptionId,
            msg.sender,
            0
        );

        emit EthscriptionDelisted(ethscriptionId, msg.sender);
    }

    // Owner functions
    function setMarketPlaceFee(uint updatedFee) public onlyOwner {
        fee = updatedFee;
    }

    function withdrawFees() public onlyOwner {
        uint amount = feesAccumulated;
        feesAccumulated = 0;
        payable(msg.sender).transfer(amount);
    }

    function transferContractOwner(address newOwner) public onlyOwner {
        transferOwnership(newOwner);
    }

    // Overrides
    function _onPotentialEthscriptionDeposit(
        address previousOwner,
        bytes memory userCallData
    ) internal virtual override {
        require(userCallData.length % 32 == 0, "InvalidEthscriptionLength");

        // Process each ethscriptionId
        for (uint256 i = 0; i < userCallData.length / 32; i++) {
            bytes32 potentialEthscriptionId = abi.decode(
                slice(userCallData, i * 32, 32),
                (bytes32)
            );

            if (
                userEthscriptionPossiblyStored(
                    previousOwner,
                    potentialEthscriptionId
                )
            ) {
                revert EthscriptionAlreadyReceivedFromSender();
            }

            EthscriptionsEscrowerStorage.s().ethscriptionReceivedOnBlockNumber[
                previousOwner
            ][potentialEthscriptionId] = block.number;
        }
    }

    // Utils
    function slice(
        bytes memory data,
        uint256 start,
        uint256 len
    ) internal pure returns (bytes memory) {
        bytes memory b = new bytes(len);
        for (uint256 i = 0; i < len; i++) {
            b[i] = data[i + start];
        }
        return b;
    }

    fallback() external {
        _onPotentialEthscriptionDeposit(msg.sender, msg.data);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Gas optimized ECDSA wrapper.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/ECDSA.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/ECDSA.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol)
///
/// @dev Note:
/// - The recovery functions use the ecrecover precompile (0x1).
///
/// WARNING! Do NOT use signatures as unique identifiers.
/// Please use EIP712 with a nonce included in the digest to prevent replay attacks.
/// This implementation does NOT check if a signature is non-malleable.
library ECDSA {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The signature is invalid.
    error InvalidSignature();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    RECOVERY OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Note: as of Solady version 0.0.68, these functions will
    // revert upon recovery failure for more safety by default.

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the `signature`.
    ///
    /// This function does NOT accept EIP-2098 short form signatures.
    /// Use `recover(bytes32 hash, bytes32 r, bytes32 vs)` for EIP-2098
    /// short form signatures instead.
    function recover(bytes32 hash, bytes memory signature) internal view returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            let signatureLength := mload(signature)
            mstore(0x00, hash)
            mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
            mstore(0x40, mload(add(signature, 0x20))) // `r`.
            mstore(0x60, mload(add(signature, 0x40))) // `s`.
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        eq(signatureLength, 65), // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the `signature`.
    ///
    /// This function does NOT accept EIP-2098 short form signatures.
    /// Use `recover(bytes32 hash, bytes32 r, bytes32 vs)` for EIP-2098
    /// short form signatures instead.
    function recoverCalldata(bytes32 hash, bytes calldata signature)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, byte(0, calldataload(add(signature.offset, 0x40)))) // `v`.
            calldatacopy(0x40, signature.offset, 0x40) // Copy `r` and `s`.
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        eq(signature.length, 65), // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the EIP-2098 short form signature defined by `r` and `vs`.
    ///
    /// This function only accepts EIP-2098 short form signatures.
    /// See: https://eips.ethereum.org/EIPS/eip-2098
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal view returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, add(shr(255, vs), 27)) // `v`.
            mstore(0x40, r)
            mstore(0x60, shr(1, shl(1, vs))) // `s`.
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        1, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the signature defined by `v`, `r`, `s`.
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, and(v, 0xff))
            mstore(0x40, r)
            mstore(0x60, s)
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        1, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   TRY-RECOVER OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // WARNING!
    // These functions will NOT revert upon recovery failure.
    // Instead, they will return the zero address upon recovery failure.
    // It is critical that the returned address is NEVER compared against
    // a zero address (e.g. an uninitialized address variable).

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the `signature`.
    ///
    /// This function does NOT accept EIP-2098 short form signatures.
    /// Use `recover(bytes32 hash, bytes32 r, bytes32 vs)` for EIP-2098
    /// short form signatures instead.
    function tryRecover(bytes32 hash, bytes memory signature)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            let signatureLength := mload(signature)
            mstore(0x00, hash)
            mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
            mstore(0x40, mload(add(signature, 0x20))) // `r`.
            mstore(0x60, mload(add(signature, 0x40))) // `s`.
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    eq(signatureLength, 65), // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the `signature`.
    ///
    /// This function does NOT accept EIP-2098 short form signatures.
    /// Use `recover(bytes32 hash, bytes32 r, bytes32 vs)` for EIP-2098
    /// short form signatures instead.
    function tryRecoverCalldata(bytes32 hash, bytes calldata signature)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, byte(0, calldataload(add(signature.offset, 0x40)))) // `v`.
            calldatacopy(0x40, signature.offset, 0x40) // Copy `r` and `s`.
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    eq(signature.length, 65), // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the EIP-2098 short form signature defined by `r` and `vs`.
    ///
    /// This function only accepts EIP-2098 short form signatures.
    /// See: https://eips.ethereum.org/EIPS/eip-2098
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, add(shr(255, vs), 27)) // `v`.
            mstore(0x40, r)
            mstore(0x60, shr(1, shl(1, vs))) // `s`.
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    1, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the signature defined by `v`, `r`, `s`.
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, and(v, 0xff))
            mstore(0x40, r)
            mstore(0x60, s)
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    1, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     HASHING OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns an Ethereum Signed Message, created from a `hash`.
    /// This produces a hash corresponding to the one signed with the
    /// [`eth_sign`](https://eth.wiki/json-rpc/API#eth_sign)
    /// JSON-RPC method as part of EIP-191.
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x20, hash) // Store into scratch space for keccak256.
            mstore(0x00, "\x00\x00\x00\x00\x19Ethereum Signed Message:\n32") // 28 bytes.
            result := keccak256(0x04, 0x3c) // `32 * 2 - (32 - 28) = 60 = 0x3c`.
        }
    }

    /// @dev Returns an Ethereum Signed Message, created from `s`.
    /// This produces a hash corresponding to the one signed with the
    /// [`eth_sign`](https://eth.wiki/json-rpc/API#eth_sign)
    /// JSON-RPC method as part of EIP-191.
    /// Note: Supports lengths of `s` up to 999999 bytes.
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            let sLength := mload(s)
            let o := 0x20
            mstore(o, "\x19Ethereum Signed Message:\n") // 26 bytes, zero-right-padded.
            mstore(0x00, 0x00)
            // Convert the `s.length` to ASCII decimal representation: `base10(s.length)`.
            for { let temp := sLength } 1 {} {
                o := sub(o, 1)
                mstore8(o, add(48, mod(temp, 10)))
                temp := div(temp, 10)
                if iszero(temp) { break }
            }
            let n := sub(0x3a, o) // Header length: `26 + 32 - o`.
            // Throw an out-of-offset error (consumes all gas) if the header exceeds 32 bytes.
            returndatacopy(returndatasize(), returndatasize(), gt(n, 0x20))
            mstore(s, or(mload(0x00), mload(n))) // Temporarily store the header.
            result := keccak256(add(s, sub(0x20, n)), add(n, sLength))
            mstore(s, sLength) // Restore the length.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   EMPTY CALLDATA HELPERS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns an empty calldata bytes.
    function emptySignature() internal pure returns (bytes calldata signature) {
        /// @solidity memory-safe-assembly
        assembly {
            signature.length := 0
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice The address and bytecode of the canonical ERC1967Factory deployment.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/ERC1967FactoryLib.sol)
/// @author jtriley-eth (https://github.com/jtriley-eth/minimum-viable-proxy)
///
/// @dev The canonical ERC1967Factory is deployed permissionlessly via
/// 0age's ImmutableCreate2Factory located at 0x0000000000FFe8B47B3e2130213B802212439497.
///
/// `ADDRESS = immutableCreate2Factory.safeCreate2(SALT, INITCODE)`
///
/// If the canonical ERC1967Factory has not been deployed on your EVM chain of choice,
/// please feel free to deploy via 0age's ImmutableCreate2Factory.
///
/// If 0age's ImmutableCreate2Factory has not been deployed on your EVM chain of choice,
/// please refer to 0age's ImmutableCreate2Factory deployment instructions at:
/// https://github.com/ProjectOpenSea/seaport/blob/main/docs/Deployment.md
///
/// Contract verification:
/// - Source code:
///   https://github.com/Vectorized/solady/blob/5212e50fef1f2ff1b1b5e03a5d276a0d23c02713/src/utils/ERC1967Factory.sol
///   (The EXACT source code is required. Use the file at the commit instead of the latest copy.)
/// - Optimization Enabled: Yes with 1000000 runs
/// - Compiler Version: v0.8.19+commit.7dd6d404
/// - Other Settings: default evmVersion, MIT license
library ERC1967FactoryConstants {
    /// @dev The canonical ERC1967Factory address for EVM chains.
    address internal constant ADDRESS = 0x0000000000006396FF2a80c067f99B3d2Ab4Df24;

    /// @dev The canonical ERC1967Factory bytecode for EVM chains.
    /// Useful for forge tests:
    /// `vm.etch(ADDRESS, BYTECODE)`.
    bytes internal constant BYTECODE =
        hex"6080604052600436106100b15760003560e01c8063545e7c611161006957806399a88ec41161004e57806399a88ec41461019d578063a97b90d5146101b0578063db4c545e146101c357600080fd5b8063545e7c61146101775780639623609d1461018a57600080fd5b80633729f9221161009a5780633729f922146101315780634314f120146101445780635414dff01461015757600080fd5b80631acfd02a146100b65780632abbef15146100d8575b600080fd5b3480156100c257600080fd5b506100d66100d1366004610604565b6101e6565b005b3480156100e457600080fd5b506101076100f3366004610637565b30600c908152600091909152602090205490565b60405173ffffffffffffffffffffffffffffffffffffffff90911681526020015b60405180910390f35b61010761013f366004610652565b610237565b6101076101523660046106d7565b61024e565b34801561016357600080fd5b50610107610172366004610738565b610267565b610107610185366004610604565b61029a565b6100d66101983660046106d7565b6102af565b6100d66101ab366004610604565b61035f565b6101076101be366004610751565b610370565b3480156101cf57600080fd5b506101d86103a9565b604051908152602001610128565b30600c52816000526020600c2033815414610209576382b429006000526004601cfd5b81905580827f7e644d79422f17c01e4894b5f4f588d331ebfa28653d42ae832dc59e38c9798f600080a35050565b60006102468484843685610370565b949350505050565b600061025e8585838087876103c2565b95945050505050565b6000806102726103a9565b905060ff600053806035523060601b6001528260155260556000209150600060355250919050565b60006102a88383368461024e565b9392505050565b30600c5283600052336020600c2054146102d1576382b429006000526004601cfd5b6040518381527f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc602082015281836040830137600080836040018334895af1610331573d610327576355299b496000526004601cfd5b3d6000803e3d6000fd5b5082847f5d611f318680d00598bb735d61bacf0c514c6b50e1e5ad30040a4df2b12791c7600080a350505050565b61036c82823660006102af565b5050565b60008360601c33148460601c151761039057632f6348366000526004601cfd5b61039f868686600187876103c2565b9695505050505050565b6000806103b461049c565b608960139091012092915050565b6000806103cd61049c565b90508480156103e757866089601384016000f592506103f3565b6089601383016000f092505b50816104075763301164256000526004601cfd5b8781527f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc602082015282846040830137600080846040018334865af161045a573d6103275763301164256000526004601cfd5b30600c5281600052866020600c20558688837fc95935a66d15e0da5e412aca0ad27ae891d20b2fb91cf3994b6a3bf2b8178082600080a4509695505050505050565b6040513060701c801561054257666052573d6000fd607b8301527f3d356020355560408036111560525736038060403d373d3d355af43d6000803e60748301527f3735a920a3ca505d382bbc545af43d6000803e6052573d6000fd5b3d6000f35b60548301527f14605757363d3d37363d7f360894a13ba1a3210667c828492db98dca3e2076cc60348301523060148301526c607f3d8160093d39f33d3d337382525090565b66604c573d6000fd60758301527f3d3560203555604080361115604c5736038060403d373d3d355af43d6000803e606e8301527f3735a920a3ca505d382bbc545af43d6000803e604c573d6000fd5b3d6000f35b604e8301527f14605157363d3d37363d7f360894a13ba1a3210667c828492db98dca3e2076cc602e83015230600e8301526c60793d8160093d39f33d3d336d82525090565b803573ffffffffffffffffffffffffffffffffffffffff811681146105ff57600080fd5b919050565b6000806040838503121561061757600080fd5b610620836105db565b915061062e602084016105db565b90509250929050565b60006020828403121561064957600080fd5b6102a8826105db565b60008060006060848603121561066757600080fd5b610670846105db565b925061067e602085016105db565b9150604084013590509250925092565b60008083601f8401126106a057600080fd5b50813567ffffffffffffffff8111156106b857600080fd5b6020830191508360208285010111156106d057600080fd5b9250929050565b600080600080606085870312156106ed57600080fd5b6106f6856105db565b9350610704602086016105db565b9250604085013567ffffffffffffffff81111561072057600080fd5b61072c8782880161068e565b95989497509550505050565b60006020828403121561074a57600080fd5b5035919050565b60008060008060006080868803121561076957600080fd5b610772866105db565b9450610780602087016105db565b935060408601359250606086013567ffffffffffffffff8111156107a357600080fd5b6107af8882890161068e565b96999598509396509294939250505056fea26469706673582212200ac7c3ccbc2d311c48bf5465b021542e0e306fe3c462c060ba6a3d2f81ff6c5f64736f6c63430008130033";

    /// @dev The initcode used to deploy the canonical ERC1967Factory.
    bytes internal constant INITCODE = abi.encodePacked(
        hex"608060405234801561001057600080fd5b506107f6806100206000396000f3fe", BYTECODE
    );

    /// @dev For deterministic deployment via 0age's ImmutableCreate2Factory.
    bytes32 internal constant SALT =
        0x0000000000000000000000000000000000000000e75e4f228818c80007508f33;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
///
/// @dev Note:
/// - For ETH transfers, please use `forceSafeTransferETH` for DoS protection.
/// - For ERC20s, this implementation won't check that a token has code,
///   responsibility is delegated to the caller.
library SafeTransferLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ETH transfer has failed.
    error ETHTransferFailed();

    /// @dev The ERC20 `transferFrom` has failed.
    error TransferFromFailed();

    /// @dev The ERC20 `transfer` has failed.
    error TransferFailed();

    /// @dev The ERC20 `approve` has failed.
    error ApproveFailed();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Suggested gas stipend for contract receiving ETH that disallows any storage writes.
    uint256 internal constant GAS_STIPEND_NO_STORAGE_WRITES = 2300;

    /// @dev Suggested gas stipend for contract receiving ETH to perform a few
    /// storage reads and writes, but low enough to prevent griefing.
    uint256 internal constant GAS_STIPEND_NO_GRIEF = 100000;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ETH OPERATIONS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // If the ETH transfer MUST succeed with a reasonable gas budget, use the force variants.
    //
    // The regular variants:
    // - Forwards all remaining gas to the target.
    // - Reverts if the target reverts.
    // - Reverts if the current contract has insufficient balance.
    //
    // The force variants:
    // - Forwards with an optional gas stipend
    //   (defaults to `GAS_STIPEND_NO_GRIEF`, which is sufficient for most cases).
    // - If the target reverts, or if the gas stipend is exhausted,
    //   creates a temporary contract to force send the ETH via `SELFDESTRUCT`.
    //   Future compatible with `SENDALL`: https://eips.ethereum.org/EIPS/eip-4758.
    // - Reverts if the current contract has insufficient balance.
    //
    // The try variants:
    // - Forwards with a mandatory gas stipend.
    // - Instead of reverting, returns whether the transfer succeeded.

    /// @dev Sends `amount` (in wei) ETH to `to`.
    function safeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gas(), to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`.
    function safeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer all the ETH and check if it succeeded or not.
            if iszero(call(gas(), to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function forceSafeTransferETH(address to, uint256 amount, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function forceSafeTransferAllETH(address to, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // forgefmt: disable-next-item
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function trySafeTransferETH(address to, uint256 amount, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function trySafeTransferAllETH(address to, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      ERC20 OPERATIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for
    /// the current contract to manage.
    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, amount) // Store the `amount` argument.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x23b872dd000000000000000000000000) // `transferFrom(address,address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends all of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have their entire balance approved for
    /// the current contract to manage.
    function safeTransferAllFrom(address token, address from, address to)
        internal
        returns (uint256 amount)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x60, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x00, 0x23b872dd) // `transferFrom(address,address,uint256)`.
            amount := mload(0x60) // The `amount` is already at 0x60. We'll need to return it.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransfer(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sends all of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransferAll(address token, address to) internal returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x70a08231) // Store the function selector of `balanceOf(address)`.
            mstore(0x20, address()) // Store the address of the current contract.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x34, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x14, to) // Store the `to` argument.
            amount := mload(0x34) // The `amount` is already at 0x34. We'll need to return it.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// Reverts upon failure.
    function safeApprove(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            // Perform the approval, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// If the initial attempt to approve fails, attempts to reset the approved amount to zero,
    /// then retries the approval again (some tokens, e.g. USDT, requires this).
    /// Reverts upon failure.
    function safeApproveWithRetry(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            // Perform the approval, retrying upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x34, 0) // Store 0 for the `amount`.
                mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
                pop(call(gas(), token, 0, 0x10, 0x44, 0x00, 0x00)) // Reset the approval.
                mstore(0x34, amount) // Store back the original `amount`.
                // Retry the approval, reverting upon failure.
                if iszero(
                    and(
                        or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                        call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                    )
                ) {
                    mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Returns the amount of ERC20 `token` owned by `account`.
    /// Returns zero if the `token` does not exist.
    function balanceOf(address token, address account) internal view returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, account) // Store the `account` argument.
            mstore(0x00, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            amount :=
                mul(
                    mload(0x20),
                    and( // The arguments of `and` are evaluated from right to left.
                        gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                        staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)
                    )
                )
        }
    }
}