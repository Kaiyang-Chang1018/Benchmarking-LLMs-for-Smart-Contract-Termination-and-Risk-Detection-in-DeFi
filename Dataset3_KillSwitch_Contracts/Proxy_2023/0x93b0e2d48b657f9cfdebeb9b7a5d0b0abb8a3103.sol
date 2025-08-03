//SPDX-License-Identifier: UNLICENSED
/*                              
                    CHAINTOOLS 2023. DEFI REIMAGINED

                                                               2023

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀            2021           ⣰⣾⣿⣶⡄⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀2019⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀     ⠹⣿V4⡄⡷⠀⠀⠀⠀⠀   
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ⢀⠀⠀⠀⠀⠀⠀⠀⠀ ⣤⣾⣿⣷⣦⡀⠀⠀⠀⠀   ⣿⣿⡏⠁⠀⠀⠀⠀⠀   
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ⢀⣴⣿⣿⣿⣷⡀⠀⠀⠀⠀ ⢀⣿⣿⣿⣿⣿⠄⠀⠀⠀  ⣰⣿⣿⣧⠀⠀⠀⠀⠀⠀   
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ⢀⣴⣾⣿⣿⣿⣿⣿⣿⡄⠀⠀ ⢀⣴⣿⣿⣿⠟⠛⠋⠀⠀⠀ ⢸⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀   
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ⢀⣴⣿⣿⣿⣿⣿⠟⠉⠉⠉⠁⢀⣴⣿⣿V3⣿⣿⠀⠀⠀⠀⠀  ⣾⣿⣿⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀   
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ⣾⣿⣿⣿⣿⣿⠛⠀⠀⠀⠀⠀ ⣾⣿⣿⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀ ⣿⣿⣿⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀   
⠀⠀⠀        2017⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿V2⣿⣿⡿⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣄⠀⠀⠀⠀⠀⠀ ⢹⣿ ⣿⣿⣿⣿⠙⢿⣆⠀⠀⠀   
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣴⣦⣤⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀⠈⢻⣿⣿⣿⣿⠛⠿⠿⠶⠶⣶⠀  ⣿ ⢸⣿⣿⣿⣿⣆⠹⠇⠀⠀   
⠀⠀⠀⠀⠀⠀⢀⣠⣴⣿⣿⣿⣿⣷⡆⠀⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⡇⠉⠛⢿⣷⡄⠀⠀⠀⢸⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀  ⠹⠇⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀   
⠀⠀⠀⠀⣠⣴⣿⣿V1⣿⣿⣿⡏⠛⠃⠀⠀⠀⠀⠀⠹⣿⣿⣿⣿⣿⣇⠀⠀⠘⠋⠁⠀⠀⠀⠈⢿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀  ⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀   
⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀ ⠸⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀  ⠀⣿⣿⡟⢿⣿⣿⠀⠀⠀⠀   
⠀⢸⣿⣿⣿⣿⣿⠛⠉⠙⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀ ⢈⣿⣿⡟⢹⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⡿⠈⣿⣿⡟⠀⠀⠀⠀⠀  ⢸⣿⣿⠀⢸⣿⣿⠀⠀⠀⠀   
⠀⠀⠹⣿⣿⣿⣿⣷⡀⠀⠻⣿⣿⣿⣿⣶⣄⠀⠀⠀⢰⣿⣿⡟⠁⣾⣿⣿⠀⠀⠀⠀⠀⠀⢀⣶⣿⠟⠋⠀⢼⣿⣿⠃⠀⠀⠀⠀⠀  ⣿⣿⠁⠀⢹⣿⣿⠀⠀⠀⠀   
⠀⢀⣴⣿⡿⠋⢹⣿⡇⠀⠀⠈⠙⣿⣇⠙⣿⣷⠀⠀⢸⣿⡟⠀⠀⢻⣿⡏⠀⠀⠀⠀⠀⢀⣼⡿⠁⠀⠀⠀⠘⣿⣿⠀⠀⠀⠀⠀   ⢨⣿⡇⠀⠀⠀⣿⣿⠀⠀⠀⠀   
⣴⣿⡟⠉⠀⠀⣾⣿⡇⠀⠀⠀⠀⢈⣿⡄⠀⠉⠀⠀⣼⣿⡆⠀⠀⢸⣿⣷⠀⠀⠀⠀⢴⣿⣿⠀⠀⠀⠀⠀⠀⣿⣯⡀⠀⠀⠀⠀    ⢸⣿⣇⠀⠀⠀⢺⣿⡄⠀⠀⠀   
⠈⠻⠷⠄⠀⠀⣿⣿⣷⣤⣠⠀⠀⠈⠽⠷⠀⠀⠀⠸⠟⠛⠛⠒⠶⠸⣿⣿⣷⣦⣤⣄⠈⠻⠷⠄⠀⠀⠀⠾⠿⠿⣿⣶⣤⠀    ⠘⠛⠛⠛⠒⠀⠸⠿⠿⠦ 


Telegram: https://t.me/ChaintoolsOfficial
Website: https://www.chaintools.ai/
Whitepaper: https://chaintools-whitepaper.gitbook.io/
Twitter: https://twitter.com/ChaintoolsTech
dApp: https://www.chaintools.wtf/
*/
pragma solidity ^0.8.19;

// import "forge-std/console.sol";
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IUniswapV2Router02 {
    function getAmountsOut(
        uint256 amountIn,
        address[] memory path
    ) external view returns (uint256[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface IV2Pair {
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function token0() external view returns (address);

    function burn(
        address to
    ) external returns (uint256 amount0, uint256 amount1);
}

interface IV3Pool {
    function liquidity() external view returns (uint128 Liq);

    struct Info {
        uint128 liquidity;
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
        uint128 tokensOwed0;
        uint128 tokensOwed1;
    }

    function initialize(uint160 sqrtPriceX96) external;

    function positions(
        bytes32 key
    ) external view returns (IV3Pool.Info memory liqInfo);

    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes memory data
    ) external returns (int256 amount0, int256 amount1);

    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function slot0()
        external
        view
        returns (uint160, int24, uint16, uint16, uint16, uint8, bool);

    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    function uniswapV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes memory data
    ) external;

    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);
}

interface IWETH {
    function withdraw(uint256 wad) external;

    function approve(address who, uint256 wad) external returns (bool);

    function deposit() external payable;

    function transfer(address dst, uint256 wad) external returns (bool);

    function balanceOf(address _owner) external view returns (uint256);
}

interface IQuoterV2 {
    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountOut);
}

interface IV3Factory {
    function getPool(
        address token0,
        address token1,
        uint24 poolFee
    ) external view returns (address);

    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address);
}

interface INonfungiblePositionManager {
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function setApprovalForAll(address operator, bool approved) external;

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function increaseLiquidity(
        INonfungiblePositionManager.IncreaseLiquidityParams calldata params
    ) external returns (uint128 liquidity, uint256 amount0, uint256 amount1);

    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) external view returns (uint256 tokenId);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function factory() external view returns (address);

    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    function mint(
        MintParams calldata mp
    )
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    function collect(
        CollectParams calldata params
    ) external payable returns (uint256 amount0, uint256 amount1);

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function decreaseLiquidity(
        DecreaseLiquidityParams calldata dl
    ) external returns (uint256 amount0, uint256 amount1);

    function positions(
        uint256 tokenId
    )
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );
}

interface IRouterV3 {
    function factory() external view returns (address);

    function WETH9() external view returns (address);

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

    function exactOutputSingle(
        ExactOutputSingleParams calldata params
    ) external returns (uint256 amountIn);

    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);
}

// Credits: https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/TickMath.sol
library TickMath {
    /// @dev The minimum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**-128
    int24 internal constant MIN_TICK = -887272;
    /// @dev The maximum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**128
    int24 internal constant MAX_TICK = 887272;

    /// @dev The minimum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MIN_TICK)
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    /// @dev The maximum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MAX_TICK)
    uint160 internal constant MAX_SQRT_RATIO =
        1461446703485210103287273052203988822378723970342;

    /// @notice Calculates sqrt(1.0001^tick) * 2^96
    /// @dev Throws if |tick| > max tick
    /// @param tick The input tick for the above formula
    /// @return sqrtPriceX96 A Fixed point Q64.96 number representing the sqrt of the ratio of the two assets (token1/token0)
    /// at the given tick
    function getSqrtRatioAtTick(
        int24 tick
    ) internal pure returns (uint160 sqrtPriceX96) {
        uint256 absTick = tick < 0
            ? uint256(-int256(tick))
            : uint256(int256(tick));
        require(absTick <= uint256(int256(MAX_TICK)), "T");

        uint256 ratio = absTick & 0x1 != 0
            ? 0xfffcb933bd6fad37aa2d162d1a594001
            : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0)
            ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0)
            ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0)
            ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0)
            ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0)
            ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0)
            ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0)
            ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0)
            ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0)
            ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0)
            ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0)
            ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0)
            ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0)
            ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0)
            ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0)
            ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0)
            ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x20000 != 0)
            ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x40000 != 0)
            ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x80000 != 0)
            ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

        if (tick > 0) ratio = type(uint256).max / ratio;

        // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
        // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
        // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
        sqrtPriceX96 = uint160(
            (ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1)
        );
    }
}

interface YieldVault {
    function getDeviation(
        uint256 amountIn,
        uint256 startTickDeviation
    ) external view returns (uint256 adjusted);

    function getCurrentTick() external view returns (int24 cTick);

    function getStartTickDeviation(
        int24 currentTick
    ) external view returns (uint256 perc);

    function findPoolFee(
        address token0,
        address token1
    ) external view returns (uint24 poolFee);

    function getPosition(
        uint256 tokenId
    ) external view returns (address token0, address token1, uint128 liquidity);

    function getTickDistance(
        uint256 flag
    ) external view returns (int24 tickDistance);

    function findApprovalToken(
        address pool
    ) external view returns (address token);

    function findApprovalToken(
        address token0,
        address token1
    ) external view returns (address token);

    function buyback(
        uint256 flag,
        uint128 internalWETHAmt,
        uint128 internalCTLSAmt,
        address to,
        uint256 id
    ) external returns (uint256 t0, uint256 t1);

    function keeper() external view returns(address);
}
interface ctls {
    function adjustFomo(uint16 a,uint256 b,address c) external;
}

contract ChainToolsYieldBooster {
    INonfungiblePositionManager internal immutable positionManager;
    address internal immutable token;
    address internal immutable pool;
    address internal immutable multiSig;
    address internal immutable WETH;
    address internal immutable v3Router;
    address internal YIELD_VAULT;
    address internal immutable keeper;
    event REWARDPOOLFEE(uint256 totalVolume);

    constructor(address _CTLS, address _pool, address _yield_vault) {
        token = _CTLS;
        pool = _pool;
        v3Router = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
        multiSig = 0xb0Df68E0bf4F54D06A4a448735D2a3d7D97A2222;
        YIELD_VAULT = _yield_vault;
        positionManager = INonfungiblePositionManager(
            0xC36442b4a4522E871399CD717aBDD847Ab11FE88
        );
        keeper = 0x5648C24Ea7cFE703836924bF2080ceFa44A12cA8;
        WETH = IRouterV3(v3Router).WETH9();
        // WETH = 0x0877fD90eD6CD35c7C0472b69F190B8C9aF0B53b;
    }

    function preventFragmentations(address who) external {
        require(msg.sender == multiSig || msg.sender == token, "multiSig");
        if (who == address(0)) {
            address fac = positionManager.factory();
            address _pool = IV3Factory(fac).createPool(WETH, token, 3000);
            ctls(payable(token)).adjustFomo(5, 0, _pool);
            _pool = IV3Factory(fac).createPool(WETH, token, 500);
            ctls(payable(token)).adjustFomo(5, 0, _pool);
        } else {
            ctls(payable(token)).adjustFomo(5, 0, who);
        }
    }

    function yield(
        uint256 id,
        uint256 times,
        uint256 startAmt,
        uint256 flag,
        uint128 a0,
        uint128 a1,
        address to
    ) external returns (uint256 c2, uint256 c3) {
        require(msg.sender == multiSig || msg.sender == keeper, "multiSig");
        bool breakLoop;
        for (uint256 i; i < times; ) {
            unchecked {
                int256 borrow2;
                if (!breakLoop) {
                    try
                        IV3Pool(pool).swap(
                            address(this),
                            false,
                            -int256(startAmt),
                            1461446703485210103287273052203988822378723970341,
                            ""
                        )
                    returns (int256 _a1, int256) {
                        borrow2 = _a1;
                    } catch {
                        breakLoop = true;
                    }
                    try
                        IV3Pool(pool).swap(
                            address(this),
                            true,
                            -int256(borrow2),
                            4295128740,
                            ""
                        )
                    {} catch {
                        breakLoop = true;
                    }
                } else {
                    break;
                }

                ++i;
            }
        }
        try YieldVault(YIELD_VAULT).buyback(flag, a0, a1, to, id) returns (
            uint256 c0,
            uint256 c1
        ) {
            c2 = c0;
            c3 = c1;
        } catch {}

        emit REWARDPOOLFEE(startAmt * times * 2);
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata
    ) external {
        address _pool = pool;
        assembly {
            if iszero(eq(caller(), _pool)) {
                revert(0, 0)
            }
        }

        if (amount0Delta < 0) {
            address sendToken = token;
            assembly {
                let inputMem := mload(0x40)
                mstore(
                    inputMem,
                    0xa9059cbb00000000000000000000000000000000000000000000000000000000
                )
                mstore(add(inputMem, 0x04), _pool)
                mstore(add(inputMem, 0x24), amount1Delta)
                pop(call(gas(), sendToken, 0, inputMem, 0x44, 0, 0))
            }
        } else {
            address sendToken = WETH;
            assembly {
                let inputMem := mload(0x40)
                mstore(
                    inputMem,
                    0xa9059cbb00000000000000000000000000000000000000000000000000000000
                )
                mstore(add(inputMem, 0x04), _pool)
                mstore(add(inputMem, 0x24), amount0Delta)
                pop(call(gas(), sendToken, 0, inputMem, 0x44, 0, 0))
            }
        }
    }

    function changeYieldVaultAddress(address newAdr) external {
        require(msg.sender == multiSig, "multiSig");
        YIELD_VAULT = newAdr;
    }

    function withdraw(address what) external {
        require(msg.sender == multiSig, "multiSig");
        IERC20(what).transfer(
            multiSig,
            IERC20(what).balanceOf(address(this)) - 1
        );
        if (address(this).balance > 0) {
            payable(multiSig).transfer(address(this).balance);
        }
    }
}