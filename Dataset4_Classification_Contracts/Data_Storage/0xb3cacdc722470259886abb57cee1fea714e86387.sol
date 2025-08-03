// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import {IBaseOracleAdapter} from "./interfaces/IBaseOracleAdapter.sol";
import {IBaseController} from "./interfaces/IBaseController.sol";
import {IOevShare} from "./interfaces/IOevShare.sol";

/**
 * @title DiamondRootOevShare contract to provide base functions that the three components of the OEV contract system
 * need. They are exposed here to simplify the inheritance structure of the OEV contract system and to enable easier
 * composability and extensibility at the integration layer, enabling arbitrary combinations of sources and destinations.
 */

abstract contract DiamondRootOevShare is IBaseController, IOevShare, IBaseOracleAdapter {
    /**
     * @notice Returns the latest data from the source.
     * @return answer The latest answer in 18 decimals.
     * @return updatedAt The timestamp of the answer.
     */
    function getLatestSourceData() public view virtual returns (int256, uint256);

    /**
     * @notice Tries getting latest data as of requested timestamp. If this is not possible, returns the earliest data
     * available past the requested timestamp within provided traversal limitations.
     * @param timestamp The timestamp to try getting latest data at.
     * @param maxTraversal The maximum number of rounds to traverse when looking for historical data.
     * @return answer The answer as of requested timestamp, or earliest available data if not available, in 18 decimals.
     * @return updatedAt The timestamp of the answer.
     */
    function tryLatestDataAt(uint256 timestamp, uint256 maxTraversal) public view virtual returns (int256, uint256);

    /**
     * @notice Returns the latest data from the source. Depending on when the OEVShare was last unlocked this might
     * return an slightly stale value to protect the OEV from being stolen by a front runner.
     * @return answer The latest answer in 18 decimals.
     * @return updatedAt The timestamp of the answer.
     */
    function internalLatestData() public view virtual returns (int256, uint256);

    /**
     * @notice Snapshot the current source data. Is a no-op if the source does not require snapshotting.
     */
    function snapshotData() public virtual;

    /**
     * @notice Permissioning function to control who can unlock the OEVShare.
     */
    function canUnlock(address caller, uint256 cachedLatestTimestamp) public view virtual returns (bool);

    /**
     * @notice Time window that bounds how long the permissioned actor has to call the unlockLatestValue function after
     * a new source update is posted. If the permissioned actor does not call unlockLatestValue within this window of a
     * new source price, the latest value will be made available to everyone without going through an MEV-Share auction.
     * @return lockWindow time in seconds.
     */
    function lockWindow() public view virtual returns (uint256);

    /**
     * @notice Max number of historical source updates to traverse when looking for a historic value in the past.
     * @return maxTraversal max number of historical source updates to traverse.
     */
    function maxTraversal() public view virtual returns (uint256);
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
import {DiamondRootOevShare} from "./DiamondRootOevShare.sol";

/**
 * @title OEVShare contract to provide permissioned updating at the execution of an MEV-share auction.
 * @dev This contract works by conditionally returning a stale value oracle price from the source adapter until a
 * permissioned actor calls the unlockLatestValue function. The call to unlockLatestValue is submitted via an MEV-share
 * auction and will be backrun by the winner of the auction. The backrunner has access to the most recent newly unlocked
 * source price. If someone tries to front-run the call to unlockLatestValue, the caller will receive a stale value. If
 * the permissioned actor does not call unlockLatestValue within the lockWindow, the latest value that is at least
 * lockWindow seconds old will be returned. This contract is intended to be used in conjunction with a Controller
 * contract that governs who can call unlockLatestValue.
 * @custom:security-contact bugs@umaproject.org
 */

abstract contract OevShare is DiamondRootOevShare {
    uint256 public lastUnlockTime; // Timestamp of the latest unlock to the OEVShare.

    /**
     * @notice Function called by permissioned actor to unlock the latest value as part of the MEV-share auction flow.
     * @dev The call to this function is expected to be sent to flashbots via eth_sendPrivateTransaction. This is the
     * transaction that is backrun by the winner of the auction. The backrunner has access to the most recent newly
     * unlocked source price as a result and therefore can extract the MEV associated with the unlock.
     */
    function unlockLatestValue() public {
        require(canUnlock(msg.sender, lastUnlockTime), "Controller blocked: canUnlock");

        snapshotData(); // If the source connected to this OevShare needs to snapshot data, do it here. Else, no op.

        lastUnlockTime = block.timestamp;

        emit LatestValueUnlocked(block.timestamp);
    }

    /**
     * @notice Returns latest data from source, governed by lockWindow controlling if returned data is stale.
     * @return answer The latest answer in 18 decimals.
     * @return timestamp The timestamp of the answer.
     */
    function internalLatestData() public view override returns (int256, uint256) {
        // Case work:
        //-> If unlockLatestValue has been called within lockWindow, then return most recent price as of unlockLatestValue call.
        //-> If unlockLatestValue has not been called in lockWindow, then return most recent value that is at least lockWindow old.
        return tryLatestDataAt(Math.max(lastUnlockTime, block.timestamp - lockWindow()), maxTraversal());
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import {DecimalLib} from "../lib/DecimalLib.sol";
import {IAggregatorV3} from "../../interfaces/chainlink/IAggregatorV3.sol";
import {DiamondRootOevShare} from "../../DiamondRootOevShare.sol";

/**
 * @title ChainlinkDestinationAdapter contract to expose OEVShare data via the standard Chainlink Aggregator interface.
 */

abstract contract ChainlinkDestinationAdapter is DiamondRootOevShare, IAggregatorV3 {
    uint8 public immutable override decimals;

    event DecimalsSet(uint8 indexed decimals);

    constructor(uint8 _decimals) {
        decimals = _decimals;

        emit DecimalsSet(_decimals);
    }

    /**
     * @notice Returns the latest data from the source.
     * @return answer The latest answer in the configured number of decimals.
     */
    function latestAnswer() public view override returns (int256) {
        (int256 answer,) = internalLatestData();
        return DecimalLib.convertDecimals(answer, 18, decimals);
    }

    /**
     * @notice Returns when the latest answer was updated.
     * @return timestamp The timestamp of the latest answer.
     */
    function latestTimestamp() public view override returns (uint256) {
        (, uint256 timestamp) = internalLatestData();
        return timestamp;
    }

    /**
     * @notice Returns an approximate form of the latest Round data. This does not implement the notion of "roundId" that
     * the normal chainlink aggregator does and returns hardcoded values for those fields.
     * @return roundId The roundId of the latest answer, hardcoded to 1.
     * @return answer The latest answer in the configured number of decimals.
     * @return startedAt The timestamp when the value was updated.
     * @return updatedAt The timestamp when the value was updated.
     * @return answeredInRound The roundId of the round in which the answer was computed, hardcoded to 1.
     */
    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80) {
        (int256 answer, uint256 updatedAt) = internalLatestData();
        return (1, DecimalLib.convertDecimals(answer, 18, decimals), updatedAt, updatedAt, 1);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";

/**
 * @title DecimalLib library to perform decimal math operations.
 */
library DecimalLib {
    /**
     * Converts int256 answer scaled at iDecimals to scale at oDecimals.
     * Source oracle adapters should pass 18 for oDecimals, while destination adapters should pass 18 for iDecimals.
     * Warning: When downscaling (i.e., when iDecimals > oDecimals), the conversion can lead to a loss of precision.
     * In the worst case, if the answer is small enough, the conversion can return zero.
     * Warning: When upscaling (i.e., when iDecimals < oDecimals), if answer * 10^(oDecimals - iDecimals) exceeds
     * the maximum int256 value, this function will revert. Ensure the provided values will not cause an overflow.
     */
    function convertDecimals(int256 answer, uint8 iDecimals, uint8 oDecimals) internal pure returns (int256) {
        if (iDecimals == oDecimals) return answer;
        if (iDecimals < oDecimals) return answer * int256(10 ** (oDecimals - iDecimals));
        return answer / int256(10 ** (iDecimals - oDecimals));
    }

    /**
     * Converts uint256 answer scaled at iDecimals to scale at oDecimals.
     * Source oracle adapters should pass 18 for oDecimals, while destination adapters should pass 18 for iDecimals.
     * Warning: When downscaling (i.e., when iDecimals > oDecimals), the conversion can lead to a loss of precision.
     * In the worst case, if the answer is small enough, the conversion can return zero.
     * Warning: When upscaling (i.e., when iDecimals < oDecimals), if answer * 10^(oDecimals - iDecimals) exceeds
     * the maximum uint256 value, this function will revert. Ensure the provided values will not cause an overflow.
     */
    function convertDecimals(uint256 answer, uint8 iDecimals, uint8 oDecimals) internal pure returns (uint256) {
        if (iDecimals == oDecimals) return answer;
        if (iDecimals < oDecimals) return answer * 10 ** (oDecimals - iDecimals);
        return answer / 10 ** (iDecimals - oDecimals);
    }

    // Derives token decimals from its scaling factor.
    function deriveDecimals(uint256 scalingFactor) internal pure returns (uint8) {
        uint256 decimals = Math.log10(scalingFactor);

        // Verify that the inverse operation yields the expected result.
        require(10 ** decimals == scalingFactor, "Invalid scalingFactor");

        // Note: decimals must fit within uint8 because:
        // 2^8 = 256, which is uint8 max.
        // This would imply an input scaling factor of 1e256. The max value of uint256 is \(2^{256} - 1\), which is approximately
        // 1.2e77, but not equal to 1e256. Therefore, decimals will always fit within uint8 or the check above will fail.
        return uint8(decimals);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import {SignedMath} from "openzeppelin-contracts/contracts/utils/math/SignedMath.sol";

import {IAggregatorV3Source} from "../../interfaces/chainlink/IAggregatorV3Source.sol";
import {IMedian} from "../../interfaces/chronicle/IMedian.sol";
import {IPyth} from "../../interfaces/pyth/IPyth.sol";
import {ChainlinkSourceAdapter} from "./ChainlinkSourceAdapter.sol";
import {ChronicleMedianSourceAdapter} from "./ChronicleMedianSourceAdapter.sol";
import {PythSourceAdapter} from "./PythSourceAdapter.sol";
import {SnapshotSource} from "./SnapshotSource.sol";

/**
 * @title BoundedUnionSourceAdapter contract to read data from multiple sources and return the newest, contingent on it
 * being within a certain tolerance of the other sources. The return logic operates as follows:
 *   a) Return the most recent price if it's within tolerance of at least one of the other two.
 *   b) If not, return the second most recent price if it's within tolerance of at least one of the other two.
 *   c) If neither a) nor b) is met, return the chainlink price.
 * @dev This adapter only works with Chainlink, Chronicle and Pyth adapters. If alternative adapter configs are desired
 * then a new adapter should be created.
 */

abstract contract BoundedUnionSourceAdapter is
    ChainlinkSourceAdapter,
    ChronicleMedianSourceAdapter,
    PythSourceAdapter
{
    uint256 public immutable BOUNDING_TOLERANCE;

    constructor(
        IAggregatorV3Source chainlink,
        IMedian chronicle,
        IPyth pyth,
        bytes32 pythPriceId,
        uint256 boundingTolerance
    ) ChainlinkSourceAdapter(chainlink) ChronicleMedianSourceAdapter(chronicle) PythSourceAdapter(pyth, pythPriceId) {
        BOUNDING_TOLERANCE = boundingTolerance;
    }

    /**
     * @notice Returns the latest data from the source, contingent on it being within a tolerance of the other sources.
     * @return answer The latest answer in 18 decimals.
     * @return timestamp The timestamp of the answer.
     */
    function getLatestSourceData()
        public
        view
        override(ChainlinkSourceAdapter, ChronicleMedianSourceAdapter, PythSourceAdapter)
        returns (int256 answer, uint256 timestamp)
    {
        (int256 clAnswer, uint256 clTimestamp) = ChainlinkSourceAdapter.getLatestSourceData();
        (int256 crAnswer, uint256 crTimestamp) = ChronicleMedianSourceAdapter.getLatestSourceData();
        (int256 pyAnswer, uint256 pyTimestamp) = PythSourceAdapter.getLatestSourceData();

        return _selectBoundedPrice(clAnswer, clTimestamp, crAnswer, crTimestamp, pyAnswer, pyTimestamp);
    }

    /**
     * @notice Snapshots is a no-op for this adapter as its never used.
     */
    function snapshotData() public override(ChainlinkSourceAdapter, SnapshotSource) {}

    /**
     * @notice Tries getting latest data as of requested timestamp. Note that for all historic lookups we simply return
     * the Chainlink data as this is the only supported source that has historical data.
     * @param timestamp The timestamp to try getting latest data at.
     * @param maxTraversal The maximum number of rounds to traverse when looking for historical data.
     * @return answer The answer as of requested timestamp, or earliest available data if not available, in 18 decimals.
     * @return updatedAt The timestamp of the answer.
     */
    function tryLatestDataAt(uint256 timestamp, uint256 maxTraversal)
        public
        view
        override(ChainlinkSourceAdapter, ChronicleMedianSourceAdapter, PythSourceAdapter)
        returns (int256, uint256)
    {
        // Chainlink has price history, so use tryLatestDataAt to pull the most recent price that satisfies the timestamp constraint.
        (int256 clAnswer, uint256 clTimestamp) = ChainlinkSourceAdapter.tryLatestDataAt(timestamp, maxTraversal);

        // For Chronicle and Pyth, just pull the most recent prices and drop them if they don't satisfy the constraint.
        (int256 crAnswer, uint256 crTimestamp) = ChronicleMedianSourceAdapter.getLatestSourceData();
        (int256 pyAnswer, uint256 pyTimestamp) = PythSourceAdapter.getLatestSourceData();

        // To "drop" Chronicle and Pyth, we set their timestamps to 0 (as old as possible) if they are too recent.
        // This means that they will never be used if either or both are 0.
        if (crTimestamp > timestamp) crTimestamp = 0;
        if (pyTimestamp > timestamp) pyTimestamp = 0;

        return _selectBoundedPrice(clAnswer, clTimestamp, crAnswer, crTimestamp, pyAnswer, pyTimestamp);
    }

    // Selects the appropriate price from the three sources based on the bounding tolerance and logic.
    function _selectBoundedPrice(int256 cl, uint256 clT, int256 cr, uint256 crT, int256 py, uint256 pyT)
        internal
        view
        returns (int256, uint256)
    {
        int256 newestVal = 0;
        uint256 newestT = 0;

        // For each price, check if it is within tolerance of the other two. If so, check if it is the newest.
        if (pyT > newestT && (_withinTolerance(py, cr) || _withinTolerance(py, cl))) (newestVal, newestT) = (py, pyT);
        if (crT > newestT && (_withinTolerance(cr, py) || _withinTolerance(cr, cl))) (newestVal, newestT) = (cr, crT);
        if (clT > newestT && (_withinTolerance(cl, py) || _withinTolerance(cl, cr))) (newestVal, newestT) = (cl, clT);

        if (newestT == 0) return (cl, clT); // If no valid price was found, default to returning chainlink.

        return (newestVal, newestT);
    }

    // Checks if value a is within tolerance of value b.
    function _withinTolerance(int256 a, int256 b) internal view returns (bool) {
        uint256 diff = SignedMath.abs(a - b);
        uint256 maxDiff = SignedMath.abs(b) * BOUNDING_TOLERANCE / 1e18;
        return diff <= maxDiff;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import {DecimalLib} from "../lib/DecimalLib.sol";
import {IAggregatorV3Source} from "../../interfaces/chainlink/IAggregatorV3Source.sol";
import {DiamondRootOevShare} from "../../DiamondRootOevShare.sol";

/**
 * @title ChainlinkSourceAdapter contract to read data from Chainlink aggregator and standardize it for the OEV.
 * @dev Can fetch information from Chainlink source at a desired timestamp for historic lookups.
 */

abstract contract ChainlinkSourceAdapter is DiamondRootOevShare {
    IAggregatorV3Source public immutable CHAINLINK_SOURCE;
    uint8 private immutable SOURCE_DECIMALS;

    // As per Chainlink documentation https://docs.chain.link/data-feeds/historical-data#roundid-in-proxy
    // roundId on the aggregator proxy is comprised of phaseId (higher 16 bits) and roundId from phase aggregator
    // (lower 64 bits). PHASE_MASK is used to calculate first roundId of current phase aggregator.
    uint80 private constant PHASE_MASK = uint80(0xFFFF) << 64;

    event SourceSet(address indexed sourceOracle, uint8 indexed sourceDecimals);

    constructor(IAggregatorV3Source source) {
        CHAINLINK_SOURCE = source;
        SOURCE_DECIMALS = source.decimals();

        emit SourceSet(address(source), SOURCE_DECIMALS);
    }

    /**
     * @notice Tries getting latest data as of requested timestamp. If this is not possible, returns the earliest data
     * available past the requested timestamp within provided traversal limitations.
     * @param timestamp The timestamp to try getting latest data at.
     * @param maxTraversal The maximum number of rounds to traverse when looking for historical data.
     * @return answer The answer as of requested timestamp, or earliest available data if not available, in 18 decimals.
     * @return updatedAt The timestamp of the answer.
     */
    function tryLatestDataAt(uint256 timestamp, uint256 maxTraversal)
        public
        view
        virtual
        override
        returns (int256, uint256)
    {
        (int256 answer, uint256 updatedAt) = _tryLatestRoundDataAt(timestamp, maxTraversal);
        return (DecimalLib.convertDecimals(answer, SOURCE_DECIMALS, 18), updatedAt);
    }

    /**
     * @notice Initiate a snapshot of the source data. This is a no-op for Chainlink.
     */
    function snapshotData() public virtual override {}

    /**
     * @notice Returns the latest data from the source.
     * @return answer The latest answer in 18 decimals.
     * @return updatedAt The timestamp of the answer.
     */
    function getLatestSourceData() public view virtual override returns (int256, uint256) {
        (, int256 sourceAnswer,, uint256 updatedAt,) = CHAINLINK_SOURCE.latestRoundData();
        return (DecimalLib.convertDecimals(sourceAnswer, SOURCE_DECIMALS, 18), updatedAt);
    }

    // Tries getting latest data as of requested timestamp. If this is not possible, returns the earliest data available
    // past the requested timestamp considering the maxTraversal limitations.
    function _tryLatestRoundDataAt(uint256 timestamp, uint256 maxTraversal) internal view returns (int256, uint256) {
        (uint80 roundId, int256 answer,, uint256 updatedAt,) = CHAINLINK_SOURCE.latestRoundData();

        // In the happy path there have been no source updates since requested time, so we can return the latest data.
        // We can use updatedAt property as it matches the block timestamp of the latest source transmission.
        if (updatedAt <= timestamp) return (answer, updatedAt);

        // Attempt traversing historical round data backwards from roundId. This might still be newer or uninitialized.
        (int256 historicalAnswer, uint256 historicalUpdatedAt) = _searchRoundDataAt(timestamp, roundId, maxTraversal);

        // Validate returned data. If it is uninitialized we fallback to returning the current latest round data.
        if (historicalUpdatedAt > 0) return (historicalAnswer, historicalUpdatedAt);
        return (answer, updatedAt);
    }

    // Tries finding latest historical data (ignoring current roundId) not newer than requested timestamp. Might return
    // newer data than requested if exceeds traversal or hold uninitialized data that should be handled by the caller.
    function _searchRoundDataAt(uint256 timestamp, uint80 targetRoundId, uint256 maxTraversal)
        internal
        view
        returns (int256, uint256)
    {
        uint80 roundId;
        int256 answer;
        uint256 updatedAt;
        uint80 traversedRounds = 0;
        uint80 startRoundId = (targetRoundId & PHASE_MASK) + 1; // Phase aggregators are starting at round 1.

        while (traversedRounds < uint80(maxTraversal) && targetRoundId > startRoundId) {
            targetRoundId--; // We started from latest roundId that should be ignored.
            // The aggregator proxy does not keep track when its phase aggregators got switched. This means that we can
            // only traverse rounds of the current phase aggregator. When phase aggregators are switched there is
            // normally an overlap period when both new and old phase aggregators receive updates. Without knowing exact
            // time when the aggregator proxy switched them we might end up returning historical data from the new phase
            // aggregator that was not yet available on the aggregator proxy at the requested timestamp.

            (roundId, answer,, updatedAt,) = CHAINLINK_SOURCE.getRoundData(targetRoundId);
            if (!(roundId == targetRoundId && updatedAt > 0)) return (0, 0);
            if (updatedAt <= timestamp) return (answer, updatedAt);
            traversedRounds++;
        }

        return (answer, updatedAt); // Did not find requested round. Return earliest round or uninitialized data.
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import {SnapshotSource} from "./SnapshotSource.sol";
import {IMedian} from "../../interfaces/chronicle/IMedian.sol";
import {SafeCast} from "openzeppelin-contracts/contracts/utils/math/SafeCast.sol";

/**
 * @title ChronicleMedianSourceAdapter contract to read data from Chronicle and standardize it for the OEV.
 */

abstract contract ChronicleMedianSourceAdapter is SnapshotSource {
    IMedian public immutable CHRONICLE_SOURCE;

    event SourceSet(address indexed sourceOracle);

    constructor(IMedian _chronicleSource) {
        CHRONICLE_SOURCE = _chronicleSource;

        emit SourceSet(address(_chronicleSource));
    }

    /**
     * @notice Returns the latest data from the source.
     * @dev The standard chronicle implementation will revert if the latest answer is not valid when calling the read
     * function. Additionally, chronicle returns the answer in 18 decimals, so no conversion is needed.
     * @return answer The latest answer in 18 decimals.
     * @return updatedAt The timestamp of the answer.
     */
    function getLatestSourceData() public view virtual override returns (int256, uint256) {
        return (SafeCast.toInt256(CHRONICLE_SOURCE.read()), CHRONICLE_SOURCE.age());
    }

    /**
     * @notice Tries getting latest data as of requested timestamp. If this is not possible, returns the earliest data
     * available past the requested timestamp within provided traversal limitations.
     * @dev Chronicle does not support historical lookups so this uses SnapshotSource to get historic data.
     * @param timestamp The timestamp to try getting latest data at.
     * @param maxTraversal The maximum number of rounds to traverse when looking for historical data.
     * @return answer The answer as of requested timestamp, or earliest available data if not available, in 18 decimals.
     * @return updatedAt The timestamp of the answer.
     */
    function tryLatestDataAt(uint256 timestamp, uint256 maxTraversal)
        public
        view
        virtual
        override
        returns (int256, uint256)
    {
        Snapshot memory snapshot = _tryLatestDataAt(timestamp, maxTraversal);
        return (snapshot.answer, snapshot.timestamp);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import {IPyth} from "../../interfaces/pyth/IPyth.sol";
import {SnapshotSource} from "./SnapshotSource.sol";
import {DecimalLib} from "../lib/DecimalLib.sol";

/**
 * @title PythSourceAdapter contract to read data from Pyth and standardize it for the OEV.
 */

abstract contract PythSourceAdapter is SnapshotSource {
    IPyth public immutable PYTH_SOURCE;
    bytes32 public immutable PYTH_PRICE_ID;

    event SourceSet(address indexed sourceOracle, bytes32 indexed pythPriceId);

    constructor(IPyth _pyth, bytes32 _pythPriceId) {
        PYTH_SOURCE = _pyth;
        PYTH_PRICE_ID = _pythPriceId;

        emit SourceSet(address(_pyth), _pythPriceId);
    }

    /**
     * @notice Returns the latest data from the source.
     * @return answer The latest answer in 18 decimals.
     * @return updatedAt The timestamp of the answer.
     */
    function getLatestSourceData() public view virtual override returns (int256, uint256) {
        IPyth.Price memory pythPrice = PYTH_SOURCE.getPriceUnsafe(PYTH_PRICE_ID);
        return (_convertDecimalsWithExponent(pythPrice.price, pythPrice.expo), pythPrice.publishTime);
    }

    /**
     * @notice Tries getting latest data as of requested timestamp. If this is not possible, returns the earliest data
     * available past the requested timestamp within provided traversal limitations.
     * @dev Pyth does not support historical lookups so this uses SnapshotSource to get historic data.
     * @param timestamp The timestamp to try getting latest data at.
     * @param maxTraversal The maximum number of rounds to traverse when looking for historical data.
     * @return answer The answer as of requested timestamp, or earliest available data if not available, in 18 decimals.
     * @return updatedAt The timestamp of the answer.
     */
    function tryLatestDataAt(uint256 timestamp, uint256 maxTraversal)
        public
        view
        virtual
        override
        returns (int256, uint256)
    {
        Snapshot memory snapshot = _tryLatestDataAt(timestamp, maxTraversal);
        return (snapshot.answer, snapshot.timestamp);
    }

    // Handle a per-price "expo" (decimal) value from pyth.
    function _convertDecimalsWithExponent(int256 answer, int32 expo) internal pure returns (int256) {
        // Expo is pyth's way of expressing decimals. -18 is equivalent to 18 decimals. -5 is equivalent to 5.
        if (expo <= 0) return DecimalLib.convertDecimals(answer, uint8(uint32(-expo)), 18);
        // Add the _decimals and expo in the case that expo is positive since it means that the fixed point number is
        // _smaller_ than the true value. This case may never be hit, it seems preferable to reverting.
        else return DecimalLib.convertDecimals(answer, 0, 18 + uint8(uint32(expo)));
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import {DiamondRootOevShare} from "../../DiamondRootOevShare.sol";

/**
 * @title SnapshotSource contract to be used in conjunction with a source adapter that needs to snapshot historic data.
 */

abstract contract SnapshotSource is DiamondRootOevShare {
    // Snapshot records the historical answer at a specific timestamp.
    struct Snapshot {
        int256 answer;
        uint256 timestamp;
    }

    Snapshot[] public snapshots; // Historical answer and timestamp snapshots.

    event SnapshotTaken(uint256 snapshotIndex, uint256 indexed timestamp, int256 indexed answer);

    /**
     * @notice Returns the latest snapshot data.
     * @return Snapshot The latest snapshot data.
     */
    function latestSnapshotData() public view returns (Snapshot memory) {
        if (snapshots.length > 0) return snapshots[snapshots.length - 1];
        return Snapshot(0, 0);
    }

    /**
     * @notice Snapshot the current source data.
     */
    function snapshotData() public virtual override {
        (int256 answer, uint256 timestamp) = getLatestSourceData();
        Snapshot memory snapshot = Snapshot(answer, timestamp);
        if (snapshot.timestamp == 0) return; // Should not store invalid data.

        // We expect source timestamps to be increasing over time, but there is little we can do to recover if source
        // timestamp decreased: we don't know if such decreased value is wrong or there was an issue with prior source
        // value. We can only detect an update in source if its timestamp is different from the last recorded snapshot.
        uint256 snapshotIndex = snapshots.length;
        if (snapshotIndex > 0 && snapshots[snapshotIndex - 1].timestamp == snapshot.timestamp) return;

        snapshots.push(snapshot);

        emit SnapshotTaken(snapshotIndex, snapshot.timestamp, snapshot.answer);
    }

    function _tryLatestDataAt(uint256 timestamp, uint256 maxTraversal) internal view returns (Snapshot memory) {
        (int256 answer, uint256 _timestamp) = getLatestSourceData();
        Snapshot memory latestData = Snapshot(answer, _timestamp);
        // In the happy path there have been no source updates since requested time, so we can return the latest data.
        // We can use timestamp property as it matches the block timestamp of the latest source update.
        if (latestData.timestamp <= timestamp) return latestData;

        // Attempt traversing historical snapshot data. This might still be newer or uninitialized.
        Snapshot memory historicalData = _searchSnapshotAt(timestamp, maxTraversal);

        // Validate returned data. If it is uninitialized we fallback to returning the current latest round data.
        if (historicalData.timestamp > 0) return historicalData;
        return latestData;
    }

    // Tries finding latest snapshotted data not newer than requested timestamp. Might still return newer data than
    // requested if exceeded traversal or hold uninitialized data that should be handled by the caller.
    function _searchSnapshotAt(uint256 timestamp, uint256 maxTraversal) internal view returns (Snapshot memory) {
        Snapshot memory snapshot;
        uint256 traversedSnapshots = 0;
        uint256 snapshotId = snapshots.length; // Will decrement when entering loop.

        while (traversedSnapshots < maxTraversal && snapshotId > 0) {
            snapshotId--; // We started from snapshots.length and we only loop if snapshotId > 0, so this is safe.
            snapshot = snapshots[snapshotId];
            if (snapshot.timestamp <= timestamp) return snapshot;
            traversedSnapshots++;
        }

        // We did not find requested snapshot. This will hold the earliest available snapshot or uninitialized data.
        return snapshot;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {OevShare} from "../OevShare.sol";

/**
 * @title BaseController providing the simplest possible controller logic to govern who can unlock the OEVShare.
 * @dev Custom Controllers can be created to provide more granular control over who can unlock the OEVShare.
 */

abstract contract BaseController is Ownable, OevShare {
    // these don't need to be public since they can be accessed via the accessor functions below.
    uint256 private lockWindow_ = 60; // The lockWindow in seconds.
    uint256 private maxTraversal_ = 10; // The maximum number of rounds to traverse when looking for historical data.

    mapping(address => bool) public unlockers;

    /**
     * @notice Enables the owner to set the unlocker status of an address. Once set, the address can unlock the OEVShare
     * and by calling unlockLatestValue as part of an MEV-share auction.
     * @param unlocker The address to set the unlocker status of.
     * @param allowed The unlocker status to set.
     */
    function setUnlocker(address unlocker, bool allowed) public onlyOwner {
        unlockers[unlocker] = allowed;

        emit UnlockerSet(unlocker, allowed);
    }

    /**
     * @notice Returns true if the caller is allowed to unlock the OEVShare.
     * @dev This implementation simply checks if the caller is in the unlockers mapping. Custom Controllers can override
     * this function to provide more granular control over who can unlock the OEVShare.
     * @param caller The address to check.
     * @param _lastUnlockTime The timestamp of the latest unlock to the OEVShare. Might be useful in verification.
     */
    function canUnlock(address caller, uint256 _lastUnlockTime) public view override returns (bool) {
        return unlockers[caller];
    }

    /**
     * @notice Enables the owner to set the lockWindow.
     * @dev If changing the lockWindow would cause OEVShare to return different data the permissioned actor must first
     * call unlockLatestValue through flashbots via eth_sendPrivateTransaction.
     * @param newLockWindow The lockWindow to set.
     */
    function setLockWindow(uint256 newLockWindow) public onlyOwner {
        (int256 currentAnswer, uint256 currentTimestamp) = internalLatestData();

        lockWindow_ = newLockWindow;

        // Compare OEVShare results so that change in lock window does not change returned data.
        (int256 newAnswer, uint256 newTimestamp) = internalLatestData();
        require(currentAnswer == newAnswer && currentTimestamp == newTimestamp, "Must unlock first");

        emit LockWindowSet(newLockWindow);
    }

    /**
     * @notice Enables the owner to set the maxTraversal.
     * @param newMaxTraversal The maxTraversal to set.
     */
    function setMaxTraversal(uint256 newMaxTraversal) public onlyOwner {
        maxTraversal_ = newMaxTraversal;

        emit MaxTraversalSet(newMaxTraversal);
    }

    /**
     * @notice Time window that bounds how long the permissioned actor has to call the unlockLatestValue function after
     * a new source update is posted. If the permissioned actor does not call unlockLatestValue within this window of a
     * new source price, the latest value will be made available to everyone without going through an MEV-Share auction.
     * @return lockWindow time in seconds.
     */
    function lockWindow() public view override returns (uint256) {
        return lockWindow_;
    }

    /**
     * @notice Max number of historical source updates to traverse when looking for a historic value in the past.
     * @return maxTraversal max number of historical source updates to traverse.
     */
    function maxTraversal() public view override returns (uint256) {
        return maxTraversal_;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

interface IBaseController {
    event LockWindowSet(uint256 indexed lockWindow);
    event MaxTraversalSet(uint256 indexed maxTraversal);
    event UnlockerSet(address indexed unlocker, bool indexed allowed);

    function canUnlock(address caller, uint256 cachedLatestTimestamp) external view returns (bool);
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

interface IBaseOracleAdapter {
    function tryLatestDataAt(uint256 _timestamp, uint256 _maxTraversal)
        external
        view
        returns (int256 answer, uint256 timestamp);

    function getLatestSourceData() external view returns (int256 answer, uint256 timestamp);
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

interface IOevShare {
    event LatestValueUnlocked(uint256 indexed timestamp);

    function internalLatestData() external view returns (int256 answer, uint256 timestamp);
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

interface IAggregatorV3 {
    function latestAnswer() external view returns (int256);

    function latestTimestamp() external view returns (uint256);

    function decimals() external view returns (uint8);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    // Other Chainlink functions we don't need.

    // function latestRound() external view returns (uint256);

    // function getAnswer(uint256 roundId) external view returns (int256);

    // function getTimestamp(uint256 roundId) external view returns (uint256);

    // function description() external view returns (string memory);

    // function version() external view returns (uint256);

    // function getRoundData(uint80 _roundId)
    //     external
    //     view
    //     returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    // event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

    // event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

interface IAggregatorV3Source {
    function decimals() external view returns (uint8);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
pragma solidity 0.8.17;

interface IMedian {
    function age() external view returns (uint32); // Last update timestamp

    function read() external view returns (uint256); // Latest price feed value (reverted if not valid)

    function peek() external view returns (uint256, bool); // Latest price feed value and validity

    // Other Median functions we don't need.
    // function wards(address) external view returns (uint256); // Authorized owners

    // function rely(address) external; // Add authorized owner

    // function deny(address) external; // Remove authorized owner

    // function wat() external view returns (bytes32); // Price feed identifier

    // function bar() external view returns (uint256); // Minimum number of oracles

    // function orcl(address) external view returns (uint256); // Authorized oracles

    // function bud(address) external view returns (uint256); // Whitelisted contracts to read price feed

    // function slot(uint8) external view returns (address); // Mapping for at most 256 oracles

    // function poke(
    //     uint256[] calldata,
    //     uint256[] calldata,
    //     uint8[] calldata,
    //     bytes32[] calldata,
    //     bytes32[] calldata
    // ) external; // Update price feed values

    // function lift(address[] calldata) external; // Add oracles

    // function drop(address[] calldata) external; // Remove oracles

    // function setBar(uint256) external; // Set minimum number of oracles

    function kiss(address) external; // Add contract to whitelist

    // function diss(address) external; // Remove contract from whitelist

    // function kiss(address[] calldata) external; // Add contracts to whitelist

    // function diss(address[] calldata) external; // Remove contracts from whitelist
}
pragma solidity ^0.8.17;

interface IPyth {
    struct Price {
        int64 price; // Price
        uint64 conf; // Confidence interval around the price
        int32 expo; // Price exponent
        uint256 publishTime; // Unix timestamp describing when the price was published
    }

    function getPriceUnsafe(bytes32 id) external view returns (Price memory price);
    function getPrice(bytes32 id) external view returns (Price memory price);
}
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import {BoundedUnionSourceAdapter} from "oev-contracts/adapters/source-adapters/BoundedUnionSourceAdapter.sol";
import {BaseController} from "oev-contracts/controllers/BaseController.sol";
import {ChainlinkDestinationAdapter} from "oev-contracts/adapters/destination-adapters/ChainlinkDestinationAdapter.sol";
import {IAggregatorV3Source} from "oev-contracts/interfaces/chainlink/IAggregatorV3Source.sol";
import {IMedian} from "oev-contracts/interfaces/chronicle/IMedian.sol";
import {IPyth} from "oev-contracts/interfaces/pyth/IPyth.sol";

contract HoneyPotOEVShare is BaseController, BoundedUnionSourceAdapter, ChainlinkDestinationAdapter {
    constructor(
        address chainlinkSource,
        address chronicleSource,
        address pythSource,
        bytes32 pythPriceId,
        uint8 decimals
    )
        BoundedUnionSourceAdapter(
            IAggregatorV3Source(chainlinkSource),
            IMedian(chronicleSource),
            IPyth(pythSource),
            pythPriceId,
            0.1e18
        )
        BaseController()
        ChainlinkDestinationAdapter(decimals)
    {}
}