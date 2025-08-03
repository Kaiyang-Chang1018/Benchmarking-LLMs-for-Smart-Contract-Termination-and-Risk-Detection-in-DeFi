pragma solidity >=0.6.2;

interface IXpRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        external
        pure
        returns (uint256 amountOut);
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        external
        pure
        returns (uint256 amountIn);
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function launch(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint8 buyLpFee,
        uint8 sellLpFee,
        uint8 buyProtocolFee,
        uint8 sellProtocolFee,
        address protocolAddress
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function updateSelf(address _token) external;

    function safeTransferLp(address _token, address to, uint256 _amount) external;

    function hardstake(address _contract, address _token, uint256 _amount) external;

    function exemptFromFee(address _address) external returns (bool);
}
pragma solidity =0.6.6;

import "./IXpRouter.sol";

interface IXpPair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function setMetadata(
        string calldata website,
        string calldata image,
        string calldata description,
        string calldata chat,
        string calldata social
    ) external;
    function websiteUrl() external view returns (string memory);
    function imageUrl() external view returns (string memory);
    function tokenDescription() external view returns (string memory);
    function chatUrl() external view returns (string memory);
    function socialUrl() external view returns (string memory);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function updateProvider(address user) external;
    function euler(uint256) external view returns (uint256);
    function viewShare() external view returns (uint256 share);
    function claimShare() external;
    function poolBalance() external view returns (uint256);
    function totalCollected() external view returns (uint256);

    function setProtocol(address) external;
    function protocol() external view returns (address);
    function payableProtocol() external view returns (address payable origin);

    function creator() external view returns (address);
    function renounce() external;

    function setFees() external;
    function updateFees(uint8, uint8, uint8, uint8) external;
    function buyLpFee() external view returns (uint8);
    function sellLpFee() external view returns (uint8);
    function buyProtocolFee() external view returns (uint8);
    function sellProtocolFee() external view returns (uint8);
    function buyTotalFee() external view returns (uint8);
    function sellTotalFee() external view returns (uint8);

    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);

    function first_mint(
        address to,
        uint8 buyLp,
        uint8 sellLp,
        uint8 buyProtocol,
        uint8 sellProtocol,
        address protocolAddress
    ) external returns (uint256 liquidity);
    function mint(address to) external returns (uint256 liquidity);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address _token0, address _token1) external;
}

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}

library UniswapV2Library {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        hex"cc3cfdf52516f231101bbe110b15f3c47658e576e20d8ad98b7fb074339665e1" // init code hash
                    )
                )
            )
        );
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB)
        internal
        view
        returns (uint256 reserveA, uint256 reserveB)
    {
        (address token0,) = sortTokens(tokenA, tokenB);
        address pair = pairFor(factory, tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1,) = IXpPair(pair).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) internal pure returns (uint256 amountB) {
        require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountOut)
    {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn.mul(1000); //997
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountIn)
    {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(1000); //997
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint256 amountIn, address[] memory path)
        internal
        view
        returns (uint256[] memory amounts)
    {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint256 amountOut, address[] memory path)
        internal
        view
        returns (uint256[] memory amounts)
    {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

interface IXpFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function routerSetter() external view returns (address);
    function router() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function setRouterSetter(address) external;
    function setRouter(address) external;
}

library TransferHelper {
    function safeApprove(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success,) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper::safeTransferETH: ETH transfer failed");
    }
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

interface IStakingContract {
    function stake(uint256, address, address) external;
}

contract XpRouter is IXpRouter {
    using SafeMath for uint256;

    address public immutable override factory;
    address public immutable override WETH;
    address payable public treasury;
    AggregatorV3Interface internal priceFeed;

    address payable public teamWallet;
    address payable public stakingContractXpLp;
    address payable public stakingContractXp;

    address public canUpdateTokenFactory;
    address public tokenFactory;
    mapping(address => bool) public override exemptFromFee;

    function setTokenFactory(address _tokenFactory) external {
        require(msg.sender == canUpdateTokenFactory, "XpRouter: FORBIDDEN");
        tokenFactory = _tokenFactory;
    }

    function addExemptFromFee(address _address) external {
        // only token factory or teamwallet can add exempt from fee
        require(msg.sender == tokenFactory || msg.sender == teamWallet, "XpRouter: FORBIDDEN");
        exemptFromFee[_address] = true;
    }

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "XpRouter: EXPIRED");
        _;
    }

    constructor(
        address _factory,
        address _WETH,
        address _oracleAddress,
        address _teamWallet,
        address _stakingContractXpLp,
        address _stakingContractXp
    ) public {
        factory = _factory;
        WETH = _WETH;
        priceFeed = AggregatorV3Interface(_oracleAddress);
        treasury = msg.sender;
        teamWallet = payable(_teamWallet);
        stakingContractXpLp = payable(_stakingContractXpLp);
        stakingContractXp = payable(_stakingContractXp);
        canUpdateTokenFactory = msg.sender;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    function getEthUsdcPrice() internal view returns (uint256) {
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        return uint256(price / 100);
    }

    function usdcToEth(uint256 usdcAmount) public view returns (uint256) {
        uint256 ethUsdcPrice = getEthUsdcPrice();
        return (usdcAmount * 1e6 * 1e18 / ethUsdcPrice);
    }

    // **** HARDSTAKE ERC20 & LP ****

    function updateSelf(address _token) public override {
        IXpPair pair = IXpPair(_token);
        require(IXpFactory(factory).getPair(pair.token0(), pair.token1()) == _token);
        pair.updateProvider(msg.sender);
    }

    function safeTransferLp(address _token, address to, uint256 _amount) public override {
        require(_amount > 0, "Amount must be greater than 0");
        IXpPair pair = IXpPair(_token);
        require(IXpFactory(factory).getPair(pair.token0(), pair.token1()) == _token);
        TransferHelper.safeTransferFrom(_token, msg.sender, to, _amount);
        pair.updateProvider(msg.sender);
    }

    function hardstake(address _contract, address _token, uint256 _amount) public override {
        require(_amount > 0, "Amount must be greater than 0");
        TransferHelper.safeTransferFrom(_token, msg.sender, _contract, _amount);
        try IXpPair(_token).token0() returns (address token0) {
            address token1 = IXpPair(_token).token1();
            if (IXpFactory(factory).getPair(token0, token1) == _token) {
                IXpPair(_token).updateProvider(msg.sender);
            }
        } catch {}
        IStakingContract(_contract).stake(_amount, msg.sender, _token);
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal virtual returns (uint256 amountA, uint256 amountB) {
        // create the pair if it doesn't exist yet
        if (IXpFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            address pair = IXpFactory(factory).createPair(tokenA, tokenB);
        }

        (uint256 reserveA, uint256 reserveB) = UniswapV2Library.getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = UniswapV2Library.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "XpRouter: INSUFFICIENT_B_AMOUNT");
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = UniswapV2Library.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, "XpRouter: INSUFFICIENT_A_AMOUNT");
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function launch(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint8 buyLpFee,
        uint8 sellLpFee,
        uint8 buyProtocolFee,
        uint8 sellProtocolFee,
        address protocolAddress
    ) external payable virtual override returns (uint256 amountToken, uint256 amountETH, uint256 liquidity) {
        (amountToken, amountETH) =
            _addLiquidity(token, WETH, amountTokenDesired, msg.value, amountTokenMin, amountETHMin);
        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity =
            IXpPair(pair).first_mint(msg.sender, buyLpFee, sellLpFee, buyProtocolFee, sellProtocolFee, protocolAddress);
        IXpPair(UniswapV2Library.pairFor(factory, token, WETH)).updateProvider(msg.sender);

        // refund dust eth, if any
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity)
    {
        (amountToken, amountETH) =
            _addLiquidity(token, WETH, amountTokenDesired, msg.value, amountTokenMin, amountETHMin);
        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = IXpPair(pair).mint(msg.sender);
        IXpPair(UniswapV2Library.pairFor(factory, token, WETH)).updateProvider(msg.sender);

        // refund dust eth, if any
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }

    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) internal ensure(deadline) returns (uint256 amountA, uint256 amountB) {
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        IXpPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint256 amount0, uint256 amount1) = IXpPair(pair).burn(to);
        (address token0,) = UniswapV2Library.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, "XpRouter: INSUFFICIENT_A_AMOUNT");
        require(amountB >= amountBMin, "XpRouter: INSUFFICIENT_B_AMOUNT");
    }

    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    ) public virtual override ensure(deadline) returns (uint256 amountETH) {
        (, amountETH) = removeLiquidity(token, WETH, liquidity, amountTokenMin, amountETHMin, address(this), deadline);
        IXpPair(UniswapV2Library.pairFor(factory, token, WETH)).updateProvider(msg.sender);
        TransferHelper.safeTransfer(token, msg.sender, IERC20(token).balanceOf(address(this)));
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(msg.sender, amountETH);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****

    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = UniswapV2Library.sortTokens(input, output);
            IXpPair pair = IXpPair(UniswapV2Library.pairFor(factory, input, output));
            uint256 amountInput;
            uint256 amountOutput;
            {
                // scope to avoid stack too deep errors
                (uint256 reserve0, uint256 reserve1,) = pair.getReserves();
                (uint256 reserveInput, uint256 reserveOutput) =
                    input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
                amountOutput = UniswapV2Library.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint256 amount0Out, uint256 amount1Out) =
                input == token0 ? (uint256(0), amountOutput) : (amountOutput, uint256(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable virtual override ensure(deadline) {
        require(path.length == 2, "XpRouter: INVALID_PATH_LENGTH");
        IXpPair Pair = IXpPair(UniswapV2Library.pairFor(factory, path[0], path[1]));
        require(path[0] == WETH, "XpRouter: INVALID_PATH");
        uint256 totalBuyFeeInEth = usdcToEth(Pair.buyTotalFee());
        require(msg.value > totalBuyFeeInEth, "XpRouter: INSUFFICIENT_ETH_FEE");

        uint256 amountIn = msg.value - usdcToEth(Pair.buyTotalFee());
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amountIn));
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);

        _swapSupportingFeeOnTransferTokens(path, to);

        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            "XpRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );

        // 50% of buy protocol fees go to the deployer
        uint256 buyProtocolFee_ = usdcToEth(Pair.buyProtocolFee()) / 2;

        // 50% of buy lp fees go to liquidity pool
        uint256 buyLpFee_ = usdcToEth(Pair.buyLpFee()) / 2;

        // 50% of buy protocol fees go to the deployer
        (bool sent1,) = IXpPair(UniswapV2Library.pairFor(factory, path[0], path[1])).payableProtocol().call{
            value: buyProtocolFee_
        }("");

        // 50% of buy lp fees go to liquidity pool
        (bool sent2,) = UniswapV2Library.pairFor(factory, path[0], path[1]).call{value: buyLpFee_}("");

        // 25% of buy protocol and buy lp fees go to the team wallet and staking contract
        uint256 toTeamWalletAndStaking = (buyProtocolFee_ / 2) + (buyLpFee_ / 2);

        (bool sent3,) = teamWallet.call{value: toTeamWalletAndStaking}("");

        // Of the 25% that goes to staking contract, 60% goes to XpLp and 40% goes to Xp
        uint256 toStakingContractXpLp = toTeamWalletAndStaking * 60 / 100;
        uint256 toStakingContractXp = toTeamWalletAndStaking * 40 / 100;

        (bool sent4,) = stakingContractXpLp.call{value: toStakingContractXpLp}("");
        (bool sent5,) = stakingContractXp.call{value: toStakingContractXp}("");

        (bool sent6,) = treasury.call{value: usdcToEth(1)}(""); // sent $1 to treasury

        require(sent1 && sent2 && sent3 && sent4 && sent5 && sent6, "Failed to send Ether");
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable virtual override ensure(deadline) {
        require(path.length == 2, "XpRouter: INVALID_PATH_LENGTH");
        IXpPair Pair = IXpPair(UniswapV2Library.pairFor(factory, path[0], path[1]));
        require(path[path.length - 1] == WETH, "XpRouter: INVALID_PATH");

        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint256 amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, "XpRouter: INSUFFICIENT_OUTPUT_AMOUNT");

        if (!exemptFromFee[msg.sender]) {
            uint256 totalSellFeeInEth = usdcToEth(Pair.sellTotalFee());
            require(msg.value >= totalSellFeeInEth, "XpRouter: INSUFFICIENT_ETH_FEE");
            _chargeFeesSell(Pair, path);
        }

        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    function _chargeFeesSell(IXpPair pair, address[] memory path) private {
        // 50% of sell protocol fees go to the deployer
        uint256 sellProtocolFee_ = usdcToEth(pair.sellProtocolFee()) / 2; // started with $10, took $5

        // 50% of sell lp fees go to liquidity pool
        uint256 sellLpFee_ = usdcToEth(pair.sellLpFee()) / 2; // started with $10, took $5

        // 50% of sell protocol fees go to the deployer
        (bool sent1,) = pair.payableProtocol().call{value: sellProtocolFee_}(""); // sent $5 from protocol fee to team

        // 50% of sell lp fees go to liquidity pool
        (bool sent2,) = UniswapV2Library.pairFor(factory, path[0], path[1]).call{value: sellLpFee_}(""); // sent $5 from lp fee to liquidity pool

        // 25% of sell protocol and sell lp fees go to the team wallet and staking contract
        uint256 toTeamWalletAndStaking = (sellProtocolFee_ / 2) + (sellLpFee_ / 2);

        (bool sent3,) = teamWallet.call{value: toTeamWalletAndStaking}(""); // sent 2.5$ from sell protocol and lp fees to team

        // Of the 25% that goes to staking contract, 60% goes to XpLp and 40% goes to Xp
        uint256 toStakingContractXpLp = toTeamWalletAndStaking * 60 / 100;
        uint256 toStakingContractXp = toTeamWalletAndStaking * 40 / 100;

        (bool sent4,) = stakingContractXpLp.call{value: toStakingContractXpLp}(""); // sent 3$ from sell protocol and lp fees to XpLp
        (bool sent5,) = stakingContractXp.call{value: toStakingContractXp}(""); // sent 2$ from sell protocol and lp fees to Xp

        (bool sent6,) = treasury.call{value: usdcToEth(1)}(""); // sent $1 to treasury

        require(sent1 && sent2 && sent3 && sent4 && sent5 && sent6, "Failed to send Ether");
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB)
        public
        pure
        virtual
        override
        returns (uint256 amountB)
    {
        return UniswapV2Library.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        public
        pure
        virtual
        override
        returns (uint256 amountOut)
    {
        return UniswapV2Library.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        public
        pure
        virtual
        override
        returns (uint256 amountIn)
    {
        return UniswapV2Library.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint256 amountIn, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return UniswapV2Library.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint256 amountOut, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return UniswapV2Library.getAmountsIn(factory, amountOut, path);
    }
}