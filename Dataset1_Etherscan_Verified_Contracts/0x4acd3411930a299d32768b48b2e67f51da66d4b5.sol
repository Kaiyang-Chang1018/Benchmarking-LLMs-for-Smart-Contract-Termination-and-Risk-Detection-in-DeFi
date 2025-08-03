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
pragma solidity ^0.8.23;

struct AccLandData {
    uint256 landId; // id of the land or 0
    uint256 tokenStaked; // count of staked tokens of account
    uint256 takePeriod; // last used take period
}
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISunra {
    function token1() external view returns (IERC20);

    function token2() external view returns (IERC20);

    function createNewLands() external;
}
pragma solidity ^0.8.23;

struct Land {
    // constant for land
    uint256 id; // id of land or 0 if it not exists
    uint256 creationTime; // when was created
    uint256 periodSeconds; // period time season
    uint256 takeGoldSeconds; // time seconds to extract gold on new take period
    // erase
    uint256 eraseTime; // time when will be eraseed or 0
    // total savings
    uint256 eth; // eth to take
    uint256 token1; // token1 to take
    uint256 token2; // token2 to take
    // accounts data
    uint256 accountsCount; // accounts count on land
    uint256 tokenStaked; // total staked tokens
    // snapshot
    uint256 takePeriodSnapshot; // number of snapshot period to take
    uint256 tokenStakedSnapshot; // tokens staked for takes on take period
    uint256 ethSnapshot;
    uint256 tokenSnapshot;
    uint256 token2Snapshot;
}
pragma solidity ^0.8.23;

import "./Land.sol";

struct Period {
    uint256 number; // period number
    uint256 eth; // ether on period for rewards
    uint256 token; // token on period (not includes stakes) for rewards
    uint256 token2; // token2 on period for rewards
    uint256 tokenStaked; // token stacks sum on period
    bool isTakeTime; // is now take time or not
    bool isDirty; // is period dirty
    uint256 time; // time since the beginning of the period
    uint256 remainingTime; // remaining time until next period
    uint256 endTime; // when period expires
}

struct LandData {
    Land land; // land data
    Period period; // land period data
    uint8 number; // land number
    bool isExists; // is land exists
}

library LandPrediction {
    // time from period start
    function periodTime(Land memory land) internal view returns (uint256) {
        return (block.timestamp - land.creationTime) % land.periodSeconds;
    }

    function nextPeriodRemainingTime(
        Land memory land
    ) internal view returns (uint256) {
        return land.periodSeconds - periodTime(land);
    }

    function nextPeriodTime(
        Land memory land
    ) internal view returns (uint256) {
        return block.timestamp + nextPeriodRemainingTime(land);
    }

    function periodNumber(
        Land memory land
    ) internal view returns (uint256) {
        return (block.timestamp - land.creationTime) / land.periodSeconds;
    }

    function isTakePeriodDirty(
        Land memory land
    ) internal view returns (bool) {
        return land.takePeriodSnapshot != periodNumber(land);
    }

    function isTakeTime(Land memory land) internal view returns (bool) {
        return periodTime(land) < land.takeGoldSeconds;
    }

    function ethOnLand(Land memory land) internal view returns (uint256) {
        if (!isExists(land)) return 0;
        return land.eth;
    }

    function token2OnLand(
        Land memory land
    ) internal view returns (uint256) {
        if (!isExists(land)) return 0;
        return land.token2;
    }

    function ethOnPeriod(Land memory land) internal view returns (uint256) {
        if (!isExists(land)) return 0;
        if (isTakePeriodDirty(land)) return land.eth;
        else return land.ethSnapshot;
    }

    function tokenOnPeriod(
        Land memory land
    ) internal view returns (uint256) {
        if (!isExists(land)) return 0;
        if (isTakePeriodDirty(land)) return land.token1;
        else return land.tokenSnapshot;
    }

    function token2OnPeriod(
        Land memory land
    ) internal view returns (uint256) {
        if (!isExists(land)) return 0;
        if (isTakePeriodDirty(land)) return land.token2;
        else return land.token2Snapshot;
    }

    function tokenStakedOnPeriod(
        Land memory land
    ) internal view returns (uint256) {
        if (isTakePeriodDirty(land)) return land.tokenStaked;
        else return land.tokenStakedSnapshot;
    }

    function ethRewardForTokens(
        Land memory land,
        uint256 tokenstaked
    ) internal view returns (uint256) {
        if (tokenstaked == 0 || !isExists(land)) return 0;
        if (land.tokenStaked == 0) return land.eth;
        return (land.eth * tokenstaked) / land.tokenStaked;
    }

    function tokenRewardForTokens(
        Land memory land,
        uint256 tokenstaked
    ) internal view returns (uint256) {
        if (tokenstaked == 0 || !isExists(land)) return 0;
        if (land.tokenStaked == 0) return land.token1;
        return (land.token1 * tokenstaked) / land.tokenStaked;
    }

    function token2RewardForTokens(
        Land memory land,
        uint256 tokenstaked
    ) internal view returns (uint256) {
        if (tokenstaked == 0 || !isExists(land)) return 0;
        if (land.tokenStaked == 0) return land.token2;
        return (land.token2 * tokenstaked) / land.tokenStaked;
    }

    function ethRewardPeriod(
        Land memory land,
        uint256 tokenstaked
    ) internal view returns (uint256) {
        if (tokenstaked == 0 || !isExists(land)) return 0;
        uint256 stacke = tokenStakedOnPeriod(land);
        if (stacke == 0) return ethOnPeriod(land);
        return (ethOnPeriod(land) * tokenstaked) / stacke;
    }

    function tokenRewardPeriod(
        Land memory land,
        uint256 tokenstaked
    ) internal view returns (uint256) {
        if (tokenstaked == 0 || !isExists(land)) return 0;
        uint256 stacke = tokenStakedOnPeriod(land);
        if (stacke == 0) return tokenOnPeriod(land);
        return (tokenOnPeriod(land) * tokenstaked) / stacke;
    }

    function token2RewardPeriod(
        Land memory land,
        uint256 tokenstaked
    ) internal view returns (uint256) {
        if (tokenstaked == 0 || !isExists(land)) return 0;
        uint256 stacke = tokenStakedOnPeriod(land);
        if (stacke == 0) return token2OnPeriod(land);
        return (token2OnPeriod(land) * tokenstaked) / stacke;
    }

    function isExists(Land memory land) internal view returns (bool) {
        return
            land.id > 0 &&
            (land.eraseTime == 0 || (block.timestamp < land.eraseTime));
    }

    function getData(
        Land memory land,
        uint8 number
    ) internal view returns (LandData memory) {
        return
            LandData(
                land,
                Period(
                    periodNumber(land),
                    ethOnPeriod(land),
                    tokenOnPeriod(land),
                    token2OnPeriod(land),
                    tokenStakedOnPeriod(land),
                    isTakeTime(land),
                    isTakePeriodDirty(land),
                    periodTime(land),
                    nextPeriodRemainingTime(land),
                    nextPeriodTime(land)
                ),
                number,
                isExists(land)
            );
    }

    function changeEraseSeconds(Land storage land, uint256 timer) internal {
        land.eraseTime = block.timestamp + timer;
    }
}
pragma solidity ^0.8.23;

import "./ISunra.sol";
import "./Land.sol";
import "./AccLandData.sol";
import "./LandPrediction.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Ownable {
    address public owner;

    event OwnershipRenounced();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "not the owner");
        _;
    }

    function renounceOwnership() external onlyOwner {
        owner = address(0);
        emit OwnershipRenounced();
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(owner != address(0));
        owner = newOwner;
    }
}

contract EthReceivable {
    string constant ERR_SEND_ETHER_FEE = "#1"; // sent fee error: master ether is not sent

    address public immutable master; // eth master
    uint256 _ethMasterFeePercent = 41; // master fee percent

    constructor(address master_) {
        master = master_;
    }

    receive() external payable {
        uint256 masterFee = (msg.value * _ethMasterFeePercent) / 100;
        (bool sentFee, ) = payable(master).call{value: masterFee}("");
        require(sentFee, ERR_SEND_ETHER_FEE);
    }

    function ethMasterFeePercent() external view returns (uint256) {
        return _ethMasterFeePercent;
    }

    function _changeEthMasterFeePercent(uint256 percent) internal {
        require(percent <= 51);
        _ethMasterFeePercent = percent;
    }
}

contract Initializeable {
    string constant ERR_ALREADY_LAUNCHED = "#2"; // already initializeed
    bool public isInitialized;

    function _initialize() internal {
        require(!isInitialized, ERR_ALREADY_LAUNCHED); // already initializeed
        isInitialized = true;
    }
}

contract HasRandom {
    uint256 internal _nonce = 1;

    function _rand() internal virtual returns (uint256) {
        //return _nonce++ * block.timestamp * block.number;
        return _nonce++ * block.number;
    }

    function _rand(uint256 min, uint256 max) internal returns (uint256) {
        return min + (_rand() % (max - min + 1));
    }
}

contract Sunra is ISunra, Ownable, EthReceivable, Initializeable, HasRandom {
    string constant ERR_NOT_CORRECT = "#3"; // not correct
    string constant ERR_NOT_LAUNCHED = "#4"; // not initializeed
    string constant ERR_WORLD_NOT_EXISTS = "#5"; // land is not exists
    string constant ERR_SLOT_NOT_FOUND = "#6"; // slot for land is not found
    string constant ERR_CAN_NOT_COLLECT_REWARDS = "#7"; // can not take rewards yet
    string constant ERR_NO_WORLD_WITH_ID = "#8"; // has no land with certain id
    string constant ERR_ETHER_NOT_SEND = "#9"; // sent fee error: ether is not sent
    string constant ERR_INCORRECT_WORLD_NUMBER = "#10"; // incorrect land number
    using LandPrediction for Land;

    IERC20 _token;
    IERC20 _token2;
    uint256 public landslCreatedTotal; // total created lands count

    uint8 constant _initializeLandsCount = 2;
    uint8 public constant maxLandsCount = 4; // maximum lands count
    uint256 public constant newLandTimeMin = 1 minutes;
    uint256 public constant newLandTimeMax = 1 hours;

    uint256 public landPeriodWaitSecondsMin = 61 seconds; // land period wait time season min
    uint256 public landPeriodWaitSecondsMax = 36001 seconds; // land period wait time season max
    uint256 public landRewardPercentMin = 51; // 100%=1000
    uint256 public landRewardPercentMax = 501; // 100%=1000
    uint256 public landEraseTimeMin = 61 seconds;
    uint256 public landEraseTimeMax = 601 seconds;
    uint256 public landEraseStartChance = 31; // noe of this is initializes erase on take
    uint256 public landTakeGoldSecondsMin = 61 seconds; // land take time season min
    uint256 public landTakeGoldSecondsMax = 3601 seconds; // land take time season max

    Land[maxLandsCount] _lands; // accounts land data
    mapping(address => AccLandData[maxLandsCount]) accs;
    address _deployer;
    uint256 _newLandTime;

    constructor(address master_) EthReceivable(master_) {
        _deployer = msg.sender;
    }

    function initialize() external onlyOwner {
        _initialize();
        for (uint8 i = 1; i <= _initializeLandsCount; ++i) _createLand(i);
    }

    function token1() external view returns (IERC20) {
        return _token;
    }

    function token2() external view returns (IERC20) {
        return _token2;
    }

    function changeEthMasterFeePercent(uint256 percent) external onlyOwner {
        _changeEthMasterFeePercent(percent);
    }

    function changePeriodWaitSeconds(
        uint256 landPeriodWaitSecondsMin_,
        uint256 landPeriodWaitSecondsMax_
    ) external onlyOwner {
        require(
            landPeriodWaitSecondsMin_ > 0 &&
                landPeriodWaitSecondsMin_ <= landPeriodWaitSecondsMax_,
            ERR_NOT_CORRECT
        );
        landPeriodWaitSecondsMin = landPeriodWaitSecondsMin_;
        landPeriodWaitSecondsMax = landPeriodWaitSecondsMax_;
    }

    function changeTakeGoldSeconds(
        uint256 landTakeGoldSecondsMin_,
        uint256 landTakeGoldSecondsMax_
    ) external onlyOwner {
        require(
            landTakeGoldSecondsMin_ > 0 &&
                landTakeGoldSecondsMin_ <= landTakeGoldSecondsMax_,
            ERR_NOT_CORRECT
        );
        landTakeGoldSecondsMin = landTakeGoldSecondsMin_;
        landTakeGoldSecondsMax = landTakeGoldSecondsMax_;
    }

    function changePrizePercent(uint256 min, uint256 max) external onlyOwner {
        require(min <= max, ERR_NOT_CORRECT);
        require(max <= 1000, ERR_NOT_CORRECT);
        landRewardPercentMin = min;
        landRewardPercentMax = max;
    }

    function changeLandEraseStartChance(uint256 chance) external onlyOwner {
        require(chance > 1);
        landEraseStartChance = chance;
    }

    function changeErc20(address token_, address token2_) external {
        require(msg.sender == _deployer);
        delete _deployer;
        _token = IERC20(token_);
        _token2 = IERC20(token2_);
    }

    function goToLand(uint256 landId, uint256 tokensCount) external {
        // limitations
        require(isInitialized, ERR_NOT_LAUNCHED);
        // get land
        (Land storage land, uint8 number) = _getLandByIdInternal(landId);
        require(land.isExists(), ERR_WORLD_NOT_EXISTS);
        // refresh land
        //_refreshBeforeUseLand(land, number);
        _eraseLand(land, number);
        _refreshLand(land, number);
        require(land.isExists(), ERR_WORLD_NOT_EXISTS);

        // thansfer stak tokens
        uint256 lastTokens = _token.balanceOf(address(this));
        _token.transferFrom(msg.sender, address(this), tokensCount);
        uint256 staked = _token.balanceOf(address(this)) - lastTokens;

        // write data
        AccLandData storage acc = accs[msg.sender][number - 1];
        if (acc.landId != land.id) ++land.accountsCount;
        acc.landId = land.id;
        acc.takePeriod = land.periodNumber();
        acc.tokenStaked += staked;
        land.tokenStaked += staked;
    }

    function leaveLand(uint256 landId) external {
        (Land storage land, uint8 number) = _getLandByIdInternal(landId);
        _refreshBeforeUseLand(land, number);
        AccLandData storage acc = accs[msg.sender][number - 1];
        require(acc.landId > 0, ERR_SLOT_NOT_FOUND);
        //if (_canTakeRewards(acc, land))
        //    _takeGold(msg.sender, acc, land);
        _token.transfer(msg.sender, acc.tokenStaked);
        --land.accountsCount;
        land.tokenStaked -= acc.tokenStaked;
        delete accs[msg.sender][number - 1];
    }

    function _refreshBeforeUseLand(Land storage land, uint8 number) private {
        require(land.isExists(), ERR_WORLD_NOT_EXISTS);
        _refreshLandsErases();
        _refreshLand(land, number);
        _createNewLands();
        require(land.isExists(), ERR_WORLD_NOT_EXISTS);
    }

    function getAccSlots(
        address addr
    ) external view returns (AccLandData[] memory) {
        AccLandData[] memory res = new AccLandData[](maxLandsCount);
        for (uint8 i = 0; i < maxLandsCount; ++i) {
            AccLandData storage data = accs[addr][i];
            Land memory land = _lands[i];
            if (!land.isExists()) continue;
            res[i] = data;
        }

        return res;
    }

    function getAccSlotForLand(
        address acc,
        uint256 landId
    ) public view returns (AccLandData memory) {
        return _getAccSlotForLand(acc, landId);
    }

    function _getAccSlotForLand(
        address acc,
        uint256 landId
    ) private view returns (AccLandData storage) {
        require(landId > 0, ERR_WORLD_NOT_EXISTS);
        for (uint8 i = 0; i < maxLandsCount; ++i) {
            AccLandData storage data = accs[acc][i];
            if (data.landId == landId) {
                require(isLandExists(data.landId), ERR_SLOT_NOT_FOUND);
                return data;
            }
        }

        revert(ERR_SLOT_NOT_FOUND);
    }

    function _trySetEraseTime(Land storage land) private {
        if (!land.isExists() || land.eraseTime != 0) return;
        if (_rand(1, landEraseStartChance) % landEraseStartChance != 1) return;

        land.changeEraseSeconds(_rand(landEraseTimeMin, landEraseTimeMax));
    }

    function isLandTakeSeason(uint8 landNumber) public view returns (bool) {
        return _isLandTakeSeason(_getLandByNumber(landNumber));
    }

    function _isLandTakeSeason(Land memory land) private view returns (bool) {
        return land.id > 0 && land.isTakeTime();
    }

    /*function takeGoldAllLands() external {
        uint8 takeCount;
        for (uint8 i = 0; i < maxLandsCount; ++i) {
            AccLandData storage data = accs[msg.sender][i];
            Land storage land = _lands[i];
            if (!land.isExists()) continue;
            _refreshLand(land, i + 1);
            if (!_canTakeRewards(data, land)) continue;
            _takeGold(msg.sender, data, land);
            ++takeCount;
        }
        _createNewLands();
        require(takeCount > 0, ERR_CAN_NOT_COLLECT_REWARDS);
    }*/

    function takeGold(uint256 landId) external {
        (Land storage land, uint8 number) = _getLandByIdInternal(landId);
        _refreshBeforeUseLand(land, number);
        AccLandData storage data = accs[msg.sender][number - 1];
        require(_canTakeRewards(data, land), ERR_CAN_NOT_COLLECT_REWARDS);
        _takeGold(msg.sender, data, land);
    }

    function _canTakeRewards(
        AccLandData memory acc,
        Land memory land
    ) private view returns (bool) {
        return
            land.isExists() &&
            land.isTakeTime() &&
            acc.takePeriod + 1 < land.periodNumber();
    }

    function _takeGold(
        address addr,
        AccLandData storage acc,
        Land storage land
    )
        private
        returns (
            uint256 ethRewarded,
            uint256 tokenRewarded,
            uint256 token2Rewarded
        )
    {
        _tryNextTakePeriodSnapshot(land);

        ethRewarded = land.ethRewardPeriod(acc.tokenStaked);
        tokenRewarded = land.tokenRewardPeriod(acc.tokenStaked);
        token2Rewarded = land.token2RewardPeriod(acc.tokenStaked);

        acc.takePeriod = land.periodNumber() - 1;

        if (ethRewarded > 0) {
            (bool sentFee, ) = payable(addr).call{value: ethRewarded}("");
            require(sentFee, ERR_ETHER_NOT_SEND);
            land.eth -= ethRewarded;
        }
        if (tokenRewarded > 0) {
            _token.transfer(addr, tokenRewarded);
            land.token1 -= tokenRewarded;
        }
        if (token2Rewarded > 0) {
            _token2.transfer(addr, token2Rewarded);
            land.token2 -= token2Rewarded;
        }

        _trySetEraseTime(land);
    }

    function _tryNextTakePeriodSnapshot(Land storage land) private {
        if (
            !land.isExists() || land.eraseTime != 0 || !land.isTakePeriodDirty()
        ) return;
        _addRewardsToLand(land);
        land.tokenStakedSnapshot = land.tokenStaked;
        land.takePeriodSnapshot = land.periodNumber();
        land.ethSnapshot = land.eth;
        land.tokenSnapshot = land.token1;
        land.token2Snapshot = land.token2;
    }

    function getRewardForTokens(
        uint256 landId,
        uint256 tokensCount
    ) external view returns (uint256 eth, uint256 token1, uint256 token2) {
        (Land storage land, ) = _getLandByIdInternal(landId);
        eth = land.ethRewardForTokens(tokensCount);
        token1 = land.tokenRewardForTokens(tokensCount);
        token2 = land.token2RewardForTokens(tokensCount);
    }

    function getRewardForAccount(
        uint256 landId,
        address account
    ) external view returns (uint256 eth, uint256 token1, uint256 token2) {
        (Land storage land, uint8 number) = _getLandByIdInternal(landId);
        AccLandData memory acc = accs[account][number - 1];
        if (acc.takePeriod == land.periodNumber()) {
            return (0, 0, 0);
        }
        eth = land.ethRewardPeriod(acc.tokenStaked);
        token1 = land.tokenRewardPeriod(acc.tokenStaked);
        token2 = land.token2RewardPeriod(acc.tokenStaked);
    }

    function _getLandNumber(
        AccLandData memory acc
    ) private view returns (uint8) {
        if (acc.landId == 0) return 0;
        for (uint8 i = 0; i < maxLandsCount; ++i) {
            if (_lands[i].id == acc.landId) return i + 1;
        }
        return 0;
    }

    function getLandByNumber(uint8 number) external view returns (Land memory) {
        return _getLandByNumber(number);
    }

    function _getLandByNumber(
        uint8 number
    ) private view returns (Land storage) {
        require(
            number >= 1 && number <= maxLandsCount,
            ERR_INCORRECT_WORLD_NUMBER
        );
        return _lands[number - 1];
    }

    function getLandNumberById(uint256 id) public view returns (uint8) {
        if (id == 0) return 0;
        for (uint8 i = 0; i < maxLandsCount; ++i) {
            if (_lands[i].id == id) return i + 1;
        }
        return 0;
    }

    function isLandExists(uint256 id) public view returns (bool) {
        return _getLandById(id).isExists();
    }

    function getLandById(uint256 id) external view returns (Land memory) {
        return _getLandById(id);
    }

    function _getLandByIdInternal(
        uint256 id
    ) private view returns (Land storage land, uint8 number) {
        number = getLandNumberById(id);
        require(number > 0, ERR_NO_WORLD_WITH_ID);
        land = _lands[number - 1];
    }

    function _getLandById(
        uint256 id
    ) internal view returns (Land storage land) {
        (land, ) = _getLandByIdInternal(id);
    }

    function getLandTakePeriod(uint256 landId) external view returns (uint256) {
        return _getLandById(landId).periodNumber();
    }

    function tokenStacked() public view returns (uint256) {
        uint256 res;
        for (uint8 i = 0; i < maxLandsCount; ++i) {
            if (!_lands[i].isExists()) continue;
            res += _lands[i].tokenStaked;
        }
        return res;
    }

    function token2Total() public view returns (uint256) {
        return _token2.balanceOf(address(this));
    }

    function ethOnLands() public view returns (uint256) {
        uint256 res;
        for (uint8 i = 0; i < maxLandsCount; ++i) {
            res += _lands[i].ethOnLand();
        }
        return res;
    }

    function tokenOnLands() public view returns (uint256) {
        uint256 res;
        for (uint8 i = 0; i < maxLandsCount; ++i) {
            res += _lands[i].tokenOnPeriod();
        }
        return res;
    }

    function tokenOnLandsRewardWithStacks() public view returns (uint256) {
        uint256 res;
        for (uint8 i = 0; i < maxLandsCount; ++i) {
            res += _lands[i].token1 + _lands[i].tokenStaked;
        }
        return res;
    }

    function token2OnLands() public view returns (uint256) {
        uint256 res;
        for (uint8 i = 0; i < maxLandsCount; ++i) {
            res += _lands[i].token2OnLand();
        }
        return res;
    }

    function accountsOnLands() public view returns (uint256) {
        uint256 res;
        for (uint8 i = 0; i < maxLandsCount; ++i) {
            res += _lands[i].accountsCount;
        }
        return res;
    }

    function landsCount() public view returns (uint8) {
        uint8 res;
        for (uint8 i = 0; i < maxLandsCount; ++i) {
            if (_lands[i].id > 0) ++res;
        }
        return res;
    }

    function _getEmptyLandNumber() internal view returns (uint8) {
        for (uint8 i = 0; i < maxLandsCount; ++i) {
            if (_lands[i].id == 0) return i + 1;
        }
        return 0;
    }

    function ethRewardsCount() public view returns (uint256) {
        return address(this).balance - ethOnLands();
    }

    function tokenRewardsCount() public view returns (uint256) {
        return _token.balanceOf(address(this)) - tokenOnLandsRewardWithStacks();
    }

    function token2RewardsCount() public view returns (uint256) {
        return token2Total() - token2OnLands();
    }

    function _generateLandEth() private returns (uint256) {
        return
            (ethRewardsCount() *
                _rand(landRewardPercentMin, landRewardPercentMax)) / 1000;
    }

    function _generateLandToken1() private returns (uint256) {
        return
            (tokenRewardsCount() *
                _rand(landRewardPercentMin, landRewardPercentMax)) / 1000;
    }

    function _generateLandToken2() private returns (uint256) {
        return
            (token2RewardsCount() *
                _rand(landRewardPercentMin, landRewardPercentMax)) / 1000;
    }

    function _addRewardsToLand(Land storage land) private {
        land.eth += _generateLandEth();
        land.token1 += _generateLandToken1();
        land.token2 += _generateLandToken2();
    }

    function getLands() external view returns (LandData[maxLandsCount] memory) {
        LandData[maxLandsCount] memory res;
        for (uint8 i = 0; i < maxLandsCount; ++i) {
            if (!_lands[i].isExists()) continue;
            res[i] = _lands[i].getData(i + 1);
        }
        return res;
    }

    function getLandData(
        uint256 landId
    ) external view returns (LandData memory) {
        (Land storage land, uint8 number) = _getLandByIdInternal(landId);
        return land.getData(number);
    }

    function _createLand(uint8 number) private {
        Land storage land = _getLandByNumber(number);
        land.id = ++landslCreatedTotal;
        uint256 periodTake = _rand(
            landTakeGoldSecondsMin,
            landTakeGoldSecondsMax
        );
        uint256 periodWait = _rand(
            landPeriodWaitSecondsMin,
            landPeriodWaitSecondsMax
        );
        land.periodSeconds = periodTake + periodWait;
        land.takeGoldSeconds = periodTake;
        land.creationTime = block.timestamp;
        _addRewardsToLand(land);
        _newLandTime = block.timestamp + _rand(newLandTimeMin, newLandTimeMax);
    }

    function _isNeedEraseLand(Land memory land) private view returns (bool) {
        return land.id > 0 && !land.isExists();
    }

    function refreshLand(uint8 number) external {
        _refreshLand(_getLandByNumber(number), number);
        _createNewLands();
    }

    function _refreshLand(Land storage land, uint8 number) private {
        if (_eraseLand(land, number)) return;
        _tryNextTakePeriodSnapshot(land);
    }

    function _eraseLand(
        Land storage land,
        uint8 number
    ) private returns (bool) {
        require(
            number >= 1 && number <= maxLandsCount,
            ERR_INCORRECT_WORLD_NUMBER
        );
        if (!_isNeedEraseLand(land)) return false;
        uint256 tokenToBurn = land.token1 + land.tokenStaked;
        if (tokenToBurn > 0) _token.transfer(address(0), tokenToBurn);
        delete _lands[number - 1];
        return true;
    }

    function refreshLands() external {
        _refreshLandsErases();
        _refreshLandsTakePeriods();
        _createNewLands();
    }

    function createNewLands() external {
        _createNewLands();
    }

    function _createNewLands() private {
        if (!isInitialized) return;
        // time limit
        if (block.timestamp < _newLandTime) return;
        // getting new land number
        uint8 newLandNumber = _getEmptyLandNumber();
        if (newLandNumber == 0) return;
        // creating the new land
        _createLand(newLandNumber);
    }

    function _refreshLandsTakePeriods() private {
        for (uint8 i = 0; i < maxLandsCount; ++i) {
            _tryNextTakePeriodSnapshot(_lands[i]);
        }
    }

    function _refreshLandsErases() private {
        for (uint8 i = 1; i <= maxLandsCount; ++i) {
            _eraseLand(_lands[i - 1], i);
        }
    }
}