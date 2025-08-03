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
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./interfaces/AggregatorV3Interface.sol";

import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract OevOracle is AggregatorV3Interface, Ownable {
    int256 public override latestAnswer;
    uint256 public override latestTimestamp;
    uint256 public override latestRound;

    struct RoundData {
        uint80 roundId;
        int256 answer;
        uint256 startedAt;
        uint256 updatedAt;
        uint80 answeredInRound;
    }

    mapping(uint256 => RoundData) roundData;

    AggregatorV3Interface public baseAggregator;

    address public updater;

    uint256 public permissionWindow = 10 minutes;

    constructor(AggregatorV3Interface _baseAggregator, address _updater) {
        baseAggregator = _baseAggregator;
        updater = _updater;

        updateAnswer();
    }

    function updateAnswer() public {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            baseAggregator.latestRoundData();

        require(latestRound != roundId, "No update needed");
        if (msg.sender != updater && msg.sender != owner()) {
            require(block.timestamp - updatedAt >= permissionWindow, "In permissioned window");
        }

        latestRound = roundId;
        latestAnswer = answer;
        latestTimestamp = updatedAt;
        roundData[roundId] = RoundData(roundId, answer, startedAt, updatedAt, answeredInRound);
    }

    function canUpdateAnswer() public view returns (bool) {
        (uint256 roundId,,,,) = baseAggregator.latestRoundData();
        return latestRound != roundId;
    }

    function setUpdater(address _updater) public onlyOwner {
        updater = _updater;
    }

    function setPermissionWindow(uint256 _permissionWindow) public onlyOwner {
        permissionWindow = _permissionWindow;
    }

    function getRoundData(uint80 _roundId)
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (
            roundData[_roundId].roundId,
            roundData[_roundId].answer,
            roundData[_roundId].startedAt,
            roundData[_roundId].updatedAt,
            roundData[_roundId].answeredInRound
        );
    }

    function latestRoundData()
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (
            roundData[latestRound].roundId,
            roundData[latestRound].answer,
            roundData[latestRound].startedAt,
            roundData[latestRound].updatedAt,
            roundData[latestRound].answeredInRound
        );
    }

    function getAnswer(uint256 roundId) public view override returns (int256) {
        return roundData[roundId].answer;
    }

    function getTimestamp(uint256 roundId) public view override returns (uint256) {
        return roundData[roundId].updatedAt;
    }

    function decimals() public view override returns (uint8) {
        return baseAggregator.decimals();
    }

    function description() public view override returns (string memory) {
        return baseAggregator.description();
    }

    function version() public view override returns (uint256) {
        return baseAggregator.version();
    }

    // TODO: we have no notion of phase or phase ID at this point. Should be pulled from Aggregator.
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface AggregatorV3Interface {
    function latestAnswer() external view returns (int256);

    function latestTimestamp() external view returns (uint256);

    function latestRound() external view returns (uint256);

    function getAnswer(uint256 roundId) external view returns (int256);

    function getTimestamp(uint256 roundId) external view returns (uint256);

    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

    event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}