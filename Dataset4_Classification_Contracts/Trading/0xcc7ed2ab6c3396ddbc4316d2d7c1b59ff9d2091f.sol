// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "../libs/constant.sol";
import "../libs/enum.sol";

/**
 * @title BurnInfo
 * @dev this contract is meant to be inherited into main contract
 * @notice It has the variables and functions specifically for tracking burn amount
 */

abstract contract BurnInfo {
    //Variables
    //track the total Hydra burn amount
    uint256 private s_totalHydraBurned;

    //mappings
    //track wallet address -> total Hydra burn amount
    mapping(address => uint256) private s_userBurnAmount;
    //track contract/project address -> total Hydra burn amount
    mapping(address => uint256) private s_project_BurnAmount;
    //track contract/project address, wallet address -> total Hydra burn amount
    mapping(address => mapping(address => uint256)) private s_projectUser_BurnAmount;

    //events
    /** @dev log user burn Hydra event
     * project can be address(0) if user burns Hydra directly from Hydra contract
     * Source 0=Liquid, 1=Mint
     */
    event HydraBurned(
        address indexed user,
        address indexed project,
        uint256 amount,
        BurnSource source
    );

    //functions
    /** @dev update the burn amount
     * @param user wallet address
     * @param project contract address
     * @param amount Hydra amount burned
     * @param source burn source LIQUID/MINT
     */
    function _updateBurnAmount(
        address user,
        address project,
        uint256 amount,
        BurnSource source
    ) internal {
        s_userBurnAmount[user] += amount;
        s_totalHydraBurned += amount;

        if (project != address(0)) {
            s_project_BurnAmount[project] += amount;
            s_projectUser_BurnAmount[project][user] += amount;
        }

        emit HydraBurned(user, project, amount, source);
    }

    //views
    /** @notice return total burned Hydra amount from all users burn or projects burn
     * @return totalBurnAmount returns entire burned Hydra
     */
    function getTotalBurnTotal() public view returns (uint256) {
        return s_totalHydraBurned;
    }

    /** @notice return user address total burned Hydra
     * @return userBurnAmount returns user address total burned Hydra
     */
    function getUserBurnTotal(address user) public view returns (uint256) {
        return s_userBurnAmount[user];
    }

    /** @notice return project address total burned Hydra amount
     * @return projectTotalBurnAmount returns project total burned Hydra
     */
    function getProjectBurnTotal(address contractAddress) public view returns (uint256) {
        return s_project_BurnAmount[contractAddress];
    }

    /** @notice return user address total burned Hydra amount via a project address
     * @param contractAddress project address
     * @param user user address
     * @return projectUserTotalBurnAmount returns user address total burned Hydra via a project address
     */
    function getProjectUserBurnTotal(
        address contractAddress,
        address user
    ) public view returns (uint256) {
        return s_projectUser_BurnAmount[contractAddress][user];
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "../libs/constant.sol";

abstract contract GlobalInfo {
    //Variables
    //deployed timestamp
    uint256 private immutable i_genesisTs;

    /** @dev track current contract day */
    uint256 private s_currentContractDay;
    /** @dev mintableHydra starts 800m ether decreases and capped at 80k ether, uint96 has enough size */
    uint96 private s_currentMintableHydra;

    /** @dev track when is the next cycle payout day for each cycle day
     * eg. s_nextCyclePayoutDay[DAY98] = 98
     *     s_nextCyclePayoutDay[DAY369] = 369
     */
    mapping(uint256 => uint256) s_nextCyclePayoutDay;

    //event
    event GlobalDailyUpdateStats(uint256 indexed day, uint256 indexed mintableHydra);

    /** @dev Update variables in terms of day, modifier is used in all external/public functions (exclude view)
     * Every interaction to the contract would run this function to update variables
     */
    modifier dailyUpdate() {
        _dailyUpdate();
        _;
    }

    constructor() {
        i_genesisTs = block.timestamp;
        s_currentContractDay = 1;
        s_currentMintableHydra = uint96(START_MAX_MINTABLE_PER_DAY);
        s_nextCyclePayoutDay[DAY98] = DAY98;
    }

    /** @dev calculate and update variables daily and reset triggers flag */
    function _dailyUpdate() private {
        uint256 currentContractDay = s_currentContractDay;
        uint256 currentBlockDay = ((block.timestamp - i_genesisTs) / 1 days) + 1;

        if (currentBlockDay > currentContractDay) {
            //get last day info ready for calculation
            uint256 newMintableHydra = s_currentMintableHydra;
            uint256 dayDifference = currentBlockDay - currentContractDay;

            /** Reason for a for loop to update Mint supply
             * Ideally, user interaction happens daily, so Mint supply is synced in every day
             *      (cylceDifference = 1)
             * However, if there's no interaction for more than 1 day, then
             *      Mint supply isn't updated correctly due to cylceDifference > 1 day
             * Eg. 2 days of no interaction, then interaction happens in 3rd day.
             *     It's incorrect to only decrease the Mint supply one time as now it's in 3rd day.
             *   And if this happens, there will be no tracked data for the skipped days as not needed
             */
            for (uint256 i; i < dayDifference; i++) {
                newMintableHydra =
                    (newMintableHydra * DAILY_SUPPLY_MINTABLE_REDUCTION) /
                    PERCENT_BPS;

                if (newMintableHydra < CAPPED_MIN_DAILY_TITAN_MINTABLE) {
                    newMintableHydra = CAPPED_MIN_DAILY_TITAN_MINTABLE;
                }

                emit GlobalDailyUpdateStats(++currentContractDay, newMintableHydra);
            }

            s_currentMintableHydra = uint96(newMintableHydra);
            s_currentContractDay = currentBlockDay;
        }
    }

    /** @dev calculate and update the next payout day for specified cycleNo
     * the formula will update the payout day based on current contract day
     * this is to make sure the value is correct when for some reason has skipped more than one cycle payout
     * @param cycleNo cycle day 98
     */
    function _setNextCyclePayoutDay(uint256 cycleNo) internal {
        uint256 maturityDay = s_nextCyclePayoutDay[cycleNo];
        uint256 currentContractDay = s_currentContractDay;
        if (currentContractDay >= maturityDay) {
            s_nextCyclePayoutDay[cycleNo] +=
                cycleNo *
                (((currentContractDay - maturityDay) / cycleNo) + 1);
        }
    }

    /** Views */
    /** @notice Returns contract deployment block timestamp
     * @return timestamp in seconds
     */
    function genesisTs() public view returns (uint256) {
        return i_genesisTs;
    }

    /** @notice Returns current block timestamp
     * @return currentBlockTs current block timestamp
     */
    function getCurrentBlockTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    /** @notice Returns current contract day
     * @return currentContractDay current contract day
     */
    function getCurrentContractDay() public view returns (uint256) {
        return s_currentContractDay;
    }

    /** @notice Returns current mint cost
     * @return currentMintCost current block timestamp
     */
    function getCurrentMintCost() public pure returns (uint256) {
        return START_MAX_MINT_COST;
    }

    /** @notice Returns current mintable Hydra
     * @return currentMintableHydra current mintable Hydra
     */
    function getCurrentMintableHydra() public view returns (uint256) {
        return s_currentMintableHydra;
    }

    /** @notice Returns next payout day for the specified cycle day
     * @param cycleNo cycle day 98
     * @return nextPayoutDay next payout day
     */
    function getNextCyclePayoutDay(uint256 cycleNo) public view returns (uint256) {
        return s_nextCyclePayoutDay[cycleNo];
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "../libs/constant.sol";

import "./openzeppelin/security/ReentrancyGuard.sol";
import "./openzeppelin/token/ERC20/ERC20.sol";
import "./openzeppelin/interfaces/IERC165.sol";

import "../interfaces/IHydra.sol";
import "../interfaces/IHydraOnBurn.sol";

import "../libs/TransferHelper.sol";

import "./OwnerInfo.sol";
import "./GlobalInfo.sol";
import "./MintInfo.sol";
import "./BurnInfo.sol";

//custom errors
error Hydra_InvalidCaller();
error Hydra_InsufficientProtocolFees();
error Hydra_NothingToDistribute();
error Hydra_InvalidAmount();
error Hydra_UnregisteredCA();
error Hydra_LPTokensHasMinted();
error Hydra_NotSupportedContract();
error Hydra_InvalidAddress();
error Hydra_MaxedWalletMints();
error Hydra_InvalidMintLadderInterval();
error Hydra_InvalidMintLadderRange();
error Hydra_InvalidBatchCount();
error Hydra_InvalidBurnRewardPercent();
error Hydra_InsufficientBurnAllowance();

/** @title HYDRA */
contract HYDRA is ERC20, OwnerInfo, GlobalInfo, MintInfo, BurnInfo, ReentrancyGuard {
    /** Storage Variables */
    /** @dev stores genesis wallet address */
    address private s_genesisAddress;

    /** @dev Current Hydra buy and burn contract address */
    address private s_buyAndBurnAddress;

    /** @dev Tracks Hydra buy and burn contract addresses status
     * Specifically used for burning Hydra in registered CA */
    mapping(address => bool) s_buyAndBurnAddressRegistry;

    /** @dev tracks if initial LP tokens has minted or not */
    bool private s_initialLPMinted;

    /** @dev tracks collected protocol fees until it is distributed */
    uint256 private s_undistributedFees;

    /** @dev TitanX incentive fee dividend amount */
    uint256 private s_TitanXIncentiveDividend;

    /** @dev tracks funds for vortex */
    uint256 private s_vortexTitanX;
    uint256 private s_vortexDragonX;

    /** @dev tracks user + project burn mints allowance */
    mapping(address => mapping(address => uint256)) private s_allowanceBurnMints;

    /** Events */
    event ProtocolFeeRecevied(address indexed user, uint256 indexed day, uint256 indexed fee);
    event FeesDistributed(address indexed caller, uint256 indexed amount);
    event VortexReceived(
        address indexed from,
        uint256 indexed day,
        address project,
        uint256 indexed amount
    );
    event VortexTriggered(
        uint256 indexed day,
        uint256 indexed vortexTitanX,
        uint256 indexed vortexDragonX
    );
    event ApproveBurnMints(address indexed user, address indexed project, uint256 indexed amount);

    constructor(address genesisAddress, address buyAndBurnAddress) ERC20("HYDRA", "HYDRA") {
        if (genesisAddress == address(0)) revert Hydra_InvalidAddress();
        if (buyAndBurnAddress == address(0)) revert Hydra_InvalidAddress();
        s_genesisAddress = genesisAddress;
        s_buyAndBurnAddress = buyAndBurnAddress;
        s_buyAndBurnAddressRegistry[buyAndBurnAddress] = true;
        s_TitanXIncentiveDividend = 3300;
        IERC20(TITANX).approve(address(this), type(uint256).max);
        IERC20(DRAGONX).approve(address(this), type(uint256).max);
    }

    /** @notice Set BuyAndBurn Contract Address.
     * Only owner can call this function
     * @param contractAddress BuyAndBurn contract address
     */
    function setBuyAndBurnContractAddress(address contractAddress) external onlyOwner {
        if (contractAddress == address(0)) revert Hydra_InvalidAddress();
        /* Only able to change to supported buyandburn contract address.
         * Also prevents owner from registering EOA address into s_buyAndBurnAddressRegistry and call burnHydra to burn user's tokens.
         */
        if (
            !IHydra(contractAddress).supportsInterface(IERC165.supportsInterface.selector) ||
            !IHydra(contractAddress).supportsInterface(type(IHydra).interfaceId)
        ) revert Hydra_NotSupportedContract();
        s_buyAndBurnAddress = contractAddress;
        s_buyAndBurnAddressRegistry[contractAddress] = true;
    }

    /** @notice Remove BuyAndBurn Contract Address from registry.
     * Only owner can call this function
     * @param contractAddress BuyAndBurn contract address
     */
    function unRegisterBuyAndBurnContractAddress(address contractAddress) external onlyOwner {
        if (contractAddress == address(0)) revert Hydra_InvalidAddress();
        s_buyAndBurnAddressRegistry[contractAddress] = false;
    }

    /** @notice Set to new genesis wallet. Only genesis wallet can call this function
     * @param newAddress new genesis wallet address
     */
    function setNewGenesisAddress(address newAddress) external {
        if (msg.sender != s_genesisAddress) revert Hydra_InvalidCaller();
        if (newAddress == address(0)) revert Hydra_InvalidAddress();
        s_genesisAddress = newAddress;
    }

    /** @notice set incentive fee percentage callable by owner only
     * amount is in 10000 scaling factor, which means 0.33 is 0.33 * 10000 = 3300
     * @param amount amount between 1 - 10000
     */
    function setTitanXIncentiveFeeDividend(uint256 amount) external dailyUpdate onlyOwner {
        if (amount == 0 || amount > 10000) revert Hydra_InvalidAmount();
        s_TitanXIncentiveDividend = amount;
    }

    /** @notice One-time function to mint inital LP tokens. Only callable by BuyAndBurn contract address.
     * @param amount tokens amount
     */
    function mintLPTokens(uint256 amount) external {
        if (msg.sender != s_buyAndBurnAddress) revert Hydra_InvalidCaller();
        if (s_initialLPMinted) revert Hydra_LPTokensHasMinted();
        s_initialLPMinted = true;
        _mint(s_buyAndBurnAddress, amount);
    }

    /** @notice burn Hydra in BuyAndBurn contract.
     * Only burns registered contract address
     */
    function burnCAHydra(address contractAddress) external {
        if (!s_buyAndBurnAddressRegistry[contractAddress]) revert Hydra_UnregisteredCA();
        _burn(contractAddress, balanceOf(contractAddress));
    }

    /** @notice Collect liquid TitanX as protocol fee to start mint
     * @param mintPower 1 - 100k
     * @param numOfDays mint length of 1 - 88
     */
    function startMint(
        uint256 mintPower,
        uint256 numOfDays
    ) external payable dailyUpdate nonReentrant {
        if (getUserLatestMintId(msg.sender) + 1 > MAX_MINT_PER_WALLET)
            revert Hydra_MaxedWalletMints();

        uint256 gMintPower = getGlobalMintPower() + mintPower;
        uint256 currentHRank = getGlobalHRank() + 1;
        uint256 gMinting = getTotalMinting() +
            _startMint(
                msg.sender,
                mintPower,
                numOfDays,
                getCurrentMintableHydra(),
                gMintPower,
                currentHRank,
                getBatchMintCost(mintPower, 1)
            );
        _updateMintStats(currentHRank, gMintPower, gMinting);
        _protocolFees(mintPower, 1, MintStatus.ACTIVE);
    }

    /** @notice create new mints in ladder up to 100 mints
     * @param mintPower 1 - 100k
     * @param minDay minimum mint length
     * @param maxDay maximum mint lenght
     * @param dayInterval day increase from previous mint length
     * @param countPerInterval how many mints per mint length
     */
    function batchMintLadder(
        uint256 mintPower,
        uint256 minDay,
        uint256 maxDay,
        uint256 dayInterval,
        uint256 countPerInterval
    ) external payable nonReentrant dailyUpdate {
        if (dayInterval == 0) revert Hydra_InvalidMintLadderInterval();
        if (maxDay < minDay || minDay == 0 || maxDay > MAX_MINT_LENGTH)
            revert Hydra_InvalidMintLadderRange();

        uint256 count = getBatchMintLadderCount(minDay, maxDay, dayInterval, countPerInterval);
        if (count == 0 || count > MAX_BATCH_MINT_COUNT) revert Hydra_InvalidBatchCount();
        if (getUserLatestMintId(msg.sender) + count > MAX_MINT_PER_WALLET)
            revert Hydra_MaxedWalletMints();

        uint256 mintCost = getBatchMintCost(mintPower, 1); //only need 1 mint cost for all mints info

        _startbatchMintLadder(
            msg.sender,
            mintPower,
            minDay,
            maxDay,
            dayInterval,
            countPerInterval,
            getCurrentMintableHydra(),
            mintCost
        );
        _protocolFees(mintPower, count, MintStatus.ACTIVE);
    }

    /** @notice claim a matured mint
     * @param id mint id
     */
    function claimMint(uint256 id) external dailyUpdate nonReentrant {
        _mintReward(_claimMint(msg.sender, id, MintAction.CLAIM));
    }

    /** @notice early end a mint
     * @param id mint id
     */
    function earlyEndMint(uint256 id) external payable nonReentrant dailyUpdate {
        (uint256 reward, uint256 mintPower) = _earlyEndMint(msg.sender, id);
        _protocolFees(mintPower, 1, MintStatus.EARLYENDED);
        _mintReward(reward);
    }

    /** @notice distribute collected fees to different pools, caller receive a small incentive fee  */
    function distributeFees() public dailyUpdate nonReentrant {
        uint256 accumulatedFees = s_undistributedFees;
        if (accumulatedFees == 0) revert Hydra_NothingToDistribute();
        s_undistributedFees = 0;

        //caller incentive fee
        uint256 incentiveFee = (accumulatedFees * s_TitanXIncentiveDividend) /
            INCENTIVE_FEE_PERCENT_BASE;
        accumulatedFees -= incentiveFee;
        TransferHelper.safeTransferFrom(TITANX, address(this), msg.sender, incentiveFee);

        //TitanX vortex
        uint256 vortex = (accumulatedFees * TITANX_VORTEX_PERCENT) / PERCENT_BPS;
        s_vortexTitanX += vortex;

        //DragonX vault
        uint256 vaultAmount = (accumulatedFees * DRAGONX_VAULT_PERCENT) / PERCENT_BPS;
        TransferHelper.safeTransferFrom(TITANX, address(this), DRAGONX, vaultAmount);

        //Buy and Burn funds
        TransferHelper.safeTransferFrom(
            TITANX,
            address(this),
            s_buyAndBurnAddress,
            accumulatedFees - vortex - vaultAmount
        );

        emit FeesDistributed(msg.sender, accumulatedFees);
    }

    /** @notice callable by anyone to fund the Vortex TitanX
     */
    function fundVortexTitanX(uint256 amount) external dailyUpdate nonReentrant {
        TransferHelper.safeTransferFrom(TITANX, msg.sender, address(this), amount);
        s_vortexTitanX += amount;

        emit VortexReceived(msg.sender, getCurrentContractDay(), TITANX, amount);
    }

    /** @notice callable by anyone to fund the Vortex DragonX
     */
    function fundVortexDragonX(uint256 amount) external dailyUpdate nonReentrant {
        TransferHelper.safeTransferFrom(DRAGONX, msg.sender, address(this), amount);
        s_vortexDragonX += amount;

        emit VortexReceived(msg.sender, getCurrentContractDay(), DRAGONX, amount);
    }

    //send accumulated TitanX and DragonX to buyandburn contract
    function triggerVortex() public dailyUpdate nonReentrant {
        uint256 currentContractDay = getCurrentContractDay();
        //check against cylce payout maturity day
        if (currentContractDay < getNextCyclePayoutDay(DAY98)) return;

        //update the next cycle payout day regardless of payout triggered succesfully or not
        _setNextCyclePayoutDay(DAY98);

        //TitanX vortex
        uint256 vortexTitanX = s_vortexTitanX;
        if (vortexTitanX != 0) {
            s_vortexTitanX = 0;
            TransferHelper.safeTransferFrom(
                TITANX,
                address(this),
                s_buyAndBurnAddress,
                vortexTitanX
            );
        }

        //DragonX vortex
        uint256 vortexDragonX = s_vortexDragonX;
        if (vortexDragonX != 0) {
            s_vortexDragonX = 0;
            TransferHelper.safeTransferFrom(
                DRAGONX,
                address(this),
                s_buyAndBurnAddress,
                vortexDragonX
            );
        }

        emit VortexTriggered(currentContractDay, vortexTitanX, vortexDragonX);
    }

    //Private Functions
    /** @dev calcualte required protocol fees */
    function _protocolFees(uint256 mintPower, uint256 count, MintStatus status) private {
        uint256 protocolFee = getBatchMintCost(mintPower, count);
        if (status == MintStatus.EARLYENDED)
            protocolFee = (protocolFee * EARLY_END_MINT_COST_PERCENT) / PERCENT_BPS;

        TransferHelper.safeTransferFrom(TITANX, msg.sender, address(this), protocolFee);
        s_undistributedFees += protocolFee;

        emit ProtocolFeeRecevied(msg.sender, getCurrentContractDay(), protocolFee);
    }

    /** @dev burn liquid Hydra through other project.
     * called by other contracts for proof of burn 2.0 with up to 8% for both builder fee and user rebate
     * @param user user address
     * @param amount liquid Hydra amount
     * @param userRebatePercentage percentage for user rebate in liquid Hydra (0 - 8)
     * @param rewardPaybackPercentage percentage for builder fee in liquid Hydra (0 - 8)
     * @param rewardPaybackAddress builder can opt to receive fee in another address
     */
    function _burnLiquidHydra(
        address user,
        uint256 amount,
        uint256 userRebatePercentage,
        uint256 rewardPaybackPercentage,
        address rewardPaybackAddress
    ) private {
        if (amount == 0) revert Hydra_InvalidAmount();
        _spendAllowance(user, msg.sender, amount);
        _burnbefore(userRebatePercentage, rewardPaybackPercentage);
        _burn(user, amount);
        _burnAfter(
            user,
            amount,
            userRebatePercentage,
            rewardPaybackPercentage,
            rewardPaybackAddress,
            BurnSource.LIQUID
        );
    }

    /** @dev burn mint through other project.
     * called by other contracts for proof of burn 2.0
     * burn mint has no builder reward and no user rebate
     * @param user user address
     * @param id mint id
     */
    function _burnMint(address user, uint256 id) private {
        _spendBurnMintAllowance(user);
        _burnbefore(0, 0);
        uint256 amount = _claimMint(user, id, MintAction.BURN);
        _mint(s_genesisAddress, (amount * 8_000) / PERCENT_BPS);
        _burnAfter(user, amount, 0, 0, msg.sender, BurnSource.MINT);
    }

    /** @dev perform checks before burning starts.
     * check reward percentage and check if called by supported contract
     * @param userRebatePercentage percentage for user rebate
     * @param rewardPaybackPercentage percentage for builder fee
     */
    function _burnbefore(
        uint256 userRebatePercentage,
        uint256 rewardPaybackPercentage
    ) private view {
        if (rewardPaybackPercentage + userRebatePercentage > MAX_BURN_REWARD_PERCENT)
            revert Hydra_InvalidBurnRewardPercent();

        //Only supported contracts is allowed to call this function
        if (
            !IERC165(msg.sender).supportsInterface(IERC165.supportsInterface.selector) ||
            !IERC165(msg.sender).supportsInterface(type(IHydraOnBurn).interfaceId)
        ) revert Hydra_NotSupportedContract();
    }

    /** @dev update burn stats and mint reward to builder or user if applicable
     * @param user user address
     * @param amount Hydra amount burned
     * @param userRebatePercentage percentage for user rebate in liquid Hydra (0 - 8)
     * @param rewardPaybackPercentage percentage for builder fee in liquid Hydra (0 - 8)
     * @param rewardPaybackAddress builder can opt to receive fee in another address
     * @param source liquid/mint
     */
    function _burnAfter(
        address user,
        uint256 amount,
        uint256 userRebatePercentage,
        uint256 rewardPaybackPercentage,
        address rewardPaybackAddress,
        BurnSource source
    ) private {
        _updateBurnAmount(user, msg.sender, amount, source);

        uint256 devFee;
        uint256 userRebate;
        if (rewardPaybackPercentage != 0)
            devFee = (amount * rewardPaybackPercentage * PERCENT_BPS) / (100 * PERCENT_BPS);
        if (userRebatePercentage != 0)
            userRebate = (amount * userRebatePercentage * PERCENT_BPS) / (100 * PERCENT_BPS);

        if (devFee != 0) _mint(rewardPaybackAddress, devFee);
        if (userRebate != 0) _mint(user, userRebate);

        IHydraOnBurn(msg.sender).onBurn(user, amount);
    }

    /** @dev mint reward to user
     * @param reward Hydra amount
     */
    function _mintReward(uint256 reward) private {
        _mint(msg.sender, reward);
        _mint(s_genesisAddress, (reward * 8_000) / PERCENT_BPS);
    }

    /** @dev reduce user's allowance for caller (spender/project) by 1 (burn 1 mint at a time)
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     * @param user user address
     */
    function _spendBurnMintAllowance(address user) private {
        uint256 currentAllowance = allowanceBurnMints(user, msg.sender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance == 0) revert Hydra_InsufficientBurnAllowance();
            --s_allowanceBurnMints[user][msg.sender];
        }
    }

    //views
    /** @notice returns user's burn mints allowance of a project
     * @param user user address
     * @param spender project address
     */
    function allowanceBurnMints(address user, address spender) public view returns (uint256) {
        return s_allowanceBurnMints[user][spender];
    }

    /** @notice Returns current buy and burn contract address
     * @return address current buy and burn contract address
     */
    function getBuyAndBurnAddress() public view returns (address) {
        return s_buyAndBurnAddress;
    }

    /** @notice Returns status of the given address
     * @return status 0 (INACTIVE) or 1 (Active)
     */
    function getBuyAndBurnAddressRegistry(address contractAddress) public view returns (bool) {
        return s_buyAndBurnAddressRegistry[contractAddress];
    }

    /** @notice get current incentive fee dividend
     * @return amount
     */
    function getTitanXIncentiveDividend() public view returns (uint256) {
        return s_TitanXIncentiveDividend;
    }

    /** @notice get undistributed TitanX balance
     * @return amount TitanX
     */
    function getUndistributedFees() public view returns (uint256) {
        return s_undistributedFees;
    }

    /** @notice get vortex TitanX balance
     * @return amount TitanX
     */
    function getVortexTitanX() public view returns (uint256) {
        return s_vortexTitanX;
    }

    /** @notice get vortex DragonX balance
     * @return amount DragonX
     */
    function getVortexDragonX() public view returns (uint256) {
        return s_vortexDragonX;
    }

    //Public functions for devs to intergrate with Hydra
    /** @notice allow anyone to sync dailyUpdate manually */
    function manualDailyUpdate() public dailyUpdate {}

    /** @notice Burn Hydra tokens and creates Proof-Of-Burn record to be used by connected DeFi and fee is paid to specified address
     * @param user user address
     * @param amount Hydra amount
     * @param userRebatePercentage percentage for user rebate in liquid Hydra (0 - 8)
     * @param rewardPaybackPercentage percentage for builder fee in liquid Hydra (0 - 8)
     * @param rewardPaybackAddress builder can opt to receive fee in another address
     */
    function burnTokensToPayAddress(
        address user,
        uint256 amount,
        uint256 userRebatePercentage,
        uint256 rewardPaybackPercentage,
        address rewardPaybackAddress
    ) public nonReentrant {
        _burnLiquidHydra(
            user,
            amount,
            userRebatePercentage,
            rewardPaybackPercentage,
            rewardPaybackAddress
        );
    }

    /** @notice Burn Hydra tokens and creates Proof-Of-Burn record to be used by connected DeFi and fee is paid to specified address
     * @param user user address
     * @param amount Hydra amount
     * @param userRebatePercentage percentage for user rebate in liquid Hydra (0 - 8)
     * @param rewardPaybackPercentage percentage for builder fee in liquid Hydra (0 - 8)
     */
    function burnTokens(
        address user,
        uint256 amount,
        uint256 userRebatePercentage,
        uint256 rewardPaybackPercentage
    ) public nonReentrant {
        _burnLiquidHydra(user, amount, userRebatePercentage, rewardPaybackPercentage, msg.sender);
    }

    /** @notice allows user to burn liquid Hydra directly from contract
     * @param amount Hydra amount
     */
    function userBurnTokens(uint256 amount) public nonReentrant {
        if (amount == 0) revert Hydra_InvalidAmount();
        _burn(msg.sender, amount);
        _updateBurnAmount(msg.sender, address(0), amount, BurnSource.LIQUID);
    }

    /** @notice Burn mint and creates Proof-Of-Burn record to be used by connected DeFi.
     * Burn mint has no project reward or user rebate
     * @param user user address
     * @param id mint id
     */
    function burnMint(address user, uint256 id) public dailyUpdate nonReentrant {
        _burnMint(user, id);
    }

    /** @notice allows user to burn mint directly from contract
     * @param id mint id
     */
    function userBurnMint(uint256 id) public dailyUpdate nonReentrant {
        _updateBurnAmount(
            msg.sender,
            address(0),
            _claimMint(msg.sender, id, MintAction.BURN),
            BurnSource.MINT
        );
    }

    /** @notice Sets `amount` as the allowance of `spender` over the caller's (user) mints.
     * @param spender contract address
     * @param amount allowance amount
     */
    function approveBurnMints(address spender, uint256 amount) public returns (bool) {
        if (spender == address(0)) revert Hydra_InvalidAddress();
        s_allowanceBurnMints[msg.sender][spender] = amount;
        emit ApproveBurnMints(msg.sender, spender, amount);
        return true;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "../libs/enum.sol";
import "../libs/constant.sol";
import "../libs/calcFunctions.sol";

//custom errors
error Hydra_InvalidMintLength();
error Hydra_InvalidMintPower();
error Hydra_NoMintExists();
error Hydra_MintHasClaimed();
error Hydra_MintNotMature();
error Hydra_MintHasBurned();
error Hydra_MintMaturityNotMet();
error Hydra_MintHasEnded();

abstract contract MintInfo {
    //variables
    /** @dev track global hRank */
    uint256 private s_globalHRank;
    /** @dev track total mint claimed */
    uint256 private s_globalMintClaim;
    /** @dev track total mint burned */
    uint256 private s_globalMintBurn;
    /** @dev track total Hydra minting */
    uint256 private s_globalHydraMinting;
    /** @dev track total Hydra penalty */
    uint256 private s_globalHydraMintPenalty;
    /** @dev track global mint power */
    uint256 private s_globalMintPower;
    /** @dev track total mint early ended */
    uint256 private s_globalMintEarlyEnded;

    //mappings
    /** @dev track address => mintId */
    mapping(address => uint256) private s_addressMId;
    /** @dev track address, mintId => hRank info (gTrank, gMintPower) */
    mapping(address => mapping(uint256 => HRankInfo)) private s_addressMIdToHRankInfo;
    /** @dev track global hRank => mintInfo*/
    mapping(uint256 => UserMintInfo) private s_hRankToMintInfo;

    //structs
    struct UserMintInfo {
        uint16 mintPower;
        uint8 numOfDays;
        uint104 mintableHydra;
        uint48 mintStartTs;
        uint48 maturityTs;
        uint104 mintedHydra;
        uint104 mintCost;
        MintStatus status;
    }

    struct HRankInfo {
        uint256 hRank;
        uint256 gMintPower;
    }

    struct UserMint {
        uint256 mId;
        uint256 hRank;
        uint256 gMintPower;
        UserMintInfo mintInfo;
    }

    //events
    event MintStarted(
        address indexed user,
        uint256 indexed hRank,
        uint256 indexed gMintpower,
        UserMintInfo userMintInfo
    );

    event MintClaimed(
        address indexed user,
        uint256 indexed hRank,
        uint256 rewardMinted,
        uint256 indexed penalty,
        uint256 mintPenalty
    );

    event MintEarlyEnded(
        address indexed user,
        uint256 indexed hRank,
        uint256 rewardMinted,
        uint256 indexed penalty
    );

    //functions
    /** @dev create a new mint
     * @param user user address
     * @param mintPower mint power
     * @param numOfDays mint lenght
     * @param mintableHydra mintable Hydra
     * @param gMintPower global mint power
     * @param currentHRank current global hRank
     * @param mintCost actual mint cost paid for a mint
     */
    function _startMint(
        address user,
        uint256 mintPower,
        uint256 numOfDays,
        uint256 mintableHydra,
        uint256 gMintPower,
        uint256 currentHRank,
        uint256 mintCost
    ) internal returns (uint256 mintable) {
        if (numOfDays == 0 || numOfDays > MAX_MINT_LENGTH) revert Hydra_InvalidMintLength();
        if (mintPower == 0 || mintPower > MAX_MINT_POWER_CAP) revert Hydra_InvalidMintPower();

        //calculate mint reward up front with the provided params
        mintable = calculateMintReward(mintPower, numOfDays, mintableHydra);

        //store variables into mint info
        UserMintInfo memory userMintInfo = UserMintInfo({
            mintPower: uint16(mintPower),
            numOfDays: uint8(numOfDays),
            mintableHydra: uint104(mintable),
            mintStartTs: uint48(block.timestamp),
            maturityTs: uint48(block.timestamp + (numOfDays * SECONDS_IN_DAY)),
            mintedHydra: 0,
            mintCost: uint104(mintCost),
            status: MintStatus.ACTIVE
        });

        /** s_addressMId[user] tracks mintId for each addrress
         * s_addressMIdToHRankInfo[user][id] tracks current mint hRank and gPowerMint
         *  s_hRankToMintInfo[currentHRank] stores mint info
         */
        uint256 id = ++s_addressMId[user];
        s_addressMIdToHRankInfo[user][id].hRank = currentHRank;
        s_addressMIdToHRankInfo[user][id].gMintPower = gMintPower;
        s_hRankToMintInfo[currentHRank] = userMintInfo;

        emit MintStarted(user, currentHRank, gMintPower, userMintInfo);
    }

    /** @dev create new mint in a batch of up to max 100 mints with different mint length
     * @param user user address
     * @param mintPower mint power
     * @param minDay minimum start day
     * @param maxDay maximum end day
     * @param dayInterval days interval between each new mint length
     * @param countPerInterval number of mint(s) to create in each mint length interval
     * @param mintableHydra mintable Hydra
     * @param mintCost actual mint cost paid for a mint
     */
    function _startbatchMintLadder(
        address user,
        uint256 mintPower,
        uint256 minDay,
        uint256 maxDay,
        uint256 dayInterval,
        uint256 countPerInterval,
        uint256 mintableHydra,
        uint256 mintCost
    ) internal {
        uint256 gMintPower = s_globalMintPower;
        uint256 currentHRank = s_globalHRank;
        uint256 gMinting = s_globalHydraMinting;

        /**first for loop is used to determine mint length
         * minDay is the starting mint length
         * maxDay is the max mint length where it stops
         * dayInterval increases the minDay for the next mint
         */
        for (; minDay <= maxDay; minDay += dayInterval) {
            /**first for loop is used to determine mint length
             * second for loop is to create number mints per mint length
             */
            for (uint256 j = 0; j < countPerInterval; j++) {
                gMintPower += mintPower;
                gMinting += _startMint(
                    user,
                    mintPower,
                    minDay,
                    mintableHydra,
                    gMintPower,
                    ++currentHRank,
                    mintCost
                );
            }
        }
        _updateMintStats(currentHRank, gMintPower, gMinting);
    }

    /** @dev update variables
     * @param currentHRank current hRank
     * @param gMintPower current global mint power
     * @param gMinting current global minting
     */
    function _updateMintStats(uint256 currentHRank, uint256 gMintPower, uint256 gMinting) internal {
        s_globalHRank = currentHRank;
        s_globalMintPower = gMintPower;
        s_globalHydraMinting = gMinting;
    }

    /** @dev calculate reward for claim mint or burn mint.
     * Claim mint has maturity check while burn mint would bypass maturity check.
     * @param user user address
     * @param id mint id
     * @param action claim mint or burn mint
     * @return reward calculated final reward after all bonuses and penalty (if any)
     */
    function _claimMint(
        address user,
        uint256 id,
        MintAction action
    ) internal returns (uint256 reward) {
        uint256 hRank = s_addressMIdToHRankInfo[user][id].hRank;
        if (hRank == 0) revert Hydra_NoMintExists();

        UserMintInfo memory mint = s_hRankToMintInfo[hRank];
        if (mint.status == MintStatus.CLAIMED) revert Hydra_MintHasClaimed();
        if (mint.status == MintStatus.BURNED) revert Hydra_MintHasBurned();
        if (mint.status == MintStatus.EARLYENDED) revert Hydra_MintHasEnded();

        //Only check maturity for claim mint action, burn mint bypass this check
        if (mint.maturityTs > block.timestamp && action == MintAction.CLAIM)
            revert Hydra_MintNotMature();

        s_globalHydraMinting -= mint.mintableHydra;
        reward = _calculateClaimReward(user, hRank, mint, action);
    }

    /** @dev calculate final reward with bonuses and penalty (if any)
     * @param user user address
     * @param hRank mint's hRank
     * @param userMintInfo mint's info
     * @param action claim mint or burn mint
     * @return reward calculated final reward after all bonuses and penalty (if any)
     */
    function _calculateClaimReward(
        address user,
        uint256 hRank,
        UserMintInfo memory userMintInfo,
        MintAction action
    ) private returns (uint256 reward) {
        if (action == MintAction.CLAIM) s_hRankToMintInfo[hRank].status = MintStatus.CLAIMED;
        if (action == MintAction.BURN) s_hRankToMintInfo[hRank].status = MintStatus.BURNED;

        uint256 penaltyAmount;
        uint256 penalty;

        //only calculate penalty when current block timestamp > maturity timestamp
        if (block.timestamp > userMintInfo.maturityTs) {
            penalty = calculateClaimMintPenalty(block.timestamp - userMintInfo.maturityTs);
        }

        uint256 mintableSupply = uint256(userMintInfo.mintableHydra);
        penaltyAmount = (mintableSupply * penalty) / 100;
        reward = mintableSupply - penaltyAmount;

        if (action == MintAction.CLAIM) ++s_globalMintClaim;
        if (action == MintAction.BURN) ++s_globalMintBurn;
        if (penaltyAmount != 0) s_globalHydraMintPenalty += penaltyAmount;

        //only stored minted amount for claim mint
        if (action == MintAction.CLAIM) s_hRankToMintInfo[hRank].mintedHydra = uint104(reward);

        emit MintClaimed(user, hRank, reward, penalty, penaltyAmount);
    }

    /**
     * @dev early end a mint that hasn't mature and already matured at least 8 days
     * @param user user address
     * @param id mint id
     * @return reward calculated reward based on number of days matured, capped at 50% max
     * @return mintPower mint's power
     */
    function _earlyEndMint(
        address user,
        uint256 id
    ) internal returns (uint256 reward, uint256 mintPower) {
        uint256 hRank = s_addressMIdToHRankInfo[user][id].hRank;
        if (hRank == 0) revert Hydra_NoMintExists();

        UserMintInfo memory mint = s_hRankToMintInfo[hRank];
        if (mint.status == MintStatus.CLAIMED) revert Hydra_MintHasClaimed();
        if (mint.status == MintStatus.BURNED) revert Hydra_MintHasBurned();
        if (mint.status == MintStatus.EARLYENDED) revert Hydra_MintHasEnded();

        //revert if miner has matured or less than 3 days
        uint256 daysMatured = (block.timestamp - mint.mintStartTs) / 1 days;
        if (mint.maturityTs <= block.timestamp || daysMatured < 3)
            revert Hydra_MintMaturityNotMet();

        s_hRankToMintInfo[hRank].status = MintStatus.EARLYENDED;

        uint256 mintableSupply = mint.mintableHydra;
        uint256 earlyEndSupply = (mintableSupply * daysMatured) / mint.numOfDays;
        uint256 maxCapAmount = (mintableSupply * EARLYEND_MAX_CAP_PERCENT) / PERCENT_BPS;
        if (earlyEndSupply > maxCapAmount) earlyEndSupply = maxCapAmount;

        s_hRankToMintInfo[hRank].mintedHydra = uint104(earlyEndSupply);
        s_globalHydraMinting -= mintableSupply;
        s_globalHydraMintPenalty += mintableSupply - earlyEndSupply;
        ++s_globalMintEarlyEnded;
        reward = earlyEndSupply;
        mintPower = mint.mintPower;

        emit MintEarlyEnded(user, hRank, reward, mintableSupply - earlyEndSupply);
    }

    //views
    /** @notice Returns the latest Mint Id of an address
     * @param user address
     * @return mId latest mint id
     */
    function getUserLatestMintId(address user) public view returns (uint256) {
        return s_addressMId[user];
    }

    /** @notice Returns mint info of an address + mint id
     * @param user address
     * @param id mint id
     * @return mintInfo user mint info
     */
    function getUserMintInfo(
        address user,
        uint256 id
    ) public view returns (UserMintInfo memory mintInfo) {
        return s_hRankToMintInfo[s_addressMIdToHRankInfo[user][id].hRank];
    }

    /** @notice Return all mints info of an address
     * @param user address
     * @return mintInfos all mints info of an address including mint id, hRank and gMintPower
     */
    function getUserMints(address user) public view returns (UserMint[] memory mintInfos) {
        uint256 count = s_addressMId[user];
        mintInfos = new UserMint[](count);

        for (uint256 i = 1; i <= count; i++) {
            mintInfos[i - 1] = UserMint({
                mId: i,
                hRank: s_addressMIdToHRankInfo[user][i].hRank,
                gMintPower: s_addressMIdToHRankInfo[user][i].gMintPower,
                mintInfo: getUserMintInfo(user, i)
            });
        }
    }

    /** @notice Return total mints burned
     * @return totalMintBurned total mints burned
     */
    function getTotalMintBurn() public view returns (uint256) {
        return s_globalMintBurn;
    }

    /** @notice Return current gobal hRank
     * @return globalHRank global hRank
     */
    function getGlobalHRank() public view returns (uint256) {
        return s_globalHRank;
    }

    /** @notice Return current gobal mint power
     * @return globalMintPower global mint power
     */
    function getGlobalMintPower() public view returns (uint256) {
        return s_globalMintPower;
    }

    /** @notice Return total mints claimed
     * @return totalMintClaimed total mints claimed
     */
    function getTotalMintClaim() public view returns (uint256) {
        return s_globalMintClaim;
    }

    /** @notice Return total active mints (exluded claimed and burned mints)
     * @return totalActiveMints total active mints
     */
    function getTotalActiveMints() public view returns (uint256) {
        return s_globalHRank - s_globalMintClaim - s_globalMintBurn;
    }

    /** @notice Return total minting Hydra
     * @return totalMinting total minting Hydra
     */
    function getTotalMinting() public view returns (uint256) {
        return s_globalHydraMinting;
    }

    /** @notice Return total mint penalty
     * @return totalHydraPenalty total mint penalty
     */
    function getTotalMintPenalty() public view returns (uint256) {
        return s_globalHydraMintPenalty;
    }

    /** @notice Return total early ended mint
     * @return totalHydraPenalty total Hydra penalty
     */
    function getTotalMintEarlyEnded() public view returns (uint256) {
        return s_globalMintEarlyEnded;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "./openzeppelin/utils/Context.sol";

error Hydra_NotOnwer();

abstract contract OwnerInfo is Context {
    address private s_owner;

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        s_owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (s_owner != msg.sender) revert Hydra_NotOnwer();
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        s_owner = newOwner;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC165.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

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
pragma solidity ^0.8.21;

interface IHydra {
    function mintLPTokens(uint256 amount) external;

    function burnCAHydra(address contractAddress) external;

    function fundVortexTitanX(uint256 amount) external;

    function fundVortexDragonX(uint256 amount) external;

    function supportsInterface(bytes4 interfaceId) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IHydraOnBurn {
    function onBurn(address user, uint256 amount) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.6.0;

import "../contracts/openzeppelin/token/ERC20/IERC20.sol";

library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(
                IERC20.transferFrom.selector,
                from,
                to,
                value
            )
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "STF"
        );
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transfer.selector, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "ST"
        );
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.approve.selector, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SA"
        );
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "STE");
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "./constant.sol";

//Hydra
/**@notice get batch mint ladder total count
 * @param minDay minimum mint length
 * @param maxDay maximum mint length, cap at 280
 * @param dayInterval day increase from previous mint length
 * @param countPerInterval number of mints per minth length
 * @return count total mints
 */
function getBatchMintLadderCount(
    uint256 minDay,
    uint256 maxDay,
    uint256 dayInterval,
    uint256 countPerInterval
) pure returns (uint256 count) {
    if (maxDay > minDay) {
        count = (((maxDay - minDay) / dayInterval) + 1) * countPerInterval;
    }
}

/** @notice get batch mint cost
 * @param mintPower mint power (1 - 100)
 * @param count number of mints
 * @return mintCost total mint cost
 */
function getBatchMintCost(uint256 mintPower, uint256 count) pure returns (uint256) {
    return (START_MAX_MINT_COST * mintPower * count) / MAX_MINT_POWER_CAP;
}

//MintInfo
/** @notice the formula to calculate mint reward at create new mint
 * @param mintPower mint power 1 - 10000
 * @param numOfDays mint length 1 - 88
 * @param mintableHydra current contract day mintable Hydra
 * @return reward base Hydra amount
 */
function calculateMintReward(
    uint256 mintPower,
    uint256 numOfDays,
    uint256 mintableHydra
) pure returns (uint256 reward) {
    uint256 baseReward = (mintableHydra * mintPower * numOfDays);

    if (numOfDays != 1)
        baseReward -= (baseReward * MINT_DAILY_REDUCTION * (numOfDays - 1)) / PERCENT_BPS;

    reward = baseReward / MAX_MINT_POWER_CAP;
}

/**
 * @dev Return penalty percentage based on number of days late after the grace period of 7 days
 * @param secsLate seconds late (block timestamp - maturity timestamp)
 * @return penalty penalty in percentage
 */
function calculateClaimMintPenalty(uint256 secsLate) pure returns (uint256 penalty) {
    if (secsLate <= CLAIM_MINT_GRACE_PERIOD * SECONDS_IN_DAY) return 0;
    if (secsLate <= (CLAIM_MINT_GRACE_PERIOD + 1) * SECONDS_IN_DAY) return 1;
    if (secsLate <= (CLAIM_MINT_GRACE_PERIOD + 2) * SECONDS_IN_DAY) return 3;
    if (secsLate <= (CLAIM_MINT_GRACE_PERIOD + 3) * SECONDS_IN_DAY) return 8;
    if (secsLate <= (CLAIM_MINT_GRACE_PERIOD + 4) * SECONDS_IN_DAY) return 17;
    if (secsLate <= (CLAIM_MINT_GRACE_PERIOD + 5) * SECONDS_IN_DAY) return 35;
    if (secsLate <= (CLAIM_MINT_GRACE_PERIOD + 6) * SECONDS_IN_DAY) return 72;
    return 99;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

address constant TITANX = 0xF19308F923582A6f7c465e5CE7a9Dc1BEC6665B1;
address constant DRAGONX = 0x96a5399D07896f757Bd4c6eF56461F58DB951862;

// ===================== common ==========================================
uint256 constant DAY98 = 98;

uint256 constant SCALING_FACTOR_1e6 = 1e6;

uint256 constant SECONDS_IN_DAY = 86400;

uint256 constant TITANX_VORTEX_PERCENT = 10_000;
uint256 constant DRAGONX_VAULT_PERCENT = 20_000;
uint256 constant PERCENT_BPS = 100_000;
uint256 constant INCENTIVE_FEE_PERCENT_BASE = 1_000_000;

//Hydra Supply Variables
uint256 constant START_MAX_MINTABLE_PER_DAY = 800_000_000 ether;
uint256 constant CAPPED_MIN_DAILY_TITAN_MINTABLE = 80_000 ether;
uint256 constant DAILY_SUPPLY_MINTABLE_REDUCTION = 99_972;
uint256 constant START_MAX_MINT_COST = 1e11 ether;
uint256 constant EARLY_END_MINT_COST_PERCENT = 50_000;
uint256 constant EARLYEND_MAX_CAP_PERCENT = 50_000;

// ===================== mintInfo ==========================================
uint256 constant MAX_MINT_POWER_CAP = 10_000;
uint256 constant MAX_MINT_LENGTH = 88;
uint256 constant CLAIM_MINT_GRACE_PERIOD = 7;
uint256 constant MAX_BATCH_MINT_COUNT = 100;
uint256 constant MAX_MINT_PER_WALLET = 1000;
uint256 constant MINT_DAILY_REDUCTION = 11_0;

// ===================== burnInfo ==========================================
uint256 constant MAX_BURN_REWARD_PERCENT = 8;
//Enum
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

enum MintAction {
    CLAIM,
    BURN
}
enum MintStatus {
    ACTIVE,
    CLAIMED,
    BURNED,
    EARLYENDED
}
enum BurnSource {
    LIQUID,
    MINT
}