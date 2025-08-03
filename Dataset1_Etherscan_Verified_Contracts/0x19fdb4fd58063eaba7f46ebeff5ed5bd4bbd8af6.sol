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
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.20;

import {Ownable} from "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.20;

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
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
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
pragma solidity 0.8.25;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "./interfaces/IRKLStaker.sol";
import "./interfaces/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract RKLStaker is IRKLStaker, Ownable2Step, IERC721Receiver {
    uint256 public paused;
    uint256 public constant MAX_STAKE_DURATION = 18 * 30 days; // 18 months
    address public immutable kongsAddress;
    address public immutable rookiesAddress;
    address public immutable clubsAddress;
    mapping(address => uint256) public allowedCollections;
    mapping(address => mapping(uint256 => address)) public tokenOwners;
    mapping(address => mapping(address => uint256)) public accruedRewards;
    mapping(address => mapping(uint256 => uint256)) public stakeStartTimestamp;
    mapping(address => mapping(uint256 => uint256)) public tokenStakedTime;

    constructor(address _kongsAddress, address _rookiesAddress, address _clubsAddress) Ownable(msg.sender) {
        kongsAddress = _kongsAddress;
        rookiesAddress = _rookiesAddress;
        clubsAddress = _clubsAddress;
        allowedCollections[kongsAddress] = 1;
        allowedCollections[rookiesAddress] = 1;
        allowedCollections[clubsAddress] = 1;
        paused = 0;
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function batchStake(address[] calldata collections, uint256[] calldata tokenIds) public {
        for (uint256 i = 0; i < collections.length; i++) {
            stake(collections[i], tokenIds[i]);
        }
    }

    function stake(address collection, uint256 tokenId) public {
        if (paused == 1) {
            revert ContractIsPaused();
        }
        if (allowedCollections[collection] == 0) {
            revert CollectionNotAllowed();
        }
        if (IERC721(collection).ownerOf(tokenId) != msg.sender) {
            revert NotOwner();
        }
        if (tokenStakedTime[collection][tokenId] >= MAX_STAKE_DURATION) {
            revert TokenStakedForMaxDuration();
        }
        tokenOwners[collection][tokenId] = msg.sender;
        stakeStartTimestamp[collection][tokenId] = block.timestamp;
        IERC721(collection).safeTransferFrom(msg.sender, address(this), tokenId);
        emit Staked(
            msg.sender,
            collection,
            tokenId,
            block.timestamp
        );
    }

    function withdraw(address collection, uint256 tokenId) public {
        if (paused == 1) {
            revert ContractIsPaused();
        }
        if (stakeStartTimestamp[collection][tokenId] == 0) {
            revert NotStaked();
        }
        if (tokenOwners[collection][tokenId] != msg.sender) {
            revert NotOwner();
        }
        tokenOwners[collection][tokenId] = address(0);
        uint256 currentStakedTime = (block.timestamp - stakeStartTimestamp[collection][tokenId]);
        uint256 reward = 0;
        if (tokenStakedTime[collection][tokenId] + currentStakedTime > MAX_STAKE_DURATION) {
            reward = MAX_STAKE_DURATION - tokenStakedTime[collection][tokenId];
        } else {
            reward = currentStakedTime;
        }
        accruedRewards[collection][msg.sender] += reward;
        tokenStakedTime[collection][tokenId] += reward;
        stakeStartTimestamp[collection][tokenId] = 0;
        IERC721(collection).safeTransferFrom(address(this), msg.sender, tokenId);
        emit Unstaked(
            msg.sender,
            collection,
            tokenId,
            block.timestamp
        );
    }

    function getAccruedRewards(address user) public view returns (uint256) {
        return accruedRewards[kongsAddress][user] + accruedRewards[rookiesAddress][user] + accruedRewards[clubsAddress][user];
    }

    function batchWithdraw(address[] calldata collections, uint256[] calldata tokenIds) public {
        for (uint256 i = 0; i < collections.length; i++) {
            withdraw(collections[i], tokenIds[i]);
        }
    }

    function allowCollection(address collection) public onlyOwner {
        if (collection == address(0)) {
            revert SettingZeroAddress();
        }
        allowedCollections[collection] = 1;
    }

    function disallowCollection(address collection) public onlyOwner {
        allowedCollections[collection] = 0;
    }

    function getKongOwner(uint256 tokenId) public view returns (address) {
        return tokenOwners[kongsAddress][tokenId];
    }

    function getRookieOwner(uint256 tokenId) public view returns (address) {
        return tokenOwners[rookiesAddress][tokenId];
    }

    function getClubOwner(uint256 tokenId) public view returns (address) {
        return tokenOwners[clubsAddress][tokenId];
    }

    function getKongsStakedTime(uint256 tokenId) public view returns (uint256) {
        return tokenStakedTime[kongsAddress][tokenId];
    }

    function getRookiesStakedTime(uint256 tokenId) public view returns (uint256) {
        return tokenStakedTime[rookiesAddress][tokenId];
    }

    function getClubsStakedTime(uint256 tokenId) public view returns (uint256) {
        return tokenStakedTime[clubsAddress][tokenId];
    }

    function getKongRemainingStakeDuration(uint256 tokenId) public view returns (uint256) {
        return getRemainingStakeDuration(kongsAddress, tokenId);
    }

    function getRookieRemainingStakeDuration(uint256 tokenId) public view returns (uint256) {
        return getRemainingStakeDuration(rookiesAddress, tokenId);
    }

    function getClubRemainingStakeDuration(uint256 tokenId) public view returns (uint256) {
        return getRemainingStakeDuration(clubsAddress, tokenId);
    }
    
    function getRemainingStakeDuration(address collection, uint256 tokenId) public view returns (uint256) {
        uint256 currentStakedTime = 0;
        if (stakeStartTimestamp[collection][tokenId] > 0) {
            currentStakedTime = block.timestamp - stakeStartTimestamp[collection][tokenId];
        }
        return MAX_STAKE_DURATION - tokenStakedTime[collection][tokenId] - currentStakedTime;
    }


    function getRemainingStakeDurations(address[] calldata collections, uint256[][] calldata tokenIds) public view returns (uint256[][] memory) {
        uint256[][] memory remainingStakeDurations = new uint256[][](collections.length);
        for (uint256 i = 0; i < collections.length; i++) {
            remainingStakeDurations[i] = new uint256[](tokenIds[i].length);
            for (uint256 j = 0; j < tokenIds[i].length; j++) {
                remainingStakeDurations[i][j] = getRemainingStakeDuration(collections[i], tokenIds[i][j]);
            }
        }
        return remainingStakeDurations;
    }

    function getBatchTokenOwners(address[] calldata collections, uint256[][] calldata tokenIds) public view returns (address[][] memory) {
        address[][] memory result = new address[][](collections.length);
        for (uint256 i = 0; i < collections.length; i++) {
            result[i] = new address[](tokenIds[i].length);
            for (uint256 j = 0; j < tokenIds[i].length; j++) {
                result[i][j] = tokenOwners[collections[i]][tokenIds[i][j]];
            }
        }
        return result;
    }

    function getBatchTokenStakedTimes(address[] calldata collections, uint256[][] calldata tokenIds) public view returns (uint256[][] memory) {
        uint256[][] memory tokenStakedTimes = new uint256[][](collections.length);
        for (uint256 i = 0; i < collections.length; i++) {
            tokenStakedTimes[i] = new uint256[](tokenIds[i].length);
            for (uint256 j = 0; j < tokenIds[i].length; j++) {
                tokenStakedTimes[i][j] = tokenStakedTime[collections[i]][tokenIds[i][j]];
            }
        }
        return tokenStakedTimes;
    }

    function getBatchStakeStartTimestamps(address[] calldata collections, uint256[][] calldata tokenIds) public view returns (uint256[][] memory) {
        uint256[][] memory stakeStartTimestamps = new uint256[][](collections.length);
        for (uint256 i = 0; i < collections.length; i++) {
            stakeStartTimestamps[i] = new uint256[](tokenIds[i].length);
            for (uint256 j = 0; j < tokenIds[i].length; j++) {
                stakeStartTimestamps[i][j] = stakeStartTimestamp[collections[i]][tokenIds[i][j]];
            }
        }
        return stakeStartTimestamps;
    }

    function getSeperateAccruedRewards(address user) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](3);
        result[0] = accruedRewards[kongsAddress][user];
        result[1] = accruedRewards[rookiesAddress][user];
        result[2] = accruedRewards[clubsAddress][user];
        return result;
    }

    function getTokenOwner(address collection, uint256 tokenId) public view returns (address) {
        return tokenOwners[collection][tokenId];
    }

    function togglePause() public onlyOwner {
        paused = paused == 0 ? 1 : 0;
    }
}
pragma solidity ^0.8.22;

interface IERC721 {
    function balanceOf(address account) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IRKLStaker {
    error CollectionNotAllowed();
    error NotOwner();
    error NotStaked();
    error AlreadyStaked();
    error TokenStakedForMaxDuration();
    error SettingZeroAddress();
    error ContractIsPaused();
    event Staked(
        address indexed staker,
        address indexed collection,
        uint256 tokenId,
        uint256 timestamp
    );

    event Unstaked(
        address indexed staker,
        address indexed collection,
        uint256 tokenId,
        uint256 timestamp
    );
    
    function stake(address collection, uint256 tokenId) external;
    function withdraw(address collection, uint256 tokenId) external;
    function getTokenOwner(address collection, uint256 tokenId) external view returns (address);
    function getAccruedRewards(address user) external view returns (uint256);
    function batchWithdraw(address[] calldata collections, uint256[] calldata tokenIds) external;
    function allowCollection(address collection) external;
    function disallowCollection(address collection) external;
    function getKongOwner(uint256 tokenId) external view returns (address);
    function getRookieOwner(uint256 tokenId) external view returns (address);
    function getClubOwner(uint256 tokenId) external view returns (address);
    function getKongRemainingStakeDuration(uint256 tokenId) external view returns (uint256);
    function getRookieRemainingStakeDuration(uint256 tokenId) external view returns (uint256);
    function getClubRemainingStakeDuration(uint256 tokenId) external view returns (uint256);
    function getRemainingStakeDurations(address[] calldata collections, uint256[][] calldata tokenIds) external view returns (uint256[][] memory);
    function getBatchTokenOwners(address[] calldata collections, uint256[][] calldata tokenIds) external view returns (address[][] memory);
    function getBatchTokenStakedTimes(address[] calldata collections, uint256[][] calldata tokenIds) external view returns (uint256[][] memory);
    function getBatchStakeStartTimestamps(address[] calldata collections, uint256[][] calldata tokenIds) external view returns (uint256[][] memory);
    function getSeperateAccruedRewards(address user) external view returns (uint256[] memory);
}