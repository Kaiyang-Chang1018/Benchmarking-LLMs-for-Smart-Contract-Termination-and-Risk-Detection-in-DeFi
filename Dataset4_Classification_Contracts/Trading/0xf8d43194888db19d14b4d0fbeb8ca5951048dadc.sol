/*

  ▄▀█ █▀█ █▀▀ █▀▀ ▄▀█ █▀▀ ▀█▀ █▀█ █▀█ █▄█
  █▀█ █▀▀ ██▄ █▀░ █▀█ █▄▄ ░█░ █▄█ █▀▄ ░█░

  Trade on ApeFactory and have fun!
  Web:      https://apefactory.fun/

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract UniswapV2Router02 {
  address public immutable factory;
  address public immutable WETH;

  error ErrorExpired();
  error ErrorInvalidPath();
  error ErrorInsufficientLiquidity();
  error ErrorInsufficientAmount();
  error ErrorInsufficientAmountIn();
  error ErrorInsufficientAmountOut();
  error ErrorTransfer(address to, uint256 amount);

  modifier ensure(uint256 deadline) {
    if (block.timestamp > deadline) { revert ErrorExpired(); }

    _;
  }

  constructor(address _factory, address _WETH) payable {
    factory = _factory;
    WETH = _WETH;
  }

  function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable ensure(deadline) {
    if (path.length != 2 || path[0] != WETH) { revert ErrorInvalidPath(); }

    uint256 amountIn = msg.value;
    address pair = IUniswapV2Factory(factory).getPair(path[0], path[1]);

    if (pair == address(0)) { revert ErrorInvalidPath(); }

    uint256 balanceBefore = IERC20(path[1]).balanceOf(to);

    IUniswapV2Pair(pair).swap{ value: amountIn }(to, path[0]);

    if (amountOutMin > 0) {
      unchecked {
        if (IERC20(path[1]).balanceOf(to) - balanceBefore < amountOutMin) { revert ErrorInsufficientAmountOut(); }
      }
    }
  }

  function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external ensure(deadline) {
    if (path.length != 2 || path[1] != WETH) { revert ErrorInvalidPath(); }

    address pair = IUniswapV2Factory(factory).getPair(path[0], path[1]);

    if (pair == address(0)) { revert ErrorInvalidPath(); }

    IERC20(path[0]).transferFrom(msg.sender, pair, amountIn);

    uint256 balanceBefore = address(to).balance;

    IUniswapV2Pair(pair).swap{ value: 0 }(to, path[0]);

    if (amountOutMin > 0) {
      unchecked {
        if (address(to).balance - balanceBefore < amountOutMin) { revert ErrorInsufficientAmountOut(); }
      }
    }
  }

  function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB) {
    if (amountA == 0) { revert ErrorInsufficientAmount(); }
    if (reserveA == 0 || reserveB == 0) { revert ErrorInsufficientLiquidity(); }

    unchecked {
      amountB = amountA * reserveB / reserveA;
    }
  }

  function getAmountsIn(uint256 amountOut, address[] memory path) external view returns (uint256[] memory amounts) {
    if (path.length != 2) { revert ErrorInvalidPath(); }
    if (amountOut == 0) { revert ErrorInsufficientAmountOut(); }

    amounts = new uint256[](2);
    amounts[1] = amountOut;

    (uint112 reserveIn, uint112 reserveOut) = _getReserves(path[0], path[1]);

    if (reserveIn == 0 || reserveOut == 0) { revert ErrorInsufficientLiquidity(); }

    amounts[0] = getAmountIn(path, amountOut, reserveIn, reserveOut);
  }

  function getAmountIn(address[] memory path, uint256 amountOut, uint112 reserveIn, uint112 reserveOut) public view returns (uint256 amountIn) {
    if (path.length != 2 || path[0] == path[1]) { revert ErrorInvalidPath(); }
    if (amountOut == 0) { revert ErrorInsufficientAmountIn(); }
    if (reserveIn == 0 || reserveOut == 0) { revert ErrorInsufficientLiquidity(); }

    address pair = IUniswapV2Factory(factory).getPair(path[0], path[1]);

    if (pair == address(0)) { revert ErrorInvalidPath(); }

    uint24 fee = IUniswapV2Pair(pair).FEE();
    uint24 tax = IUniswapV2Pair(pair).TAX();

    unchecked {
      uint256 numerator = uint256(reserveIn) * amountOut * 100_000;
      uint256 denominator = (uint256(reserveOut) - amountOut) * (100_000 - uint256(fee + tax));

      amountIn = (numerator / denominator) + 1;
    }
  }

  function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts) {
    if (path.length != 2) { revert ErrorInvalidPath(); }
    if (amountIn == 0) { revert ErrorInsufficientAmountIn(); }

    amounts = new uint256[](2);
    amounts[0] = amountIn;

    (uint112 reserveIn, uint112 reserveOut) = _getReserves(path[0], path[1]);

    if (reserveIn == 0 || reserveOut == 0) { revert ErrorInsufficientLiquidity(); }

    amounts[1] = getAmountOut(path, amountIn, reserveIn, reserveOut);
  }

  function getAmountOut(address[] memory path, uint256 amountIn, uint112 reserveIn, uint112 reserveOut) public view returns (uint256 amountOut) {
    if (path.length != 2 || path[0] == path[1]) { revert ErrorInvalidPath(); }
    if (amountIn == 0) { revert ErrorInsufficientAmountIn(); }
    if (reserveIn == 0 || reserveOut == 0) { revert ErrorInsufficientLiquidity(); }

    address pair = IUniswapV2Factory(factory).getPair(path[0], path[1]);

    if (pair == address(0)) { revert ErrorInvalidPath(); }

    uint24 fee = IUniswapV2Pair(pair).FEE();
    uint24 tax = IUniswapV2Pair(pair).TAX();

    unchecked {
      uint256 amountInAdjusted = amountIn * (100_000 - uint256(fee + tax));
      uint256 numerator = amountInAdjusted * uint256(reserveOut);
      uint256 denominator = (uint256(reserveIn) * 100_000) + amountInAdjusted;

      amountOut = numerator / denominator;
    }
  }

  function _getReserves(address tokenA, address tokenB) private view returns (uint112 reserveA, uint112 reserveB) {
    address pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);

    if (pair == address(0)) { revert ErrorInvalidPath(); }

    (address token0,) = _sortTokens(tokenA, tokenB);
    (uint112 reserve0, uint112 reserve1,) = IUniswapV2Pair(pair).getReserves();
    (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
  }

  function _sortTokens(address tokenA, address tokenB) private pure returns (address token0, address token1) {
    (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
  }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

interface IERC20 {
  function balanceOf(address owner) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

interface IUniswapV2Factory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

interface IUniswapV2Pair {
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function swap(address to, address tokenIn) external payable;
  function FEE() external view returns (uint24);
  function TAX() external view returns (uint24);
  function ETH_INITIAL_VIRTUAL_RESERVE() external view returns (uint112);
}