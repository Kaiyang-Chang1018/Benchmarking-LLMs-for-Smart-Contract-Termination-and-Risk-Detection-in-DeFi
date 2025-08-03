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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.20;

import {IERC721Receiver} from "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or
 * {IERC721-setApprovalForAll}.
 */
abstract contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTStaking is ERC721Holder, Ownable {
    IERC721 public nftToken;
    uint256 public constant TOKENS_PER_NFT = 1000;
    uint256 public constant APR = 200; // 6.9% APR
    uint256 public constant ROUND_DURATION = 45 days;
    uint256 public constant ROUND_COOLDOWN = 5 days;
    uint256 public constant ROUNDS_COUNT = 3;

    struct Stake {
        uint256 tokenId;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        uint256 stakedRound;
    }

    struct Round {
        uint256 startTime;
        uint256 endTime;
        bool isActive;
    }

    struct UserInfo {
        Stake[] stakes;
        uint256 totalRewards;
    }

    mapping(address => UserInfo) public userInfo;
    mapping(uint256 => Round) public rounds;
    uint256 public currentRoundIndex;
    bool public allRoundsEnded;
    address[] public stakers;
    mapping(address => bool) public isStaker;

    event Staked(
        address indexed user,
        uint256 tokenId,
        uint256 timestamp,
        uint256 roundIndex
    );
    event Unstaked(address indexed user, uint256 tokenId, uint256 timestamp);
    event RoundStarted(uint256 roundIndex, uint256 startTime, uint256 endTime);
    event RoundEnded(uint256 roundIndex, uint256 endTime);
    event RewardsCalculated(address indexed user, uint256 rewards);

    constructor(address _nftToken) Ownable(msg.sender) {
        nftToken = IERC721(_nftToken);
    }

    function stake(uint256 tokenId) external {
        require(!allRoundsEnded, "Staking has ended");
        require(
            rounds[currentRoundIndex].isActive,
            "Current round is not active"
        );

        UserInfo storage user = userInfo[msg.sender];
        bool found = false;

        for (uint256 i = 0; i < user.stakes.length; i++) {
            if (user.stakes[i].tokenId == tokenId) {
                require(!user.stakes[i].isActive, "NFT is already staked");
                user.stakes[i].startTime = block.timestamp;
                user.stakes[i].endTime = 0;
                user.stakes[i].isActive = true;
                user.stakes[i].stakedRound = currentRoundIndex;
                found = true;
                break;
            }
        }

        if (!found) {
            nftToken.safeTransferFrom(msg.sender, address(this), tokenId);
            user.stakes.push(
                Stake(tokenId, block.timestamp, 0, true, currentRoundIndex)
            );
        }

        if (!isStaker[msg.sender]) {
            stakers.push(msg.sender);
            isStaker[msg.sender] = true;
        }

        emit Staked(msg.sender, tokenId, block.timestamp, currentRoundIndex);
    }

    function unstake(uint256 tokenId) external {
        UserInfo storage user = userInfo[msg.sender];
        for (uint256 i = 0; i < user.stakes.length; i++) {
            if (user.stakes[i].tokenId == tokenId) {
                require(user.stakes[i].isActive, "NFT is not currently staked");
                require(
                    isRoundEnded(user.stakes[i].stakedRound),
                    "Cannot unstake before the staked round ends"
                );

                _calculateAndUpdateRewards(msg.sender, i);

                user.stakes[i].endTime = block.timestamp;
                user.stakes[i].isActive = false;

                nftToken.safeTransferFrom(address(this), msg.sender, tokenId);

                emit Unstaked(msg.sender, tokenId, block.timestamp);
                return;
            }
        }
        revert("Stake not found");
    }

    function _calculateAndUpdateRewards(
        address user,
        uint256 stakeIndex
    ) internal {
        UserInfo storage userInfo = userInfo[user];
        Stake storage stake = userInfo.stakes[stakeIndex];

        uint256 endTime = stake.isActive ? block.timestamp : stake.endTime;
        uint256 stakeDuration = endTime - stake.startTime;
        uint256 reward = (TOKENS_PER_NFT * stakeDuration * APR) /
            (365 days) /
            100;

        userInfo.totalRewards += reward;
        emit RewardsCalculated(user, userInfo.totalRewards);
    }

    function getUserRewards(address user) public view returns (uint256) {
        return userInfo[user].totalRewards;
    }

    function rescueNFT(uint256 nftId) external onlyOwner {
        nftToken.safeTransferFrom(address(this), msg.sender, nftId);
    }

    function _startNewRound() internal {
        currentRoundIndex++;
        require(currentRoundIndex <= ROUNDS_COUNT, "All rounds completed");

        uint256 startTime = block.timestamp;
        if (currentRoundIndex > 1) {
            startTime = rounds[currentRoundIndex - 1].endTime + ROUND_COOLDOWN;
        }

        uint256 endTime = startTime + ROUND_DURATION;
        rounds[currentRoundIndex] = Round(startTime, endTime, true);

        emit RoundStarted(currentRoundIndex, startTime, endTime);
    }

    function startRoundEarly() external onlyOwner {
        require(
            !rounds[currentRoundIndex].isActive,
            "Previous round is still active"
        );

        _startNewRound();
    }

    function endRoundEarly() external onlyOwner {
        require(currentRoundIndex > 0, "No active round");
        Round storage currentRound = rounds[currentRoundIndex];
        require(currentRound.isActive, "Round is not active");

        currentRound.endTime = block.timestamp;
        currentRound.isActive = false;

        emit RoundEnded(currentRoundIndex, block.timestamp);

        if (currentRoundIndex < ROUNDS_COUNT) {
            _startNewRound();
        } else {
            allRoundsEnded = true;
        }
    }

    function getCurrentRound()
        external
        view
        returns (uint256, uint256, uint256, bool)
    {
        Round memory currentRound = rounds[currentRoundIndex];
        return (
            currentRoundIndex,
            currentRound.startTime,
            currentRound.endTime,
            currentRound.isActive
        );
    }

    function calculateAllRewards() external onlyOwner {
        require(allRoundsEnded, "All rounds have not ended yet");

        for (uint256 i = 0; i < stakers.length; i++) {
            address user = stakers[i];
            UserInfo storage userInfo = userInfo[user];
            for (uint256 j = 0; j < userInfo.stakes.length; j++) {
                if (userInfo.stakes[j].isActive) {
                    _calculateAndUpdateRewards(user, j);
                    userInfo.stakes[j].isActive = false;
                    userInfo.stakes[j].endTime = block.timestamp;
                }
            }
        }
    }

    function getStakersCount() external view returns (uint256) {
        return stakers.length;
    }

    function isRoundEnded(uint256 roundIndex) public view returns (bool) {
        require(
            roundIndex > 0 && roundIndex <= currentRoundIndex,
            "Invalid round index"
        );
        return block.timestamp > rounds[roundIndex].endTime;
    }

    // New function to get the number of staked NFTs for a given user
    function getStakedNFTCount(address user) external view returns (uint256) {
        UserInfo storage userInfo = userInfo[user];
        uint256 count = 0;
        for (uint256 i = 0; i < userInfo.stakes.length; i++) {
            if (userInfo.stakes[i].isActive) {
                count++;
            }
        }
        return count;
    }
}