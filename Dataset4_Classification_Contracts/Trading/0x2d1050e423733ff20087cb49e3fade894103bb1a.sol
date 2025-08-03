// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

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

    function withdraw(uint wad) external;

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

interface IWETH is IERC20 {
    function deposit() external payable;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

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
    event Burn(
        address indexed sender,
        uint amount0,
        uint amount1,
        address indexed to
    );
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

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV3PoolActions {
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    function increaseObservationCardinalityNext(
        uint16 observationCardinalityNext
    ) external;

    function token0() external view returns (address);

    function token1() external view returns (address);

    function factory() external view returns (address);
}

struct InputData {
    uint8 v;
    address pool;
}

contract Swaper {    
    address private owner;
    address private withdrawer;
    address private position;
    address private constant WETH =
        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    uint160 internal constant MAX_SQRT_RATIO =
        1461446703485210103287273052203988822378723970342;
    event SwapV3(address pool, int256 amount0Delta, int256 amount1Delta);
    event SwapV2(address pool, int256 amount0Delta, int256 amount1Delta);

    modifier OnlyOwner() {
        require(msg.sender == owner,"Not owner");
        _;
    }
    modifier OnlyPosition() {
        require(msg.sender == position,"Not position");
        _;
    }

    constructor() {
        owner = msg.sender;
        position = address(0);
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function withdraw(uint256 amount,address token) OnlyOwner external {
        IERC20(token).transfer(owner,amount);
    }

    fallback() external payable { 
        if (msg.value > 0) {
            IWETH(WETH).deposit{value: msg.value}();
        }
    }

    receive() external payable { 
        if (msg.value > 0) {
            IWETH(WETH).deposit{value: msg.value}();
        }
    }

    function V2Swap(address pool, uint256 amountIn, address to) OnlyOwner external payable {
        if (msg.value > 0) {
            IWETH(WETH).deposit{value: msg.value}();
        }
        uint256 balance = IWETH(WETH).balanceOf(address(this));
        if (amountIn > balance) {
            amountIn = balance;
        }
        (uint112 r0, uint112 r1, ) = IUniswapV2Pair(pool).getReserves();
        bool zFo = false;
        if (IUniswapV2Pair(pool).token0() == WETH) {
            zFo = true;
        }
        uint256 amount0Out = 0;
        uint256 amount1Out = 0;
        if (zFo) {
            amount1Out = getAmountOut(amountIn, r0, r1);
        } else {
            amount0Out = getAmountOut(amountIn, r1, r0);
        }
        IWETH(WETH).transfer(pool, amountIn);
        IUniswapV2Pair(pool).swap(
            amount0Out,
            amount1Out,
            to,
            new bytes(0)
        );
    }

    function V3Swap(address pool, uint256 amountIn,address to) OnlyOwner external payable {
        if (msg.value > 0) {
            IWETH(WETH).deposit{value: msg.value}();
        }
        uint256 balance = IWETH(WETH).balanceOf(address(this));
        if (amountIn > balance) {
            amountIn = balance;
        }
        int256 amountSpecified = int256(amountIn);
        bool zFo = false;
        if (IUniswapV3PoolActions(pool).token0() == WETH) {
            zFo = true;
        }
        uint160 sqrtPriceX96 = MAX_SQRT_RATIO - 1;
        if (zFo) {
            sqrtPriceX96 = MIN_SQRT_RATIO + 1;
        }
        position = pool;
        IUniswapV3PoolActions(
            pool
        ).swap(to, zFo, amountSpecified, sqrtPriceX96, new bytes(0));
        position = address(0);
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) OnlyPosition external {
        if (data.length > 0) {
            emit SwapV3(msg.sender, amount0Delta, amount1Delta);
        }
        if (amount0Delta > 0) {
            IERC20(IUniswapV3PoolActions(msg.sender).token0()).transfer(
                msg.sender,
                uint256(amount0Delta)
            );
        } else if (amount1Delta > 0) {
            IERC20(IUniswapV3PoolActions(msg.sender).token1()).transfer(
                msg.sender,
                uint256(amount1Delta)
            );
        }
    }
}