// SPDX-License-Identifier: UNLICENSED

/**
 WELCOME TO ZE DICE ROULETTE.
 DIVE INTO THE WORLD OF PUMPMENTAL BETTING.


    .-------.
   / *   * /|
  / *   * / |
 .-------.* |
 | *   * | *.
 | *   * | /
 | *   * |/
 '-------'

Website: https://wagerzz.gg/
Telegram: https://t.me/wagerZz_gg
X: https://twitter.com/wagerzz_gg
**/

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.2

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


// File contracts/TelegramDiceRoulette/telegramDiceRoulette.sol


/**
 WELCOME TO ZE DICE ROULETTE.
 DIVE INTO THE WORLD OF PUMPMENTAL BETTING.


    .-------.
   / *   * /|
  / *   * / |
 .-------.* |
 | *   * | *.
 | *   * | /
 | *   * |/
 '-------'

Website: https://wagerzz.gg/
Telegram: https://t.me/wagerZz_gg
X: https://twitter.com/wagerzz_gg
**/

pragma solidity 0.8.15;

contract TelegramDiceRoulette {

    IERC20 public bettingToken;
    address public owner;
    address public collectorWallet;
    uint16 public protocolFeeBps = 0; // 1% (100 basis points)
    uint16 public burnBps = 0;    // 1% (100 basis points)
    address public maintainer;
    uint32 private cardIdCounter = 0;
    // Mapping from the player's Ethereum address to their unique cardId
    mapping(address => uint32) public playerCards;

    struct Game {
        bool inProgress;
        address[] players;
        uint256[] bets;
        bytes32 hashedPredictedOutcomes;
        address[] winners;
    }

    mapping(int64 => Game) public games;
    int64[] public allTgChats;

    event NewGame(int64 indexed tgChatId, address indexed player, uint256 betAmount, bytes32 hashedPredictedOutcomes);
    event Win(int64 indexed tgChatId, address indexed winner, uint256 amountWon);
    event Collected(int64 indexed tgChatId, uint256 amount);
    event Burn(int64 indexed tgChatId, uint256 amount);
    event GameAborted(int64 indexed tgChatId);

    modifier onlyOwnerOrMaintainer() {
        require(msg.sender == owner || msg.sender == maintainer, "Not the owner or maintainer");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(address _bettingToken, address _collectorWallet, address _maintainer) {
        bettingToken = IERC20(_bettingToken);
        collectorWallet = _collectorWallet;
        owner = msg.sender;
        maintainer = _maintainer;
    }

    function setParameters(uint16 _protocolFeeBps, uint16 _burnBps, address _collectorWallet) public onlyOwner {
        require(_protocolFeeBps + _burnBps <= 10000, "Total BPS can't exceed 10000");
        protocolFeeBps = _protocolFeeBps;
        burnBps = _burnBps;
        collectorWallet = _collectorWallet;
    }

    /**
     * @dev Create a new player card for the caller and assign a unique cardId
     * @param secret The secret that the bot is expecting.
     * @return The assigned cardId for the new player card
     */
    function createPlayerCard(uint32 secret) external returns (uint32) {
        // Check if the user already has a player card
        require(playerCards[msg.sender] == 0, "User already has a player card");
        // Increment the cardId counter
        cardIdCounter++;
        // Assign the new cardId to the caller's address
        playerCards[msg.sender] = cardIdCounter;
        // Return the assigned cardId to the caller
        return cardIdCounter;
    }

    function newGame(int64 _tgChatId, address[] memory _players, uint256[] memory _bets, bytes32 _hashedPredictedOutcomes) public onlyOwnerOrMaintainer {
        require(_players.length == _bets.length, "Players and bets arrays length mismatch");
        require(!games[_tgChatId].inProgress, "Game already in progress for this chat ID");

        uint256 totalTransferred = 0;
        for (uint16 i = 0; i < _players.length; i++) {
            require(bettingToken.transferFrom(_players[i], address(this), _bets[i]), "Token transfer failed");
            totalTransferred += _bets[i];
        }

        games[_tgChatId] = Game({
        inProgress: true,
        players: _players,
        bets: _bets,
        hashedPredictedOutcomes: _hashedPredictedOutcomes,
        winners: new address[](0)
        });
        allTgChats.push(_tgChatId);

        emit NewGame(_tgChatId, msg.sender, totalTransferred, _hashedPredictedOutcomes);
    }

    function endGame(int64 _tgChatId, address[] memory winners) public onlyOwnerOrMaintainer {
        require(games[_tgChatId].inProgress, "No game in progress for this chat ID.");

        uint256 totalPot = 0;
        uint256 totalWinningBets = 0;
        uint256 fees = 0;
        uint256 burnAmount = 0;
        uint256 distributablePot = 0;
        uint256[] memory winnerBets = new uint256[](winners.length);

        for (uint16 i = 0; i < games[_tgChatId].players.length; i++) {
            totalPot += games[_tgChatId].bets[i];
        }

        // Calculate total winning bets and store individual winner bets
        for (uint16 i = 0; i < winners.length; i++) {
            for (uint16 j = 0; j < games[_tgChatId].players.length; j++) {
                if (winners[i] == games[_tgChatId].players[j]) {
                    totalWinningBets += games[_tgChatId].bets[j];
                    winnerBets[i] = games[_tgChatId].bets[j];
                    break;
                }
            }
        }

        fees = (totalPot * protocolFeeBps) / 10000;
        burnAmount = (totalPot * burnBps) / 10000;
        distributablePot = totalPot - fees - burnAmount;

        // Distribute the winnings proportionally based on each winner's bet
        for (uint16 i = 0; i < winners.length; i++) {
            uint256 playerWinnings = (winnerBets[i] * distributablePot) / totalWinningBets;
            require(bettingToken.transfer(winners[i], playerWinnings), "Winnings transfer failed.");
            emit Win(_tgChatId, winners[i], playerWinnings);
        }

        // Transfer fees and burn amounts
        if (fees > 0) {
            require(bettingToken.transfer(collectorWallet, fees), "protcol fee transfer failed.");
            emit Collected(_tgChatId, fees);
        }
        if (burnAmount > 0) {
            require(bettingToken.transfer(address(0xdead), burnAmount), "burnAmount transfer failed.");
            emit Burn(_tgChatId, burnAmount);
        }

        // Update the game details with the winners and mark the game as ended
        games[_tgChatId].winners = winners;
        games[_tgChatId].inProgress = false;
    }

    function abortGame(int64 _tgChatId) public onlyOwnerOrMaintainer {
        require(games[_tgChatId].inProgress, "No game in progress for this chat ID.");

        for (uint16 i = 0; i < games[_tgChatId].players.length; i++) {
            require(bettingToken.transfer(games[_tgChatId].players[i], games[_tgChatId].bets[i]), "Refund transfer failed.");
        }

        games[_tgChatId].inProgress = false;
        emit GameAborted(_tgChatId);
    }

    function abortAllGames() public onlyOwnerOrMaintainer {
        for (uint256 i = 0; i < allTgChats.length; i++) {
            int64 tgChatId = allTgChats[i];
            if (games[tgChatId].inProgress) {
                abortGame(tgChatId);
            }
        }
    }

    function removeTgId(int64 _tgChatId) public onlyOwnerOrMaintainer {
        require(!games[_tgChatId].inProgress, "Game still in progress for this chat ID.");
        delete games[_tgChatId];
    }

    function isGameInProgress(int64 _tgChatId) public view returns (bool) {
        return games[_tgChatId].inProgress;
    }

    function setMaintainer(address _newMaintainer) public onlyOwner {
        maintainer = _newMaintainer;
    }

}