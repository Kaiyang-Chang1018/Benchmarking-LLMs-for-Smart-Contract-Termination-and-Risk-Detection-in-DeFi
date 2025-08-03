// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;


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

interface IUniswapV3Pool {
  function observe(
    uint32[] calldata secondsAgos
  ) external
    view
    returns (
      int56[] memory tickCumulatives,
      uint160[] memory secondsPerLiquidityCumulativeX128s
    );

  function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
  function fee() external returns(uint24);
}



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

     function decimals() external view returns (uint8);
}



/**
 * @title IAFiStorage.
 * @notice Interface of the AFiStorage.
 */

interface IIEarnManager {
  function recommend(
    address _token,
    address afiBase,
    address afiStorage
  ) external view returns (string memory choice, uint capr, uint aapr, uint dapr);
}

interface IAFiStorage {
  /**
   * @notice Struct representing investor details.
   * @param isPresent Boolean indicating whether an investor exists.
   * @param uTokenBalance Investor underlying token balance.
   * @param investedAmount Amount of StableCoin invested in the underlying token
   */
  struct Investor {
    bool isPresent;
    uint depositNAV;
    uint redemptionNAV;
  }

  struct RedemptionParams {
        address baseContract;
        uint r;
        address oToken;
        uint256 cSwapCounter;
        address[] uTokens;
        address[] iTokens;
        uint256 deadline;
        uint256[] minimumReturnAmount;
        uint256 _pool;
        uint256 tSupply;
        uint256 depositNAV;
    }

  /**
   * @notice Struct representing TeamWallet details.
   * @param isPresent Boolean indicating whether a wallet exists.
   * @param isActive Boolean indicating whether a wallet is active.
   * @param walletAddress Wallet address.
   */
  struct TeamWallet {
    bool isPresent;
    bool isActive;
    address walletAddress;
  }

  /**
   * @notice Struct representing Rebalance details.
   * @param scenario Scenario can be either of 0, 1 or 2.
   * @param rebalancedUToken Address of the underlying token that is rebalanced.
   * @param rebalancedToUTokens Array of addresses of underlying tokens to which the uToken has been rebalanced.
   */
  struct RebalanceDetails {
    uint8 scenario;
    address rebalancedUToken;
    address[] rebalancedToUTokens;
  }

  /**
   * @param walletAddress Address of the wallet.
   * @param isActive Boolean indicating wallet active status.
   */
  event TeamWalletActive(address indexed walletAddress, bool isActive);

  /**
   * @param walletAddress Address of the wallet.
   * @param isActive Boolean indicating wallet active status.
   */
  event TeamWalletAdd(address indexed walletAddress, bool isActive);

  /**
   * @notice Returns the team wallet details.
   * @param aFiContract Address of the AFi contract.
   * @param _wallet Wallet address
   * @return isPresent Boolean indicating the present status of the wallet.
   * @return isActive Boolean indicating whether to set the wallet to either active/inactive.
   */
  function getTeamWalletDetails(
    address aFiContract,
    address _wallet
  ) external view returns (bool isPresent, bool isActive);



   function handleRedemption(RedemptionParams memory params, uint _shares, uint swapMethod) external  returns (uint256 redemptionFromContract);

  /**
   * @notice To add a new team wallet.
   * @param aFiContract Address of the AFi contract.
   * @param _wallet Wallet address that has to be added in the `teamWallets` array.
   * @param isActive Boolean indicating whether to set the wallet to either active/inactive.
   * @param isPresent Boolean indicating the present status of the wallet.
   */
  function addTeamWallet(
    address aFiContract,
    address _wallet,
    bool isActive,
    bool isPresent
  ) external;

  /**
   * @notice Returns the team wallets for an AFi.
   * @param aFiContract Address of the AFi contract.
   * @return _teamWallets Array of teamWallets.
   */
  function getTeamWalletsOfAFi(
    address aFiContract
  ) external view returns (address[] memory _teamWallets);

  /**
   * @notice Sets the address for team wallets.
   * @param aFiContract Address of the AFi contract.
   * @param _teamWallets Array of addresses for the team wallets.
   */
  function setTeamWallets(address aFiContract, address[] memory _teamWallets) external;

  /**
   * @notice Sets the status for the AFi in the storage contract.
   * @param aFiContract Address of the AFi contract.
   * @param active status for afiContracts.
   */
  function setAFiActive(address aFiContract, bool active) external;

  /**
   * @notice Sets Active Rebalance status of an AFi.
   * @param aFiContract Address of the AFi contract.
   * @param status indicating active rebalance status of the AFi contract.
   */
  function setActiveRebalancedStatus(address aFiContract, bool status) external;

  /**
   * @notice gets Active Rebalance status of an AFi.
   * @param aFiContract Address of the AFi contract.
   * @return _isActiveRebalanced bool indicating active rebalance status of the AFi contract.
   */
  function isAFiActiveRebalanced(
    address aFiContract
  ) external view returns (bool _isActiveRebalanced);

  function getTotalActiveWallets(address aFiContract) external view returns (uint);

  function calcPoolValue(
    address tok,
    address afiContract
  ) external view returns (uint);

  function calculateBalanceOfUnderlying(
    address tok,
    address afiContract
  ) external view returns (uint);

  function calculatePoolInUsd(address afiContract) external view returns (uint);

  function afiSync(
    address afiContract,
    address tok,
    address aaveTok,
    address compV3Comet,
    address compTok
  ) external;

  function getPriceInUSDC(
    address tok
  ) external view returns (uint256, uint256);

  function validateAndGetDecimals(address tok) external view returns (uint256);

  function getStakedStatus(
    address aFiContract,
    address uToken
  ) external view returns (bool);

  function rearrange(address aFiContract,address[] memory underlyingTokens, uint256[] memory newProviders) external;

  function swapForOtherProduct(
    address afiContract,
    uint r,
    address oToken,
    uint deadline,
    uint[] memory minimumReturnAmount,
    address[] memory uToken
  ) external returns (uint256);

  function _withdrawAll(address afiContract, address tok) external returns(bool);
  function getAFiOracle() external view returns(address);

  function calculateRedemptionFromContract(
    address afiContract,
    address tok,
    uint256 r
  ) external view returns (uint256, bool, uint256, uint256, uint256);



  function tvlRead(
    address tok,
    address afiContract
  ) external view returns (uint, uint256);

  function getPreSwapDepositsTokens(
    address aFiContract,
    uint256 _cSwapCounter,
    address stableToken
  ) external view returns (uint256);

  function setPreDepositedInputToken(uint256 _cSwapCounter, uint256 _amount,address _oToken) external;
  function setPreDepositedInputTokenInRebalance(
    address aficontract,
    uint256 _cSwapCounter,
    uint256 _amount,
    address _oToken
  ) external;

  function convertInUSDAndTok(
    address tok,
    uint256 amt,
    bool usd
  ) external view returns (uint256);

  function calculateShares(
    address afiContract,
    uint256 amount,
    uint256 prevPool,
    uint256 _totalSupply,
    address iToken,
    uint256 currentDepositNAV
  ) external view returns (uint256 shares, uint256 newDepositNAV);

  function deletePreDepositedInputToken(
    address aFiContract,
    address oToken,
    uint256 currentCounter
  )external;

  function doSwapForThewhiteListRemoval(
    address tok,
    uint256 _cSwapCounter,
    address swapToken,
    uint256 deadline,
    uint256 minAmountOut
  ) external;
}

interface IPassiveRebal {
  function applyRebalForProportions(
    address _aFiContract,
    address _aFiManager,
    address _aFiStorage,
    address[] memory _tokens,
    uint256 strategy
  ) external returns (uint[] memory proportions, uint256 totalProp);

  function getPauseStatus() external returns (bool);

  function setPassiveRebalancedStatus(address aFiContract, bool status) external;

  function isAFiPassiveRebalanced(
    address aFiContract
  ) external returns (bool _isPassiveRebalanced);

  function getRebalStrategyNumber(address aFiContract) external returns (uint);

  function uniswapV3Oracle(
    address afiContract,
    address _tokenIn,
    address _tokenOut,
    uint _amountIn,
    uint _maxTime,
    address middleToken,
    uint256 minimumReturnAmount
  ) external returns (bytes memory swapParams);

  function updateuniPool(address tok, address midTok) external;

  function getPool(address tok, address midTok) external view returns (address);

  function upDateInputTokPool(address[] memory iToken, bytes memory uniData) external;

  function getPriceOracle(address tok) external view returns (address);

  function updateOracleData(
    address _uToken,
    address _oracleAddress
  ) external;

   function removeToken(
    address[] memory _nonOverlappingITokens,
    address token
  ) external pure returns (address[] memory);

}


/**
 * @title PassiveRebal.
 * @notice Interface of the Passive Rebalance contract.
 */
interface PassiveRebal {
  function applyRebalForProportions(
    address _aFiContract,
    address _aFiManager,
    address _aFiStorage,
    address[] memory _tokens,
    uint256 strategy
  ) external returns (uint[] memory proportions, uint256);

  function getPauseStatus() external returns (bool);

  function setPassiveRebalancedStatus(address aFiContract, bool status) external;

  function isAFiPassiveRebalanced(
    address aFiContract
  ) external returns (bool _isPassiveRebalanced);

  function getRebalStrategyNumber(address aFiContract) external returns (uint);
}

interface IAFiOracle {
  function uniswapV3Oracle(
    address afiContract,
    address _tokenIn,
    address _tokenOut,
    uint _amountIn,
    uint _maxTime,
    address middleToken,
    uint256 minimumReturnAmount
  ) external returns (bytes memory swapParams);
}

interface IAFiManager {
  function updateUTokenProportion(
    address aFiContract,
    address aFiStorage
  ) external returns (uint256[] memory);

  function inputTokenUSD(
    IAFi aFiContract,
    uint256 cSwapCounter,
    IAFiStorage _aFiStorage
  ) external view returns (uint256 totalPreDepositInUSD);

  function intializeData(
    address aFiContract,
    address[] memory underlyingTokens,
    uint[] memory underlyingProportion
  ) external;

  function uTokenslippage(
    address aFiContract,
    address uToken
  ) external view returns (uint uTokenSlippage);
}

/**
 * @title IAFi.
 * @notice Interface of the AToken.
 */
interface IAFi {

  struct UnderlyingData {
    address[] _underlyingTokens; //uTokens
    address[] _underlyingUniPoolToken; //uToken - MiddleToken
  }

  struct PoolsData {
    address[] _depositStableCoin;
    address[] _depositCoinOracle;
    bytes underlyingData;
    address[] _compound;
    address[] _aaveToken;
    address[] _priceOracles;
    uint[] _underlyingTokensProportion;
    address[] compoundV3Comet;
    uint _typeOfProduct;
  }


  /**
   * @param account Address of the account that paused the contract.
   * @param isDeposit True if we want to pause deposit otherwise false if want to pause withdraw.
   */
  event Paused(address account, bool isDeposit);
  /**
   * @param account Address of the account that unpaused the contract.
   * @param isDeposit True if we want to unpause deposit otherwise false if want to unpause withdraw.
   */
  event Unpaused(address account, bool isDeposit);

  /**
   * @notice Function to initialize the data, owner and afi token related data.
   * @dev the function should be called once only by factory
   * @param newOwner indicates the owner of the created afi product.
   * @param _name indicates the name of the afi Token
   * @param _symbol indicates symbol of the the afi Token.
   * @param data indicates the encoded data that follows the PoolsData struct format.
   * @param _isActiveRebalanced indicates the active rebalance status of the afi contract.
   * @param _aFiStorage indicates the afi storage contract address.
   */
  function initialize(
    address newOwner,
    string memory _name,
    string memory _symbol,
    bytes memory data,
    bool _isActiveRebalanced,
    IAFiStorage _aFiStorage,
    address[] memory _commonInputTokens
  ) external;

  /**
   * @notice Function to initialize accepted tokens in deposit and withdraw functions.
   * @dev  the function should be called once only by factory
   * @param iToken indicates the array of the accepted token addressess.
   */
  function initializeToken(
    address[] memory iToken,
    address[] memory _teamWallets,
    IPassiveRebal _rebalContract,
    bool _isPassiveRebalanced,
    address _aFiManager
  ) external;

  function getcSwapCounter() external view returns(uint256);

  /**
   * @notice Returns the array of underlying tokens.
   * @return uTokensArray Array of underlying tokens.
   */
  function getUTokens() external view returns (address[] memory uTokensArray);

  function swapViaStorageOrManager(
    address from,
    address to,
    uint amount,
    uint deadline,
    address midTok,
    uint minimumReturnAmount
  ) external returns (uint256);

  /**
   * @notice Returns the paused status of the contract.
   */
  function isPaused() external view returns (bool, bool);

  function getProportions()
    external
    view
    returns (uint[] memory, uint[] memory);

  /**
   * @notice Updates the pool data during Active Rebalance.
   * @param data that follows PoolsData format indicates the data of the token being rebalanced in Active Rebalance.
   */
  function updatePoolData(bytes memory data) external;

  function sendProfitOrFeeToManager(
    address wallet,
    uint profitShare,
    address oToken
  ) external;

  function totalSupply() external view returns (uint);

  function _supplyCompV3(address tok, uint amount) external;

  function _supplyAave(address tok, uint amount) external;

  function _supplyCompound(address tok, uint amount) external;

  function _withdrawAave(address tok, uint amount) external;

  function _withdrawCompoundV3(address tok, uint amount) external;

  function _withdrawCompound(address tok, uint amount) external;

  function getTVLandRebalContractandType()
    external
    view
  returns (uint256, address, uint256);

  function getInputToken() external view returns (address[] memory, address[] memory);

  function swap(
    address inputToken,
    address uTok,
    uint256 amountAsPerProportion,
    uint _deadline,
    address middleToken,
    uint256 minimumReturnAmount
  ) external returns (uint256);

  function updateDp(
    uint256[] memory _defaultProportion,
    uint256[] memory _uTokensProportion,
    uint256 activeStrategy
  ) external;

  function updateuTokAndProp(
    address[] memory _uTokens
  ) external;

  function underlyingTokensStaking(address[] memory _depositTokens) external returns(uint256 _totalProp);

  function depositUserNav(address user) external view returns (uint256);

  function setUnstakeData(uint256 totalQueuedShares) external returns (address[] memory, address[] memory, uint256, uint256);

  function isOTokenWhitelisted(address oToken) external view returns (bool);

  function validateWithdraw(address user, address oToken, uint256 _shares) external view returns( uint ibalance);

  function updateLockedTokens(address user, uint256 amount, bool lock, bool updateBalance) external;

  function getVaultDetails() external view returns(string memory, string memory);

  function checkTVL(bool _updateTVL) external;

  function updateInputTokens(address[] memory _inputTokens) external;
}

interface IUniswapOracleV3 {
  function PERIOD() external returns (uint256);
  function factory() external returns (address);
  function getTotalProfit() external view returns (uint256);
  function getDaoProfit() external view returns (uint256);
  function update(address _tokenIn, address _tokenOut) external;

  function quotePrice(IAFi aFiContract,address _tokenIn, address _depositToken, uint256 _amount) external view returns (uint256 price);


  function consult(
    address _tokenIn,
    uint256 _amountIn,
    address _tokenOut
  ) external view returns (uint256 _amountOut);

  function estimateAmountOut(
    address tokenIn,
    uint128 amountIn,
    address tokenOut
  ) external view returns (uint amountOut);

  function estimateAmountOutMin(
    address tokenIn,
    uint128 amountIn,
    address tokenOut,
    address pool
  ) external view returns (uint amountOut);

  function updateAndConsult(
    address _tokenIn,
    uint256 _amountIn,
    address _tokenOut
  ) external returns (uint256 _amountOut);

  function checkUnderlyingPool(address token) external view returns (bool hasPool);
  function getStalePriceDelay(address aFiContract, address uToken) external view returns(uint256);
  function getPriceAndDecimals(address aFiContract, address uToken, address feed) external view returns(int256 , uint8 );
  function getPriceInUSDC(address tok) external view returns (uint256, uint256);
  function getMidToken(address tok) external view returns (address);
  function updateMidToken(address[] memory tok, address[] memory midTok) external;
  function setRedeemData(address _oToken, uint256 _batchWithdrawCounter, uint256 _totalShares, uint256 _oTokenUnits) external;
  function getControllers(address afiContract) external view returns(address, address);
}


/// @title Math library for computing sqrt prices from ticks and vice versa
/// @notice Computes sqrt price for ticks of size 1.0001, i.e. sqrt(1.0001^tick) as fixed point Q64.96 numbers. Supports
/// prices between 2**-128 and 2**128
library TickMath {
    error T();
    error R();

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
        unchecked {
            uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
            if (absTick > uint256(int256(MAX_TICK))) revert T();

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
    }

    /// @notice Calculates the greatest tick value such that getRatioAtTick(tick) <= ratio
    /// @dev Throws in case sqrtPriceX96 < MIN_SQRT_RATIO, as MIN_SQRT_RATIO is the lowest value getRatioAtTick may
    /// ever return.
    /// @param sqrtPriceX96 The sqrt ratio for which to compute the tick as a Q64.96
    /// @return tick The greatest tick for which the ratio is less than or equal to the input ratio
    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        unchecked {
            // second inequality must be < because the price can never reach the price at the max tick
            if (!(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO)) revert R();
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

            tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
        }
    }
}
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
        unchecked {
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
            uint256 twos = (0 - denominator) & denominator;
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
        unchecked {
            result = mulDiv(a, b, denominator);
            if (mulmod(a, b, denominator) > 0) {
                require(result < type(uint256).max);
                result++;
            }
        }
    }
}

library OracleLibrary {
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
}

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
/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
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
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
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
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

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

        function safeTransfer(
            IERC20 token,
            address to,
            uint256 value
        ) internal {
            _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
        }

        function safeTransferFrom(
            IERC20 token,
            address from,
            address to,
            uint256 value
        ) internal {
            _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
        }

        /**
        * @dev Deprecated. This function has issues similar to the ones found in
        * {IERC20-approve}, and its usage is discouraged.
        *
        * Whenever possible, use {safeIncreaseAllowance} and
        * {safeDecreaseAllowance} instead.
        */
        function safeApprove(
            IERC20 token,
            address spender,
            uint256 value
        ) internal {
            // safeApprove should only be called when setting an initial allowance,
            // or when resetting it to zero. To increase and decrease it, use
            // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
            require(
                (value == 0) || (token.allowance(address(this), spender) == 0),
                "SafeERC20: approve from non-zero to non-zero allowance"
            );
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
        }

        function safeIncreaseAllowance(
            IERC20 token,
            address spender,
            uint256 value
        ) internal {
            uint256 newAllowance = token.allowance(address(this), spender) + value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }

        function safeDecreaseAllowance(
            IERC20 token,
            address spender,
            uint256 value
        ) internal {
            unchecked {
                uint256 oldAllowance = token.allowance(address(this), spender);
                require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
                uint256 newAllowance = oldAllowance - value;
                _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
            }
        }

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
            require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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

            bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
            if (returndata.length > 0) {
                // Return data is optional
                require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
            }
        }
    }

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

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address internal _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    // /**
    //  * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
    //  * Can only be called by the current owner.
    //  */
    // function transferOwnership(address newOwner) public virtual override onlyOwner {
    //     _pendingOwner = newOwner;
    //     emit OwnershipTransferStarted(owner(), newOwner);
    // }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() external {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }
}

contract OwnableDelayModule is Ownable2Step {
  address internal delayModule;

  constructor() {
    delayModule = msg.sender;
  }

  function isDelayModule() internal view {
    require(msg.sender == delayModule, "NA");
  }

  function setDelayModule(address _delayModule) external {
    isDelayModule();
    require(_delayModule != address(0), "ODZ");
    delayModule = _delayModule;
  }

  function getDelayModule() external view returns (address) {
    return delayModule;
  }

  /**
   * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public override {
    isDelayModule();
    _pendingOwner = newOwner;
    emit OwnershipTransferStarted(owner(), newOwner);
  }
}

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 roundId) external view returns (int256);
  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

interface AggregatorV2V3Interface is AggregatorInterface
{
}


interface AggregatorV3Interface {

  struct Phase {
    uint16 id;
    AggregatorV2V3Interface aggregator;
  }

  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  
  /**
   * @notice returns the current phase's aggregator address.
   */
  function aggregator()
    external
    view
    returns (address);

  function minAnswer() external view returns(uint);

  function maxAnswer() external view returns(uint);

}

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
}



/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}

struct RewardOwed {
  address token;
  uint owed;
}

interface ICompRewardV3 {
  function getRewardOwed(
    address comet,
    address account
  ) external returns (RewardOwed memory);

  function claim(address comet, address src, bool shouldAccrue) external;
}

contract AFiOracle is ReentrancyGuard, OwnableDelayModule {
  using SafeCast for uint256;
  using SafeERC20 for IERC20;

  IAFiStorage internal aFiStorage;

  mapping(address => mapping(address => uint24)) public _fee;
  uint32 internal secondsAgo = 900;
  uint256 internal csFee = 5e20;
  uint256 internal csFeeUpperLimit = 5e21;

  address internal rebal;
  uint256 internal stalePricewindowLimit = 1 hours;
  uint internal daoProfit = 6;
  uint internal totalProfit = 10;
  bool public paused;

  address[] internal token;
  address[] internal uTokens;

  address internal afiManager;
  mapping(address => address) internal cumulativeSwapControllers;
  mapping(address => address) internal unstakingController;

  address internal constant UNISWAP_FACTORY =
    0x1F98431c8aD98523631AE4a59f267346ea31F984;
  address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address private constant USDC_ORACLE = 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6;
  address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  ICompRewardV3 internal constant COMPV3_REWARD =
    ICompRewardV3(0x1B0e765F6224C21223AeA2af16c1C46E38885a40);

  struct SwapParameters {
    address afiContract;
    address oToken;
    uint256 cSwapFee;
    uint256 cSwapCounter;
    address[] depositTokens;
    uint256[] minimumReturnAmount;
    uint256[] iMinimumReturnAmount; // minimum amount out expcted after swaps For deposit tokens
    address[] underlyingTokens;
    uint256[] newProviders;
    uint _deadline;
    address[] cometToClaim;
    address[] cometRewardTokens;
    uint256[] rewardTokenMinReturnAmounts;
  }

  struct TokenInfo {
    address[] tokens;
    address[] uTokens;
    uint256[] uTokenProportions;
    uint256[] defaultProportion;
  }

  struct WithdrawQueueDetails {
    mapping(address => mapping(address => mapping(uint256 => uint256))) queuedShares;
  }

  mapping(address => WithdrawQueueDetails) internal userOtokenLiability;
  mapping(address => uint) internal stalePriceDelay;
  mapping(address => uint256) internal lastSwapTime;
  mapping(address => uint) internal swapPeriod;
  mapping(address => address) internal underlyingUniPoolToken;
  mapping(address => mapping(address => mapping(uint => uint))) public totalShares;
  mapping(address => mapping(address => mapping(uint => uint))) public outputTokenUnits;
  mapping(address => uint256) public batchWithdrawCounter;
  mapping(address => mapping(uint => uint)) public totalQueuedShares;
  mapping(address => mapping(address => uint)) internal teamWalletsProfit;

  event ProfitShareUpdated(uint daoProfit, uint totalProfit);
  event ProfitShareDistributed(
    address indexed aFiContract,
    address indexed teamWallet,
    uint256 amount
  );
  event WithdrawQueue(address indexed user, uint256 shares, address indexed oToken);
  event WithdrawDeQueue(address indexed user, uint256 shares);

  /**
   * @notice To initialize/deploy the AFIOracle contract.
   * @param passiveRebalContract Address of AFiPassiveRebalStrategies contract.
   */
  constructor(address passiveRebalContract) {
    addressZero(passiveRebalContract);
    rebal = passiveRebalContract;
  }

  /**
   * @param account Address of the account that paused the contract.
   */
  event Paused(address account);
  /**
   * @param account Address of the account that unpaused the contract.
   */
  event Unpaused(address account);

  modifier onlySpecificAddress(address _addr) {
    require(msg.sender == _addr, "AFO04"); //solhint-disable-line reason-string
    _;
  }

  function getMidToken(address tok) external view returns (address) {
    return underlyingUniPoolToken[tok];
  }

  function addressZero(address add1) internal pure {
    require(add1 != address(0), "AF03");
  }

  function updateAFiManager(address _afiManager) external onlyOwner {
    addressZero(_afiManager);
    afiManager = _afiManager;
  }

  function getTotalProfit() external view returns (uint256) {
    return totalProfit;
  }

  function getDaoProfit() external view returns (uint256) {
    return daoProfit;
  }

  function updateMidToken(address[] memory tok, address[] memory midTok) external {
    require(msg.sender == owner() || msg.sender == afiManager, "NA");
    for (uint i; i < tok.length; i++) {
      addressZero(tok[i]);
      addressZero(midTok[i]);
      underlyingUniPoolToken[tok[i]] = midTok[i];
    }
  }

  modifier contractUnpaused() {
    require(!paused, "AM08");
    _;
  }

  modifier contractPaused() {
    require(paused, "AM09");
    _;
  }

  function greaterComparison(uint256 valA, uint256 valB) internal pure {
    require(valA >= valB, "AO24");
  }

  /**
   * @notice To pause the contract.
   * @dev Requirements: It can only be invoked by owner.
   */
  function pause() external contractUnpaused onlyOwner {
    paused = true;
    emit Paused(msg.sender);
  }

  /**
   * @notice To resume/unpause the contract.
   * @dev Requirements: It can only be invoked by the owner.
   */
  function unPause() external contractPaused onlyOwner {
    paused = false;
    emit Unpaused(msg.sender);
  }

  function setAFiStorage(address _storage) external onlyOwner {
    addressZero(_storage);
    aFiStorage = IAFiStorage(_storage);
  }

  /**
   * @notice Updates the address of the cumulative swap wallet for aFi Vault.
   * @dev Only the contract owner can call this function.
   * @param afiContract Vault address
   * @param _cumulativeSwapController New address for the cumulative swap wallet for afiContract vault.
   * @param _unstakingController New address for the unstaking controller wallet for afiContract vault.
   */
  function updateVaultControllers(
    address afiContract,
    address _cumulativeSwapController,
    address _unstakingController
  ) external onlyOwner {
    cumulativeSwapControllers[afiContract] = _cumulativeSwapController;
    unstakingController[afiContract] = _unstakingController;
  }

  function getControllers(
    address afiContract
  ) external view returns (address, address) {
    return (cumulativeSwapControllers[afiContract], unstakingController[afiContract]);
  }

  /**
   * @notice Executes cumulative token swaps and updates staking for underlying tokens.
   * @param params The struct containing swap parameters.
   */
  function cumulativeSwap(
    SwapParameters memory params
  ) external onlySpecificAddress(cumulativeSwapControllers[params.afiContract]) {
    require(
      block.timestamp - lastSwapTime[params.afiContract] >= swapPeriod[params.afiContract],
      "Swap period not elapsed"
    );

    TokenInfo memory tokenInfo;
    (params.depositTokens,) = IAFi(params.afiContract).getInputToken();
    params.cSwapCounter = IAFi(params.afiContract).getcSwapCounter();
    tokenInfo.uTokens = IAFi(params.afiContract).getUTokens();

    if (params.cometRewardTokens.length > 0)
      claimCompV3Rewards(
        params.afiContract,
        params.cometToClaim,
        params.cometRewardTokens,
        params.rewardTokenMinReturnAmounts,
        params.oToken,
        params._deadline
      );

    uint256 totalProp = IAFi(params.afiContract).underlyingTokensStaking(params.depositTokens);
    (tokenInfo.uTokenProportions, tokenInfo.defaultProportion) = IAFi(params.afiContract)
      .getProportions();
    performTokenSwaps(params, tokenInfo, totalProp);

    aFiStorage.rearrange(params.afiContract, params.underlyingTokens, params.newProviders);
    // Update last swap time after all operations are complete
    lastSwapTime[params.afiContract] = block.timestamp;
  }

  function claimCompV3Rewards(
    address afiContract,
    address[] memory cometToClaim,
    address[] memory cometRewardTokens,
    uint256[] memory rewardTokenMinReturnAmounts,
    address oToken,
    uint256 _deadline
  ) internal {
    uint256 balToSwap;
    address tok;
    for (uint8 i = 0; i < uint8(cometToClaim.length); i++) {
      tok = cometRewardTokens[i];
      balToSwap = IERC20(tok).balanceOf(afiContract);

      COMPV3_REWARD.claim(cometToClaim[i], afiContract, true);
      if (IERC20(tok).balanceOf(afiContract) > balToSwap) {
        balToSwap = IERC20(tok).balanceOf(afiContract) - balToSwap;
        doSwap(
          afiContract,
          tok,
          oToken,
          balToSwap,
          _deadline,
          WETH,
          rewardTokenMinReturnAmounts[i]
        );
      }
    }
  }

  function performTokenSwaps(
    SwapParameters memory params,
    TokenInfo memory tokenInfo,
    uint256 totalProp
  ) internal {
    uint256 temp;
    for (uint256 j = 0; j < params.depositTokens.length; j++) {
      (temp) = aFiStorage.getPreSwapDepositsTokens(
        params.afiContract,
        params.cSwapCounter,
        params.depositTokens[j]
      );
      if (params.depositTokens[j] != params.oToken && temp > 0) {
        doSwap(
          params.afiContract,
          params.depositTokens[j],
          params.oToken,
          temp,
          params._deadline,
          WETH,
          params.iMinimumReturnAmount[j]
        );
      }
    }
    // Assuming `redeemTxFee` and `csFee` are defined and handled elsewhere
    require(
      redeemTxFee(params.afiContract, params.oToken, params.cSwapFee) <= csFee,
      "AFO01"
    );

    swapIntoUnderlying(params, tokenInfo, totalProp);
  }

  function swapIntoUnderlying(
    SwapParameters memory params,
    TokenInfo memory tokenInfo,
    uint256 _totalProp
  ) internal {
    uint256 tempBalance;
      uint256[] memory tokenProportions = tokenInfo.uTokenProportions;

      // Check for passive rebalance status and adjust token proportions if necessary
      if (
        IPassiveRebal(rebal).isAFiPassiveRebalanced(params.afiContract) &&
        IPassiveRebal(rebal).getRebalStrategyNumber(params.afiContract) == 0
      ) {
        tokenProportions = tokenInfo.defaultProportion;
        _totalProp = 0;
        for(uint i =0; i< tokenProportions.length; i++){
          _totalProp += tokenProportions[i];
        }
      }

      tempBalance = IERC20(params.oToken).balanceOf(params.afiContract);
      for (uint i = 0; i < tokenInfo.uTokens.length; i++) {
        // Perform swap if conditions are met
        if (tokenProportions[i] >= 1 && tempBalance > 0) {

          doSwap(
            params.afiContract,
            params.oToken,
            tokenInfo.uTokens[i],
            (tempBalance * tokenProportions[i]) / _totalProp,
            params._deadline,
            address(0), // Assuming this is intended as the recipient or a swap parameter
            params.minimumReturnAmount[i]
          );
        }
      }
  }

  /**
   * @notice Computes the redemption fee for a transaction.
   * @dev This function is internal and computes the redemption fee based on the provided parameters.
   * @param afiContract The address of the AFi contract.
   * @param _inputToken The address of the input token for the transaction.
   * @param cSwapFee The cumulative swap fee to calculate the redemption fee from.
   * @return redFee The computed redemption fee.
   */
  function redeemTxFee(
    address afiContract,
    address _inputToken,
    uint256 cSwapFee
  ) internal returns (uint256 redFee) {
    if (cSwapFee > 0) {
      (uint256 price, uint256 decimal) = getPriceInUSDC(
        _inputToken
      );
      uint iTokenDecimal = 18 - IERC20(_inputToken).decimals();
      redFee = (
        ((cSwapFee)*price*(10 ** iTokenDecimal))/(
          decimal
        )
      );
      IERC20(_inputToken).safeTransferFrom(
        afiContract,
        cumulativeSwapControllers[afiContract],
        cSwapFee
      );
    }
  }

  /**
   * @notice Queues a withdrawal for a user.
   * @param afiContract The address of the AFi contract.
   * @param _shares The amount of shares to withdraw.
   * @param oToken The address of the output token.
   */
  function queueWithdraw(
    address afiContract,
    uint _shares,
    address oToken
  ) external nonReentrant {
    IAFi(afiContract).validateWithdraw(msg.sender, oToken, _shares);
    userOtokenLiability[msg.sender].queuedShares[afiContract][oToken][
      batchWithdrawCounter[afiContract]
    ] += _shares;
    totalShares[afiContract][oToken][batchWithdrawCounter[afiContract]] += _shares; //in AFi Token
    totalQueuedShares[afiContract][batchWithdrawCounter[afiContract]] += _shares;

    updateLockedTokensInVault(afiContract, _shares, true, false);

    emit WithdrawQueue(msg.sender, _shares, oToken);
  }

  function updateLockedTokensInVault(address afiContract, uint256 _shares, bool status, bool toLock) internal {
    IAFi(afiContract).updateLockedTokens(msg.sender, _shares, status, toLock);
  }

  /**
   * @notice Retrieves the queued shares for a user.
   * @param user The address of the user.
   * @param afiContract The address of the AFi contract.
   * @param oToken The address of the output token.
   * @return The number of queued shares for the user.
   */
  function getUserQueuedShares(
    address user,
    address afiContract,
    address oToken,
    uint256 bCounter
  ) external view returns (uint256) {
    return userOtokenLiability[user].queuedShares[afiContract][oToken][bCounter];
  }

  /**
   * @notice Removes queued withdrawal for a users.
   * @param afiContract The address of the AFi contract.
   * @param oToken The address of the output token.
   */
  function unqueueWithdraw(address afiContract, address oToken) external nonReentrant {
    uint256 userShares = userOtokenLiability[msg.sender].queuedShares[afiContract][
      oToken
    ][batchWithdrawCounter[afiContract]];
    
    totalShares[afiContract][oToken][batchWithdrawCounter[afiContract]] -= userShares; //in AFi Token
    
    deleteUserOTokenLiability(afiContract, oToken, batchWithdrawCounter[afiContract]);
    
    totalQueuedShares[afiContract][batchWithdrawCounter[afiContract]] -= userShares;
    
    updateLockedTokensInVault(afiContract, userShares, false, false);
    emit WithdrawDeQueue(msg.sender, userShares);
  }

  function deleteUserOTokenLiability(address afiContract, address _oToken, uint256 bCounter) internal {
    delete userOtokenLiability[msg.sender].queuedShares[afiContract][_oToken][bCounter];
  }

  // call updateTVL before this function
  /**
   * @notice Performs unstaking for queued withdrawals.
   * @param afiContract The address of the AFi contract.
   * @param oToken The address of the output token.
   * @param deadline The deadline for the transaction.
   * @param minimumReturnAmount An array of minimum return amounts.
   * @param minOutForiToken An array of minimum output amounts for iToken.
   */
  function unstakeForQueuedWithdrawals(
    address afiContract,
    address oToken,
    uint256 deadline,
    uint[] memory minimumReturnAmount,
    uint256[] memory minOutForiToken,
    bool _updateTVL
  ) external onlySpecificAddress(unstakingController[afiContract]) {
    IAFi(afiContract).checkTVL(_updateTVL);
    require(IAFi(afiContract).isOTokenWhitelisted(oToken), "AFO02");
    uint256 pool;
    uint256 _totalSupply;
    (token, uTokens, pool, _totalSupply) = IAFi(afiContract).setUnstakeData(
      totalQueuedShares[afiContract][batchWithdrawCounter[afiContract]]
    );
    uint toSwap;
    if (totalQueuedShares[afiContract][batchWithdrawCounter[afiContract]] > 0) {
      toSwap =
        (pool * (totalQueuedShares[afiContract][batchWithdrawCounter[afiContract]])) /
        (_totalSupply);
      toSwap = aFiStorage.swapForOtherProduct(
        afiContract,
        toSwap,
        oToken,
        deadline,
        minimumReturnAmount,
        uTokens
      );
    }

    swapAndTransfer(afiContract, oToken, toSwap, minOutForiToken, deadline);
    delete totalQueuedShares[afiContract][batchWithdrawCounter[afiContract]];
    batchWithdrawCounter[afiContract]++;
  }

  function swapAndTransfer(
    address afiContract,
    address oToken,
    uint256 toSwap,
    uint256[] memory minOutForiToken,
    uint256 deadline
  ) internal {
    uint256 depositTokensToSwap;
    uint256 toDeduct;
    for (uint i; i < token.length; i++) {
      if (
        token[i] != oToken &&
        totalShares[afiContract][token[i]][batchWithdrawCounter[afiContract]] > 0
      ) {
        depositTokensToSwap =
          (toSwap *
            (totalShares[afiContract][token[i]][batchWithdrawCounter[afiContract]])) /
          (totalQueuedShares[afiContract][batchWithdrawCounter[afiContract]]);
        if (depositTokensToSwap > 0) {
          toDeduct += depositTokensToSwap;
          depositTokensToSwap = doSwap(
            afiContract,
            oToken,
            token[i],
            depositTokensToSwap,
            deadline,
            WETH,
            minOutForiToken[i]
          );
        }
        if (IERC20(token[i]).balanceOf(afiContract) > 0) {
          IERC20(token[i]).safeTransferFrom(
            afiContract,
            address(this),
            depositTokensToSwap
          );
        }
        outputTokenUnits[afiContract][token[i]][
          batchWithdrawCounter[afiContract]
        ] = depositTokensToSwap;
      }
    }

    for (uint j; j < token.length; j++) {
      if (
        token[j] == oToken &&
        totalShares[afiContract][token[j]][batchWithdrawCounter[afiContract]] > 0
      ) {
        depositTokensToSwap = toSwap - toDeduct;
        IERC20(token[j]).safeTransferFrom(
          afiContract,
          address(this),
          depositTokensToSwap
        );
        outputTokenUnits[afiContract][oToken][
          batchWithdrawCounter[afiContract]
        ] = depositTokensToSwap;
        break;
      }
    }
  }

  function doSwap(
    address afiContract,
    address tokenIn,
    address tokenOut,
    uint amt,
    uint deadline,
    address middleTok,
    uint256 minOut
  ) internal returns (uint256) {
    return IAFi(afiContract).swap(tokenIn, tokenOut, amt, deadline, middleTok, minOut);
  }

  /**
   * @notice Redeems tokens for a user based on their queued shares and batch withdrawal index.
   * @param aFiContract The address of the AFi contract.
   * @param _iTokens An array of token addresses to redeem.
   * @param batchWithdrawIndex The batch withdrawal index.
   */
  function redeem(
    IAFi aFiContract,
    address[] memory _iTokens,
    uint256 batchWithdrawIndex
  ) external {
    require(batchWithdrawIndex < batchWithdrawCounter[address(aFiContract)], "AO01");
    uint redemptionValue;
    uint256 userDepositedAFiInOToken;
    uint256 userShares;
    uint256 userDepositNav; //Calculation for the deposit token value
    for (uint i = 0; i < _iTokens.length; i++) {
      userShares = userOtokenLiability[msg.sender].queuedShares[address(aFiContract)][
        _iTokens[i]
      ][batchWithdrawIndex];
      userDepositNav = aFiContract.depositUserNav(msg.sender);
      aFiContract.updateLockedTokens(msg.sender, userShares, false, true);
      if (userShares > 0) {
        redemptionValue = ((userShares *
          (outputTokenUnits[address(aFiContract)][_iTokens[i]][batchWithdrawIndex])) /
          (totalShares[address(aFiContract)][_iTokens[i]][batchWithdrawIndex]));

        (uint256 price, uint256 multiplier) = getPriceInUSDC(
          _iTokens[i]
        );
        uint8 decimals = 18 - IERC20(_iTokens[i]).decimals();
        userDepositedAFiInOToken =
          (userDepositNav * (userShares) * (multiplier)) /
          (price * (10 ** decimals) * 10000);

        if (redemptionValue > userDepositedAFiInOToken) {
          teamWalletsProfit[address(aFiContract)][_iTokens[i]] +=
            ((redemptionValue - userDepositedAFiInOToken) * (totalProfit)) /
            (100);
          redemptionValue -=
            ((redemptionValue - userDepositedAFiInOToken) * (totalProfit)) /
            (100);
        }
        deleteUserOTokenLiability(address(aFiContract), _iTokens[i], batchWithdrawIndex);
        IERC20(_iTokens[i]).safeTransfer(msg.sender, redemptionValue);
      }
    }
  }

  /**
   * @notice Returns the Swap Period for a specific aFi contract.
   * @param afiContract Address of the aFi contract.
   * @return uint256 Swap Period in seconds.
   */
  function getSwapPeriod(address afiContract) external view returns (uint) {
    return swapPeriod[afiContract];
  }

  /**
   * @notice Updates the Swap Period for a specific aFi contract.
   * @dev Only the contract owner can call this function.
   * @param afiContract Address of the aFi contract.
   * @param _newSwapPeiod New Swap Period in seconds.
   */
  function updateSwapPeriod(
    address afiContract,
    uint _newSwapPeiod
  ) external onlyOwner {
    swapPeriod[afiContract] = _newSwapPeiod;
  }

  /**
   * @notice Returns the timestamp of the last cumulative swap execution.
   * @param afiContract Address of the aFi contract.
   * @return uint256 Timestamp of the last cumulative swap.
   */
  function getLastSwapTime(address afiContract) external view returns (uint256) {
    return lastSwapTime[afiContract];
  }

  /**
   * @notice Sets the cumulative swap fee upper limit.
   * @dev Only the contract owner can call this function.
   * @param _csFeeUpperLimit New cumulative swap fee maximum limit.
   */
  function setcsFeeUpperLimit(
    uint256 _csFeeUpperLimit
  ) external onlyOwner {
    csFeeUpperLimit = _csFeeUpperLimit;
  }

  function getFeeDetails()
    external
    view
    returns (uint256, uint256)
  {
    return (csFee, csFeeUpperLimit);
  }

  /**
   * @notice Sets the cumulative swap fee.
   * @dev Only the contract owner can call this function.
   * @param _csFee New cumulative swap fee.
   */
  function setcsFee(uint256 _csFee) external onlyOwner {
    require(_csFee <= csFeeUpperLimit, "AFO111");
    csFee = _csFee;
  }

  /**
   * @notice To get the number of USDC tokens for aFi vault.
   * @param tokenIn Address of underlying token from set.
   * @param amountIn Amount of underlying token
   * @param tokenOut Address of the underlying token for aFi contract(USDC).
   */
  function estimateAmountOut(
    address tokenIn,
    uint128 amountIn,
    address tokenOut
  ) public view returns (uint amountOut) {
    address _pool = IUniswapV3Factory(UNISWAP_FACTORY).getPool(
      tokenOut,
      tokenIn,
      _fee[tokenIn][tokenOut]
    );
    addressZero(_pool);
    amountOut = getAmountOutMin(tokenIn, amountIn, tokenOut, _pool);
  }

  function estimateAmountOutMin(
    address tokenIn,
    uint128 amountIn,
    address tokenOut,
    address poolToConsider
  ) public view returns (uint amountOut) {
    addressZero(poolToConsider);
    amountOut = getAmountOutMin(tokenIn, amountIn, tokenOut, poolToConsider);
  }

  function getAmountOutMin(
    address tokenIn,
    uint128 amountIn,
    address tokenOut,
    address poolToConsider
  ) internal view returns (uint amountOut) {
    uint32[] memory secondsAgos = new uint32[](2);
    secondsAgos[0] = secondsAgo;
    secondsAgos[1] = 0;

    // int56 since tick * time = int24 * uint32
    // 56 = 24 + 32
    (int56[] memory tickCumulatives, ) = IUniswapV3Pool(poolToConsider).observe(
      secondsAgos
    );

    int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

    // int56 / uint32 = int24
    // int24 tick = int24(tickCumulativesDelta / secondsAgo);
    int24 tick = int24( tickCumulativesDelta / int56( int32(secondsAgo) ) );
    // Always round to negative infinity
    /*
      int doesn't round down when it is negative

      int56 a = -3
      -3 / 10 = -3.3333... so round down to -4
      but we get
      a / 10 = -3

      so if tickCumulativeDelta < 0 and division has remainder, then round
      down
      */
    if (tickCumulativesDelta < 0 && (tickCumulativesDelta % int56( int32(secondsAgo)) != 0)) {
      tick--;
    }

    amountOut = OracleLibrary.getQuoteAtTick(tick, amountIn, tokenIn, tokenOut);
  }

  /**
   * @notice Increases the observation cardinality for a Uniswap V3 pool.
   * @dev This function is used to adjust the observation cardinality for improved price accuracy.
   * @param _pool Address of the Uniswap V3 pool.
   * @param observationCardinalityNext New observation cardinality to set.
   */
  function increaseObservation(
    address _pool,
    uint16 observationCardinalityNext
  ) external {
    IUniswapV3Pool(_pool).increaseObservationCardinalityNext(
      observationCardinalityNext
    );
  }

  /**
   * @notice Updates the time interval in seconds for retrieving historical prices.
   * @dev Only the contract owner can call this function.
   * @param sec New time interval in seconds.
   */
  function updateSecAgo(uint32 sec) external onlyOwner {
    secondsAgo = sec;
  }

  function getSecAgo() external view returns (uint256) {
    return secondsAgo;
  }

  /**
   * @notice Updates the global fees for Uniswap V3 pool operations.
   * @dev Only the contract owner can call this function.
   * @param fees New fee value to set for the token pair.
   */
  function updateGlobalFees(
    address[] memory tokenA,
    address[] memory tokenB,
    uint24[] memory fees
  ) external onlyOwner {
    for (uint i; i < fees.length; i++) {
      _fee[tokenA[i]][tokenB[i]] = fees[i];
    }
  }

  /**
   * @notice Initializes the stale price delay for multiple underlying tokens.
   * @dev Only the contract owner can call this function.
   * @param underlyingTokens Array of underlying tokens.
   * @param _stalePriceDelay Array of stale price delays corresponding to each underlying token.
   */
  function intializeStalePriceDelay(
    address[] memory underlyingTokens,
    uint256[] memory _stalePriceDelay
  ) external onlyOwner {
    require(underlyingTokens.length == _stalePriceDelay.length, "AFO011");
    for (uint i = 0; i < underlyingTokens.length; i++) {
      setSPDelay(underlyingTokens[i], _stalePriceDelay[i]);
    }
  }

  /**
   * @notice Sets the stale price delay for a specific underlying token.
   * @dev Only the contract owner can call this function, and the current delay must be greater than 1 hour.
   * @param uToken Address of the underlying token.
   * @param _stalePriceDelay New stale price delay to set.
   */
  function setStalePriceDelay(
    address uToken,
    uint256 _stalePriceDelay
  ) external onlyOwner {
    setSPDelay(uToken, _stalePriceDelay);
  }

  function setSPDelay(
    address uToken,
    uint256 _stalePriceDelay
  ) internal {
    require(_stalePriceDelay > stalePricewindowLimit, "AFO01");
    stalePriceDelay[uToken] = _stalePriceDelay;
  }

  function setstalepriceWindowLimit(uint256 _stalePWindow) external onlyOwner {
    stalePricewindowLimit = _stalePWindow;
  }

  function getstalepriceWindowLimit() external view returns (uint256) {
    return stalePricewindowLimit;
  }

  /**
   * @notice Gets the stale price delay for a specific underlying token.
   * @param uToken Address of the underlying token.
   * @return The stale price delay for the specified underlying token.
   */
  function getStalePriceDelay(
    address uToken
  ) external view returns (uint256) {
    return stalePriceDelay[uToken];
  }

  /**
   * @notice Gets the price and decimals of a specified token from a price feed.
   * @param uToken Address of the underlying token.
   * @param feed Address of the price feed.
   * @return The price and decimals of the specified token.
   */
  function getPriceAndDecimals(
    address uToken,
    address feed
  ) public view returns (int256, uint8) {
    (, int256 inPrice, , uint256 updatedAt, ) = AggregatorV3Interface(feed)
      .latestRoundData();

    address currentPhaseAggregator = AggregatorV3Interface(feed).aggregator();

    uint256 minPrice = AggregatorV3Interface(currentPhaseAggregator).minAnswer();

    uint256 maxPrice = AggregatorV3Interface(currentPhaseAggregator).maxAnswer();

    if (uint(inPrice) >= maxPrice || uint(inPrice) <= minPrice) revert("AFOOO");

    uint8 decimals = AggregatorV3Interface(feed).decimals();
    greaterComparison(
      updatedAt,
      block.timestamp - stalePriceDelay[uToken]
    );
    greaterComparison(uint(inPrice), 0);
    return (inPrice, decimals);
  }

  function getPriceOracleRebal(address tok) internal view returns(address){
    return IPassiveRebal(rebal).getPriceOracle(tok);
  }

  /**
   * @notice Checks if the given token is USDC and retrieves its price and multiplier.
   * @param tok Address of the token to check price .
   * @return The token's price and multiplier.
   */
  function getPriceInUSDC(
    address tok
  ) public view returns (uint256, uint256) {
    uint256 multiplier = 1e6;
    uint256 price;
    // Transfer Aarna Token to investor
    if (tok != USDC) {
      address oracle = getPriceOracleRebal(tok);
      if (oracle != address(0)) {
        (int256 tokPrice, ) = getPriceAndDecimals(tok, oracle);
        (int256 usdcPrice, ) = getPriceAndDecimals(USDC, USDC_ORACLE);
        price = ((SafeCast.toUint256(tokPrice) * (10 ** 6)) /
          SafeCast.toUint256((usdcPrice)));
      } else {
        uint256 uTokensDecimal = IERC20(tok).decimals();
        uint256 amountIn = 10 ** uTokensDecimal;
        price = getMinimumAmountOut(tok, amountIn, USDC, address(0));
      }
    } else {
      price = 1;
      multiplier = 1;
    }
    return (price, multiplier);
  }

  function updateRebalContract(address _rebal) external onlyOwner {
    addressZero(_rebal);
    rebal = _rebal;
  }

  function getUniPool(address tok, address poolToken) internal view returns(address){
    return IPassiveRebal(rebal).getPool(
      tok,
      poolToken
    );
  }

  function getMinimumAmountOut(
    address _tokenIn,
    uint256 _amountIn,
    address _tokenOut,
    address _uniPool
  ) internal view returns (uint256 amountOut) {
    address uniPool;

    if (_tokenIn == (WETH) || _tokenOut == (WETH)) {
      amountOut = estimateAmountOut(_tokenIn, uint128(_amountIn), _tokenOut);
    } else if (
      _tokenIn == underlyingUniPoolToken[_tokenIn] ||
      _tokenOut == underlyingUniPoolToken[_tokenIn]
    ) {      
      uniPool = getUniPool(_tokenIn, underlyingUniPoolToken[_tokenIn]);
      if (_uniPool != address(0)) {
        uniPool = _uniPool;
      }
      amountOut = estimateAmounts(
        _tokenIn,
        _amountIn,
        underlyingUniPoolToken[_tokenIn],
        uniPool
      );
    } else {
      uniPool = getUniPool(_tokenIn, underlyingUniPoolToken[_tokenIn]);
      address unipoolOut = getUniPool(_tokenOut, underlyingUniPoolToken[_tokenIn]);
      
      amountOut = estimateAmounts(
        _tokenIn,
        _amountIn,
        underlyingUniPoolToken[_tokenIn],
        uniPool
      );
      amountOut = estimateAmounts(
        underlyingUniPoolToken[_tokenIn],
        amountOut,
        _tokenOut,
        unipoolOut
      );
    }
  }

  function estimateAmounts(
    address intok,
    uint256 amt,
    address outTok,
    address uniPool
  ) internal view returns (uint256) {
    uint256 _amountOut = estimateAmountOutMin(intok, uint128(amt), outTok, uniPool);
    return _amountOut;
  }

  /**
   * @notice Updates the profit share parameters.
   * @dev Only the contract owner can call this function, and the contract must be unpaused.
   * @param _totalProfit Total profit percentage (<= 10).
   * @param _daoProfit DAO profit percentage (< _totalProfit).
   */
  function updateProfitShare(
    uint _totalProfit,
    uint _daoProfit
  ) external onlyOwner contractUnpaused {
    require(_daoProfit < _totalProfit && _totalProfit <= 10, "AM02");
    daoProfit = _daoProfit;
    totalProfit = _totalProfit;
    emit ProfitShareUpdated(daoProfit, totalProfit); // Emit relevant event
  }

  function teamProfitshares(
    address _aFiStorage,
    address aFiContract,
    uint profitShare
  ) internal view returns (uint teamProfitShare) {
    uint totalActive = IAFiStorage(_aFiStorage).getTotalActiveWallets(aFiContract);
    if (totalActive > 1) {
      teamProfitShare =
        (profitShare * (totalProfit - daoProfit)) /
        ((totalActive - 1) * (totalProfit));
    }
  }

  /**
   * @notice Distributes profit shares among team wallets for aFiContract.
   * @param aFiContract The address of the AFi contract.
   * @param _aFiStorage The address of the AFiStorage contract.
   * @param iToken An array of iToken addresses.
   * @return totalProfitShare The total profit share distributed.
   */
  function unstakingProfitDistribution(
    address aFiContract,
    address _aFiStorage,
    address[] memory iToken
  ) external onlyOwner returns (uint totalProfitShare) {
    // Investor has made a profit, let us distribute the profit share amongst team wallet
    address[] memory _teamWallets = IAFiStorage(_aFiStorage).getTeamWalletsOfAFi(
      aFiContract
    );
    uint256 teamProfitShare;
    uint256 profitShare;
    // Alpha Creator gets 4% of gain
    for (uint j; j < iToken.length; j++) {
      profitShare = teamWalletsProfit[aFiContract][iToken[j]];
      if (profitShare > 0) {
        teamProfitShare = teamProfitshares(_aFiStorage, aFiContract, profitShare);
        {
          uint256 daoProfitShare;
          bool isActive;
          for (uint i = 0; i < _teamWallets.length; i++) {
            (isActive, ) = IAFiStorage(_aFiStorage).getTeamWalletDetails(
              aFiContract,
              _teamWallets[i]
            );
            if (isActive) {
              if (i == 0) {
                // /**
                //   Always at i==0 address must be of Aarna Dao
                //   Aarna DAO gets 6% of gain
                // */
                daoProfitShare = (profitShare * (daoProfit)) / (totalProfit);
                profitShare = daoProfitShare;
              } else {
                profitShare = teamProfitShare;
              }

              totalProfitShare = totalProfitShare + (profitShare);

              IERC20(iToken[j]).safeTransfer(_teamWallets[i], profitShare);

              emit ProfitShareDistributed(aFiContract, _teamWallets[i], profitShare);
            }
          }
        }
      }
      teamWalletsProfit[aFiContract][iToken[j]] = 0;
    }
  }

  function getAFiContracts() external view returns(IAFiStorage, address, address){
    return (aFiStorage, rebal, afiManager);
  }
}