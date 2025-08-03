/**
 WELCOME TO ZE DICE.
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
Telegram: https://t.me/+roYJUAvu9rJmZDQ0
X: https://twitter.com/wagerzz_gg
**/

// File @openzeppelin/contracts/utils/Context.sol@v4.9.2

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


// File @openzeppelin/contracts/access/Ownable.sol@v4.9.2

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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


// File contracts/interfaces/IBuyBack.sol

pragma solidity ^0.8.15;

interface IBuyBackToken {
    function buyBackTokens(uint256 amountInWei) payable external;
}


// File contracts/BookieZ.sol

pragma solidity 0.8.15;


contract BookieZ is Ownable {

    mapping (uint256 => address) public resultsToToken;
    bool public initialized;
    uint256 public lastTotalPrize;
    uint256 public lastDiceOutcome;
    uint256 public pendingToBeBought;
    address public diceRollerBot = 0x16719D5A9512e1B1628Ad2992c08F2964EabE367;

    event ResultToTokenAddressSet(uint256 indexed result, address tokenAddress);

    constructor() {
        initialized = false;
    }



    modifier onlyOwnerOrDiceRollerBot() {
        require(msg.sender == owner() || msg.sender == diceRollerBot, "Only the owner or diceRollerBot can call this function");
        _;
    }

    modifier onlyValidResult(uint256 _result) {
        require(_result >= 1 && _result <= 6, "Result must be between 1 and 6");
        _;
    }

    function setDiceRollerBot(address _diceRollerBot) external onlyOwner {
        diceRollerBot = _diceRollerBot;
    }

    function announceDiceOutcome(uint256 _result, uint256 _amount) external onlyOwnerOrDiceRollerBot onlyValidResult(_result) {
        require(_amount <= address(this).balance, "Cannot buy back more than the actual balance");

        if (_amount == 0) {
            _amount = address(this).balance;
        }
        lastTotalPrize = address(this).balance;
        pendingToBeBought = address(this).balance;
        lastDiceOutcome = _result;

        IBuyBackToken(resultsToToken[_result]).buyBackTokens{value: _amount}(_amount);
        pendingToBeBought -= _amount;
    }

    function buyBackWinnerToken(uint256 _amount) external onlyOwnerOrDiceRollerBot {
        require(_amount <= pendingToBeBought, "Cannot buy back more than the actual balance");

        if (_amount == 0) {
            _amount = pendingToBeBought;
        }

        IBuyBackToken(resultsToToken[lastDiceOutcome]).buyBackTokens{value: _amount}(_amount);
        pendingToBeBought -= _amount;
    }

    function initializeParams(
        address token1,
        address token2,
        address token3,
        address token4,
        address token5,
        address token6
    ) external onlyOwner {
        require(!initialized, "Already initialized");

        resultsToToken[1] = token1;
        resultsToToken[2] = token2;
        resultsToToken[3] = token3;
        resultsToToken[4] = token4;
        resultsToToken[5] = token5;
        resultsToToken[6] = token6;

        initialized = true;
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}