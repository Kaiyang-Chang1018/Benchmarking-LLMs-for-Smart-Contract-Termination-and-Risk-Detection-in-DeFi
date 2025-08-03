// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import "../interfaces/IUniswapV2Factory.sol";
import "../interfaces/IUniswapV3Factory.sol";
import "../interfaces/IShogun.sol";
import "../interfaces/IX28.sol";
import "./openzeppelin/security/ReentrancyGuard.sol";
import "./openzeppelin/token/ERC721/IERC165.sol";

import "../libs/Constant.sol";
import "../libs/UniswapV2Library.sol";
import "../libs/CallbackValidation.sol";
import "../libs/OracleLibrary.sol";

contract BuyAndBurnShogun is ReentrancyGuard {
    /** @dev Shogun genesis timestamp */
    uint256 private s_shogunGenesisTs;

    /** @dev Shogun contract address */
    address private s_shogunAddress;

    /** @dev owner address */
    address private s_ownerAddress;

    /** @dev Shogun TitanX uniswapv2 pool address */
    address private s_poolAddress;

    //TitanX to X28
    /** @dev TitanX to X28 */
    uint256 private s_totalTitanXBuy;

    /** @dev X28 bought via TitanX > X28 burned */
    uint256 private s_totalX28Burned;

    /** @dev X28 to Shogun */
    uint256 private s_totalX28Buy;

    //burn stats
    /** @dev tracks Shogun burned through buyandburn */
    uint256 private s_totalShogunBurn;

    //config variables
    //TitanX
    /** @dev tracks current per swap cap TitanX */
    uint256 private s_capPerSwapTitanX;

    /** @dev tracks timestamp of the last TitanX buy X28 was called */
    uint256 private s_lastCallTsBuynBurnTitanX;

    /** @dev TitanX slippage */
    uint256 private s_slippageBuynBurnTitanX;

    /** @dev TitanX incentive fee dividend amount */
    uint256 private s_TitanXIncentiveDividend;

    /** @dev current TitanX swap cap per interval */
    uint256 private s_currentCapPerIntervalTitanX;

    //X28
    /** @dev tracks current per swap cap X28 */
    uint256 private s_capPerSwapX28;

    /** @dev tracks timestamp of the last X28 buy Shogun and burn was called */
    uint256 private s_lastCallTsBuynBurnX28;

    /** @dev X28 slippage */
    uint256 private s_slippageBuynBurnX28;

    /** @dev X28 incentive fee dividend amount */
    uint256 private s_X28IncentiveDividend;

    /** @dev current X28 swap cap per interval */
    uint256 private s_currentCapPerIntervalX28;

    /** @dev uniswapv3 oracle price seconds ago */
    uint32 private s_twapSecondsAgo;

    /** @dev max cap for missed interval accumulation */
    uint256 private s_maxIntervalAccumulation;

    //event
    event BoughtX28(uint256 indexed titanx, uint256 indexed x28, address indexed caller);
    event BoughtAndBurned(uint256 indexed x28, uint256 indexed Shogun, address indexed caller);

    constructor() {
        s_ownerAddress = msg.sender;

        s_capPerSwapTitanX = 1e5 ether;
        s_slippageBuynBurnTitanX = MIN_SLIPPAGE_TITANX;
        s_TitanXIncentiveDividend = 5000;

        s_capPerSwapX28 = 1e5 ether;
        s_slippageBuynBurnX28 = MIN_SLIPPAGE_X28;
        s_X28IncentiveDividend = 5000;

        s_twapSecondsAgo = 300;
        s_maxIntervalAccumulation = 3;
    }

    /** @notice remove owner */
    function renounceOwnership() public {
        require(msg.sender == s_ownerAddress, "InvalidCaller");
        s_ownerAddress = address(0);
    }

    /** @notice set new owner address. Only callable by owner address.
     * @param ownerAddress new owner address
     */
    function setOwnerAddress(address ownerAddress) external {
        require(msg.sender == s_ownerAddress, "InvalidCaller");
        require(ownerAddress != address(0), "InvalidAddress");
        s_ownerAddress = ownerAddress;
    }

    /** @notice set Shogun address. One-time setter. Only callable by owner address.
     * @param shogunAddress Shogun contract address
     */
    function setShogunContractAddress(address shogunAddress) external {
        require(msg.sender == s_ownerAddress, "InvalidCaller");
        require(s_shogunAddress == address(0), "CannotResetAddress");
        require(shogunAddress != address(0), "InvalidAddress");
        s_shogunAddress = shogunAddress;
        uint256 genesisTs = IShogun(shogunAddress).genesisTs();
        s_shogunGenesisTs = genesisTs;
        s_lastCallTsBuynBurnTitanX = genesisTs;
        s_lastCallTsBuynBurnX28 = genesisTs;
        _createPool();
        _createInitialLiquidity();
    }

    /**
     * @notice set TitanX cap amount per buynburn call. Only callable by owner address.
     * @param amount amount in 18 decimals
     */
    function setCapPerSwapTitanX(uint256 amount) external {
        require(msg.sender == s_ownerAddress, "InvalidCaller");
        s_capPerSwapTitanX = amount;
    }

    /**
     * @notice set buy and burn slippage % minimum received amount. Only callable by owner address.
     * @param amount amount from 5 - 15
     */
    function setTitanXSlippage(uint256 amount) external {
        require(msg.sender == s_ownerAddress, "InvalidCaller");
        require(amount >= MIN_SLIPPAGE_TITANX && amount <= MAX_SLIPPAGE_TITANX, "5-15_Only");
        s_slippageBuynBurnTitanX = amount;
    }

    /** @notice set TitanX incentive fee percentage callable by owner only
     * amount is in 10000 scaling factor, which means 0.33 is 0.33 * 10000 = 3300
     * @param amount amount between 1 - 10000
     */
    function setTitanXIncentiveFeeDividend(uint256 amount) external {
        require(msg.sender == s_ownerAddress, "InvalidCaller");
        require(amount != 0 && amount <= 10000, "InvalidAmount");
        s_TitanXIncentiveDividend = amount;
    }

    /**
     * @notice set X28 cap amount per buynburn call. Only callable by owner address.
     * @param amount amount in 18 decimals
     */
    function setCapPerSwapX28(uint256 amount) external {
        require(msg.sender == s_ownerAddress, "InvalidCaller");
        s_capPerSwapX28 = amount;
    }

    /**
     * @notice set buy and burn slippage % minimum received amount. Only callable by owner address.
     * @param amount amount from 5 - 15
     */
    function setX28Slippage(uint256 amount) external {
        require(msg.sender == s_ownerAddress, "InvalidCaller");
        require(amount >= MIN_SLIPPAGE_X28 && amount <= MAX_SLIPPAGE_X28, "5-15_Only");
        s_slippageBuynBurnX28 = amount;
    }

    /** @notice set X28 incentive fee percentage callable by owner only
     * amount is in 10000 scaling factor, which means 0.33 is 0.33 * 10000 = 3300
     * @param amount amount between 1 - 10000
     */
    function setX28IncentiveFeeDividend(uint256 amount) external {
        require(msg.sender == s_ownerAddress, "InvalidCaller");
        require(amount != 0 && amount <= 10000, "InvalidAmount");
        s_X28IncentiveDividend = amount;
    }

    /**
     * @notice set twap seconds ago. Only callable by owner address.
     * @param secs amount in seconds
     */
    function setTwapSecondsAgo(uint32 secs) external {
        require(msg.sender == s_ownerAddress, "InvalidCaller");
        require(secs >= MIN_TWAP_SECONDS && secs <= MAX_TWAP_SECONDS, "5min-12h_Only");
        s_twapSecondsAgo = secs;
    }

    /**
     * @notice set max for missed interval accumulation. Only callable by owner address.
     * @param max number
     */
    function setMaxIntervalAccumulations(uint256 max) external {
        require(msg.sender == s_ownerAddress, "InvalidCaller");
        require(max != 0, "CannotZero");
        s_maxIntervalAccumulation = max;
    }

    /** @notice burn all Shogun in BuyAndBurn address */
    function burnShogun() public {
        IShogun(s_shogunAddress).burnCAShogun(address(this));
    }

    /** @notice daily update only callable by Shogun contract
     * this will sync daily update with Shogun
     * reset & calculate daily B&B funds + swap cap per interval
     */
    function dailyUpdate() external {
        require(msg.sender == s_shogunAddress, "InvalidCaller");

        //Initial phase of 28 days to use 28% of balance
        //Phase 2 is from day 29 onwards to use 8% of balance
        uint256 percent = ((block.timestamp - s_shogunGenesisTs) / 1 days) + 1 <= 28
            ? INITIAL_PHASE_BNB_FUNDS_PERCENT
            : PHASE_2_BNB_FUNDS_PERCENT;
        _updateTitanXCap(percent);
        _updateX28Cap(percent);
    }

    /** @notice buy and burn Shogun from uniswap pool */
    function buyX28() public nonReentrant {
        require(msg.sender == tx.origin, "InvalidCaller");
        uint256 balance = IERC20(TITANX).balanceOf(address(this));
        require(balance != 0, "NoAvailableFunds");
        require(block.timestamp - s_lastCallTsBuynBurnTitanX > INTERVAL_SECONDS, "IntervalWait");
        _titanXBuyX28(balance);
    }

    /** @notice buy and burn Shogun from uniswap pool */
    function buynBurn() public nonReentrant {
        require(msg.sender == tx.origin, "InvalidCaller");
        uint256 balance = IERC20(X28).balanceOf(address(this));
        require(balance != 0, "NoAvailableFunds");
        require(block.timestamp - s_lastCallTsBuynBurnX28 > INTERVAL_SECONDS, "IntervalWait");
        _x28BuyShogun(balance);
    }

    /** @notice Used by uniswapV3. Modified from uniswapV3 swap callback function to complete the swap */
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata
    ) external {
        require(amount0Delta > 0 || amount1Delta > 0); // swaps entirely within 0-liquidity regions are not supported

        IUniswapV3Pool pool = CallbackValidation.verifyCallback(
            UNISWAPV3FACTORY,
            TITANX,
            X28,
            POOLFEE1PERCENT
        );
        require(address(pool) == X28_TITANX_POOL, "WrongPool");

        uint256 swapAmount = amount0Delta > 0 ? uint256(amount0Delta) : uint256(amount1Delta);
        s_totalTitanXBuy += swapAmount;
        IERC20(TITANX).transfer(msg.sender, swapAmount);
    }

    // ==================== Private Functions =======================================
    /** @dev reset interval count + calculate daily B&B funds with swap cap per interval */
    function _updateTitanXCap(uint256 percent) private {
        uint256 balance = IERC20(TITANX).balanceOf(address(this));
        if (balance == 0) {
            s_currentCapPerIntervalTitanX = 0;
            return;
        }
        s_currentCapPerIntervalTitanX = (balance * percent) / PERCENT_BPS / MAX_INTERVALS;
    }

    /** @dev reset interval count + calculate daily B&B funds with swap cap per interval */
    function _updateX28Cap(uint256 percent) private {
        uint256 balance = IERC20(X28).balanceOf(address(this));
        if (balance == 0) {
            s_currentCapPerIntervalX28 = 0;
            return;
        }
        s_currentCapPerIntervalX28 = (balance * percent) / PERCENT_BPS / MAX_INTERVALS;
    }

    /** @dev create pool */
    function _createPool() private {
        require(s_poolAddress == address(0), "PoolHasCreated");
        s_poolAddress = IUniswapV2Factory(UNISWAPV2FACTORY).createPair(s_shogunAddress, X28);
        require(
            s_poolAddress == IUniswapV2Factory(UNISWAPV2FACTORY).getPair(s_shogunAddress, X28),
            "CreatePairFailed"
        );
    }

    /** @dev create initial liquidity */
    function _createInitialLiquidity() private {
        IShogun(s_shogunAddress).mintLPTokens();
        _mintPosition();
    }

    /** @dev mint full range LP token */
    function _mintPosition() private {
        IERC20(X28).transfer(s_poolAddress, INITIAL_LP_X28);
        IERC20(s_shogunAddress).transfer(s_poolAddress, INITIAL_LP_SHOGUN);
        IUniswapV2Pair(s_poolAddress).mint(address(this));
    }

    /** @dev check against swap cap and use the amount to swap X28.
     * reward TitanX as incentive fee to caller.
     */
    function _titanXBuyX28(uint256 balance) private {
        uint256 amount = getNextIntervalSwapAmountTitanX();
        require(amount != 0, "SwapAmountIsZero");

        amount = amount > balance ? balance : amount;
        s_lastCallTsBuynBurnTitanX = block.timestamp;

        uint256 incentiveFee = (amount * s_TitanXIncentiveDividend) / INCENTIVE_FEE_PERCENT_BASE;
        amount -= incentiveFee;

        _swapTitanXForX28(amount);
        IERC20(TITANX).transfer(msg.sender, incentiveFee);
    }

    /** @dev call uniswap swap function to swap TitanX for X28, then burn all X28
     * @param amountTitanX TitanX amount
     */
    function _swapTitanXForX28(uint256 amountTitanX) private {
        //calculate minimum amount for slippage protection
        uint256 minTokenAmount = ((amountTitanX * 1 ether * (100 - s_slippageBuynBurnTitanX)) /
            getTwapX28TitanX()) / 100;

        (int256 amount0, int256 amount1) = IUniswapV3Pool(X28_TITANX_POOL).swap(
            address(this),
            TITANX < X28,
            int256(amountTitanX),
            TITANX < X28 ? MIN_SQRT_RATIO + 1 : MAX_SQRT_RATIO - 1,
            ""
        );
        uint256 x28Amount = TITANX < X28
            ? uint256(amount1 >= 0 ? amount1 : -amount1)
            : uint256(amount0 >= 0 ? amount0 : -amount0);
        //slippage protection check
        require(x28Amount >= minTokenAmount, "TooLittleReceived");

        //burn X28
        uint256 burnAmount = (x28Amount * BURN_PERCENT) / PERCENT_BPS;
        IX28(X28).transfer(X28_BNB, burnAmount);
        IX28(X28).burnCAX28(X28_BNB);
        s_totalX28Burned += burnAmount;

        //transfer LP amount to LP address
        IX28(X28).transfer(
            IShogun(s_shogunAddress).getLPAddress(),
            (x28Amount * LP_PERCENT) / PERCENT_BPS
        );

        //transfer genesis amount to genesis address
        IX28(X28).transfer(
            IShogun(s_shogunAddress).getGenesisAddress(),
            (x28Amount * GENESIS_PERCENT) / PERCENT_BPS
        );

        emit BoughtX28(amountTitanX, x28Amount, msg.sender);
    }

    /** @dev check against swap cap and use the amount to swap Shogun.
     * reward X28 as incentive fee to caller.
     */
    function _x28BuyShogun(uint256 balance) private {
        uint256 amount = getNextIntervalSwapAmountX28();
        require(amount != 0, "SwapAmountIsZero");

        amount = amount > balance ? balance : amount;
        s_lastCallTsBuynBurnX28 = block.timestamp;

        uint256 incentiveFee = (amount * s_X28IncentiveDividend) / INCENTIVE_FEE_PERCENT_BASE;
        amount -= incentiveFee;

        _swapX28ForShogun(amount);
        IERC20(X28).transfer(msg.sender, incentiveFee);
    }

    /** @dev call uniswap swap function to swap X28 for Shogun, then burn Shogun
     * @param amount amount
     */
    function _swapX28ForShogun(uint256 amount) private {
        //calculate minimum amount for slippage protection
        uint256 minTokenAmount = ((amount * 1 ether * (100 - s_slippageBuynBurnX28)) /
            getCurrentShogunX28Price()) / 100;

        address[] memory path = new address[](2);
        path[0] = X28;
        path[1] = s_shogunAddress;

        uint256[] memory amounts = UniswapV2Library.getAmountsOut(s_poolAddress, amount, path);
        require(amounts[1] >= minTokenAmount, "TooLittleReceived");
        IERC20(X28).transfer(s_poolAddress, amount);
        uint256 amountShogun = _swap(s_poolAddress, amounts, path);

        s_totalShogunBurn += (amountShogun * SHOGUN_BURN_PERCENT) / PERCENT_BPS;
        s_totalX28Buy += amount;
        burnShogun();

        emit BoughtAndBurned(amount, amountShogun, msg.sender);
    }

    /** @dev swap tokens
     * @param pairAddress pair address
     * @param amounts amounts in and out
     * @param path token addresses
     */
    function _swap(
        address pairAddress,
        uint256[] memory amounts,
        address[] memory path
    ) private returns (uint256) {
        (address token0, ) = UniswapV2Library.sortTokens(path[0], path[1]);
        uint256 amountOut = amounts[1];
        (uint256 amount0Out, uint256 amount1Out) = path[0] == token0
            ? (uint256(0), amountOut)
            : (amountOut, uint256(0));
        IUniswapV2Pair(pairAddress).swap(amount0Out, amount1Out, address(this), new bytes(0));
        return amount0Out == uint256(0) ? amount1Out : amount0Out;
    }

    //views
    function getGenesisTs() public view returns (uint256) {
        return s_shogunGenesisTs;
    }

    /** @notice supported interface check
     * @param interfaceId interfaceId
     * return bool true/false
     */
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return
            interfaceId == IERC165.supportsInterface.selector ||
            interfaceId == type(IShogun).interfaceId;
    }

    /** @notice get Shogun TitanX pool address
     * @return address Shogun TitanX pool address
     */
    function getPoolAddress() public view returns (address) {
        return s_poolAddress;
    }

    /** @notice get buy and burn funds
     * @return amount TitanX amount
     */
    function getTitanXBuyAndBurnFunds() public view returns (uint256) {
        return IERC20(TITANX).balanceOf(address(this));
    }

    /** @notice get buy and burn funds
     * @return amount TitanX amount
     */
    function getX28BuyAndBurnFunds() public view returns (uint256) {
        return IERC20(X28).balanceOf(address(this));
    }

    /** @notice get total TitanX amount used to buy X28
     * @return total TitanX amount
     */
    function getTotalTitanXBuy() public view returns (uint256) {
        return s_totalTitanXBuy;
    }

    /** @notice get total X28 burned via TitanX > X28
     * @return total TitanX amount
     */
    function getTotalX28Burned() public view returns (uint256) {
        return s_totalX28Burned;
    }

    /** @notice get total X28 amount used to buy and burn Shogun
     * @return total X28 amount
     */
    function getTotalX28Buy() public view returns (uint256) {
        return s_totalX28Buy;
    }

    /** @notice get total Shogun amount burned
     * @return amount total Shogun amount
     */
    function getTotalShogunBurn() public view returns (uint256) {
        return s_totalShogunBurn;
    }

    /** @notice get X28/TitanX twap
     * @return amount
     */
    function getTwapX28TitanX() public view returns (uint256) {
        (int24 meanTick, ) = OracleLibrary.consult(X28_TITANX_POOL, s_twapSecondsAgo);
        uint256 sqrtPriceX96 = TickMath.getSqrtRatioAtTick(meanTick);
        uint256 numerator1 = sqrtPriceX96 * sqrtPriceX96;
        uint256 numerator2 = 1 ether;
        uint256 price = FullMath.mulDiv(numerator1, numerator2, 1 << 192);
        price = TITANX < X28 ? (1 ether * 1 ether) / price : price;
        return price;
    }

    /** @notice get current price of the Shogun/X28 pair
     * @return price
     */
    function getCurrentShogunX28Price() public view returns (uint256) {
        (uint256 Res0, uint256 Res1) = UniswapV2Library.getReserves(
            s_poolAddress,
            X28,
            s_shogunAddress
        );
        return (Res0 * 1 ether) / Res1;
    }

    /** @notice get Shogun address
     * @return ShogunAddress Shogun address
     */
    function getShogunAddress() public view returns (address) {
        return s_shogunAddress;
    }

    /** @notice get cap amount per buy and burn
     * @return cap amount
     */
    function getTitanXBuyAndBurnCap() public view returns (uint256) {
        return s_capPerSwapTitanX;
    }

    /** @notice get buynburn slippage
     * @return slippage
     */
    function getSlippageBuynBurnTitanX() public view returns (uint256) {
        return s_slippageBuynBurnTitanX;
    }

    /** @notice get the buy and burn last called timestamp
     * return ts timestamp in seconds
     */
    function getLastCalledTsBuynBurnTitanX() public view returns (uint256) {
        return s_lastCallTsBuynBurnTitanX;
    }

    /** @notice get current TitanX incentive fee dividend
     * @return amount
     */
    function getTitanXIncentiveDividend() public view returns (uint256) {
        return s_TitanXIncentiveDividend;
    }

    /** @notice get cap amount per buy and burn
     * @return cap amount
     */
    function getX28BuyAndBurnCap() public view returns (uint256) {
        return s_capPerSwapX28;
    }

    /** @notice get buynburn slippage
     * @return slippage
     */
    function getSlippageBuynBurnX28() public view returns (uint256) {
        return s_slippageBuynBurnX28;
    }

    /** @notice get the buy and burn last called timestamp
     * return ts timestamp in seconds
     */
    function getLastCalledTsBuynBurnX28() public view returns (uint256) {
        return s_lastCallTsBuynBurnX28;
    }

    /** @notice get current X28 incentive fee dividend
     * @return amount
     */
    function getX28IncentiveDividend() public view returns (uint256) {
        return s_X28IncentiveDividend;
    }

    /** @notice get the buynburn interval between each call in seconds
     * @return seconds
     */
    function getBuynBurnInterval() public pure returns (uint256) {
        return INTERVAL_SECONDS;
    }

    /** @notice get current max cap for missed interval accumulation
     * @return max
     */
    function getCurrentMaxIntervalAccumulation() public view returns (uint256) {
        return s_maxIntervalAccumulation;
    }

    /** @notice get today's max B&B funds TitanX > X28
     * @return amount
     */
    function getTodayMaxBuyFundsTitanX() public view returns (uint256) {
        return getCurrentCapPerIntervalTitanX() * MAX_INTERVALS;
    }

    /** @notice get today's max B&B funds X28 > Shogun
     * @return amount
     */
    function getTodayMaxBuyFundsX28() public view returns (uint256) {
        return getCurrentCapPerIntervalX28() * MAX_INTERVALS;
    }

    /** @notice get today's TitanX swap cap per interval
     * @return amount
     */
    function getCurrentCapPerIntervalTitanX() public view returns (uint256) {
        uint256 currentCap = s_currentCapPerIntervalTitanX;
        uint256 swapCapLimit = s_capPerSwapTitanX;
        currentCap = currentCap > swapCapLimit ? swapCapLimit : currentCap;
        return currentCap;
    }

    /** @notice get today's X28 swap cap per interval
     * @return amount
     */
    function getCurrentCapPerIntervalX28() public view returns (uint256) {
        uint256 currentCap = s_currentCapPerIntervalX28;
        uint256 swapCapLimit = s_capPerSwapX28;
        currentCap = currentCap > swapCapLimit ? swapCapLimit : currentCap;
        return currentCap;
    }

    /** @notice get missed intervals based on last called timestamp, up to 3 intervals */
    function getMissedIntervals(uint256 lastCallTs) public view returns (uint256) {
        uint256 missedIntervals = (block.timestamp - lastCallTs) / INTERVAL_SECONDS;
        uint256 maxAccumulation = s_maxIntervalAccumulation;
        missedIntervals = missedIntervals > maxAccumulation ? maxAccumulation : missedIntervals;
        missedIntervals = missedIntervals == 0 ? 1 : missedIntervals;
        return missedIntervals;
    }

    /** @notice get next interval swap amount up to 3 missed intervals
     * @return amount
     */
    function getNextIntervalSwapAmountTitanX() public view returns (uint256) {
        return getCurrentCapPerIntervalTitanX() * getMissedIntervals(s_lastCallTsBuynBurnTitanX);
    }

    /** @notice get next interval swap amount up to 3 missed intervals
     * @return amount
     */
    function getNextIntervalSwapAmountX28() public view returns (uint256) {
        return getCurrentCapPerIntervalX28() * getMissedIntervals(s_lastCallTsBuynBurnX28);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.7.6;

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

pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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
pragma solidity ^0.7.6;

interface IShogun {
    function mintLPTokens() external;

    function burnCAShogun(address contractAddress) external;

    function genesisTs() external returns (uint256);

    function getGenesisAddress() external returns (address);

    function getLPAddress() external returns (address);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.7.6;
pragma abicoder v2;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.7.6;
pragma abicoder v2;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title The interface for the Uniswap V3 Factory
/// @notice The Uniswap V3 Factory facilitates creation of Uniswap V3 pools and control over the protocol fees
interface IUniswapV3Factory {
    /// @notice Emitted when the owner of the factory is changed
    /// @param oldOwner The owner before the owner was changed
    /// @param newOwner The owner after the owner was changed
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    /// @notice Emitted when a pool is created
    /// @param token0 The first token of the pool by address sort order
    /// @param token1 The second token of the pool by address sort order
    /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// @param tickSpacing The minimum number of ticks between initialized ticks
    /// @param pool The address of the created pool
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    /// @notice Emitted when a new fee amount is enabled for pool creation via the factory
    /// @param fee The enabled fee, denominated in hundredths of a bip
    /// @param tickSpacing The minimum number of ticks between initialized ticks for pools created with the given fee
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    /// @notice Returns the current owner of the factory
    /// @dev Can be changed by the current owner via setOwner
    /// @return The address of the factory owner
    function owner() external view returns (address);

    /// @notice Returns the tick spacing for a given fee amount, if enabled, or 0 if not enabled
    /// @dev A fee amount can never be removed, so this value should be hard coded or cached in the calling context
    /// @param fee The enabled fee, denominated in hundredths of a bip. Returns 0 in case of unenabled fee
    /// @return The tick spacing
    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    /// @notice Returns the pool address for a given pair of tokens and a fee, or address 0 if it does not exist
    /// @dev tokenA and tokenB may be passed in either token0/token1 or token1/token0 order
    /// @param tokenA The contract address of either token0 or token1
    /// @param tokenB The contract address of the other token
    /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// @return pool The pool address
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    /// @notice Creates a pool for the given two tokens and fee
    /// @param tokenA One of the two tokens in the desired pool
    /// @param tokenB The other of the two tokens in the desired pool
    /// @param fee The desired fee for the pool
    /// @dev tokenA and tokenB may be passed in either order: token0/token1 or token1/token0. tickSpacing is retrieved
    /// from the fee. The call will revert if the pool already exists, the fee is invalid, or the token arguments
    /// are invalid.
    /// @return pool The address of the newly created pool
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    /// @notice Updates the owner of the factory
    /// @dev Must be called by the current owner
    /// @param _owner The new owner of the factory
    function setOwner(address _owner) external;

    /// @notice Enables a fee amount with the given tickSpacing
    /// @dev Fee amounts may never be removed once enabled
    /// @param fee The fee amount to enable, denominated in hundredths of a bip (i.e. 1e-6)
    /// @param tickSpacing The spacing between ticks to be enforced for all pools created with the given fee amount
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import "./pool/IUniswapV3PoolImmutables.sol";
import "./pool/IUniswapV3PoolState.sol";
import "./pool/IUniswapV3PoolDerivedState.sol";
import "./pool/IUniswapV3PoolActions.sol";
import "./pool/IUniswapV3PoolOwnerActions.sol";
import "./pool/IUniswapV3PoolEvents.sol";

/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "../contracts/openzeppelin/token/ERC20/IERC20.sol";

interface IX28 is IERC20 {
    function mintX28withTitanX(uint256 amount) external;

    function burnCAX28(address contractAddress) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Permissionless pool actions
/// @notice Contains pool methods that can be called by anyone
interface IUniswapV3PoolActions {
    /// @notice Sets the initial price for the pool
    /// @dev Price is represented as a sqrt(amountToken1/amountToken0) Q64.96 value
    /// @param sqrtPriceX96 the initial sqrt price of the pool as a Q64.96
    function initialize(uint160 sqrtPriceX96) external;

    /// @notice Adds liquidity for the given recipient/tickLower/tickUpper position
    /// @dev The caller of this method receives a callback in the form of IUniswapV3MintCallback#uniswapV3MintCallback
    /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
    /// on tickLower, tickUpper, the amount of liquidity, and the current price.
    /// @param recipient The address for which the liquidity will be created
    /// @param tickLower The lower tick of the position in which to add liquidity
    /// @param tickUpper The upper tick of the position in which to add liquidity
    /// @param amount The amount of liquidity to mint
    /// @param data Any data that should be passed through to the callback
    /// @return amount0 The amount of token0 that was paid to mint the given amount of liquidity. Matches the value in the callback
    /// @return amount1 The amount of token1 that was paid to mint the given amount of liquidity. Matches the value in the callback
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Collects tokens owed to a position
    /// @dev Does not recompute fees earned, which must be done either via mint or burn of any amount of liquidity.
    /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
    /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    /// @param recipient The address which should receive the fees collected
    /// @param tickLower The lower tick of the position for which to collect fees
    /// @param tickUpper The upper tick of the position for which to collect fees
    /// @param amount0Requested How much token0 should be withdrawn from the fees owed
    /// @param amount1Requested How much token1 should be withdrawn from the fees owed
    /// @return amount0 The amount of fees collected in token0
    /// @return amount1 The amount of fees collected in token1
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    /// @notice Burn liquidity from the sender and account tokens owed for the liquidity to the position
    /// @dev Can be used to trigger a recalculation of fees owed to a position by calling with an amount of 0
    /// @dev Fees must be collected separately via a call to #collect
    /// @param tickLower The lower tick of the position for which to burn liquidity
    /// @param tickUpper The upper tick of the position for which to burn liquidity
    /// @param amount How much liquidity to burn
    /// @return amount0 The amount of token0 sent to the recipient
    /// @return amount1 The amount of token1 sent to the recipient
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Swap token0 for token1, or token1 for token0
    /// @dev The caller of this method receives a callback in the form of IUniswapV3SwapCallback#uniswapV3SwapCallback
    /// @param recipient The address to receive the output of the swap
    /// @param zeroForOne The direction of the swap, true for token0 to token1, false for token1 to token0
    /// @param amountSpecified The amount of the swap, which implicitly configures the swap as exact input (positive), or exact output (negative)
    /// @param sqrtPriceLimitX96 The Q64.96 sqrt price limit. If zero for one, the price cannot be less than this
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    /// @param data Any data to be passed through to the callback
    /// @return amount0 The delta of the balance of token0 of the pool, exact when negative, minimum when positive
    /// @return amount1 The delta of the balance of token1 of the pool, exact when negative, minimum when positive
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    /// @notice Receive token0 and/or token1 and pay it back, plus a fee, in the callback
    /// @dev The caller of this method receives a callback in the form of IUniswapV3FlashCallback#uniswapV3FlashCallback
    /// @dev Can be used to donate underlying tokens pro-rata to currently in-range liquidity providers by calling
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    /// @param recipient The address which will receive the token0 and token1 amounts
    /// @param amount0 The amount of token0 to send
    /// @param amount1 The amount of token1 to send
    /// @param data Any data to be passed through to the callback
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    /// @notice Increase the maximum number of price and liquidity observations that this pool will store
    /// @dev This method is no-op if the pool already has an observationCardinalityNext greater than or equal to
    /// the input observationCardinalityNext.
    /// @param observationCardinalityNext The desired minimum number of observations for the pool to store
    function increaseObservationCardinalityNext(
        uint16 observationCardinalityNext
    ) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that is not stored
/// @notice Contains view functions to provide information about the pool that is computed rather than stored on the
/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    /// @notice Returns the cumulative tick and liquidity as of each timestamp `secondsAgo` from the current block timestamp
    /// @dev To get a time weighted average tick or liquidity-in-range, you must call this with two values, one representing
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    /// @dev The time weighted average tick represents the geometric time weighted average price of the pool, in
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    /// @param secondsAgos From how long ago each cumulative tick and liquidity value should be returned
    /// @return tickCumulatives Cumulative tick values as of each `secondsAgos` from the current block timestamp
    /// @return secondsPerLiquidityCumulativeX128s Cumulative seconds per liquidity-in-range value as of each `secondsAgos` from the current block
    /// timestamp
    function observe(
        uint32[] calldata secondsAgos
    )
        external
        view
        returns (
            int56[] memory tickCumulatives,
            uint160[] memory secondsPerLiquidityCumulativeX128s
        );

    /// @notice Returns a snapshot of the tick cumulative, seconds per liquidity and seconds inside a tick range
    /// @dev Snapshots must only be compared to other snapshots, taken over a period for which a position existed.
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    /// @param tickLower The lower tick of the range
    /// @param tickUpper The upper tick of the range
    /// @return tickCumulativeInside The snapshot of the tick accumulator for the range
    /// @return secondsPerLiquidityInsideX128 The snapshot of seconds per liquidity for the range
    /// @return secondsInside The snapshot of seconds per liquidity for the range
    function snapshotCumulativesInside(
        int24 tickLower,
        int24 tickUpper
    )
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Events emitted by a pool
/// @notice Contains all events emitted by the pool
interface IUniswapV3PoolEvents {
    /// @notice Emitted exactly once by a pool when #initialize is first called on the pool
    /// @dev Mint/Burn/Swap cannot be emitted by the pool before Initialize
    /// @param sqrtPriceX96 The initial sqrt price of the pool, as a Q64.96
    /// @param tick The initial tick of the pool, i.e. log base 1.0001 of the starting price of the pool
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    /// @notice Emitted when liquidity is minted for a given position
    /// @param sender The address that minted the liquidity
    /// @param owner The owner of the position and recipient of any minted liquidity
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity minted to the position range
    /// @param amount0 How much token0 was required for the minted liquidity
    /// @param amount1 How much token1 was required for the minted liquidity
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted when fees are collected by the owner of a position
    /// @dev Collect events may be emitted with zero amount0 and amount1 when the caller chooses not to collect fees
    /// @param owner The owner of the position for which fees are collected
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount0 The amount of token0 fees collected
    /// @param amount1 The amount of token1 fees collected
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    /// @notice Emitted when a position's liquidity is removed
    /// @dev Does not withdraw any fees earned by the liquidity position, which must be withdrawn via #collect
    /// @param owner The owner of the position for which liquidity is removed
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity to remove
    /// @param amount0 The amount of token0 withdrawn
    /// @param amount1 The amount of token1 withdrawn
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted by the pool for any swaps between token0 and token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the output of the swap
    /// @param amount0 The delta of the token0 balance of the pool
    /// @param amount1 The delta of the token1 balance of the pool
    /// @param sqrtPriceX96 The sqrt(price) of the pool after the swap, as a Q64.96
    /// @param liquidity The liquidity of the pool after the swap
    /// @param tick The log base 1.0001 of price of the pool after the swap
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    /// @notice Emitted by the pool for any flashes of token0/token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the tokens from flash
    /// @param amount0 The amount of token0 that was flashed
    /// @param amount1 The amount of token1 that was flashed
    /// @param paid0 The amount of token0 paid for the flash, which can exceed the amount0 plus the fee
    /// @param paid1 The amount of token1 paid for the flash, which can exceed the amount1 plus the fee
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    /// @notice Emitted by the pool for increases to the number of observations that can be stored
    /// @dev observationCardinalityNext is not the observation cardinality until an observation is written at the index
    /// just before a mint/swap/burn.
    /// @param observationCardinalityNextOld The previous value of the next observation cardinality
    /// @param observationCardinalityNextNew The updated value of the next observation cardinality
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    /// @notice Emitted when the protocol fee is changed by the pool
    /// @param feeProtocol0Old The previous value of the token0 protocol fee
    /// @param feeProtocol1Old The previous value of the token1 protocol fee
    /// @param feeProtocol0New The updated value of the token0 protocol fee
    /// @param feeProtocol1New The updated value of the token1 protocol fee
    event SetFeeProtocol(
        uint8 feeProtocol0Old,
        uint8 feeProtocol1Old,
        uint8 feeProtocol0New,
        uint8 feeProtocol1New
    );

    /// @notice Emitted when the collected protocol fees are withdrawn by the factory owner
    /// @param sender The address that collects the protocol fees
    /// @param recipient The address that receives the collected protocol fees
    /// @param amount0 The amount of token0 protocol fees that is withdrawn
    /// @param amount0 The amount of token1 protocol fees that is withdrawn
    event CollectProtocol(
        address indexed sender,
        address indexed recipient,
        uint128 amount0,
        uint128 amount1
    );
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that never changes
/// @notice These parameters are fixed for a pool forever, i.e., the methods will always return the same values
interface IUniswapV3PoolImmutables {
    /// @notice The contract that deployed the pool, which must adhere to the IUniswapV3Factory interface
    /// @return The contract address
    function factory() external view returns (address);

    /// @notice The first of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token0() external view returns (address);

    /// @notice The second of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token1() external view returns (address);

    /// @notice The pool's fee in hundredths of a bip, i.e. 1e-6
    /// @return The fee
    function fee() external view returns (uint24);

    /// @notice The pool tick spacing
    /// @dev Ticks can only be used at multiples of this value, minimum of 1 and always positive
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    /// @return The tick spacing
    function tickSpacing() external view returns (int24);

    /// @notice The maximum amount of position liquidity that can use any tick in the range
    /// @dev This parameter is enforced per tick to prevent liquidity from overflowing a uint128 at any point, and
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    /// @return The max amount of liquidity per tick
    function maxLiquidityPerTick() external view returns (uint128);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface IUniswapV3PoolOwnerActions {
    /// @notice Set the denominator of the protocol's % share of the fees
    /// @param feeProtocol0 new protocol fee for token0 of the pool
    /// @param feeProtocol1 new protocol fee for token1 of the pool
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    /// @notice Collect the protocol fee accrued to the pool
    /// @param recipient The address to which collected protocol fees should be sent
    /// @param amount0Requested The maximum amount of token0 to send, can be 0 to collect fees in only token1
    /// @param amount1Requested The maximum amount of token1 to send, can be 0 to collect fees in only token0
    /// @return amount0 The protocol fee collected in token0
    /// @return amount1 The protocol fee collected in token1
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction
interface IUniswapV3PoolState {
    /// @notice The 0th storage slot in the pool stores many values, and is exposed as a single method to save gas
    /// when accessed externally.
    /// @return sqrtPriceX96 The current price of the pool as a sqrt(token1/token0) Q64.96 value
    /// tick The current tick of the pool, i.e. according to the last tick transition that was run.
    /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// observationIndex The index of the last oracle observation that was written,
    /// observationCardinality The current maximum number of observations stored in the pool,
    /// observationCardinalityNext The next maximum number of observations, to be updated when the observation.
    /// feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    /// @notice The fee growth as a Q128.128 fees of token0 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal0X128() external view returns (uint256);

    /// @notice The fee growth as a Q128.128 fees of token1 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal1X128() external view returns (uint256);

    /// @notice The amounts of token0 and token1 that are owed to the protocol
    /// @dev Protocol fees will never exceed uint128 max in either token
    function protocolFees()
        external
        view
        returns (uint128 token0, uint128 token1);

    /// @notice The currently in range liquidity available to the pool
    /// @dev This value has no relationship to the total liquidity across all ticks
    function liquidity() external view returns (uint128);

    /// @notice Look up information about a specific tick in the pool
    /// @param tick The tick to look up
    /// @return liquidityGross the total amount of position liquidity that uses the pool either as tick lower or
    /// tick upper,
    /// liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(
        int24 tick
    )
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    /// @notice Returns 256 packed tick initialized boolean values. See TickBitmap for more information
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    /// @notice Returns the information about a position by the position's key
    /// @param key The position's key is a hash of a preimage composed by the owner, tickLower and tickUpper
    /// @return _liquidity The amount of liquidity in the position,
    /// Returns feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// Returns feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// Returns tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// Returns tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(
        bytes32 key
    )
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    /// @notice Returns data about a specific observation index
    /// @param index The element of the observations array to fetch
    /// @dev You most likely want to use #observe() instead of this method to get an observation as of some amount of time
    /// ago, rather than at a specific index in the array.
    /// @return blockTimestamp The timestamp of the observation,
    /// Returns tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// Returns secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// Returns initialized whether the observation has been initialized and the values are safe to use
    function observations(
        uint256 index
    )
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "../interfaces/IUniswapV3Pool.sol";
import "./PoolAddress.sol";

/// @notice Provides validation for callbacks from Uniswap V3 Pools
library CallbackValidation {
    /// @notice Returns the address of a valid Uniswap V3 Pool
    /// @param factory The contract address of the Uniswap V3 factory
    /// @param tokenA The contract address of either token0 or token1
    /// @param tokenB The contract address of the other token
    /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// @return pool The V3 pool contract address
    function verifyCallback(
        address factory,
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal view returns (IUniswapV3Pool pool) {
        return
            verifyCallback(
                factory,
                PoolAddress.getPoolKey(tokenA, tokenB, fee)
            );
    }

    /// @notice Returns the address of a valid Uniswap V3 Pool
    /// @param factory The contract address of the Uniswap V3 factory
    /// @param poolKey The identifying key of the V3 pool
    /// @return pool The V3 pool contract address
    function verifyCallback(
        address factory,
        PoolAddress.PoolKey memory poolKey
    ) internal view returns (IUniswapV3Pool pool) {
        pool = IUniswapV3Pool(PoolAddress.computeAddress(factory, poolKey));
        require(msg.sender == address(pool));
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

address constant UNISWAPV3FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
address constant UNISWAPV2FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
address constant TITANX = 0xF19308F923582A6f7c465e5CE7a9Dc1BEC6665B1;

address constant X28 = 0x5c47902c8C80779CB99235E42C354E53F38C3B0d;
address constant X28_BNB = 0xa3144E7FCceD79Ce6ff6E14AE9d8DF229417A7a2;
address constant X28_TITANX_POOL = 0x99f60479da6A49D55eBA34893958cdAACc710eE9;

uint256 constant INITIAL_LP_X28 = 2_800_000_000 ether;
uint256 constant INITIAL_LP_SHOGUN = 1_000_000 ether;

uint24 constant POOLFEE1PERCENT = 10000; //1% Fee
uint160 constant MIN_SQRT_RATIO = 4295128739;
uint160 constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

uint256 constant INCENTIVE_FEE_PERCENT_BASE = 1_000_000;

uint256 constant MIN_TWAP_SECONDS = 300; //5 minutes
uint256 constant MAX_TWAP_SECONDS = 43200; //12 hours

uint256 constant MIN_SLIPPAGE_TITANX = 5;
uint256 constant MAX_SLIPPAGE_TITANX = 15;

uint256 constant MIN_SLIPPAGE_X28 = 5;
uint256 constant MAX_SLIPPAGE_X28 = 15;

uint256 constant PERCENT_BPS = 100_00;

uint256 constant INITIAL_PHASE_BNB_FUNDS_PERCENT = 28_00;
uint256 constant PHASE_2_BNB_FUNDS_PERCENT = 8_00;

uint256 constant SHOGUN_BURN_PERCENT = 28_00;

uint256 constant MAX_INTERVALS = 288;
uint256 constant INTERVAL_SECONDS = 300; //5 minutes

uint256 constant GENESIS_PERCENT = 5_00;
uint256 constant BURN_PERCENT = 20_00;
uint256 constant LP_PERCENT = 22_00;
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0 <0.8.0;

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits
library FullMath {
    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remainder Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division
        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        // Make sure the result is less than 2**256.
        // Also prevents denominator == 0
        require(denominator > prod1);

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0]
        // Compute remainder using mulmod
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        // Subtract 256 bit number from 512 bit number
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator
        // Compute largest power of two divisor of denominator.
        // Always >= 1.
        uint256 twos = -denominator & denominator;
        // Divide denominator by power of two
        assembly {
            denominator := div(denominator, twos)
        }

        // Divide [prod1 prod0] by the factors of two
        assembly {
            prod0 := div(prod0, twos)
        }
        // Shift in bits from prod1 into prod0. For this we need
        // to flip `twos` such that it is 2**256 / twos.
        // If twos is zero, then it becomes one
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        // Invert denominator mod 2**256
        // Now that denominator is an odd number, it has an inverse
        // modulo 2**256 such that denominator * inv = 1 mod 2**256.
        // Compute the inverse by starting with a seed that is correct
        // correct for four bits. That is, denominator * inv = 1 mod 2**4
        uint256 inv = (3 * denominator) ^ 2;
        // Now use Newton-Raphson iteration to improve the precision.
        // Thanks to Hensel's lifting lemma, this also works in modular
        // arithmetic, doubling the correct bits in each step.
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        // Because the division is now exact we can divide by multiplying
        // with the modular inverse of denominator. This will give us the
        // correct result modulo 2**256. Since the precoditions guarantee
        // that the outcome is less than 2**256, this is the final result.
        // We don't need to compute the high bits of the result and prod1
        // is no longer required.
        result = prod0 * inv;
        return result;
    }

    /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0 <0.8.0;

import "./FullMath.sol";
import "./TickMath.sol";
import "../interfaces/IUniswapV3Pool.sol";

/// @title Oracle library
/// @notice Provides functions to integrate with V3 pool oracle
library OracleLibrary {
    /// @notice Calculates time-weighted means of tick and liquidity for a given Uniswap V3 pool
    /// @param pool Address of the pool that we want to observe
    /// @param secondsAgo Number of seconds in the past from which to calculate the time-weighted means
    /// @return arithmeticMeanTick The arithmetic mean tick from (block.timestamp - secondsAgo) to block.timestamp
    /// @return harmonicMeanLiquidity The harmonic mean liquidity from (block.timestamp - secondsAgo) to block.timestamp
    function consult(
        address pool,
        uint32 secondsAgo
    ) internal view returns (int24 arithmeticMeanTick, uint128 harmonicMeanLiquidity) {
        require(secondsAgo != 0, "BP");

        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = secondsAgo;
        secondsAgos[1] = 0;

        (
            int56[] memory tickCumulatives,
            uint160[] memory secondsPerLiquidityCumulativeX128s
        ) = IUniswapV3Pool(pool).observe(secondsAgos);

        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
        uint160 secondsPerLiquidityCumulativesDelta = secondsPerLiquidityCumulativeX128s[1] -
            secondsPerLiquidityCumulativeX128s[0];

        arithmeticMeanTick = int24(tickCumulativesDelta / secondsAgo);
        // Always round to negative infinity
        if (tickCumulativesDelta < 0 && (tickCumulativesDelta % secondsAgo != 0))
            arithmeticMeanTick--;

        // We are multiplying here instead of shifting to ensure that harmonicMeanLiquidity doesn't overflow uint128
        uint192 secondsAgoX160 = uint192(secondsAgo) * type(uint160).max;
        harmonicMeanLiquidity = uint128(
            secondsAgoX160 / (uint192(secondsPerLiquidityCumulativesDelta) << 32)
        );
    }

    /// @notice Given a tick and a token amount, calculates the amount of token received in exchange
    /// @param tick Tick value used to calculate the quote
    /// @param baseAmount Amount of token to be converted
    /// @param baseToken Address of an ERC20 token contract used as the baseAmount denomination
    /// @param quoteToken Address of an ERC20 token contract used as the quoteAmount denomination
    /// @return quoteAmount Amount of quoteToken received for baseAmount of baseToken
    function getQuoteAtTick(
        int24 tick,
        uint128 baseAmount,
        address baseToken,
        address quoteToken
    ) internal pure returns (uint256 quoteAmount) {
        uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);

        // Calculate quoteAmount with better precision if it doesn't overflow when multiplied by itself
        if (sqrtRatioX96 <= type(uint128).max) {
            uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX192, baseAmount, 1 << 192)
                : FullMath.mulDiv(1 << 192, baseAmount, ratioX192);
        } else {
            uint256 ratioX128 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX128, baseAmount, 1 << 128)
                : FullMath.mulDiv(1 << 128, baseAmount, ratioX128);
        }
    }

    /// @notice Given a pool, it returns the number of seconds ago of the oldest stored observation
    /// @param pool Address of Uniswap V3 pool that we want to observe
    /// @return secondsAgo The number of seconds ago of the oldest observation stored for the pool
    function getOldestObservationSecondsAgo(
        address pool
    ) internal view returns (uint32 secondsAgo) {
        (, , uint16 observationIndex, uint16 observationCardinality, , , ) = IUniswapV3Pool(pool)
            .slot0();
        require(observationCardinality > 0, "NI");

        (uint32 observationTimestamp, , , bool initialized) = IUniswapV3Pool(pool).observations(
            (observationIndex + 1) % observationCardinality
        );

        // The next index might not be initialized if the cardinality is in the process of increasing
        // In this case the oldest observation is always in index 0
        if (!initialized) {
            (observationTimestamp, , , ) = IUniswapV3Pool(pool).observations(0);
        }

        secondsAgo = uint32(block.timestamp) - observationTimestamp;
    }

    /// @notice Given a pool, it returns the tick value as of the start of the current block
    /// @param pool Address of Uniswap V3 pool
    /// @return The tick that the pool was in at the start of the current block
    function getBlockStartingTickAndLiquidity(address pool) internal view returns (int24, uint128) {
        (
            ,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            ,
            ,

        ) = IUniswapV3Pool(pool).slot0();

        // 2 observations are needed to reliably calculate the block starting tick
        require(observationCardinality > 1, "NEO");

        // If the latest observation occurred in the past, then no tick-changing trades have happened in this block
        // therefore the tick in `slot0` is the same as at the beginning of the current block.
        // We don't need to check if this observation is initialized - it is guaranteed to be.
        (
            uint32 observationTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,

        ) = IUniswapV3Pool(pool).observations(observationIndex);
        if (observationTimestamp != uint32(block.timestamp)) {
            return (tick, IUniswapV3Pool(pool).liquidity());
        }

        uint256 prevIndex = (uint256(observationIndex) + observationCardinality - 1) %
            observationCardinality;
        (
            uint32 prevObservationTimestamp,
            int56 prevTickCumulative,
            uint160 prevSecondsPerLiquidityCumulativeX128,
            bool prevInitialized
        ) = IUniswapV3Pool(pool).observations(prevIndex);

        require(prevInitialized, "ONI");

        uint32 delta = observationTimestamp - prevObservationTimestamp;
        tick = int24((tickCumulative - prevTickCumulative) / delta);
        uint128 liquidity = uint128(
            (uint192(delta) * type(uint160).max) /
                (uint192(
                    secondsPerLiquidityCumulativeX128 - prevSecondsPerLiquidityCumulativeX128
                ) << 32)
        );
        return (tick, liquidity);
    }

    /// @notice Information for calculating a weighted arithmetic mean tick
    struct WeightedTickData {
        int24 tick;
        uint128 weight;
    }

    /// @notice Given an array of ticks and weights, calculates the weighted arithmetic mean tick
    /// @param weightedTickData An array of ticks and weights
    /// @return weightedArithmeticMeanTick The weighted arithmetic mean tick
    /// @dev Each entry of `weightedTickData` should represents ticks from pools with the same underlying pool tokens. If they do not,
    /// extreme care must be taken to ensure that ticks are comparable (including decimal differences).
    /// @dev Note that the weighted arithmetic mean tick corresponds to the weighted geometric mean price.
    function getWeightedArithmeticMeanTick(
        WeightedTickData[] memory weightedTickData
    ) internal pure returns (int24 weightedArithmeticMeanTick) {
        // Accumulates the sum of products between each tick and its weight
        int256 numerator;

        // Accumulates the sum of the weights
        uint256 denominator;

        // Products fit in 152 bits, so it would take an array of length ~2**104 to overflow this logic
        for (uint256 i; i < weightedTickData.length; i++) {
            numerator += weightedTickData[i].tick * int256(weightedTickData[i].weight);
            denominator += weightedTickData[i].weight;
        }

        weightedArithmeticMeanTick = int24(numerator / int256(denominator));
        // Always round to negative infinity
        if (numerator < 0 && (numerator % int256(denominator) != 0)) weightedArithmeticMeanTick--;
    }

    /// @notice Returns the "synthetic" tick which represents the price of the first entry in `tokens` in terms of the last
    /// @dev Useful for calculating relative prices along routes.
    /// @dev There must be one tick for each pairwise set of tokens.
    /// @param tokens The token contract addresses
    /// @param ticks The ticks, representing the price of each token pair in `tokens`
    /// @return syntheticTick The synthetic tick, representing the relative price of the outermost tokens in `tokens`
    function getChainedPrice(
        address[] memory tokens,
        int24[] memory ticks
    ) internal pure returns (int256 syntheticTick) {
        require(tokens.length - 1 == ticks.length, "DL");
        for (uint256 i = 1; i <= ticks.length; i++) {
            // check the tokens for address sort order, then accumulate the
            // ticks into the running synthetic tick, ensuring that intermediate tokens "cancel out"
            tokens[i - 1] < tokens[i] ? syntheticTick += ticks[i - 1] : syntheticTick -= ticks[
                i - 1
            ];
        }
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Provides functions for deriving a pool address from the factory, tokens, and the fee
library PoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH =
        0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    /// @notice The identifying key of the pool
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    /// @notice Returns PoolKey: the ordered tokens with the matched fee levels
    /// @param tokenA The first token of a pool, unsorted
    /// @param tokenB The second token of a pool, unsorted
    /// @param fee The fee level of the pool
    /// @return Poolkey The pool details with ordered token0 and token1 assignments
    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    /// @notice Deterministically computes the pool address given the factory and PoolKey
    /// @param factory The Uniswap V3 factory contract address
    /// @param key The PoolKey
    /// @return pool The contract address of the V3 pool
    function computeAddress(
        address factory,
        PoolKey memory key
    ) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encode(key.token0, key.token1, key.fee)),
                        POOL_INIT_CODE_HASH
                    )
                )
            )
        );
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.7.6;
pragma abicoder v2;

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0 <0.8.0;

/// @title Math library for computing sqrt prices from ticks and vice versa
/// @notice Computes sqrt price for ticks of size 1.0001, i.e. sqrt(1.0001^tick) as fixed point Q64.96 numbers. Supports
/// prices between 2**-128 and 2**128
library TickMath {
    /// @dev The minimum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**-128
    int24 internal constant MIN_TICK = -887272;
    /// @dev The maximum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**128
    int24 internal constant MAX_TICK = -MIN_TICK;

    /// @dev The minimum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MIN_TICK)
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    /// @dev The maximum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MAX_TICK)
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    /// @notice Calculates sqrt(1.0001^tick) * 2^96
    /// @dev Throws if |tick| > max tick
    /// @param tick The input tick for the above formula
    /// @return sqrtPriceX96 A Fixed point Q64.96 number representing the sqrt of the ratio of the two assets (token1/token0)
    /// at the given tick
    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        require(absTick <= uint256(MAX_TICK), "T");

        uint256 ratio = absTick & 0x1 != 0
            ? 0xfffcb933bd6fad37aa2d162d1a594001
            : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

        if (tick > 0) ratio = type(uint256).max / ratio;

        // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
        // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
        // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
        sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }

    /// @notice Calculates the greatest tick value such that getRatioAtTick(tick) <= ratio
    /// @dev Throws in case sqrtPriceX96 < MIN_SQRT_RATIO, as MIN_SQRT_RATIO is the lowest value getRatioAtTick may
    /// ever return.
    /// @param sqrtPriceX96 The sqrt ratio for which to compute the tick as a Q64.96
    /// @return tick The greatest tick for which the ratio is less than or equal to the input ratio
    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        // second inequality must be < because the price can never reach the price at the max tick
        require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, "R");
        uint256 ratio = uint256(sqrtPriceX96) << 32;

        uint256 r = ratio;
        uint256 msb = 0;

        assembly {
            let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(5, gt(r, 0xFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(4, gt(r, 0xFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(3, gt(r, 0xFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(2, gt(r, 0xF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(1, gt(r, 0x3))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := gt(r, 0x1)
            msb := or(msb, f)
        }

        if (msb >= 128) r = ratio >> (msb - 127);
        else r = ratio << (127 - msb);

        int256 log_2 = (int256(msb) - 128) << 64;

        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(63, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(62, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(61, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(60, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(59, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(58, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(57, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(56, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(55, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(54, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(53, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(52, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(51, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(50, f))
        }

        int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number

        int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
        int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

        tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96
            ? tickHi
            : tickLow;
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.7.6;
pragma abicoder v2;

import "./Constant.sol";
import "./SafeMath.sol";
import "../interfaces/IUniswapV2Pair.sol";

/**
 * @notice this is a modified version of UniswapV2 library
 * specifically, we pass in the pair address created by contract in order to pinpoint exactly which pair we want to buy and burn
 */
library UniswapV2Library {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(
        address tokenA,
        address tokenB
    ) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address pairAddress,
        address tokenA,
        address tokenB
    ) internal view returns (uint reserveA, uint reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1, ) = IUniswapV2Pair(pairAddress).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) internal pure returns (uint amountB) {
        require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) internal pure returns (uint amountOut) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) internal pure returns (uint amountIn) {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address pairAddress,
        uint amountIn,
        address[] memory path
    ) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(pairAddress, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address pairAddress,
        uint amountOut,
        address[] memory path
    ) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(pairAddress, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}