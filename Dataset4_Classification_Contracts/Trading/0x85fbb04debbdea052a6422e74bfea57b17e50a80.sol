// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {HalfLifeCarbonCreditAuction} from "@/libraries/HalfLifeCarbonCreditAuction.sol";
import {ICarbonCreditAuction} from "@/interfaces/ICarbonCreditAuction.sol";
/**
 * @title CarbonCreditDescendingPriceAuction
 * @notice This contract is a reverse dutch auction for GCC.
 *         - The price has a half life of 1 week
 *         - The max that the price can grow is 2x per 24 hours
 *         - For every sale made, the price increases by the % of the total sold that the sale was
 *             - For example, if 10% of the available GCC is sold, then the price increases by 10%
 *             - If 100% of the available GCC is sold, then the price doubles
 *         - GCC is added to the pool of available GCC linearly over the course of a week
 *         - When new GCC is added, all pending vesting amounts and the new amount are vested over the course of a week
 *         - There is no cap on the amount of GCC that can be purchased in a single transaction
 *         - All GCC donations must be registered by the miner pool contract
 * @author DavidVorick
 * @author 0xSimon(twitter) -  0xSimbo(github)
 */

contract CarbonCreditDescendingPriceAuction is ICarbonCreditAuction {
    /* -------------------------------------------------------------------------- */
    /*                                   errors                                   */
    /* -------------------------------------------------------------------------- */
    error CallerNotGCC();
    error UserPriceNotHighEnough();
    error NotEnoughGCCForSale();
    error CannotBuyZeroUnits();

    /* -------------------------------------------------------------------------- */
    /*                                  constants                                 */
    /* -------------------------------------------------------------------------- */

    /// @dev The precision (magnifier) used for calculations
    uint256 private constant PRECISION = 1e8;
    /// @dev The number of seconds in a day
    uint256 private constant ONE_DAY = uint256(1 days);
    /// @dev The number of seconds in a week
    uint256 private constant ONE_WEEK = uint256(7 days);
    /**
     * @notice the amount of GCC sold within a single unit (0.000000000001 GCC)
     * @dev This is equal to 1e-12 GCC
     */
    uint256 public constant SALE_UNIT = 1e6;

    /* -------------------------------------------------------------------------- */
    /*                                 immutables                                 */
    /* -------------------------------------------------------------------------- */

    /// @notice The GLOW token
    IERC20 public immutable GLOW;
    /// @notice The GCC token
    IERC20 public immutable GCC;

    /* -------------------------------------------------------------------------- */
    /*                                 state vars                                */
    /* -------------------------------------------------------------------------- */
    /**
     * @dev a variable to keep track of the total amount of GCC that has been fully vested
     *         - it's not accurate and should only be used in conjunction with
     *             - {totalAmountReceived} to calculate the total supply
     *             - as shown in {totalSupply}
     */
    uint256 internal _pesudoTotalAmountFullyAvailableForSale;

    /// @notice The total amount of GLOW received from the miner pool
    uint256 public totalAmountReceived;

    /// @notice The total number of units of GCC sold
    uint256 public totalUnitsSold;

    /// @notice The price of GCC 24 hours ago
    ///         - this price is not accurate if there have been no sales in the last 24 hours
    ///         - it should not be relied on for accurate calculations
    uint256 public pseudoPrice24HoursAgo;

    /// @dev The price of GCC per sale unit
    /// @dev this price is not the actual price, and should be used in conjunction with {getPricePerUnit}
    uint256 internal pricePerSaleUnit;

    /// @notice The timestamps
    Timestamps public timestamps;

    /* -------------------------------------------------------------------------- */
    /*                                   structs                                  */
    /* -------------------------------------------------------------------------- */
    /**
     * @dev A struct to keep track of the timestamps all in a single slot
     * @param lastSaleTimestamp the timestamp of the last sale
     * @param lastReceivedTimestamp the timestamp of the last time GCC was received from the miner pool
     * @param lastPriceChangeTimestamp the timestamp of the last time the price changed
     */
    struct Timestamps {
        uint64 lastSaleTimestamp;
        uint64 lastReceivedTimestamp;
        uint64 lastPriceChangeTimestamp;
        uint64 firstReceivedTimestamp;
    }

    /* -------------------------------------------------------------------------- */
    /*                                 constructor                                */
    /* -------------------------------------------------------------------------- */
    /**
     * @param glow the GLOW token
     * @param gcc the GCC token
     * @param startingPrice the starting price of 1 unit of GCC
     */
    constructor(IERC20 glow, IERC20 gcc, uint256 startingPrice) payable {
        GLOW = glow;
        GCC = gcc;
        pricePerSaleUnit = startingPrice;
        pseudoPrice24HoursAgo = startingPrice;
    }

    /* -------------------------------------------------------------------------- */
    /*                                 buy gcc                                    */
    /* -------------------------------------------------------------------------- */

    /**
     * @inheritdoc ICarbonCreditAuction
     */
    function buyGCC(uint256 unitsToBuy, uint256 maxPricePerUnit) external {
        if (unitsToBuy == 0) {
            _revert(CannotBuyZeroUnits.selector);
        }
        Timestamps memory _timestamps = timestamps;
        uint256 _lastPriceChangeTimestamp = _timestamps.lastPriceChangeTimestamp;
        uint256 _pseudoPrice24HoursAgo = pseudoPrice24HoursAgo;
        uint256 price = getPricePerUnit();
        if (price > maxPricePerUnit) {
            _revert(UserPriceNotHighEnough.selector);
        }
        uint256 gccPurchasing = unitsToBuy * SALE_UNIT;
        uint256 glowToTransfer = unitsToBuy * price;

        uint256 totalSaleUnitsAvailable = totalSaleUnits();
        uint256 saleUnitsLeftForSale = totalSaleUnitsAvailable - totalUnitsSold;

        if (saleUnitsLeftForSale < unitsToBuy) {
            _revert(NotEnoughGCCForSale.selector);
        }

        uint256 newPrice = price + (price * (unitsToBuy * PRECISION / saleUnitsLeftForSale) / PRECISION);

        //The new price can never grow more than 100% in 24 hours
        if (newPrice * PRECISION / _pseudoPrice24HoursAgo > 2 * PRECISION) {
            newPrice = _pseudoPrice24HoursAgo * 2;
        }
        //If it's been more than a day since the last sale, then update the price
        //To the price in the current tx
        //Also update the last price change timestamp
        if (block.timestamp - _lastPriceChangeTimestamp > ONE_DAY) {
            pseudoPrice24HoursAgo = price;
            _lastPriceChangeTimestamp = block.timestamp;
        }

        //
        pricePerSaleUnit = newPrice;

        totalUnitsSold += unitsToBuy;
        timestamps = Timestamps({
            lastSaleTimestamp: uint64(block.timestamp),
            lastReceivedTimestamp: _timestamps.lastReceivedTimestamp,
            lastPriceChangeTimestamp: uint64(_lastPriceChangeTimestamp),
            firstReceivedTimestamp: _timestamps.firstReceivedTimestamp
        });
        GLOW.transferFrom(msg.sender, address(this), glowToTransfer);
        GCC.transfer(msg.sender, gccPurchasing);
    }

    /* -------------------------------------------------------------------------- */
    /*                                 receive gcc                                */
    /* -------------------------------------------------------------------------- */

    /**
     * @inheritdoc ICarbonCreditAuction
     */
    function receiveGCC(uint256 amount) external {
        if (msg.sender != address(GCC)) {
            _revert(CallerNotGCC.selector);
        }
        Timestamps memory _timestamps = timestamps;
        _pesudoTotalAmountFullyAvailableForSale = totalSupply();
        timestamps = Timestamps({
            lastSaleTimestamp: _timestamps.lastSaleTimestamp,
            lastReceivedTimestamp: uint64(block.timestamp),
            lastPriceChangeTimestamp: _timestamps.lastPriceChangeTimestamp,
            firstReceivedTimestamp: _timestamps.firstReceivedTimestamp == 0
                ? uint64(block.timestamp)
                : _timestamps.firstReceivedTimestamp
        });
        totalAmountReceived += amount;
    }

    /* -------------------------------------------------------------------------- */
    /*                                 view functions                             */
    /* -------------------------------------------------------------------------- */

    /**
     * @inheritdoc ICarbonCreditAuction
     */
    function getPricePerUnit() public view returns (uint256) {
        Timestamps memory _timestamps = timestamps;
        uint256 _lastSaleTimestamp = _timestamps.lastSaleTimestamp;
        uint256 firstReceivedTimestamp = _timestamps.firstReceivedTimestamp;
        if (firstReceivedTimestamp == 0) {
            return pricePerSaleUnit;
        }
        if (_lastSaleTimestamp == 0) {
            _lastSaleTimestamp = firstReceivedTimestamp;
        }
        uint256 _pricePerSaleUnit = pricePerSaleUnit;
        return
            HalfLifeCarbonCreditAuction.calculateHalfLifeValue(_pricePerSaleUnit, block.timestamp - _lastSaleTimestamp);
    }

    /**
     * @inheritdoc ICarbonCreditAuction
     */
    function totalSupply() public view returns (uint256) {
        Timestamps memory _timestamps = timestamps;
        uint256 _lastReceivedTimestamp = _timestamps.lastReceivedTimestamp;
        uint256 _totalAmountReceived = totalAmountReceived;
        uint256 amountThatNeedsToVest = _totalAmountReceived - _pesudoTotalAmountFullyAvailableForSale;
        uint256 timeDiff = _min(ONE_WEEK, block.timestamp - _lastReceivedTimestamp);
        return (_pesudoTotalAmountFullyAvailableForSale + amountThatNeedsToVest * timeDiff / ONE_WEEK);
    }

    /**
     * @inheritdoc ICarbonCreditAuction
     */
    function unitsForSale() external view returns (uint256) {
        return totalSaleUnits() - totalUnitsSold;
    }

    /**
     * @inheritdoc ICarbonCreditAuction
     */
    function totalSaleUnits() public view returns (uint256) {
        return totalSupply() / (SALE_UNIT);
    }

    /* -------------------------------------------------------------------------- */
    /*                                     utils                                  */
    /* -------------------------------------------------------------------------- */
    /**
     * @param a the first number
     * @param b the second number
     * @return smaller - the smaller of the two numbers
     */
    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? b : a;
    }

    /**
     * @notice More efficiently reverts with a bytes4 selector
     * @param selector The selector to revert with
     */
    function _revert(bytes4 selector) private pure {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            mstore(0x0, selector)
            revert(0x0, 0x04)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICarbonCreditAuction {
    /* -------------------------------------------------------------------------- */
    /*                                   state-changing                           */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice receives GCC from the miner pool
     * @param amount the amount of GCC to receive
     * @dev this function can only be called by the miner pool contract
     */
    function receiveGCC(uint256 amount) external;
    /**
     * @notice purchases {unitsToBuy} units of GCC at a maximum price of {maxPricePerUnit} GLOW per unit
     * @param unitsToBuy the number of units to buy
     * @param maxPricePerUnit the maximum price per unit that the user is willing to pay
     */
    function buyGCC(uint256 unitsToBuy, uint256 maxPricePerUnit) external;

    /* -------------------------------------------------------------------------- */
    /*                                 view functions                             */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice returns the price per unit of GCC
     */
    function getPricePerUnit() external view returns (uint256);

    /**
     * @notice returns the total supply of GCC available for sale in WEI
     * @dev this is not to be confused with the total units of GCC available for sale
     */
    function totalSupply() external view returns (uint256);

    /**
     * @notice returns the number of units of GCC available for sale
     */
    function unitsForSale() external view returns (uint256);

    /**
     * @notice returns the cumulative total number of units of GCC that have been sold or are available for sale
     */
    function totalSaleUnits() external view returns (uint256);
}
// SPDX-License-Identifier: BSD-4-Clause
/*
 * ABDK Math 64.64 Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <mikhail.vladimirov@gmail.com>
 */
pragma solidity ^0.8.0;

/**
 * Smart contract library of mathematical functions operating with signed
 * 64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is
 * basically a simple fraction whose numerator is signed 128-bit integer and
 * denominator is 2^64.  As long as denominator is always the same, there is no
 * need to store it, thus in Solidity signed 64.64-bit fixed point numbers are
 * represented by int128 type holding only the numerator.
 */
library ABDKMath64x64 {
    /*
    * Minimum value signed 64.64-bit fixed point number may have. 
    */
    int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

    /*
    * Maximum value signed 64.64-bit fixed point number may have. 
    */
    int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    /**
     * Convert signed 256-bit integer number into signed 64.64-bit fixed point
     * number.  Revert on overflow.
     *
     * @param x signed 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function fromInt(int256 x) internal pure returns (int128) {
        unchecked {
            require(x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF);
            return int128(x << 64);
        }
    }

    /**
     * Convert signed 64.64 fixed point number into signed 64-bit integer number
     * rounding down.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64-bit integer number
     */
    function toInt(int128 x) internal pure returns (int64) {
        unchecked {
            return int64(x >> 64);
        }
    }

    /**
     * Convert unsigned 256-bit integer number into signed 64.64-bit fixed point
     * number.  Revert on overflow.
     *
     * @param x unsigned 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function fromUInt(uint256 x) internal pure returns (int128) {
        unchecked {
            require(x <= 0x7FFFFFFFFFFFFFFF);
            return int128(int256(x << 64));
        }
    }

    /**
     * Convert signed 64.64 fixed point number into unsigned 64-bit integer
     * number rounding down.  Revert on underflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return unsigned 64-bit integer number
     */
    function toUInt(int128 x) internal pure returns (uint64) {
        unchecked {
            require(x >= 0);
            return uint64(uint128(x >> 64));
        }
    }

    /**
     * Convert signed 128.128 fixed point number into signed 64.64-bit fixed point
     * number rounding down.  Revert on overflow.
     *
     * @param x signed 128.128-bin fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function from128x128(int256 x) internal pure returns (int128) {
        unchecked {
            int256 result = x >> 64;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Convert signed 64.64 fixed point number into signed 128.128 fixed point
     * number.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 128.128 fixed point number
     */
    function to128x128(int128 x) internal pure returns (int256) {
        unchecked {
            return int256(x) << 64;
        }
    }

    /**
     * Calculate x + y.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function add(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            int256 result = int256(x) + y;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Calculate x - y.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function sub(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            int256 result = int256(x) - y;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Calculate x * y rounding down.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function mul(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            int256 result = int256(x) * y >> 64;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Calculate x * y rounding towards zero, where x is signed 64.64 fixed point
     * number and y is signed 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64 fixed point number
     * @param y signed 256-bit integer number
     * @return signed 256-bit integer number
     */
    function muli(int128 x, int256 y) internal pure returns (int256) {
        unchecked {
            if (x == MIN_64x64) {
                require(
                    y >= -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                        && y <= 0x1000000000000000000000000000000000000000000000000
                );
                return -y << 63;
            } else {
                bool negativeResult = false;
                if (x < 0) {
                    x = -x;
                    negativeResult = true;
                }
                if (y < 0) {
                    y = -y; // We rely on overflow behavior here
                    negativeResult = !negativeResult;
                }
                uint256 absoluteResult = mulu(x, uint256(y));
                if (negativeResult) {
                    require(absoluteResult <= 0x8000000000000000000000000000000000000000000000000000000000000000);
                    return -int256(absoluteResult); // We rely on overflow behavior here
                } else {
                    require(absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
                    return int256(absoluteResult);
                }
            }
        }
    }

    /**
     * Calculate x * y rounding down, where x is signed 64.64 fixed point number
     * and y is unsigned 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64 fixed point number
     * @param y unsigned 256-bit integer number
     * @return unsigned 256-bit integer number
     */
    function mulu(int128 x, uint256 y) internal pure returns (uint256) {
        unchecked {
            if (y == 0) return 0;

            require(x >= 0);

            uint256 lo = (uint256(int256(x)) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
            uint256 hi = uint256(int256(x)) * (y >> 128);

            require(hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            hi <<= 64;

            require(hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - lo);
            return hi + lo;
        }
    }

    /**
     * Calculate x / y rounding towards zero.  Revert on overflow or when y is
     * zero.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function div(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            require(y != 0);
            int256 result = (int256(x) << 64) / y;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are signed 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x signed 256-bit integer number
     * @param y signed 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function divi(int256 x, int256 y) internal pure returns (int128) {
        unchecked {
            require(y != 0);

            bool negativeResult = false;
            if (x < 0) {
                x = -x; // We rely on overflow behavior here
                negativeResult = true;
            }
            if (y < 0) {
                y = -y; // We rely on overflow behavior here
                negativeResult = !negativeResult;
            }
            uint128 absoluteResult = divuu(uint256(x), uint256(y));
            if (negativeResult) {
                require(absoluteResult <= 0x80000000000000000000000000000000);
                return -int128(absoluteResult); // We rely on overflow behavior here
            } else {
                require(absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
                return int128(absoluteResult); // We rely on overflow behavior here
            }
        }
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x unsigned 256-bit integer number
     * @param y unsigned 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function divu(uint256 x, uint256 y) internal pure returns (int128) {
        unchecked {
            require(y != 0);
            uint128 result = divuu(x, y);
            require(result <= uint128(MAX_64x64));
            return int128(result);
        }
    }

    /**
     * Calculate -x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function neg(int128 x) internal pure returns (int128) {
        unchecked {
            require(x != MIN_64x64);
            return -x;
        }
    }

    /**
     * Calculate |x|.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function abs(int128 x) internal pure returns (int128) {
        unchecked {
            require(x != MIN_64x64);
            return x < 0 ? -x : x;
        }
    }

    /**
     * Calculate 1 / x rounding towards zero.  Revert on overflow or when x is
     * zero.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function inv(int128 x) internal pure returns (int128) {
        unchecked {
            require(x != 0);
            int256 result = int256(0x100000000000000000000000000000000) / x;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Calculate arithmetics average of x and y, i.e. (x + y) / 2 rounding down.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function avg(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            return int128((int256(x) + int256(y)) >> 1);
        }
    }

    /**
     * Calculate geometric average of x and y, i.e. sqrt (x * y) rounding down.
     * Revert on overflow or in case x * y is negative.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function gavg(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            int256 m = int256(x) * int256(y);
            require(m >= 0);
            require(m < 0x4000000000000000000000000000000000000000000000000000000000000000);
            return int128(sqrtu(uint256(m)));
        }
    }

    /**
     * Calculate x^y assuming 0^0 is 1, where x is signed 64.64 fixed point number
     * and y is unsigned 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y uint256 value
     * @return signed 64.64-bit fixed point number
     */
    function pow(int128 x, uint256 y) internal pure returns (int128) {
        unchecked {
            bool negative = x < 0 && y & 1 == 1;

            uint256 absX = uint128(x < 0 ? -x : x);
            uint256 absResult;
            absResult = 0x100000000000000000000000000000000;

            if (absX <= 0x10000000000000000) {
                absX <<= 63;
                while (y != 0) {
                    if (y & 0x1 != 0) {
                        absResult = absResult * absX >> 127;
                    }
                    absX = absX * absX >> 127;

                    if (y & 0x2 != 0) {
                        absResult = absResult * absX >> 127;
                    }
                    absX = absX * absX >> 127;

                    if (y & 0x4 != 0) {
                        absResult = absResult * absX >> 127;
                    }
                    absX = absX * absX >> 127;

                    if (y & 0x8 != 0) {
                        absResult = absResult * absX >> 127;
                    }
                    absX = absX * absX >> 127;

                    y >>= 4;
                }

                absResult >>= 64;
            } else {
                uint256 absXShift = 63;
                if (absX < 0x1000000000000000000000000) {
                    absX <<= 32;
                    absXShift -= 32;
                }
                if (absX < 0x10000000000000000000000000000) {
                    absX <<= 16;
                    absXShift -= 16;
                }
                if (absX < 0x1000000000000000000000000000000) {
                    absX <<= 8;
                    absXShift -= 8;
                }
                if (absX < 0x10000000000000000000000000000000) {
                    absX <<= 4;
                    absXShift -= 4;
                }
                if (absX < 0x40000000000000000000000000000000) {
                    absX <<= 2;
                    absXShift -= 2;
                }
                if (absX < 0x80000000000000000000000000000000) {
                    absX <<= 1;
                    absXShift -= 1;
                }

                uint256 resultShift = 0;
                while (y != 0) {
                    require(absXShift < 64);

                    if (y & 0x1 != 0) {
                        absResult = absResult * absX >> 127;
                        resultShift += absXShift;
                        if (absResult > 0x100000000000000000000000000000000) {
                            absResult >>= 1;
                            resultShift += 1;
                        }
                    }
                    absX = absX * absX >> 127;
                    absXShift <<= 1;
                    if (absX >= 0x100000000000000000000000000000000) {
                        absX >>= 1;
                        absXShift += 1;
                    }

                    y >>= 1;
                }

                require(resultShift < 64);
                absResult >>= 64 - resultShift;
            }
            int256 result = negative ? -int256(absResult) : int256(absResult);
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Calculate sqrt (x) rounding down.  Revert if x < 0.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function sqrt(int128 x) internal pure returns (int128) {
        unchecked {
            require(x >= 0);
            return int128(sqrtu(uint256(int256(x)) << 64));
        }
    }

    /**
     * Calculate binary logarithm of x.  Revert if x <= 0.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function log_2(int128 x) internal pure returns (int128) {
        unchecked {
            require(x > 0);

            int256 msb = 0;
            int256 xc = x;
            if (xc >= 0x10000000000000000) {
                xc >>= 64;
                msb += 64;
            }
            if (xc >= 0x100000000) {
                xc >>= 32;
                msb += 32;
            }
            if (xc >= 0x10000) {
                xc >>= 16;
                msb += 16;
            }
            if (xc >= 0x100) {
                xc >>= 8;
                msb += 8;
            }
            if (xc >= 0x10) {
                xc >>= 4;
                msb += 4;
            }
            if (xc >= 0x4) {
                xc >>= 2;
                msb += 2;
            }
            if (xc >= 0x2) msb += 1; // No need to shift xc anymore

            int256 result = msb - 64 << 64;
            uint256 ux = uint256(int256(x)) << uint256(127 - msb);
            for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
                ux *= ux;
                uint256 b = ux >> 255;
                ux >>= 127 + b;
                result += bit * int256(b);
            }

            return int128(result);
        }
    }

    /**
     * Calculate natural logarithm of x.  Revert if x <= 0.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function ln(int128 x) internal pure returns (int128) {
        unchecked {
            require(x > 0);

            return int128(int256(uint256(int256(log_2(x))) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF >> 128));
        }
    }

    /**
     * Calculate binary exponent of x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function exp_2(int128 x) internal pure returns (int128) {
        unchecked {
            require(x < 0x400000000000000000); // Overflow

            if (x < -0x400000000000000000) return 0; // Underflow

            uint256 result = 0x80000000000000000000000000000000;

            if (x & 0x8000000000000000 > 0) {
                result = result * 0x16A09E667F3BCC908B2FB1366EA957D3E >> 128;
            }
            if (x & 0x4000000000000000 > 0) {
                result = result * 0x1306FE0A31B7152DE8D5A46305C85EDEC >> 128;
            }
            if (x & 0x2000000000000000 > 0) {
                result = result * 0x1172B83C7D517ADCDF7C8C50EB14A791F >> 128;
            }
            if (x & 0x1000000000000000 > 0) {
                result = result * 0x10B5586CF9890F6298B92B71842A98363 >> 128;
            }
            if (x & 0x800000000000000 > 0) {
                result = result * 0x1059B0D31585743AE7C548EB68CA417FD >> 128;
            }
            if (x & 0x400000000000000 > 0) {
                result = result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8 >> 128;
            }
            if (x & 0x200000000000000 > 0) {
                result = result * 0x10163DA9FB33356D84A66AE336DCDFA3F >> 128;
            }
            if (x & 0x100000000000000 > 0) {
                result = result * 0x100B1AFA5ABCBED6129AB13EC11DC9543 >> 128;
            }
            if (x & 0x80000000000000 > 0) {
                result = result * 0x10058C86DA1C09EA1FF19D294CF2F679B >> 128;
            }
            if (x & 0x40000000000000 > 0) {
                result = result * 0x1002C605E2E8CEC506D21BFC89A23A00F >> 128;
            }
            if (x & 0x20000000000000 > 0) {
                result = result * 0x100162F3904051FA128BCA9C55C31E5DF >> 128;
            }
            if (x & 0x10000000000000 > 0) {
                result = result * 0x1000B175EFFDC76BA38E31671CA939725 >> 128;
            }
            if (x & 0x8000000000000 > 0) {
                result = result * 0x100058BA01FB9F96D6CACD4B180917C3D >> 128;
            }
            if (x & 0x4000000000000 > 0) {
                result = result * 0x10002C5CC37DA9491D0985C348C68E7B3 >> 128;
            }
            if (x & 0x2000000000000 > 0) {
                result = result * 0x1000162E525EE054754457D5995292026 >> 128;
            }
            if (x & 0x1000000000000 > 0) {
                result = result * 0x10000B17255775C040618BF4A4ADE83FC >> 128;
            }
            if (x & 0x800000000000 > 0) {
                result = result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB >> 128;
            }
            if (x & 0x400000000000 > 0) {
                result = result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9 >> 128;
            }
            if (x & 0x200000000000 > 0) {
                result = result * 0x10000162E43F4F831060E02D839A9D16D >> 128;
            }
            if (x & 0x100000000000 > 0) {
                result = result * 0x100000B1721BCFC99D9F890EA06911763 >> 128;
            }
            if (x & 0x80000000000 > 0) {
                result = result * 0x10000058B90CF1E6D97F9CA14DBCC1628 >> 128;
            }
            if (x & 0x40000000000 > 0) {
                result = result * 0x1000002C5C863B73F016468F6BAC5CA2B >> 128;
            }
            if (x & 0x20000000000 > 0) {
                result = result * 0x100000162E430E5A18F6119E3C02282A5 >> 128;
            }
            if (x & 0x10000000000 > 0) {
                result = result * 0x1000000B1721835514B86E6D96EFD1BFE >> 128;
            }
            if (x & 0x8000000000 > 0) {
                result = result * 0x100000058B90C0B48C6BE5DF846C5B2EF >> 128;
            }
            if (x & 0x4000000000 > 0) {
                result = result * 0x10000002C5C8601CC6B9E94213C72737A >> 128;
            }
            if (x & 0x2000000000 > 0) {
                result = result * 0x1000000162E42FFF037DF38AA2B219F06 >> 128;
            }
            if (x & 0x1000000000 > 0) {
                result = result * 0x10000000B17217FBA9C739AA5819F44F9 >> 128;
            }
            if (x & 0x800000000 > 0) {
                result = result * 0x1000000058B90BFCDEE5ACD3C1CEDC823 >> 128;
            }
            if (x & 0x400000000 > 0) {
                result = result * 0x100000002C5C85FE31F35A6A30DA1BE50 >> 128;
            }
            if (x & 0x200000000 > 0) {
                result = result * 0x10000000162E42FF0999CE3541B9FFFCF >> 128;
            }
            if (x & 0x100000000 > 0) {
                result = result * 0x100000000B17217F80F4EF5AADDA45554 >> 128;
            }
            if (x & 0x80000000 > 0) {
                result = result * 0x10000000058B90BFBF8479BD5A81B51AD >> 128;
            }
            if (x & 0x40000000 > 0) {
                result = result * 0x1000000002C5C85FDF84BD62AE30A74CC >> 128;
            }
            if (x & 0x20000000 > 0) {
                result = result * 0x100000000162E42FEFB2FED257559BDAA >> 128;
            }
            if (x & 0x10000000 > 0) {
                result = result * 0x1000000000B17217F7D5A7716BBA4A9AE >> 128;
            }
            if (x & 0x8000000 > 0) {
                result = result * 0x100000000058B90BFBE9DDBAC5E109CCE >> 128;
            }
            if (x & 0x4000000 > 0) {
                result = result * 0x10000000002C5C85FDF4B15DE6F17EB0D >> 128;
            }
            if (x & 0x2000000 > 0) {
                result = result * 0x1000000000162E42FEFA494F1478FDE05 >> 128;
            }
            if (x & 0x1000000 > 0) {
                result = result * 0x10000000000B17217F7D20CF927C8E94C >> 128;
            }
            if (x & 0x800000 > 0) {
                result = result * 0x1000000000058B90BFBE8F71CB4E4B33D >> 128;
            }
            if (x & 0x400000 > 0) {
                result = result * 0x100000000002C5C85FDF477B662B26945 >> 128;
            }
            if (x & 0x200000 > 0) {
                result = result * 0x10000000000162E42FEFA3AE53369388C >> 128;
            }
            if (x & 0x100000 > 0) {
                result = result * 0x100000000000B17217F7D1D351A389D40 >> 128;
            }
            if (x & 0x80000 > 0) {
                result = result * 0x10000000000058B90BFBE8E8B2D3D4EDE >> 128;
            }
            if (x & 0x40000 > 0) {
                result = result * 0x1000000000002C5C85FDF4741BEA6E77E >> 128;
            }
            if (x & 0x20000 > 0) {
                result = result * 0x100000000000162E42FEFA39FE95583C2 >> 128;
            }
            if (x & 0x10000 > 0) {
                result = result * 0x1000000000000B17217F7D1CFB72B45E1 >> 128;
            }
            if (x & 0x8000 > 0) {
                result = result * 0x100000000000058B90BFBE8E7CC35C3F0 >> 128;
            }
            if (x & 0x4000 > 0) {
                result = result * 0x10000000000002C5C85FDF473E242EA38 >> 128;
            }
            if (x & 0x2000 > 0) {
                result = result * 0x1000000000000162E42FEFA39F02B772C >> 128;
            }
            if (x & 0x1000 > 0) {
                result = result * 0x10000000000000B17217F7D1CF7D83C1A >> 128;
            }
            if (x & 0x800 > 0) {
                result = result * 0x1000000000000058B90BFBE8E7BDCBE2E >> 128;
            }
            if (x & 0x400 > 0) {
                result = result * 0x100000000000002C5C85FDF473DEA871F >> 128;
            }
            if (x & 0x200 > 0) {
                result = result * 0x10000000000000162E42FEFA39EF44D91 >> 128;
            }
            if (x & 0x100 > 0) {
                result = result * 0x100000000000000B17217F7D1CF79E949 >> 128;
            }
            if (x & 0x80 > 0) {
                result = result * 0x10000000000000058B90BFBE8E7BCE544 >> 128;
            }
            if (x & 0x40 > 0) {
                result = result * 0x1000000000000002C5C85FDF473DE6ECA >> 128;
            }
            if (x & 0x20 > 0) {
                result = result * 0x100000000000000162E42FEFA39EF366F >> 128;
            }
            if (x & 0x10 > 0) {
                result = result * 0x1000000000000000B17217F7D1CF79AFA >> 128;
            }
            if (x & 0x8 > 0) {
                result = result * 0x100000000000000058B90BFBE8E7BCD6D >> 128;
            }
            if (x & 0x4 > 0) {
                result = result * 0x10000000000000002C5C85FDF473DE6B2 >> 128;
            }
            if (x & 0x2 > 0) {
                result = result * 0x1000000000000000162E42FEFA39EF358 >> 128;
            }
            if (x & 0x1 > 0) {
                result = result * 0x10000000000000000B17217F7D1CF79AB >> 128;
            }

            result >>= uint256(int256(63 - (x >> 64)));
            require(result <= uint256(int256(MAX_64x64)));

            return int128(int256(result));
        }
    }

    /**
     * Calculate natural exponent of x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function exp(int128 x) internal pure returns (int128) {
        unchecked {
            require(x < 0x400000000000000000); // Overflow

            if (x < -0x400000000000000000) return 0; // Underflow

            return exp_2(int128(int256(x) * 0x171547652B82FE1777D0FFDA0D23A7D12 >> 128));
        }
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x unsigned 256-bit integer number
     * @param y unsigned 256-bit integer number
     * @return unsigned 64.64-bit fixed point number
     */
    function divuu(uint256 x, uint256 y) private pure returns (uint128) {
        unchecked {
            require(y != 0);

            uint256 result;

            if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) {
                result = (x << 64) / y;
            } else {
                uint256 msb = 192;
                uint256 xc = x >> 192;
                if (xc >= 0x100000000) {
                    xc >>= 32;
                    msb += 32;
                }
                if (xc >= 0x10000) {
                    xc >>= 16;
                    msb += 16;
                }
                if (xc >= 0x100) {
                    xc >>= 8;
                    msb += 8;
                }
                if (xc >= 0x10) {
                    xc >>= 4;
                    msb += 4;
                }
                if (xc >= 0x4) {
                    xc >>= 2;
                    msb += 2;
                }
                if (xc >= 0x2) msb += 1; // No need to shift xc anymore

                result = (x << 255 - msb) / ((y - 1 >> msb - 191) + 1);
                require(result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

                uint256 hi = result * (y >> 128);
                uint256 lo = result * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

                uint256 xh = x >> 192;
                uint256 xl = x << 64;

                if (xl < lo) xh -= 1;
                xl -= lo; // We rely on overflow behavior here
                lo = hi << 128;
                if (xl < lo) xh -= 1;
                xl -= lo; // We rely on overflow behavior here

                result += xh == hi >> 128 ? xl / y : 1;
            }

            require(result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            return uint128(result);
        }
    }

    /**
     * Calculate sqrt (x) rounding down, where x is unsigned 256-bit integer
     * number.
     *
     * @param x unsigned 256-bit integer number
     * @return unsigned 128-bit integer number
     */
    function sqrtu(uint256 x) private pure returns (uint128) {
        unchecked {
            if (x == 0) {
                return 0;
            } else {
                uint256 xx = x;
                uint256 r = 1;
                if (xx >= 0x100000000000000000000000000000000) {
                    xx >>= 128;
                    r <<= 64;
                }
                if (xx >= 0x10000000000000000) {
                    xx >>= 64;
                    r <<= 32;
                }
                if (xx >= 0x100000000) {
                    xx >>= 32;
                    r <<= 16;
                }
                if (xx >= 0x10000) {
                    xx >>= 16;
                    r <<= 8;
                }
                if (xx >= 0x100) {
                    xx >>= 8;
                    r <<= 4;
                }
                if (xx >= 0x10) {
                    xx >>= 4;
                    r <<= 2;
                }
                if (xx >= 0x4) r <<= 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1; // Seven iterations should be enough
                uint256 r1 = x / r;
                return uint128(r < r1 ? r : r1);
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ABDKMath64x64} from "@/libraries/ABDKMath64x64.sol";

library HalfLifeCarbonCreditAuction {
    /**
     * @dev the halving period in seconds (7 days)
     * @dev the price of the carbon credit auction decays with a half-life or 7 days
     *         - the price will shrink exponentially every 7 days unless there are purchases
     */
    uint256 constant HALVING_PERIOD = uint256(7 days);

    /**
     * @notice calculates the value remaining after a given amount of time has elapsed
     *         - using a half-life of 52 weeks
     * @param initialValue the initial value
     * @param elapsedSeconds the number of seconds that have elapsed
     * @return value - the value remaining given a half-life of 52 weeks
     */
    function calculateHalfLifeValue(uint256 initialValue, uint256 elapsedSeconds) public pure returns (uint256) {
        if (elapsedSeconds == 0) {
            return initialValue;
        }
        // Convert the half-life from months to seconds
        uint256 halfLifeSeconds = HALVING_PERIOD;

        // Calculate the ratio of elapsed time to half-life in fixed point format
        int128 tOverT =
            ABDKMath64x64.div(ABDKMath64x64.fromUInt(elapsedSeconds), ABDKMath64x64.fromUInt(halfLifeSeconds));

        // Calculate (1/2)^(t/T) using the fact that e^(ln(0.5)*t/T) = (0.5)^(t/T)
        int128 halfPowerTOverT =
            ABDKMath64x64.exp(ABDKMath64x64.mul(ABDKMath64x64.ln(ABDKMath64x64.divu(1, 2)), tOverT));

        // Calculate the final amount
        uint256 finalValue = ABDKMath64x64.mulu(halfPowerTOverT, initialValue);

        return finalValue;
    }
}