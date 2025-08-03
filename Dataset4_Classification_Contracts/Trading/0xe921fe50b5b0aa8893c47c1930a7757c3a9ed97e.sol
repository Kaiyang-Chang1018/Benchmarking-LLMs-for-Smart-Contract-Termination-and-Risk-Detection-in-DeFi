// SPDX-License-Identifier: MIT
// Deployed at:  (Ethereum)
pragma solidity 0.8.28;

// Interfaces of external contracts we need to interact with (only the functions we use)
interface IERC20 {
  function balanceOf(address account) external view returns (uint256);
  function transferFrom(address sender, address recipient, uint256 amount)
    external returns (bool);
}

interface IUniswapV3Pool {
  function swap(
    address recipient,
    bool zeroForOne,
    int256 amountSpecified,
    uint160 sqrtPriceLimitX96,
    bytes calldata data) external returns (int256 amount0, int256 amount1);
}

interface IUniswapV3SwapCallback {
  function uniswapV3SwapCallback(
    int256 amount0Delta, // negative = was sent, positive = must be received
    int256 amount1Delta,
    bytes calldata data) external;
}

// Contract to buy and sell from/to specific pools on Ethereum.
// Assumes the pools are UniswapV3 pools that we trust are working correctly.
contract EthereumLeanTradeHelper {
  address private constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
  address private constant TARA = 0x2F42b7d686ca3EffC69778B6ED8493A7787b4d6E;
  address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address private constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
 
  // UniswapV3 pools
  address private constant TARA_USDT_1 = 0x203CB9b58a5aD9E3C5Eda27277Ef906BDFF0395c;
  address private constant WBTC_WETH_005 = 0x4585FE77225b41b697C938B018E2Ac67Ac5a20c0;
  address private constant WETH_USDT_005 = 0x11b815efB8f581194ae79006d24E0d814B7697F6;

  // Make the swap calls more readable
  bool private constant FORWARD = true;
  bool private constant BACKWARD = false;

  uint160 private constant MIN_SQRT_PRICE = 4295128739 + 1;
  uint160 private constant MAX_SQRT_PRICE = 1461446703485210103287273052203988822378723970342 - 1;

  // Used for unpacking parameters to the buy and sell functions
  uint256 constant private MAX128 = type(uint128).max;
  uint256 constant private MAX124 = MAX128 >> 4;

  function _callerBalanceOf(address token) private view returns (uint256) {
    return IERC20(token).balanceOf(msg.sender);
  }

  function _transferFrom(address from, address token, address to, uint256 amount) private {
    bool success = IERC20(token).transferFrom(from, to, amount);
    require(success, "TH: token transfer failure (check allowance)");
  }

  function _v3Swap(
    address pool,
    address payer,
    address recipient,
    bool zeroForOne,
    int256 amount) private {

    IUniswapV3Pool(pool).swap(
      recipient,
      zeroForOne,
      amount,
      zeroForOne ? MIN_SQRT_PRICE : MAX_SQRT_PRICE,
      abi.encode(payer));
  }

  function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external {
    (address payer) = abi.decode(data, (address));
    address pool = msg.sender;

    if (pool == TARA_USDT_1) {
      if (amount0Delta > 0) {
        return _transferFrom(payer, TARA, pool, uint256(amount0Delta));
      } else {
        return _transferFrom(payer, USDT, pool, uint256(amount1Delta));
      }
    } else if (pool == WBTC_WETH_005) {
      if (amount0Delta > 0) {
        return _transferFrom(payer, WBTC, pool, uint256(amount0Delta));
      } else {
        return _transferFrom(payer, WETH, pool, uint256(amount1Delta));
      }
    } else if (pool == WETH_USDT_005) {
      if (amount0Delta > 0) {
        return _transferFrom(payer, WETH, pool, uint256(amount0Delta));
      } else {
        return _transferFrom(payer, USDT, pool, uint256(amount1Delta));
      }
    }

    revert("TH: unexpected callback invocation");
  }

  function buyTara(uint256 packedParams) external returns (uint256 usdtBalanceAfter) {
    uint256 taraBuyAmount = packedParams & MAX128;
    packedParams >>= 128;
    uint256 minUsdtBalanceAfter = packedParams;

    _v3Swap(TARA_USDT_1, msg.sender, msg.sender, BACKWARD, -int256(taraBuyAmount));

    usdtBalanceAfter = _callerBalanceOf(USDT);
    require(usdtBalanceAfter >= minUsdtBalanceAfter, "TH: would cost too much USDT");
  }

  function sellTara(uint256 packedParams) external returns (uint256 usdtBalanceAfter) {
    uint256 taraSellAmount = packedParams & MAX128;
    packedParams >>= 128;
    uint256 minUsdtBalanceAfter = packedParams;

    _v3Swap(TARA_USDT_1, msg.sender, msg.sender, FORWARD, int256(taraSellAmount));

    usdtBalanceAfter = _callerBalanceOf(USDT);
    require(usdtBalanceAfter >= minUsdtBalanceAfter, "TH: would give too little USDT");
  }

  function buyWbtc(uint256 packedParams) external returns (uint256 wethBalanceAfter) {
    uint256 wbtcBuyAmount = packedParams & MAX128;
    packedParams >>= 128;
    uint256 minWethBalanceAfter = packedParams;

    _v3Swap(WBTC_WETH_005, msg.sender, msg.sender, BACKWARD, -int256(wbtcBuyAmount));

    wethBalanceAfter = _callerBalanceOf(WETH);
    require(wethBalanceAfter >= minWethBalanceAfter, "TH: would cost too much WETH");
  }

  function sellWbtc(uint256 packedParams) external returns (uint256 wethBalanceAfter) {
    uint256 wbtcSellAmount = packedParams & MAX128;
    packedParams >>= 128;
    uint256 minWethBalanceAfter = packedParams;

    _v3Swap(WBTC_WETH_005, msg.sender, msg.sender, FORWARD, int256(wbtcSellAmount));

    wethBalanceAfter = _callerBalanceOf(WETH);
    require(wethBalanceAfter >= minWethBalanceAfter, "TH: would give too little WETH");
  }

  function buyUsdt(uint256 packedParams) external returns (uint256 wethBalanceAfter) {
    uint256 usdtBuyAmount = packedParams & MAX128;
    packedParams >>= 128;
    uint256 minWethBalanceAfter = packedParams;

    _v3Swap(WETH_USDT_005, msg.sender, msg.sender, FORWARD, -int256(usdtBuyAmount));

    wethBalanceAfter = _callerBalanceOf(WETH);
    require(wethBalanceAfter >= minWethBalanceAfter, "TH: would cost too much WETH");
  }

  function sellUsdt(uint256 packedParams) external returns (uint256 wethBalanceAfter) {
    uint256 usdtSellAmount = packedParams & MAX128;
    packedParams >>= 128;
    uint256 minWethBalanceAfter = packedParams;

    _v3Swap(WETH_USDT_005, msg.sender, msg.sender, BACKWARD, int256(usdtSellAmount));

    wethBalanceAfter = _callerBalanceOf(WETH);
    require(wethBalanceAfter >= minWethBalanceAfter, "TH: would give too little WETH");
  }
}