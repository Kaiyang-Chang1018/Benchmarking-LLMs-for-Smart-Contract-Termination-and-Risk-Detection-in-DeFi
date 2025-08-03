/**
 *Submitted for verification at basescan.org on 2023-08-10
*/

// File: contracts/Context.sol


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

// File: contracts/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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



pragma solidity >=0.8.2 <0.9.0;


// TODO: Events, final pricing model, 

contract EtfBet is Ownable {

    uint256 public constant CREATOR_PREMINT = 1 ether; // 1e18

    address public protocolFeeDestination = 0x03DCc8d126045a8c8B1E3c11DC442c4b229f1c77; //0x6FC7f47Ec1c3181Ec8027f6C8cd9b0367f07Db26;
    address public rageModeFeeDestination = 0xC754e76233F1324D6B345740798DaB26FaACc0b7; //0x52E52BF832D77d8be17920C0bCa7C01A21F3DD8b;
    address public nextBonusDestination = 0x62861C2678173f9F9E4F564081Bee1Ad63fF4c29; //0x0f2Cc9aACEa541862CD67E50E8Fb93d6863f4Adb;
    uint256 public protocolFeePercent = 80000000000000000;
    uint256 public rageModeFeePercent = 20000000000000000;
    uint256 public nextBonusFeePercent = 100000000000000000;

    uint256 public longShareSupply;
    mapping(address => uint256) public longShareBalance;

    uint256 public shortShareSupply;
    mapping(address => uint256) public shortShareBalance;

    bool public rageModeEnable;

    bool public gameOverEnable;

    uint256 public eftApproveResult;// 1 pass 2 reject

    bool public eftHasPublish;

    bool public nextBonusClaimed;

    uint256 public selftBalance;

    uint256 public longEtherValue;

    uint256 public shortEtherValue;

    modifier volidEtfResultor(uint256 result) {
        require(result == 1 || result == 2);
        _;
    }

    event LongTrade(address trader, bool isBuy, uint256 shareAmount, uint256 ethAmount, uint256 protocolEthAmount, uint256 rageModeEthAmount, uint256 supply);

    event ShortTrade(address trader, bool isBuy, uint256 shareAmount, uint256 ethAmount, uint256 protocolEthAmount, uint256 rageModeEthAmount, uint256 supply);


    constructor() {
        longShareBalance[msg.sender] = CREATOR_PREMINT;
        shortShareBalance[msg.sender] = CREATOR_PREMINT;
        longShareSupply = CREATOR_PREMINT;
        shortShareSupply = CREATOR_PREMINT;
    }
    function setProtocolFeeDestination(address _feeDestination) public onlyOwner {
        protocolFeeDestination = _feeDestination;
    }

    function setRageModeFeeDestination(address _feeDestination) public onlyOwner {
        rageModeFeeDestination = _feeDestination;
    }

    function setNextBonusDestination(address destination) public onlyOwner {
        nextBonusDestination = destination;
    }

    function setProtocolFeePercent(uint256 _feePercent) public onlyOwner {
        protocolFeePercent = _feePercent;
    }

    function setRageModeFeePercent(uint256 _feePercent) public onlyOwner {
        rageModeFeePercent = _feePercent;
    }

    function setNextBonusFeePercent(uint256 _feePercent) public onlyOwner {
        nextBonusFeePercent = _feePercent;
    }

    function setRageModeEnable(bool enable) public onlyOwner {
        rageModeEnable = enable;
    }

    function setGameOverEnable(bool enable) public onlyOwner {
        gameOverEnable = enable;
    }

    function publishEtfResult(uint256 result) public onlyOwner volidEtfResultor(result) {
        require(!eftHasPublish, "has publish");
        require(gameOverEnable, "Gaming");
        require(result == 1 || result == 2, "invalid result");
        eftApproveResult = result;
        eftHasPublish = true;
    }

    function _curve(uint256 x) private pure returns (uint256) {
        return x <= CREATOR_PREMINT ? 0 : ((x - CREATOR_PREMINT) * (x - CREATOR_PREMINT) * (x - CREATOR_PREMINT));
    }

    function getPrice(uint256 supply, uint256 amount) public pure returns (uint256) {
        return (_curve(supply + amount) - _curve(supply)) / 1 ether / 1 ether / 50_000 / 3;
    }

    // function getLongBuyPrice(uint256 amount) public view returns (uint256) {
    //     return getPrice(longShareSupply, amount);
    // }

    // function getPrice(uint256 supply, uint256 amount) public pure returns (uint256) {
    //     uint256 sum1 = supply == 0 ? 0 : (supply - 1 )* (supply) * (2 * (supply - 1) + 1) / 6;
    //     uint256 sum2 = supply == 0 && amount == 1 ? 0 : (supply - 1 + amount) * (supply + amount) * (2 * (supply - 1 + amount) + 1) / 6;
    //     uint256 summation = sum2 - sum1;
    //     return summation * 1 ether / 50000000;
    // }

    function getBuyLongPrice(uint256 amount) public view returns (uint256) {
        return getPrice(longShareSupply, amount);
    }

    function getSellLongPrice(uint256 amount) public view returns (uint256) {
        return getPrice(longShareSupply - amount, amount);
    }

    function getBuyLongPriceAfterFee(uint256 amount) public view returns (uint256) {
        uint256 price = getBuyLongPrice(amount);
        uint256 protocolFee = price * protocolFeePercent / 1 ether;
        uint256 rageModeFee = price * rageModeFeePercent / 1 ether;
        return price + protocolFee + rageModeFee;
    }

    function getSellLongPriceAfterFee(uint256 amount) public view returns (uint256) {
        uint256 price = getSellLongPrice(amount);
        uint256 protocolFee = price * protocolFeePercent / 1 ether;
        uint256 rageModeFee = price * rageModeFeePercent / 1 ether;
        return price - protocolFee - rageModeFee;
    }

    function buyLongShares(uint256 amount) public payable {
        require(!gameOverEnable, "Game Over");
        uint256 supply = longShareSupply;
        uint256 price = getPrice(supply, amount);
        uint256 protocolFee = price * protocolFeePercent / 1 ether;
        uint256 rageModeFee = price * rageModeFeePercent / 1 ether;
        require(msg.value >= price + protocolFee + rageModeFee, "Insufficient payment");
        longShareBalance[msg.sender] = longShareBalance[msg.sender] + amount;
        longShareSupply = supply + amount;
        emit LongTrade(msg.sender, true, amount, price, protocolFee, rageModeFee, supply + amount);
        (bool success1, ) = protocolFeeDestination.call{value: protocolFee}("");
        (bool success2, ) = rageModeFeeDestination.call{value: rageModeFee}("");
        selftBalance = selftBalance + msg.value - protocolFee - rageModeFee;
        longEtherValue = longEtherValue + msg.value - protocolFee - rageModeFee;
        require(success1 && success2, "Unable to send funds");
    }

    function sellLongShares(uint256 amount) public payable {
        require(!gameOverEnable, "Game Over");
        require(!rageModeEnable, "Rage Mode");
        uint256 supply = longShareSupply;
        require(supply > amount, "Cannot sell the last share");
        uint256 price = getPrice(supply - amount, amount);
        uint256 protocolFee = price * protocolFeePercent / 1 ether;
        uint256 rageModeFee = price * rageModeFeePercent / 1 ether;
        require(longShareBalance[msg.sender] >= amount, "Insufficient shares");
        longShareBalance[msg.sender] = longShareBalance[msg.sender] - amount;
        longShareSupply = supply - amount;
        emit LongTrade(msg.sender, false, amount, price, protocolFee, rageModeFee, supply - amount);
        (bool success1, ) = msg.sender.call{value: price - protocolFee - rageModeFee}("");
        (bool success2, ) = protocolFeeDestination.call{value: protocolFee}("");
        (bool success3, ) = rageModeFeeDestination.call{value: rageModeFee}("");
        selftBalance = selftBalance - price;
        longEtherValue = longEtherValue - price;
        require(success1 && success2 && success3, "Unable to send funds");
    }

    function getBuyShortPrice(uint256 amount) public view returns (uint256) {
        return getPrice(shortShareSupply, amount);
    }

    function getSellShortPrice(uint256 amount) public view returns (uint256) {
        return getPrice(shortShareSupply - amount, amount);
    }

    function getBuyShortPriceAfterFee(uint256 amount) public view returns (uint256) {
        uint256 price = getBuyShortPrice(amount);
        uint256 protocolFee = price * protocolFeePercent / 1 ether;
        uint256 rageModeFee = price * rageModeFeePercent / 1 ether;
        return price + protocolFee + rageModeFee;
    }

    function getSellShortPriceAfterFee(uint256 amount) public view returns (uint256) {
        uint256 price = getSellShortPrice(amount);
        uint256 protocolFee = price * protocolFeePercent / 1 ether;
        uint256 rageModeFee = price * rageModeFeePercent / 1 ether;
        return price - protocolFee - rageModeFee;
    }

    function buyShortShares(uint256 amount) public payable {
        require(!gameOverEnable, "Game Over");
        uint256 supply = shortShareSupply;
        uint256 price = getPrice(supply, amount);
        uint256 protocolFee = price * protocolFeePercent / 1 ether;
        uint256 rageModeFee = price * rageModeFeePercent / 1 ether;
        require(msg.value >= price + protocolFee + rageModeFee, "Insufficient payment");
        shortShareBalance[msg.sender] = shortShareBalance[msg.sender] + amount;
        shortShareSupply = supply + amount;
        emit ShortTrade(msg.sender, true, amount, price, protocolFee, rageModeFee, supply + amount);
        (bool success1, ) = protocolFeeDestination.call{value: protocolFee}("");
        (bool success2, ) = rageModeFeeDestination.call{value: rageModeFee}("");
        selftBalance = selftBalance + msg.value - protocolFee - rageModeFee;
        shortEtherValue = shortEtherValue + msg.value - protocolFee - rageModeFee;
        require(success1 && success2, "Unable to send funds");
    }

    function sellShortShares(uint256 amount) public payable {
        require(!gameOverEnable, "Game Over");
        require(!rageModeEnable, "Rage Mode");
        uint256 supply = shortShareSupply;
        require(supply > amount, "Cannot sell the last share");
        uint256 price = getPrice(supply - amount, amount);
        uint256 protocolFee = price * protocolFeePercent / 1 ether;
        uint256 rageModeFee = price * rageModeFeePercent / 1 ether;
        require(shortShareBalance[msg.sender] >= amount, "Insufficient shares");
        shortShareBalance[msg.sender] = shortShareBalance[msg.sender] - amount;
        shortShareSupply = supply - amount;
        emit ShortTrade(msg.sender, false, amount, price, protocolFee, rageModeFee, supply - amount);
        (bool success1, ) = msg.sender.call{value: price - protocolFee - rageModeFee}("");
        (bool success2, ) = protocolFeeDestination.call{value: protocolFee}("");
        (bool success3, ) = rageModeFeeDestination.call{value: rageModeFee}("");
        selftBalance = selftBalance - price;
        shortEtherValue = shortEtherValue - price;
        require(success1 && success2 && success3, "Unable to send funds");
    }

    function claimShare(uint256 amount) public payable {
        require(gameOverEnable, "Gaming");
        require(nextBonusClaimed, "next bonus unclaim");
        require(eftApproveResult == 1 || eftApproveResult == 2, "invalid result");
        if (eftApproveResult == 1) {
            require(longShareBalance[msg.sender] >= amount, "Insufficient shares");
            longShareBalance[msg.sender] = longShareBalance[msg.sender] - amount;
            uint256 sendValue = selftBalance * amount / longShareSupply;
            (bool success, ) = msg.sender.call{value: sendValue}("");
            require(success, "Unable to send funds");
        } else {
            require(shortShareBalance[msg.sender] >= amount, "Insufficient shares");
            shortShareBalance[msg.sender] = shortShareBalance[msg.sender] - amount;
            uint256 sendValue = selftBalance * amount / shortShareSupply;
            (bool success, ) = msg.sender.call{value: sendValue}("");
            require(success, "Unable to send funds");
        }
    }

    function claimNextBonus() public onlyOwner {
        require(gameOverEnable, "Gaming");
        require(!nextBonusClaimed, "next bonus claimed");
        require(eftApproveResult == 1 || eftApproveResult == 2, "invalid result");
        if (eftApproveResult == 1) {
            uint256 nextBonusFee = shortEtherValue * nextBonusFeePercent / 1 ether;
            require(selftBalance > nextBonusFee, "Insufficient selftBalance");
            selftBalance = selftBalance - nextBonusFee;
            (bool success, ) = nextBonusDestination.call{value: nextBonusFee}("");
            nextBonusClaimed = true;
            require(success, "Unable to send funds");
        } else {
            uint256 nextBonusFee = longEtherValue * nextBonusFeePercent / 1 ether;
            require(selftBalance > nextBonusFee, "Insufficient selftBalance");
            selftBalance = selftBalance - nextBonusFee;
            (bool success, ) = nextBonusDestination.call{value: nextBonusFee}("");
            nextBonusClaimed = true;
            require(success, "Unable to send funds");
        }
        
    }
}