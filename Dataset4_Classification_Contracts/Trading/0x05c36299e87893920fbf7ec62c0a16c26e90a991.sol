//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.2 <0.9.0;

library SafeCast {

    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }
    
    function toInt256(uint256 value) internal pure returns (int256) {
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

interface IRouter {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function factory() external view returns (address);
}

interface IUniswapV3Factory {
    function getPool(address tokenA, address tokenB, uint24 fee) external view returns (address pool);
}

interface IUniswapV2Pair {
    function swap(uint _amount0Out, uint _amount1Out, address _to, bytes calldata _data) external;
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

interface IUniswapV3Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function fee() external view returns (uint24);    
    function swap(address _recipient, bool _zeroForOne, int256 _amountSpecified, uint160 _sqrtPriceLimitX96, bytes calldata _data) external returns (int256 _amount0, int256 _amount1);
}

interface IUniswapV3QuoterV1 {
    function quoteExactInputSingle(
        address _tokenIn,
        address _tokenOut,
        uint24 _fee,
        uint256 _amountIn,
        uint160 _sqrtPriceLimitX96
    ) external returns (uint256 _amountOut);
}

interface IUniswapV3QuoterV1Feeless {
    function quoteExactInputSingle(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint160 _limitSqrtPrice
    ) external returns (uint256 _amountOut, uint16 _fee);
}

struct UniswapV3QuoteExactInputSingleParams {
    address tokenIn;
    address tokenOut;
    uint256 amountIn;
    uint24 fee;
    uint160 _sqrtPriceLimitX96;
}
interface IUniswapV3QuoterV2 {
    function quoteExactInputSingle(
        UniswapV3QuoteExactInputSingleParams memory _params
    ) external returns (
        uint256 _amountOut,
        uint160 _sqrtPriceX96After,
        uint32 _initializedTicksCrossed,
        uint256 _gasEstimate
    );
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint _amount) external;
    function transfer(address _dst, uint _wad) external returns (bool);
    function transferFrom(address _src, address _dst, uint _wad) external returns (bool);
    function balanceOf(address _address) external returns (uint256);
}

interface IERC20 {
    function balanceOf(address _address) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transferFrom(address _from, address _to, uint256 _amount) external;
    function transfer(address _to, uint256 _amount) external;
    function approve(address spender, uint256 value) external returns (bool);
}

interface IUniswapV3SwapCallback {
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata _data
    ) external;
}


library UniswapV2Library {
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address _tokenA, address _tokenB) internal pure returns (address _token0, address _token1) {
        require(_tokenA != _tokenB, 'BarkBot Router: IDENTICAL_ADDRESSES');
        (_token0, _token1) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);
        require(_token0 != address(0), 'BarkBot Router: ZERO_ADDRESS');
    }

    function getReserves(address _pair, address _tokenA, address _tokenB) internal view returns (uint _reserveA, uint _reserveB) {
        (address _token0,) = sortTokens(_tokenA, _tokenB);
        (uint _reserve0, uint _reserve1,) = IUniswapV2Pair(_pair).getReserves();
        (_reserveA, _reserveB) = _tokenA == _token0 ? (_reserve0, _reserve1) : (_reserve1, _reserve0);
    }

    function getAmountOut(uint _amountIn, uint _reserveIn, uint _reserveOut) internal pure returns (uint _amountOut) {
        require(_amountIn > 0, 'BarkBot Router: INSUFFICIENT_INPUT_AMOUNT');
        require(_reserveIn > 0 && _reserveOut > 0, 'BarkBot Router: INSUFFICIENT_LIQUIDITY');
        uint _amountInWithFee = _amountIn * 997;
        uint _numerator = _amountInWithFee * _reserveOut;
        uint _denominator = (_reserveIn * 1000) + _amountInWithFee;
        _amountOut = _numerator / _denominator;
    }
}

library TransferHelper {
    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

contract BarkBotRouterV1 is IUniswapV3SwapCallback {
    struct SwapDataV3 {
        address spend;
        address get;
        uint24 fee;
        address payer;
    }

    struct FeeRecipient {
        address recipient;
        uint256 fee;
    }

    using SafeCast for uint256;
    using SafeCast for int256;
    uint160 constant MIN_SQRT_RATIO = 4295128739 + 1;
    uint160 constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342 - 1;
    uint256 constant MIN_FEE_SIZE = 100;
    uint256 constant MAX_FEE_POOL = 100000;
    IWETH private WETH;
    address private m_WethAddress;
    address private m_UniswapV3FactoryAddress;
    FeeRecipient[] private m_FeeRecipients;

    mapping (address => bool) m_Admin;

    receive() external payable {
        assert(msg.sender == m_WethAddress || m_Admin[msg.sender]);
    }
    
    modifier ensure(uint256 _deadline) {
        require(_deadline >= block.timestamp, "BarkBot Router: EXPIRED");
        _;
    }

    modifier onlyAdmin() {
        require(m_Admin[msg.sender]);
        _;
    }
 
    constructor(address _weth) {
        m_WethAddress = _weth;
        m_UniswapV3FactoryAddress = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
        WETH = IWETH(m_WethAddress);
        m_Admin[msg.sender] = true;
    }
    
    function _getAmountWithFee(uint256 _amount, uint256 _fee) private view returns (uint256, uint256) {
        if (_fee < 100 || _amount < 1000) {
            return (_amount, 0);
        }
        require(
            _fee <= 2500, // max fee 2.5%
            "BarkBot Router: INVALID_FEE"
        );
        uint256 _feeAmount = _amount * _fee / 100000;
        return (_amount - _feeAmount, _feeAmount);
    }

    function getAmountOut(
        address _pair, 
        uint _amountIn, 
        address _spend, 
        address _get, 
        uint256 _routerFee
    ) public view returns (
        uint _amountOut
    ) {
        if (_get != m_WethAddress) { // if quoting a buy, get fee from the front
            (_amountIn,) = _getAmountWithFee(_amountIn, _routerFee);
        }
        (uint _reserveIn, uint _reserveOut) = UniswapV2Library.getReserves(_pair, _spend, _get);
        _amountOut = UniswapV2Library.getAmountOut(_amountIn, _reserveIn, _reserveOut);
        if (_get == m_WethAddress) { // if quoting a sell, get fee from the back
            (_amountOut,) = _getAmountWithFee(_amountOut, _routerFee);
        }
    }

    function getAmountOutUniswapV3QuoterV1(
        address _quoter,
        address _spend,
        address _get,
        uint24 _poolFee,
        uint256 _amountIn,
        uint160 _sqrtPriceLimitX96,
        uint256 _routerFee
    ) public returns (
        uint256 _amountOut
    ) {
        if (_get != m_WethAddress) { // if quoting a buy, get fee from the front
            (_amountIn,) = _getAmountWithFee(_amountIn, _routerFee);
        }
        _amountOut = IUniswapV3QuoterV1(_quoter).quoteExactInputSingle(_spend, _get, _poolFee, _amountIn, _sqrtPriceLimitX96);
        if (_get == m_WethAddress) { // if quoting a sell, get fee from the back
            (_amountOut,) = _getAmountWithFee(_amountOut, _routerFee);
        }
    }

    function getAmountOutUniswapV3QuoterV1Feeless(
        address _quoter,
        address _spend,
        address _get,
        uint256 _amountIn,
        uint160 _sqrtPriceLimitX96,
        uint256 _routerFee
    ) public returns (
        uint256 _amountOut,
        uint16 _poolFee
    ) {
        if (_get != m_WethAddress) { // if quoting a buy, get fee from the front
            (uint256 _amountWithFee,) = _getAmountWithFee(_amountIn, _routerFee);
            _amountIn = _amountWithFee;
        }
        (_amountOut, _poolFee) = IUniswapV3QuoterV1Feeless(_quoter).quoteExactInputSingle(_spend, _get, _amountIn, _sqrtPriceLimitX96);
        if (_get == m_WethAddress) { // if quoting a sell, get fee from the back
            (uint256 _amountWithFee,) = _getAmountWithFee(_amountOut, _routerFee);
            _amountOut = _amountWithFee;
        }
    }

    function getAmountOutUniswapV3QuoterV2(
        address _quoter,
        UniswapV3QuoteExactInputSingleParams memory _params,
        uint256 _routerFee
    ) public returns (
        uint256 _amountOut,
        uint160 _sqrtPriceX96After,
        uint32 _initializedTicksCrossed,
        uint256 _gasEstimate
    ) {
        if (_params.tokenOut != m_WethAddress) { // if quoting a buy, get fee from the front
            (uint256 _amountWithFee,) = _getAmountWithFee(_params.amountIn, _routerFee);
            _params.amountIn = _amountWithFee;
        }
        (
            _amountOut, 
            _sqrtPriceX96After, 
            _initializedTicksCrossed,
            _gasEstimate
        ) = IUniswapV3QuoterV2(_quoter).quoteExactInputSingle(_params);
        if (_params.tokenOut == m_WethAddress) { // if quoting a sell, get fee from the back
            (uint256 _amountWithFee,) = _getAmountWithFee(_amountOut, _routerFee);
            _amountOut = _amountWithFee;
        }
    }
    
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        address _pair, 
        address _get, 
        uint256 _amountOutMin,
        uint256 _routerFee,
        uint256 _deadline
    )  external payable ensure(_deadline) {
        require(_get != address(WETH), "BarkBot Router: INVALID_PATH");
        (uint256 _amountIn,) = _getAmountWithFee(msg.value, _routerFee);
        WETH.deposit{value: _amountIn}();
        assert(WETH.transfer(_pair, _amountIn));
        uint _balanceBefore = IERC20(_get).balanceOf(msg.sender);
        _swapSupportingFeeOnTransferTokens(_pair, m_WethAddress, _get, msg.sender);
        require(
            IERC20(_get).balanceOf(msg.sender) - _balanceBefore >= _amountOutMin,
            'BarkBot Router: INSUFFICIENT_OUTPUT_AMOUNT'
        );
        _transferETHToFeeRecipients();
    }
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        address _pair, 
        address _spend, 
        uint256 _amountIn, 
        uint256 _amountOutMin,
        uint256 _routerFee,
        uint256 _deadline
    ) external ensure(_deadline) {
        require(_spend != address(WETH), "BarkBot Router: INVALID_PATH");
        _checkApproved(_spend, _amountIn);
        TransferHelper.safeTransferFrom(_spend, msg.sender, _pair, _amountIn);
        _swapSupportingFeeOnTransferTokens(_pair, _spend, m_WethAddress, address(this));
        uint _amountOut = WETH.balanceOf(address(this));
        require(
            _amountOut >= _amountOutMin, 
            'BarkBot Router: INSUFFICIENT_OUTPUT_AMOUNT'
        );
        WETH.withdraw(_amountOut);
        (_amountOut,) = _getAmountWithFee(_amountOut, _routerFee);
        TransferHelper.safeTransferETH(msg.sender, _amountOut);
        _transferETHToFeeRecipients();
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        address _pair, 
        address _spend,
        address _get,
        uint256 _amountIn,
        uint256 _amountOutMin,
        uint256 _routerFee,
        uint256 _deadline
    ) external ensure(_deadline) {
        require(_spend != address(WETH) && _get != address(WETH), "BarkBot Router: INVALID_PATH");
        (_amountIn,) = _getAmountWithFee(_amountIn, _routerFee);
        _checkApproved(_spend, _amountIn);
        TransferHelper.safeTransferFrom(_spend, msg.sender, _pair, _amountIn);
        uint _balanceBefore = IERC20(_get).balanceOf(msg.sender);
        _swapSupportingFeeOnTransferTokens(_pair, _spend, _get, msg.sender);
        require(
            IERC20(_get).balanceOf(msg.sender) - _balanceBefore >= _amountOutMin,
            'BarkBot Router: INSUFFICIENT_OUTPUT_AMOUNT'
        );   
    }

    function _swapSupportingFeeOnTransferTokens(address _pairAddress, address _spend, address _get, address _to) internal virtual {
        (address _input, address _output) = (_spend, _get);
        (address _token0,) = UniswapV2Library.sortTokens(_input, _output);
        uint _amountInput;
        uint _amountOutput;
        IUniswapV2Pair _pair = IUniswapV2Pair(_pairAddress);
        { // scope to avoid stack too deep errors
        (uint _reserveIn, uint _reserveOut) = UniswapV2Library.getReserves(_pairAddress, _spend, _get);
        _amountInput = IERC20(_input).balanceOf(address(_pair)) - _reserveIn;
        _amountOutput = UniswapV2Library.getAmountOut(_amountInput, _reserveIn, _reserveOut);
        }
        (uint _amount0Out, uint _amount1Out) = _input == _token0 ? (uint(0), _amountOutput) : (_amountOutput, uint(0));
        _pair.swap(_amount0Out, _amount1Out, _to, new bytes(0));
    }

    function swapExactETHForTokensV3(
        address _factory,
        address _pair, 
        address _get, 
        uint256 _amountOutMin, 
        uint256 _routerFee,
        uint256 _deadline
    ) external ensure(_deadline) payable {
        (uint256 _amountIn,) = _getAmountWithFee(msg.value, _routerFee);
        uint256 _output = _swapTokensV3(_factory, _pair, m_WethAddress, _get, _amountIn);
        require(
            _output >= _amountOutMin, 
            "BarkBot Router: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        _transferETHToFeeRecipients();
    }
    
    function swapExactTokensForETHV3(
        address _factory,
        address _pair,
        address _spend, 
        uint256 _amountIn, 
        uint256 _amountOutMin, 
        uint256 _routerFee,
        uint256 _deadline
    ) external ensure(_deadline) payable {
        _checkApproved(_spend, _amountIn);
        uint256 _output = _swapTokensV3(_factory, _pair, _spend, m_WethAddress, _amountIn);
        require(
            _output >= _amountOutMin, 
            "BarkBot Router: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        WETH.withdraw(_output);
        (_output,) = _getAmountWithFee(_output, _routerFee);
        TransferHelper.safeTransferETH(msg.sender, _output);
        _transferETHToFeeRecipients();
    }

    function swapExactTokensForTokensV3(
        address _factory,
        address _pair, 
        address _spend, 
        address _get, 
        uint256 _amountIn, 
        uint256 _amountOutMin, 
        uint256 _routerFee,
        uint256 _deadline
    ) external ensure(_deadline) {
        _checkApproved(_spend, _amountIn);
        (_amountIn,) = _getAmountWithFee(_amountIn, _routerFee);
        uint256 _output = _swapTokensV3(_factory, _pair, _spend, _get, _amountIn);
        require(
            _output >= _amountOutMin, 
            "BarkBot Router: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }

    function _swapTokensV3(
        address _factory,
        address _pair,
        address _spend,
        address _get,
        uint256 _amountIn
    ) internal returns (uint256) {
        m_UniswapV3FactoryAddress = _factory;
        bool _zeroForOne = _spend < _get ? true : false;
        uint160 _sqrtPriceLimitX96 = _zeroForOne ? MIN_SQRT_RATIO : MAX_SQRT_RATIO;
        bytes memory _data = abi.encode(SwapDataV3(_spend, _get, IUniswapV3Pair(_pair).fee(), msg.sender));
        address _recipient = _get == m_WethAddress ? address(this) : msg.sender;
        (int256 _outputA, int256 _outputB) = 
            IUniswapV3Pair(_pair).swap(
                _recipient, 
                _zeroForOne, 
                SafeCast.toInt256(_amountIn), 
                _sqrtPriceLimitX96,
                _data
            );
        int256 _output = _zeroForOne ? _outputB : _outputA;
        _output = _output < 0 ? _output * -1 : _output;
        return SafeCast.toUint256(_output);
    }

    function _checkApproved(address _address, uint256 _amount) private view {
        IERC20 _token = IERC20(_address);
        uint256 _allowance = _token.allowance(msg.sender, address(this));
        uint256 _bal = _token.balanceOf(msg.sender);
        require(_bal >= _amount, "BarkBot Router: INSUFFICIENT_FUNDS");
        require(_allowance >= _amount, "BarkBot Router: NEEDS_APPROVAL");           
    }

    function _transferETHToFeeRecipients() internal {
        uint256 _bal = address(this).balance;
        for (uint i = 0; i < m_FeeRecipients.length; i++) {
            uint256 _fee = m_FeeRecipients[i].fee;
            if (_fee >= MIN_FEE_SIZE) {
                uint256 _amt = _bal * _fee / MAX_FEE_POOL;
                // cuidado ese :>
                if (_amt > address(this).balance) {
                    _amt = address(this).balance;
                    TransferHelper.safeTransferETH(m_FeeRecipients[i].recipient, _amt);
                    return;
                }
                TransferHelper.safeTransferETH(m_FeeRecipients[i].recipient, _amt);
            }
        }
    }
    
    function uniswapV3SwapCallback(int256 _amount0Delta, int256 _amount1Delta, bytes calldata _data) external override {
        SwapDataV3 memory _decoded = abi.decode(_data, (SwapDataV3));
        address _spend = _decoded.spend;
        address _get = _decoded.get;
        address _spender = _decoded.payer;
        address _recipient = msg.sender;

        address _pool = IUniswapV3Factory(m_UniswapV3FactoryAddress).getPool(_spend, _get, _decoded.fee);
        require(_pool == _recipient, "BarkBot Router: INVALID_RECIPIENT");
        uint256 _payment = _amount0Delta < 0 ? SafeCast.toUint256(_amount1Delta) : SafeCast.toUint256(_amount0Delta);

        if (_spend == m_WethAddress && address(this).balance >= _payment) {
            // buy
            WETH.deposit{value: _payment}(); 
            WETH.transfer(_recipient, _payment);
        } else {
            // sell
            IERC20(_spend).transferFrom(_spender, _recipient, _payment);
        }
    }

    function enableAdmin(address _address) external onlyAdmin {
        require(
            _address != address(0), 
            "Barkbot Router: INVALID_ADMIN_ADDRESS"
        );
        m_Admin[_address] = true;
    }

    function disableAdmin(address _address) external onlyAdmin {
        require(
            _address != msg.sender, 
            "Barkbot Router: ADMIN_PERMISSION_CONFLICT"
        );
        m_Admin[_address] = false;
    }

    function cleanMisplacedETH() external onlyAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }

    function weth() public view returns (address) {
        return m_WethAddress;
    }

    function getMaxFeePool() onlyAdmin public view returns (uint256) {
        return MAX_FEE_POOL;
    }

    function getAllocatedFeePool() onlyAdmin public view returns (uint256 _feePool) {
        for (uint i = 0; i < m_FeeRecipients.length; i++) {
            _feePool += m_FeeRecipients[i].fee;
        }
    }
    
    function getRecipientFee(address _recipient) onlyAdmin public view returns (uint256) {
        for (uint i = 0; i < m_FeeRecipients.length; i++) {
            if (m_FeeRecipients[i].recipient == _recipient) {
                return m_FeeRecipients[i].fee;
            }
        }
    }

    function setFeeRecipient(address _recipient, uint256 _fee) onlyAdmin public {
        require(
            _fee >= MIN_FEE_SIZE,
            "BarkBot Router: FEE_TOO_SMALL"
        );

        uint256 _feePool = getAllocatedFeePool();

        for (uint i = 0; i < m_FeeRecipients.length; i++) {
            if (m_FeeRecipients[i].recipient == _recipient) {
                require(
                    _feePool + _fee - m_FeeRecipients[i].fee <= MAX_FEE_POOL,
                    "BarkBot Router: FEE_OVERFLOW_FOR_EXISTING"
                );
                m_FeeRecipients[i].fee = _fee;
                return;
            }
        }

        require(
            _feePool + _fee <= MAX_FEE_POOL,
            "BarkBot Router: FEE_OVERFLOW_FOR_NEW"
        );

        // No existing recipient was reached. Create new...
        m_FeeRecipients.push(FeeRecipient(_recipient, _fee));
    }

    function disableFeeRecipient(address _recipient) onlyAdmin public {
        for (uint i = 0; i < m_FeeRecipients.length; i++) {
            if (m_FeeRecipients[i].recipient == _recipient) {
                m_FeeRecipients[i].fee = 0;
                return;
            }
        }
    }
}