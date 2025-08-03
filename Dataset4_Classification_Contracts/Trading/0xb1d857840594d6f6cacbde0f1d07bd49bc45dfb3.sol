// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IERC20 {
  function balanceOf(address account) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
}

interface IERC20NonCompliant {
  // transfer without return value, used by old USDT contract
  function transfer(address to, uint256 value) external;
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

// Contract to buy and sell in the TARA-USDT UniswapV3 pool on Ethereum.
contract EthereumTaraTrader {
  address private constant TARA = 0x2F42b7d686ca3EffC69778B6ED8493A7787b4d6E;
  address private constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
  address private constant TARA_USDT_1 = 0x203CB9b58a5aD9E3C5Eda27277Ef906BDFF0395c;

  uint160 private constant MIN_SQRT_PRICE = 4295128739 + 1;
  uint160 private constant MAX_SQRT_PRICE = 1461446703485210103287273052203988822378723970342 - 1;

  // Used for unpacking parameters to the buy and sell functions
  uint256 private constant MAX128 = type(uint128).max;

  // Owner of the funds in the contract, set to deployer in the constructor
  address private immutable _owner;

  uint256 private transient _outputOrInputAmount;  // Return value set in callback

  constructor() {
    _owner = msg.sender;
  }

  function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata) external {
    require(msg.sender == TARA_USDT_1);

    if (amount0Delta > 0) {
      // Sell TARA. Pay TARA to the pair and record how much USDT we will get.
      IERC20(TARA).transfer(TARA_USDT_1, uint256(amount0Delta));
      _outputOrInputAmount = uint256(-amount1Delta);
    } else {
      // Buy TARA. Pay USDT and record how much we paid.
      IERC20NonCompliant(USDT).transfer(TARA_USDT_1, uint256(amount1Delta));
      _outputOrInputAmount = uint256(amount1Delta);
    }
  }

  function singleCall(address targetContract, bytes calldata inputData) external {
    require(msg.sender == _owner);
    targetContract.call(inputData);
  }

  function withdrawTara() external {
    require(msg.sender == _owner);
    unchecked {
      // Leave 1 wei to save gas over time
      IERC20(TARA).transfer(msg.sender, IERC20(TARA).balanceOf(address(this)) - 1);
    }
  }

  function withdrawUsdt() external {
    require(msg.sender == _owner);
    unchecked {
      IERC20NonCompliant(USDT).transfer(msg.sender, IERC20(USDT).balanceOf(address(this)) - 1);
    }
  }

  function buy(uint256 packedParams) external returns (uint256 usdtInput) {
    require(msg.sender == _owner);

    uint256 taraBuyAmount = packedParams & MAX128;
    uint256 maxUsdtInput = packedParams >> 128;

    IUniswapV3Pool(TARA_USDT_1).swap(address(this), false, -int256(taraBuyAmount), MAX_SQRT_PRICE, "");
    usdtInput = _outputOrInputAmount;
    require(usdtInput <= maxUsdtInput);
  }

  function sell(uint256 packedParams) external returns (uint256 usdtOutput) {
    require(msg.sender == _owner);

    uint256 taraSellAmount = packedParams & MAX128;
    uint256 minUsdtOutput = packedParams >> 128;

    IUniswapV3Pool(TARA_USDT_1).swap(address(this), true, int256(taraSellAmount), MIN_SQRT_PRICE, "");
    usdtOutput = _outputOrInputAmount;
    require(usdtOutput >= minUsdtOutput);
  }
}