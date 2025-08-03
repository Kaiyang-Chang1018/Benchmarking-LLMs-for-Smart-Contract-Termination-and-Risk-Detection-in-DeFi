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
// @author: @gizmolab_
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingOriginals is Ownable {
    bool public stakingEnabled = false;

    uint256 public totalStaked;
    uint256 public baseReward = 10;
    address public theOriginalsContract = 0x3A1561Ef33515BBA77A4df88D80aFA9D363900E1;

    struct Stake {
        uint256 tokenId; // 32bits
        uint256 timestamp; // 32bits
        uint256 lockingTier;
    }

    struct lockingTier {
        uint256 lockDays;
        uint256 multiplier;
    }

    mapping(uint256 => lockingTier) public lockingTiers;

    mapping(address => Stake[]) public stakedTokens;
    mapping(uint256 => uint256) public tokenRewards;

    event NFTStaked(
        address owner,
        address tokenAddress,
        uint256 tokenId,
        uint256 value,
        uint256 lockingTier
    );
    event NFTUnstaked(
        address owner,
        address tokenAddress,
        uint256 tokenId,
        uint256 value,
        uint256 lockingTier
    );
    constructor() Ownable(msg.sender) {
        lockingTiers[0] = lockingTier(0, 100); // 1x multiplier (represented as 100)
        lockingTiers[1] = lockingTier(30 days, 120); // 1.2x multiplier
        lockingTiers[2] = lockingTier(60 days, 140); // 1.4x multiplier
        lockingTiers[3] = lockingTier(90 days, 160); // 1.6x multiplier
        lockingTiers[4] = lockingTier(180 days, 200); // 2x multiplier
    }

    /*==============================================================
    ==                    User Staking Functions                  ==
    ==============================================================*/

    function stakeNfts(
        address _contract,
        uint256 _lockingTier,
        uint256[] calldata tokenIds
    ) external {
        require(stakingEnabled == true, "Staking is not enabled yet.");

        IERC721 nftContract = IERC721(_contract);

        for (uint256 i; i < tokenIds.length; i++) {
            require(
                nftContract.ownerOf(tokenIds[i]) == msg.sender,
                "You do not own this token"
            );
            nftContract.transferFrom(msg.sender, address(this), tokenIds[i]);
            stakedTokens[msg.sender].push(
                Stake(tokenIds[i], block.timestamp, _lockingTier)
            );
            emit NFTStaked(
                msg.sender,
                _contract,
                tokenIds[i],
                block.timestamp,
                _lockingTier
            );
            totalStaked++;
        }
    }

    function unstakeNfts(
        address _contract,
        uint256[] calldata tokenIds
    ) external {
        require(stakingEnabled == true, "Staking is not enabled yet.");

        IERC721 nftContract = IERC721(_contract);

        for (uint256 i; i < tokenIds.length; i++) {
            bool isTokenOwner = false;
            uint256 stakeIndex = 0;

            for (uint256 j = 0; j < stakedTokens[msg.sender].length; j++) {
                if (stakedTokens[msg.sender][j].tokenId == tokenIds[i]) {
                    isTokenOwner = true;
                    stakeIndex = j;
                    break;
                }
            }

            require(isTokenOwner, "You do not own this Token");

            Stake memory stake = stakedTokens[msg.sender][stakeIndex];
            uint256 lockPeriod = lockingTiers[stake.lockingTier].lockDays;
            require(
                block.timestamp >= stake.timestamp + lockPeriod,
                "Locking period not over"
            );

            // Calculate rewards only for locked tokens
            if (stake.lockingTier > 0) {
                uint256 rewardAmount = _calculateUnstakeRewards(
                    msg.sender,
                    tokenIds[i]
                );
                tokenRewards[tokenIds[i]] += rewardAmount;
            }

            nftContract.transferFrom(address(this), msg.sender, tokenIds[i]);

            // Remove the stake from the user's array
            stakedTokens[msg.sender][stakeIndex] = stakedTokens[msg.sender][
                stakedTokens[msg.sender].length - 1
            ];
            stakedTokens[msg.sender].pop();

            totalStaked--;

            emit NFTUnstaked(
                msg.sender,
                _contract,
                tokenIds[i],
                block.timestamp,
                stake.lockingTier
            );
        }
    }

    /*==============================================================
    ==                    Burn Function                           ==
    ==============================================================*/

    /*==============================================================
    ==                    Public Get Functions                    ==
    ==============================================================*/

    function getStakedTokens(
        address _user
    ) external view returns (uint256[] memory) {
        Stake[] memory userStakes = stakedTokens[_user];
        uint256[] memory tokenIds = new uint256[](userStakes.length);
        for (uint256 i = 0; i < userStakes.length; i++) {
            tokenIds[i] = userStakes[i].tokenId;
        }
        return tokenIds;
    }

    function getStakedTokensLength(
        address _user
    ) external view returns (uint256) {
        return stakedTokens[_user].length;
    }
    function getUserRewards(
        address _user,
        uint256[] memory _tokenIds
    ) external view returns (uint256) {
        uint256 totalRewards = 0;

        // Get all staked tokens for the user
        Stake[] memory userStakes = stakedTokens[_user];
        uint256[] memory stakedTokenIds = new uint256[](userStakes.length);
        for (uint256 i = 0; i < userStakes.length; i++) {
            stakedTokenIds[i] = userStakes[i].tokenId;
        }

        // Calculate rewards for staked tokens
        totalRewards += _calculateRewards(_user, stakedTokenIds);

        // Add rewards for all tokens (staked and unstaked)
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            totalRewards += tokenRewards[_tokenIds[i]];
        }

        return totalRewards;
    }
    /*==============================================================
    ==                    Owner Functions                         ==
    ==============================================================*/

    function setStakingEnabled(bool _enabled) external onlyOwner {
        stakingEnabled = _enabled;
    }

    function setBaseReward(uint256 _reward) external onlyOwner {
        baseReward = _reward;
    }

    function setTheOriginalsContract(address _contract) external onlyOwner {
        theOriginalsContract = _contract;
    }

    function setLockingTiers(
        uint256 _tier,
        uint256 _lockDays,
        uint256 _multiplier
    ) external onlyOwner {
        lockingTiers[_tier] = lockingTier(_lockDays, _multiplier);
    }

    /*==============================================================
    ==                     Reward Calculate Functions             ==
    ==============================================================*/

    function _calculateRewards(
        address _user,
        uint256[] memory _tokenIds
    ) internal view returns (uint256) {
        uint256 totalReward = 0;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 tokenId = _tokenIds[i];

            // Find the stake for this token ID
            Stake memory stake;
            bool found = false;
            for (uint256 j = 0; j < stakedTokens[_user].length; j++) {
                if (stakedTokens[_user][j].tokenId == tokenId) {
                    stake = stakedTokens[_user][j];
                    found = true;
                    break;
                }
            }

            require(found, "Stake not found for token");

            uint256 timeSinceLastClaim = block.timestamp - stake.timestamp;
            uint256 lockingMultiplier = lockingTiers[stake.lockingTier]
                .multiplier;

            // Calculate new reward since last claim
            uint256 reward = (timeSinceLastClaim *
                baseReward *
                lockingMultiplier) / (100 * 1 days);
            totalReward += reward;
        }
        return totalReward;
    }

    function _calculateUnstakeRewards(
        address _user,
        uint256 _tokenId
    ) internal view returns (uint256) {
        // Find the stake for this token ID
        Stake memory stake;
        bool found = false;
        for (uint256 j = 0; j < stakedTokens[_user].length; j++) {
            if (stakedTokens[_user][j].tokenId == _tokenId) {
                stake = stakedTokens[_user][j];
                found = true;
                break;
            }
        }

        require(found, "Stake not found for token");

        uint256 reward = 0;
        if (stake.lockingTier > 0) {
            uint256 lockPeriod = lockingTiers[stake.lockingTier].lockDays;
            if (block.timestamp >= stake.timestamp + lockPeriod) {
                uint256 timeSinceStake = block.timestamp - stake.timestamp;
                uint256 rewardPeriod = timeSinceStake - lockPeriod;
                uint256 rewardPerToken = baseReward;
                uint256 lockingMultiplier = lockingTiers[stake.lockingTier]
                    .multiplier;

                reward =
                    (rewardPeriod * rewardPerToken * lockingMultiplier) /
                    (100 * 1 days);
            }
        }
        return reward;
    }
}