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
pragma solidity ^0.8.22;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

struct BlokContract {
    uint256 timestamp;
    uint256 rentDeposit;
    uint256 rentFlowRate;
    uint256 cooldownEndTimestamp;

}

contract BoredBloks is Ownable {
    constructor(
        address _initialOwner, 
        address _protocolFeeCollector, 
        address _billboredFeeCollector,
        address _rewardsPoolCollector
    )  Ownable(_initialOwner)
    {
        protocolFeeCollector = _protocolFeeCollector;
        billboredFeeCollector = _billboredFeeCollector;
        rewardsPoolCollector = _rewardsPoolCollector;
    }

    uint16  public constant TOTAL_BLOKS = 369;
    uint256 public constant PERCENT_FACTOR = 100_00;
    uint256 public constant SECONDS_IN_SIXTY_NINE_HOURS = 248_400;

    mapping(uint16 => address) public owners;

    mapping(uint16 => uint256) public prices;
    mapping(uint16 => uint256) public settledRentBalances;

    mapping(uint16 => BlokContract) public blokContracts;

    uint256 public defaultBuyPrice = 0 ether;
    uint256 public cooldownPeriod = 260;
    uint256 public protocolFeePercent = 3_69; // Fixed transaction fee
    uint256 public billboredFeeRate = 6_90;   // % of sell price / 69 hours                 
    uint256 public rewardPoolRate = 6_90;     // % of sell price / 69 hours    

    address public protocolFeeCollector = 0x0000000000000000000000000000000000000000;
    address public billboredFeeCollector = 0x0000000000000000000000000000000000000000;
    address public rewardsPoolCollector = 0x0000000000000000000000000000000000000000;
    uint256 public settledRentBalance = 0;
    
    event BlokBuy(
        uint16  blokId,
        uint256 timestamp,
        address buyer,
        uint256 buyPrice,
        uint256 sellPrice,
        uint256 rentDepositAdded,
        uint256 rentFlowRate,
        uint256 cooldownEndTimestamp
    );

    event BlokUpdate(
        uint16  blokId,
        uint256 timestamp,
        address owner,
        uint256 sellPrice,
        uint256 rentDeposit,
        uint256 rentDepositAdded,
        uint256 rentDepositWithdrawn,
        uint256 rentFlowRate
    );

    event BlokSell(
        uint16  blokId,
        uint256 timestamp,
        address seller,
        uint256 sellPrice,
        uint256 sellerProceeds,
        uint256 rentDepositWithdrawn,
        uint256 protocolFee
    );

    function setDefaultBuyPrice(uint256 _defaultBuyPrice) public onlyOwner {
        defaultBuyPrice = _defaultBuyPrice;
    }

    function setCooldownPeriod(uint256 _seconds) public onlyOwner {
        cooldownPeriod = _seconds;
    }

    function setProtocolFeeCollector(address _protocolFeeCollector) public onlyOwner {
        protocolFeeCollector = _protocolFeeCollector;
    }

    function setProtocolFeePercent(uint256 _protocolFeePercent) public onlyOwner {
        protocolFeePercent = _protocolFeePercent;
    }

    function setBillboredFeeCollector(address _billboredFeeCollector) public onlyOwner {
        billboredFeeCollector = _billboredFeeCollector;
    }

    function setBillboredFeeRate(uint256 _billboredFeeRate) public onlyOwner {
        billboredFeeRate = _billboredFeeRate;
    }

    function setRewardsPoolCollector(address _rewardsPoolCollector) public onlyOwner {
        rewardsPoolCollector = _rewardsPoolCollector;
    }

    function setRewardPoolRate(uint256 _rewardPoolRate) public onlyOwner {
        rewardPoolRate = _rewardPoolRate;
    }

    function checkBlokExists(uint16 _blokId) public pure {
        require(_blokId > 0 && _blokId <= TOTAL_BLOKS, "Blok does not exist");
    }

    function getSellPrice(uint16 _blokId) external view returns (uint256) {
       return prices[_blokId];
    }

    function realtimeBalanceOf(
        uint16 _blokId,
        uint256 _timestamp
    )  public view returns (uint256, uint256, uint256, uint256, uint256) {

        checkBlokExists(_blokId);

        uint256 deposit = blokContracts[_blokId].rentDeposit;
        uint256 rentPaid = ((_timestamp - blokContracts[_blokId].timestamp) * blokContracts[_blokId].rentFlowRate);
        
        uint256 rentDepositOwed = 0;
        if(blokContracts[_blokId].rentDeposit > rentPaid) 
            rentDepositOwed = blokContracts[_blokId].rentDeposit - rentPaid;
        else
            rentPaid = blokContracts[_blokId].rentDeposit;

        uint256 totalRate = billboredFeeRate + rewardPoolRate;
        uint256 billboredFee = rentPaid * billboredFeeRate / totalRate;
        uint256 rewardPoolFee = rentPaid * rewardPoolRate / totalRate;
 
        return (deposit, rentPaid, rentDepositOwed, billboredFee, rewardPoolFee);
    }

    function realtimeBalanceOfNow(
       uint16 _blokId
    ) public view returns (uint256, uint256, uint256, uint256, uint256, uint256) {

        uint256 timestamp = block.timestamp;
        (uint256 deposit, uint256 rentPaid, uint256 rentDepositOwed, 
            uint256 billboredFee, uint256 rewardPoolFee) = realtimeBalanceOf(_blokId, timestamp);

        return (deposit, rentPaid, rentDepositOwed, billboredFee, rewardPoolFee, timestamp);
    }

    function realtimeRentCollectedBalance(
        uint256 _timestamp
    ) public view returns (uint256, uint256) {

        uint256 totalDeposit = 0;
        uint256 availableBalance = 0;

        for (uint16 i = 1; i <= TOTAL_BLOKS; i++) {

            totalDeposit += blokContracts[i].rentDeposit;

            uint256 rentCollected = ((_timestamp - blokContracts[i].timestamp) * blokContracts[i].rentFlowRate);

            if(blokContracts[i].rentDeposit <= rentCollected) 
                availableBalance = availableBalance + blokContracts[i].rentDeposit;
            else
                availableBalance = availableBalance + rentCollected;
        }

        return (totalDeposit, availableBalance);
    }

    function realtimeRentCollectedBalanceNow() public view returns (uint256, uint256, uint256) {

        uint256 timestamp = block.timestamp;
        (uint256 totalDeposit, uint256 availableBalance) = realtimeRentCollectedBalance(timestamp);

        return (totalDeposit, availableBalance, timestamp);
    }

    function isBlokSolvent(
        uint16 _blokId,
        uint256 _timestamp
    ) public view returns(bool)  {

        checkBlokExists(_blokId);

        (,,uint256 depositOwed,,) = realtimeBalanceOf(_blokId, _timestamp);
        return depositOwed > 0;
    }

    function isBlokSolventNow(
       uint16 _blokId
    ) public view returns(bool) {
        return isBlokSolvent(_blokId, block.timestamp);
    }

    function checkBlokSolvent(
        uint16 _blokId,
        uint256 _timestamp
    ) public view {
        require(isBlokSolvent(_blokId, _timestamp), "Blok is not solvent");
    }

    function isBlokCooldownPeriodMet(
        uint16 _blokId,
        uint256 _timestamp
    ) public view returns(bool) {
        return (_timestamp >= blokContracts[_blokId].cooldownEndTimestamp);
    }

    function isBlokCooldownPeriodMetNow(
        uint16 _blokId
    ) public view returns(bool) {
        return isBlokCooldownPeriodMet(_blokId, block.timestamp);
    }

    function checkCooldownPeriodMet(
        uint16 _blokId,
        uint256 _timestamp
    ) public view {
        require(isBlokCooldownPeriodMet(_blokId, _timestamp), "Cooldown period not met");
    }

    function calculateSellAmount(
        uint16 _blokId
    ) public view returns (uint256, uint256, uint256) {

        checkBlokExists(_blokId);

        bool isBlockSolvent = isBlokSolvent(_blokId, block.timestamp);

        uint256 currentBuyPrice = prices[_blokId];
        if(!isBlockSolvent)
            currentBuyPrice = defaultBuyPrice;

        uint256 protocolFee = currentBuyPrice * protocolFeePercent / PERCENT_FACTOR;
        uint256 sellerProceeds = currentBuyPrice - protocolFee;

        return (currentBuyPrice, sellerProceeds, protocolFee);
    }

    function buyBlok(
        uint16 _blokId,
        uint256 _buyPrice,
        uint256 _sellPrice
    ) external payable {

        checkBlokExists(_blokId);
        checkCooldownPeriodMet(_blokId, block.timestamp);

        bool isBlockSolvent = isBlokSolvent(_blokId, block.timestamp);

        uint256 currentBuyPrice = prices[_blokId];
        if(!isBlockSolvent)
            currentBuyPrice = defaultBuyPrice;
        require(currentBuyPrice == _buyPrice, "Buy price is incorrect");

        require(_sellPrice > 0, "Sell price must be greater than 0");

        uint256 _rentPerSixtyNineHours = _sellPrice * (billboredFeeRate + rewardPoolRate) / PERCENT_FACTOR;
        uint256 rentFlowRate = _rentPerSixtyNineHours / SECONDS_IN_SIXTY_NINE_HOURS;
        uint256 _minimumRentDepositRequired = rentFlowRate * cooldownPeriod;
        require(msg.value >= (currentBuyPrice + _minimumRentDepositRequired), "Insufficient payment");

        _sellBlok(_blokId, currentBuyPrice, isBlockSolvent);

        owners[_blokId] = msg.sender;
        prices[_blokId] = _sellPrice;

        uint256 rentDeposited = msg.value - currentBuyPrice;
        uint256 cooldownEndTimestamp = block.timestamp + cooldownPeriod;
        blokContracts[_blokId].timestamp = block.timestamp;
        blokContracts[_blokId].rentDeposit = rentDeposited;
        blokContracts[_blokId].rentFlowRate = rentFlowRate;
        blokContracts[_blokId].cooldownEndTimestamp = cooldownEndTimestamp;

        emit BlokBuy(
            _blokId, 
            block.timestamp,
            msg.sender,
            currentBuyPrice, 
            _sellPrice, 
            rentDeposited, 
            rentFlowRate,
            cooldownEndTimestamp
        );
    }

    function updateBlok(
        uint16 _blokId,
        uint256 _sellPrice,
        uint256 _withdrawalAmount
    ) external payable {

        checkBlokExists(_blokId);
        checkCooldownPeriodMet(_blokId, block.timestamp);
        checkBlokSolvent(_blokId, block.timestamp);
        
        address owner = owners[_blokId];
        require(owner == msg.sender, "Only owner can set a new price");

        prices[_blokId] = _sellPrice;

        uint256 _rentPerSixtyNineHours = _sellPrice * (billboredFeeRate + rewardPoolRate) / PERCENT_FACTOR;
        uint256 rentFlowRate = _rentPerSixtyNineHours / SECONDS_IN_SIXTY_NINE_HOURS;  

        (uint256 _rentDepositOwed) = _distributeRentPayments(_blokId);

        uint256 rentDepositWithdrawn = _withdrawalAmount;
        if(rentDepositWithdrawn > _rentDepositOwed || _sellPrice == 0) rentDepositWithdrawn = _rentDepositOwed;

        if(rentDepositWithdrawn > 0) {
            (bool withdrawAmountSuccess,) = payable(owner).call{value: (rentDepositWithdrawn)}("");
            require(withdrawAmountSuccess, "Withdrawal failed, reverted");
        }

        uint256 rentDeposit = msg.value + (_rentDepositOwed - rentDepositWithdrawn);

        blokContracts[_blokId].timestamp = block.timestamp;
        blokContracts[_blokId].rentDeposit = rentDeposit;
        blokContracts[_blokId].rentFlowRate = rentFlowRate;
        
        emit BlokUpdate(
            _blokId,
            block.timestamp,  
            msg.sender, 
            _sellPrice,
            rentDeposit, 
            msg.value,
            rentDepositWithdrawn, 
            rentFlowRate
        );
    }

    function withdrawSettledRent() external payable {

        uint256 availableBillboredFeeBalance = 0;
        uint256 availableRewardPoolFeeBalance = 0;

        for (uint16 i = 1; i <= TOTAL_BLOKS; i++) {

            (,uint256 rentPaid, uint256 rentDepositOwed, uint256 billboredFee, uint256 rewardPoolFee) = realtimeBalanceOf(i, block.timestamp);

            availableBillboredFeeBalance = availableBillboredFeeBalance + billboredFee;
            availableRewardPoolFeeBalance = availableRewardPoolFeeBalance + rewardPoolFee;

            blokContracts[i].timestamp = block.timestamp;
            blokContracts[i].rentDeposit = rentDepositOwed;

            settledRentBalance += rentPaid;
            settledRentBalances[i] += rentPaid;
        }

        (bool billboredFeeCollectionSuccess,) = payable(billboredFeeCollector).call{value: (availableBillboredFeeBalance)}("");
        require(billboredFeeCollectionSuccess, "Billbored fee collection failed, reverted");

        (bool rewardPoolFeeWithdrawalSuccess,) = payable(rewardsPoolCollector).call{value: (availableRewardPoolFeeBalance)}("");
        require(rewardPoolFeeWithdrawalSuccess, "Reward pool collection failed, reverted");
    }

    function _sellBlok(
        uint16 _blokId,
        uint256 _currentBuyPrice,
        bool _isBlockSolvent
    ) internal {
        
        address owner = owners[_blokId];
        require(owner != msg.sender || !_isBlockSolvent, "Owner cannot buy their own blok unless they are in a default state");

        uint256 rentDepositOwedToSeller = 0;
        uint256 protocolFee = 0;
        uint256 sellerProceeds = 0;

        if(_currentBuyPrice > 0) {

            (rentDepositOwedToSeller) = _distributeRentPayments(_blokId);

            (, sellerProceeds, protocolFee) = calculateSellAmount(_blokId);
            
            (bool _sellAmountSuccess,) = payable(owner).call{value: (sellerProceeds + rentDepositOwedToSeller)}("");
            require(_sellAmountSuccess, "Sell failed, reverted");

            (bool protocolFeeCollectionSuccess,) = payable(protocolFeeCollector).call{value: (protocolFee)}("");
            require(protocolFeeCollectionSuccess, "Protocol fee collection failed, reverted");
        }

        if(_isBlockSolvent) {

            emit BlokSell(
                _blokId,
                block.timestamp, 
                owner,  
                _currentBuyPrice,
                sellerProceeds,
                rentDepositOwedToSeller,
                protocolFee
            );
        }
    }

    function _distributeRentPayments(
        uint16 _blokId
    ) internal returns(uint256) {

        (, uint256 rentPaid, uint256 rentDepositOwed, uint256 billboredFee, uint256 rewardPoolFee) = realtimeBalanceOf(_blokId, block.timestamp);

        (bool billboredFeeCollectionSuccess,) = payable(billboredFeeCollector).call{value: (billboredFee)}("");
        require(billboredFeeCollectionSuccess, "Billbored fee collection failed, reverted");

        (bool rewardPoolCollectionSuccess,) = payable(rewardsPoolCollector).call{value: (rewardPoolFee)}("");
        require(rewardPoolCollectionSuccess, "Reward pool collection failed, reverted");

        settledRentBalance += rentPaid;
        settledRentBalances[_blokId] += rentPaid;

        return (rentDepositOwed);
    }
}