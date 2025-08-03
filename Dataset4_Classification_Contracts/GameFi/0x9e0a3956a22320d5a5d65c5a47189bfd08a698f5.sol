// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SlotContractV3 is Ownable {
    IERC20 public bettingToken;
    IERC20 public WETH;
    uint256 public immutable minimumBet;
    uint256 public immutable revenueBps;

    constructor(
        address _bettingToken,
        address _WETH,
        uint256 _minimumBet,
        uint256 _revenueBps,
        uint256 _playerPercentage,
        uint256 _holderPercentage
    ) {
        revenueBps = _revenueBps;
        bettingToken = IERC20(_bettingToken);
        WETH = IERC20(_WETH);
        minimumBet = _minimumBet;
        playerPercentage = _playerPercentage;
        holderPercentage = _holderPercentage;
    }

    mapping(address => uint256) public claimedHolderShares;
    mapping(int64 => mapping(address => uint256)) public claimedPlayerShares;
    mapping(int64 => mapping(address => uint256)) public unclaimedPlayerShares;
    mapping(address => uint256) public unclaimedHolderRewards;
    uint256 public totalUnclaimedHolderRewards;
    uint256 public totalRevenuePlayers;
    uint256 public totalRevenueHolders;
    uint256 public totalPlayerShares;
    uint256 public playerPercentage;
    uint256 public holderPercentage;

    struct Game {
        uint256 minBet;
        uint256[] betAmounts;
        address[] players;
        bool inProgress;
        uint16 loser;
    }

    mapping(int64 => Game) public games;
    int64[] public activeTgGroups;

    event Bet(int64 tgChatId, address player, uint256 amount);
    event Win(int64 tgChatId, address player, uint256 amount);
    event Loss(int64 tgChatId, address player, uint256 amount);
    event Revenue(int64 tgChatId, uint256 amount);

    function isGameInProgress(int64 _tgChatId) public view returns (bool) {
        return games[_tgChatId].inProgress;
    }

    function removeTgId(int64 _tgChatId) internal {
        for (uint256 i = 0; i < activeTgGroups.length; i++) {
            if (activeTgGroups[i] == _tgChatId) {
                activeTgGroups[i] = activeTgGroups[activeTgGroups.length - 1];
                activeTgGroups.pop();
            }
        }
    }

    function updatePlayerPercentage(uint256 newPercentage) public onlyOwner {
        require(newPercentage <= 100, "Percentage must be <= 100");
        playerPercentage = newPercentage;
    }

    function updateHolderPercentage(uint256 newPercentage) public onlyOwner {
        require(newPercentage <= 100, "Percentage must be <= 100");
        holderPercentage = newPercentage;
    }

    function addTokensToRevenueHolders(uint256 amount) public onlyOwner {
        totalRevenueHolders += amount;
        bettingToken.transferFrom(msg.sender, address(this), amount);
    }

    function addTokensToRevenuePlayers(uint256 amount) public onlyOwner {
        totalRevenuePlayers += amount;
        bettingToken.transferFrom(msg.sender, address(this), amount);
    }

    function claimRevenueShare(int64 _tgChatId) public {
        uint256 unclaimedShare = unclaimedPlayerShares[_tgChatId][msg.sender];
        uint256 playerReward = 0;

        if (unclaimedShare > 0 && totalPlayerShares > 0) {
            uint256 playerShare = (unclaimedShare * 10000) / totalPlayerShares;
            playerReward = (playerShare * totalRevenuePlayers) / 10000;
        }

        uint256 holderReward = unclaimedHolderRewards[msg.sender];
        uint256 userReward = playerReward + holderReward;

        totalRevenueHolders -= holderReward;

        claimedPlayerShares[_tgChatId][msg.sender] += playerReward;
        claimedHolderShares[msg.sender] += holderReward;
        totalUnclaimedHolderRewards -= holderReward;
        totalRevenuePlayers -= playerReward;
        totalPlayerShares -= unclaimedShare;
        unclaimedHolderRewards[msg.sender] = 0;
        unclaimedPlayerShares[_tgChatId][msg.sender] = 0;

        bettingToken.transfer(msg.sender, userReward);
    }

    function getPlayerRewards(int64 _tgChatId, address _player)
        public
        view
        returns (uint256)
    {
        uint256 unclaimedShare = unclaimedPlayerShares[_tgChatId][_player];
        if (unclaimedShare == 0) {
            return 0;
        }

        uint256 playerShare = (unclaimedShare * 10000) / totalPlayerShares;
        uint256 playerReward = (playerShare * totalRevenuePlayers) / 10000;

        return playerReward;
    }

    function updateHolderRewards(
        address[] memory holders,
        uint256[] memory rewards
    ) public onlyOwner {
        require(holders.length == rewards.length, "Array length mismatch");

        for (uint256 i = 0; i < holders.length; i++) {
            address holder = holders[i];
            uint256 holderReward = rewards[i];

            unclaimedHolderRewards[holder] = holderReward;
        }
    }

    function updateTotalUnclaimedRewards(uint256 newTotal) public onlyOwner {
        totalUnclaimedHolderRewards = newTotal;
    }

    function newGame(
        int64 _tgChatId,
        uint256 _minBet,
        address[] memory _players,
        uint256[] memory _bets,
        bool useWETH
    ) public onlyOwner returns (uint256[] memory) {
        require(
            _players.length == _bets.length,
            "Players/bets length mismatch"
        );
        require(
            !isGameInProgress(_tgChatId),
            "There is already a game in progress"
        );

        uint256 betTotal = 0;
        for (uint16 i = 0; i < _bets.length; i++) {
            require(_bets[i] >= _minBet, "Bet is smaller than the minimum");
            betTotal += _bets[i];
        }

        IERC20 chosenToken = useWETH ? WETH : bettingToken;

        for (uint16 i = 0; i < _bets.length; i++) {
            require(
                chosenToken.allowance(_players[i], address(this)) >= _bets[i],
                "Not enough allowance"
            );
            bool isSent = chosenToken.transferFrom(
                _players[i],
                address(this),
                _bets[i]
            );
            require(isSent, "Funds transfer failed");

            emit Bet(_tgChatId, _players[i], _bets[i]);
        }

        Game memory g;
        g.minBet = _minBet;
        g.betAmounts = _bets;
        g.players = _players;
        g.inProgress = true;

        games[_tgChatId] = g;
        activeTgGroups.push(_tgChatId);

        return _bets;
    }

    function endGame(
        int64 _tgChatId,
        address _winner,
        bool usedWETH
    ) public onlyOwner {
        require(
            isGameInProgress(_tgChatId),
            "No game in progress for this Telegram chat ID"
        );

        Game storage g = games[_tgChatId];
        require(g.inProgress, "Game is not in progress");

        uint256 totalBets = 0;
        for (uint16 i = 0; i < g.betAmounts.length; i++) {
            totalBets += g.betAmounts[i];
        }

        uint256 revenueShare = (totalBets * revenueBps) / 10000;
        uint256 winnings = totalBets - revenueShare;

        uint256 revenuePlayers = (revenueShare * playerPercentage) / 100;

        IERC20 chosenToken = usedWETH ? WETH : bettingToken;

        chosenToken.transfer(_winner, winnings);
        emit Win(_tgChatId, _winner, winnings);

        emit Revenue(_tgChatId, revenueShare);

        totalRevenuePlayers += revenuePlayers;
        totalRevenueHolders += (revenueShare * holderPercentage) / 100;

        totalPlayerShares += revenuePlayers;

        for (uint16 i = 0; i < g.players.length; i++) {
            address player = g.players[i];
            uint256 playerShare = (revenuePlayers * g.betAmounts[i]) /
                totalBets;
            unclaimedPlayerShares[_tgChatId][player] += playerShare;
        }

        chosenToken.transfer(address(this), revenueShare);

        g.inProgress = false;
        removeTgId(_tgChatId);
    }

    function abortGame(int64 _tgChatId, bool usedWETH) public onlyOwner {
        require(
            isGameInProgress(_tgChatId),
            "No game in progress for this Telegram chat ID"
        );
        Game storage g = games[_tgChatId];

        IERC20 chosenToken = usedWETH ? WETH : bettingToken;

        for (uint16 i = 0; i < g.players.length; i++) {
            bool isSent = chosenToken.transfer(g.players[i], g.betAmounts[i]);
            require(isSent, "Funds transfer failed");
        }

        g.inProgress = false;
        removeTgId(_tgChatId);
    }

    function abortAllGames(bool usedWETH) public onlyOwner {
        int64[] memory _activeTgGroups = activeTgGroups;
        for (uint256 i = 0; i < _activeTgGroups.length; i++) {
            abortGame(_activeTgGroups[i], usedWETH);
        }
    }

    function setBettingToken(address _newBettingToken) public onlyOwner {
        require(_newBettingToken != address(0), "Invalid token address");
        bettingToken = IERC20(_newBettingToken);
    }

    function setWETH(address _newWETH) public onlyOwner {
        require(_newWETH != address(0), "Invalid token address");
        WETH = IERC20(_newWETH);
    }

    function emergencyWithdrawERC20(address tokenAddress, address to)
        external
        onlyOwner
    {
        IERC20 token = IERC20(tokenAddress);
        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenBalance > 0, "No tokens to withdraw");
        totalRevenueHolders = 0;
        totalRevenuePlayers = 0;

        token.transfer(to, tokenBalance);
    }

    function emergencyWithdrawEther(address payable to) external onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No Ether to withdraw");

        (bool success, ) = to.call{value: contractBalance}("");
        require(success, "Withdraw failed");
    }
}