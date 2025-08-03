// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.19;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
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
        return functionCallWithValue(target, data, 0, defaultRevert);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with a
     * `customRevert` function as a fallback when `target` reverts.
     *
     * Requirements:
     *
     * - `customRevert` must be a reverting function.
     *
     * _Available since v5.0._
     */
    function functionCall(
        address target,
        bytes memory data,
        function() internal view customRevert
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, customRevert);
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, defaultRevert);
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with a `customRevert` function as a fallback revert reason when `target` reverts.
     *
     * Requirements:
     *
     * - `customRevert` must be a reverting function.
     *
     * _Available since v5.0._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        function() internal view customRevert
    ) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, customRevert);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, defaultRevert);
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
        function() internal view customRevert
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, customRevert);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, defaultRevert);
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
        function() internal view customRevert
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, customRevert);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided `customRevert`) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v5.0._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        function() internal view customRevert
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check if target is a contract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                if (target.code.length == 0) {
                    revert AddressEmptyCode(target);
                }
            }
            return returndata;
        } else {
            _revert(returndata, customRevert);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or with a default revert error.
     *
     * _Available since v5.0._
     */
    function verifyCallResult(bool success, bytes memory returndata) internal view returns (bytes memory) {
        return verifyCallResult(success, returndata, defaultRevert);
    }

    /**
     * @dev Same as {xref-Address-verifyCallResult-bool-bytes-}[`verifyCallResult`], but with a
     * `customRevert` function as a fallback when `success` is `false`.
     *
     * Requirements:
     *
     * - `customRevert` must be a reverting function.
     *
     * _Available since v5.0._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        function() internal view customRevert
    ) internal view returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, customRevert);
        }
    }

    /**
     * @dev Default reverting function when no `customRevert` is provided in a function call.
     */
    function defaultRevert() internal pure {
        revert FailedInnerCall();
    }

    function _revert(bytes memory returndata, function() internal view customRevert) private view {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            customRevert();
            revert FailedInnerCall();
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.19;

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
/*
   DiceBot Game

    .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------. 
    | .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
    | |  ________    | || |     _____    | || |     ______   | || |  _________   | || |   ______     | || |     ____     | || |  _________   | |
    | | |_   ___ `.  | || |    |_   _|   | || |   .' ___  |  | || | |_   ___  |  | || |  |_   _ \    | || |   .'    `.   | || | |  _   _  |  | |
    | |   | |   `. \ | || |      | |     | || |  / .'   \_|  | || |   | |_  \_|  | || |    | |_) |   | || |  /  .--.  \  | || | |_/ | | \_|  | |
    | |   | |    | | | || |      | |     | || |  | |         | || |   |  _|  _   | || |    |  __'.   | || |  | |    | |  | || |     | |      | |
    | |  _| |___.' / | || |     _| |_    | || |  \ `.___.'\  | || |  _| |___/ |  | || |   _| |__) |  | || |  \  `--'  /  | || |    _| |_     | |
    | | |________.'  | || |    |_____|   | || |   `._____.'  | || | |_________|  | || |  |_______/   | || |   `.____.'   | || |   |_____|    | |
    | |              | || |              | || |              | || |              | || |              | || |              | || |              | |
    | '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
    '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------' 

*/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "./SafeERC20.sol";
import "./Ownable.sol";

/**
 * @title DiceBot Game
 * @dev 
 */
contract DiceBotGame is Ownable {
    using SafeERC20 for IERC20;

    // Revenue Wallet
    address public revenueWallet;

    // The amount to take as revenue, in basis points.
    uint256 public immutable revenueBps;

    // The amount to burn forever, in basis points.
    uint256 public immutable burnBps;

    struct DiceGame {
        uint32 betSize;
        uint256 gameAmount;
        address bettingToken;
        address[] players;
        address winner;
        uint32 winnerScore;
        bool inProgress;
    }

    // Map GameID to their games.
    mapping(uint64 => DiceGame) public games;

    struct BettingToken {
        bool isBetting;
        uint256 minimumBet;
        address burnAddress;
    }
    // Map Betting Token to Bool
    mapping(address => BettingToken) public bettingToken;
    address[] public bettingTokenList;

    address private constant DEAD_ADDR = 0x000000000000000000000000000000000000dEaD;

    // Stores the amount each player has bet for a game.
    event Bet(uint64 indexed gameId, address indexed bettingToken, address indexed player, uint256 amount);

    // Stores the amount each player wins for a game.
    event Win(uint64 indexed gameId, address indexed bettingToken, address indexed player);

    // Stores the amount collected by the protocol.
    event Revenue(uint64 indexed gameId, address indexed bettingToken, uint256 indexed amount);

    // Stores the amount burned by the protocol.
    event Burn(uint64 indexed gameId, address indexed bettingToken, uint256 indexed amount);

    constructor(uint256 _revenueBps, uint256 _burnBps, address _revenueWallet) Ownable(msg.sender) {
        // Update Revenue Wallet
        revenueWallet = _revenueWallet;
        // Update Revenue Bps
        revenueBps = _revenueBps;
        // Update Burn Bps
        burnBps = _burnBps;
    }

    /**
     * @dev Change Revenue Wallet
     */
    function changeRevenueWallet(address _newRevenue) public onlyOwner() {
        revenueWallet = _newRevenue;
    }

    /**
     * @dev Add betting token, only owner call it
     * @param tokenAddress New bettingToken address
     * @param minimumBet MinimumBet amount for new bettingToken
     */
    function addBettingToken(address tokenAddress, uint256 minimumBet, address burnAddress) public onlyOwner() {
        // Check Betting Token Exists
        if (!bettingToken[tokenAddress].isBetting) {
            // Update Betting Flag
            bettingToken[tokenAddress].isBetting = true;

            // Add New Betting Token
            bettingTokenList.push(tokenAddress);
        }

        // Update Betting Amount
        bettingToken[tokenAddress].minimumBet = minimumBet;

        // Update Burn Address
        bettingToken[tokenAddress].burnAddress = burnAddress;
    }

    /**
     * @dev Remove betting token
     * @param tokenAddress Removing bettingToken address
     */
    function removeBettingToken(address tokenAddress) public onlyOwner() {
        if (bettingToken[tokenAddress].isBetting) {
            // Update Betting Flag
            bettingToken[tokenAddress].isBetting = false;

            // Remove Betting Token
            uint bettingTokenListLength = bettingTokenList.length;
            for (uint i = 0; i < bettingTokenListLength; i += 1) {
                if (bettingTokenList[i] == tokenAddress) {
                    // Swap with Last ID
                    bettingTokenList[i] = bettingTokenList[bettingTokenListLength - 1];

                    // Remove Last ID
                    bettingTokenList.pop();
                }
            }
        }
    }

    /**
     * @dev Check if there is a game in progress for a Telegram group.
     * @param gameId Dice GameID
     * @return true if there is a game in progress, otherwise false
     */
    function isGameInProgress(uint64 gameId) public view returns (bool) {
        return games[gameId].inProgress;
    }

    /**
     * @dev Create a new game. Transfer funds into escrow.
     * @param _gameId Dice Bot Game ID
     * @param _betSize Number of chambers in the revolver
     * @param _bettingToken Betting Token for Dice
     * @param _gameAmount Amount of Game
     * @param _players Address list of players in game
     */
    function newGame(
        uint64 _gameId,
        address _bettingToken,
        uint32 _betSize,
        uint256 _gameAmount,
        address[] memory _players
    ) public onlyOwner {
        require(_betSize >= 2, "Bet size too small");
        require(bettingToken[_bettingToken].isBetting, "Not betting token");
        require(bettingToken[_bettingToken].minimumBet <= _gameAmount, "Game amount should be more than minimum bet.");
        require(_players.length == _betSize, "Players length mismatch");
        require(!isGameInProgress(_gameId), "This game is on progress");

        // TransferFrom Amount of Betting Token to Game Contract
        for (uint32 i = 0; i < _betSize; i += 1) {
            // Check Balance
            require(IERC20(_bettingToken).balanceOf(_players[i]) >= _gameAmount, "Not enough balance");
            // Check Allowance
            require(IERC20(_bettingToken).allowance(_players[i], address(this)) >= _gameAmount, "Not enough allowance");

            IERC20(_bettingToken).safeTransferFrom(_players[i], address(this), _gameAmount);

            emit Bet(_gameId, _bettingToken, _players[i], _gameAmount);
        }

        // Create & Update New Game
        DiceGame memory newG;

        newG.bettingToken = _bettingToken;
        newG.betSize = _betSize;
        newG.gameAmount = _gameAmount;
        newG.players = _players;
        newG.inProgress = true;

        games[_gameId] = newG;
    }

    /**
     * @dev Declare a loser of the game and pay out the winnings.
     * @param _gameId Dice Bot Game ID
     * @param _scoreList Dice Game Score per Address
     */
    function endGame(
        uint64 _gameId,
        address[] memory _addressList,
        uint32[] memory _scoreList
    ) public onlyOwner {
        // Check Game in Progress
        require(isGameInProgress(_gameId), "No game in progress for this TG Dice Game ID");

        // Get Current Game
        DiceGame storage currentGame = games[_gameId];
        // Check Game Size
        require(currentGame.betSize == _addressList.length, "Players length mismatch");
        require(currentGame.betSize == _scoreList.length, "Players length mismatch");
        // Get Betting Token
        address _bettingToken = currentGame.bettingToken;
        // Get Burn Address
        address _burnAddress = bettingToken[_bettingToken].burnAddress;

        // Update Game Status
        currentGame.inProgress = false;

        uint256 totalAmount = currentGame.gameAmount * currentGame.betSize;
        // Get Winner
        uint32 winnerId = 0;
        for (uint32 i = 1; i < currentGame.betSize; i += 1) {
            if (_scoreList[winnerId] < _scoreList[i]) {
                winnerId = i;
            }
        }
        // Calc Burn & Revenue & Winner Amount
        require(burnBps + revenueBps < 10000, "Total fees must be < 100%");
        uint256 burnAmount = totalAmount * burnBps / 10000;
        uint256 revenueAmount = totalAmount * revenueBps / 10000;
        uint256 winnerAmount = totalAmount - burnAmount - revenueAmount;

        // Transfer to Winner
        IERC20(_bettingToken).safeTransfer(_addressList[winnerId], winnerAmount);

        // Transfer to Revenue Wallet
        IERC20(_bettingToken).safeTransfer(revenueWallet, revenueAmount);

        // Burn burnAmount
        IERC20(_bettingToken).safeTransfer(_burnAddress, burnAmount);

        // Update Game Winner Address & Score
        currentGame.winner = _addressList[winnerId];
        currentGame.winnerScore = _scoreList[winnerId];

        // Emit the Events
        emit Win(_gameId, _bettingToken, _addressList[winnerId]);
        emit Revenue(_gameId,_bettingToken, revenueAmount);
        emit Burn(_gameId,_bettingToken, burnAmount);
    }

    /**
     * @dev Abort a game and refund the bets. Use in emergencies
     *      e.g. bot crash.
     * @param _gameId DiceBot Game ID
     */
    function abortGame(uint64 _gameId) public onlyOwner {
        require(isGameInProgress(_gameId), "No game in progress for this Telegram chat ID");

        DiceGame storage currentGame = games[_gameId];
        address _bettingToken = currentGame.bettingToken;

        for (uint32 i = 0; i < currentGame.betSize; i += 1) {
            IERC20(_bettingToken).safeTransfer(currentGame.players[i], currentGame.gameAmount);
        }

        currentGame.inProgress = false;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.19;

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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.19;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.19;

import "./Context.sol";

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
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor(address initialOwner) {
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.19;

import "./IERC20.sol";
import "./IERC20Permit.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Compatible with tokens that require the approval to be set to
     * 0 before setting it to a non-zero value.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        if (nonceAfter != nonceBefore + 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}