// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@uniswap/v3-core/contracts/libraries/FixedPoint96.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IPeripheryImmutableState.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "./libraries/FullMath.sol";
import "./interfaces/IDecentralizedIndex.sol";
import "./interfaces/IDexAdapter.sol";
import "./interfaces/IIndexUtils.sol";
import "./interfaces/IStakingPoolToken.sol";
import "./interfaces/ITokenRewards.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV3Pool.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IWETH.sol";
import "./Zapper.sol";

contract IndexUtils is Context, IIndexUtils, Zapper {
    using SafeERC20 for IERC20;

    constructor(IV3TwapUtilities _v3TwapUtilities, IDexAdapter _dexAdapter) Zapper(_v3TwapUtilities, _dexAdapter) {}

    function bond(IDecentralizedIndex _indexFund, address _token, uint256 _amount, uint256 _amountMintMin) external {
        IDecentralizedIndex.IndexAssetInfo[] memory _assets = _indexFund.getAllAssets();
        uint256[] memory _balsBefore = new uint256[](_assets.length);

        uint256 _tokenCurSupply = _indexFund.totalAssets(_token);
        uint256 _tokenAmtSupplyRatioX96 =
            _indexFund.totalSupply() == 0 ? FixedPoint96.Q96 : (_amount * FixedPoint96.Q96) / _tokenCurSupply;
        uint256 _al = _assets.length;
        for (uint256 _i; _i < _al; _i++) {
            uint256 _amountNeeded = _indexFund.totalSupply() == 0
                ? _indexFund.getInitialAmount(_token, _amount, _assets[_i].token)
                : FullMath.mulDivRoundingUp(
                    _indexFund.totalAssets(_assets[_i].token), _tokenAmtSupplyRatioX96, FixedPoint96.Q96
                );
            _balsBefore[_i] = IERC20(_assets[_i].token).balanceOf(address(this));
            IERC20(_assets[_i].token).safeTransferFrom(_msgSender(), address(this), _amountNeeded);
            IERC20(_assets[_i].token).safeIncreaseAllowance(address(_indexFund), _amountNeeded);
        }
        uint256 _idxBalBefore = IERC20(_indexFund).balanceOf(address(this));
        _indexFund.bond(_token, _amount, _amountMintMin);
        IERC20(_indexFund).safeTransfer(_msgSender(), IERC20(_indexFund).balanceOf(address(this)) - _idxBalBefore);

        // refund any excess tokens to user we didn't use to bond
        for (uint256 _i; _i < _al; _i++) {
            _checkAndRefundERC20(_msgSender(), _assets[_i].token, _balsBefore[_i]);
        }
    }

    function addLPAndStake(
        IDecentralizedIndex _indexFund,
        uint256 _amountIdxTokens,
        address _pairedLpTokenProvided,
        uint256 _amtPairedLpTokenProvided,
        uint256 _amountPairedLpTokenMin,
        uint256 _slippage,
        uint256 _deadline
    ) external payable override returns (uint256 _amountOut) {
        address _indexFundAddy = address(_indexFund);
        address _pairedLpToken = _indexFund.PAIRED_LP_TOKEN();
        uint256 _idxTokensBefore = IERC20(_indexFundAddy).balanceOf(address(this));
        uint256 _pairedLpTokenBefore = IERC20(_pairedLpToken).balanceOf(address(this));
        uint256 _ethBefore = address(this).balance - msg.value;
        IERC20(_indexFundAddy).safeTransferFrom(_msgSender(), address(this), _amountIdxTokens);
        if (_pairedLpTokenProvided == address(0)) {
            require(msg.value > 0, "NEEDETH");
            _amtPairedLpTokenProvided = msg.value;
        } else {
            IERC20(_pairedLpTokenProvided).safeTransferFrom(_msgSender(), address(this), _amtPairedLpTokenProvided);
        }
        if (_pairedLpTokenProvided != _pairedLpToken) {
            _zap(_pairedLpTokenProvided, _pairedLpToken, _amtPairedLpTokenProvided, _amountPairedLpTokenMin);
        }

        IERC20(_pairedLpToken).safeIncreaseAllowance(
            _indexFundAddy, IERC20(_pairedLpToken).balanceOf(address(this)) - _pairedLpTokenBefore
        );

        // keeping 1 wei of each asset on the CA reduces transfer gas cost due to non-zero storage
        // so worth it to keep 1 wei in the CA if there's not any here already
        _amountOut = _indexFund.addLiquidityV2(
            IERC20(_indexFundAddy).balanceOf(address(this)) - (_idxTokensBefore == 0 ? 1 : _idxTokensBefore),
            IERC20(_pairedLpToken).balanceOf(address(this)) - (_pairedLpTokenBefore == 0 ? 1 : _pairedLpTokenBefore),
            _slippage,
            _deadline
        );
        require(_amountOut > 0, "LPM");

        IERC20(DEX_ADAPTER.getV2Pool(_indexFundAddy, _pairedLpToken)).safeIncreaseAllowance(
            _indexFund.lpStakingPool(), _amountOut
        );
        _amountOut = _stakeLPForUserHandlingLeftoverCheck(_indexFund.lpStakingPool(), _msgSender(), _amountOut);

        // refunds if needed for index tokens and pairedLpToken
        if (address(this).balance > _ethBefore) {
            (bool _s,) = payable(_msgSender()).call{value: address(this).balance - _ethBefore}("");
            require(_s && address(this).balance >= _ethBefore, "TOOMUCH");
        }
        _checkAndRefundERC20(_msgSender(), _indexFundAddy, _idxTokensBefore == 0 ? 1 : _idxTokensBefore);
        _checkAndRefundERC20(_msgSender(), _pairedLpToken, _pairedLpTokenBefore == 0 ? 1 : _pairedLpTokenBefore);
    }

    function unstakeAndRemoveLP(
        IDecentralizedIndex _indexFund,
        uint256 _amountStakedTokens,
        uint256 _minLPTokens,
        uint256 _minPairedLpToken,
        uint256 _deadline
    ) external override {
        address _stakingPool = _indexFund.lpStakingPool();
        address _pairedLpToken = _indexFund.PAIRED_LP_TOKEN();
        uint256 _stakingBalBefore = IERC20(_stakingPool).balanceOf(address(this));
        uint256 _pairedLpTokenBefore = IERC20(_pairedLpToken).balanceOf(address(this));
        IERC20(_stakingPool).safeTransferFrom(_msgSender(), address(this), _amountStakedTokens);
        uint256 _indexBalBefore = _unstakeAndRemoveLP(
            _indexFund,
            _stakingPool,
            IERC20(_stakingPool).balanceOf(address(this)) - _stakingBalBefore,
            _minLPTokens,
            _minPairedLpToken,
            _deadline
        );
        if (IERC20(address(_indexFund)).balanceOf(address(this)) > _indexBalBefore) {
            IERC20(address(_indexFund)).safeTransfer(
                _msgSender(), IERC20(address(_indexFund)).balanceOf(address(this)) - _indexBalBefore
            );
        }
        if (IERC20(_pairedLpToken).balanceOf(address(this)) > _pairedLpTokenBefore) {
            IERC20(_pairedLpToken).safeTransfer(
                _msgSender(), IERC20(_pairedLpToken).balanceOf(address(this)) - _pairedLpTokenBefore
            );
        }
    }

    function claimRewardsMulti(address[] memory _rewards) external {
        uint256 _rl = _rewards.length;
        for (uint256 _i; _i < _rl; _i++) {
            ITokenRewards(_rewards[_i]).claimReward(_msgSender());
        }
    }

    /// @dev the ERC20 approval for the input token to stake has already been approved
    function _stakeLPForUserHandlingLeftoverCheck(address _stakingPool, address _receiver, uint256 _stakeAmount)
        internal
        returns (uint256 _finalAmountOut)
    {
        _finalAmountOut = _stakeAmount;
        if (IERC20(_stakingPool).balanceOf(address(this)) > 0) {
            IStakingPoolToken(_stakingPool).stake(_receiver, _stakeAmount);
            return _finalAmountOut;
        }

        IStakingPoolToken(_stakingPool).stake(address(this), _stakeAmount);
        // leave 1 wei in the CA for future gas savings
        _finalAmountOut = IERC20(_stakingPool).balanceOf(address(this)) - 1;
        IERC20(_stakingPool).safeTransfer(_receiver, _finalAmountOut);
    }

    function _unstakeAndRemoveLP(
        IDecentralizedIndex _indexFund,
        address _stakingPool,
        uint256 _unstakeAmount,
        uint256 _minLPTokens,
        uint256 _minPairedLpTokens,
        uint256 _deadline
    ) internal returns (uint256 _fundTokensBefore) {
        address _pairedLpToken = _indexFund.PAIRED_LP_TOKEN();
        address _v2Pool = DEX_ADAPTER.getV2Pool(address(_indexFund), _pairedLpToken);
        uint256 _v2TokensBefore = IERC20(_v2Pool).balanceOf(address(this));
        IStakingPoolToken(_stakingPool).unstake(_unstakeAmount);

        _fundTokensBefore = _indexFund.balanceOf(address(this));
        IERC20(_v2Pool).safeIncreaseAllowance(
            address(_indexFund), IERC20(_v2Pool).balanceOf(address(this)) - _v2TokensBefore
        );
        _indexFund.removeLiquidityV2(
            IERC20(_v2Pool).balanceOf(address(this)) - _v2TokensBefore, _minLPTokens, _minPairedLpTokens, _deadline
        );
    }

    function _bondToRecipient(
        IDecentralizedIndex _indexFund,
        address _indexToken,
        uint256 _bondTokens,
        uint256 _amountMintMin,
        address _recipient
    ) internal returns (uint256) {
        uint256 _idxTokensBefore = IERC20(address(_indexFund)).balanceOf(address(this));
        IERC20(_indexToken).safeIncreaseAllowance(address(_indexFund), _bondTokens);
        _indexFund.bond(_indexToken, _bondTokens, _amountMintMin);
        uint256 _idxTokensGained = IERC20(address(_indexFund)).balanceOf(address(this)) - _idxTokensBefore;
        if (_recipient != address(this)) {
            IERC20(address(_indexFund)).safeTransfer(_recipient, _idxTokensGained);
        }
        return _idxTokensGained;
    }

    function _checkAndRefundERC20(address _user, address _asset, uint256 _beforeBal) internal {
        uint256 _curBal = IERC20(_asset).balanceOf(address(this));
        if (_curBal > _beforeBal) {
            IERC20(_asset).safeTransfer(_user, _curBal - _beforeBal);
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@uniswap/v3-core/contracts/libraries/FixedPoint96.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IPeripheryImmutableState.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "./interfaces/ICurvePool.sol";
import "./interfaces/IDecentralizedIndex.sol";
import "./interfaces/IDexAdapter.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV3Pool.sol";
import "./interfaces/IV3TwapUtilities.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/IZapper.sol";

contract Zapper is IZapper, Context, Ownable {
    using SafeERC20 for IERC20;

    address constant STYETH = 0x583019fF0f430721aDa9cfb4fac8F06cA104d0B4;
    address constant YETH = 0x1BED97CBC3c24A4fb5C069C6E311a967386131f7;
    address constant WETH_YETH_POOL = 0x69ACcb968B19a53790f43e57558F5E443A91aF22;
    address constant V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address immutable V2_ROUTER;
    address immutable WETH;
    IV3TwapUtilities immutable V3_TWAP_UTILS;
    IDexAdapter immutable DEX_ADAPTER;

    // pool => slippage (1 == 0.1%, 1000 == 100%)
    mapping(address => uint256) _slippage;
    uint256 _defaultSlippage = 30; // 3%

    address public OHM = 0x64aa3364F17a4D01c6f1751Fd97C2BD3D7e7f1D5;
    address public pOHM;

    // token in => token out => swap pool(s)
    mapping(address => mapping(address => Pools)) public zapMap;
    // curve pool => token => idx
    mapping(address => mapping(address => int128)) public curveTokenIdx;

    constructor(IV3TwapUtilities _v3TwapUtilities, IDexAdapter _dexAdapter) Ownable(_msgSender()) {
        V2_ROUTER = _dexAdapter.V2_ROUTER();
        V3_TWAP_UTILS = _v3TwapUtilities;
        DEX_ADAPTER = _dexAdapter;
        WETH = _dexAdapter.WETH();

        if (block.chainid == 1) {
            // WETH/YETH
            _setZapMapFromPoolSingle(PoolType.CURVE, 0x69ACcb968B19a53790f43e57558F5E443A91aF22);
            // WETH/DAI
            _setZapMapFromPoolSingle(PoolType.V3, 0x60594a405d53811d3BC4766596EFD80fd545A270);
            // WETH/USDC
            _setZapMapFromPoolSingle(PoolType.V3, 0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640);
            // WETH/OHM
            _setZapMapFromPoolSingle(PoolType.V3, 0x88051B0eea095007D3bEf21aB287Be961f3d8598);
            // USDC/OHM
            _setZapMapFromPoolSingle(PoolType.V3, 0x893f503FaC2Ee1e5B78665db23F9c94017Aae97D);
        }
    }

    function _zap(address _in, address _out, uint256 _amountIn, uint256 _amountOutMin)
        internal
        returns (uint256 _amountOut)
    {
        if (_in == address(0)) {
            _amountIn = _ethToWETH(_amountIn);
            _in = WETH;
            if (_out == WETH) {
                return _amountIn;
            }
        }
        // handle pOHM separately through pod, modularize later
        bool _isOutPOHM;
        if (pOHM == _out) {
            _isOutPOHM = true;
            _out = OHM;
        }
        // handle yETH and st-yETH special through curve pool, modularize later
        if (_out == YETH || _out == STYETH) {
            require(_in == WETH, "YETHIN");
            return _wethToYeth(_amountIn, _amountOutMin, _out == STYETH);
        } else if (_in == YETH || _in == STYETH) {
            require(_out == WETH, "YETHOUT");
            return _styethToWeth(_amountIn, _amountOutMin, _in == YETH);
        }
        Pools memory _poolInfo = zapMap[_in][_out];
        // no pool so just try to swap over one path univ2
        if (_poolInfo.pool1 == address(0)) {
            address[] memory _path = new address[](2);
            _path[0] = _in;
            _path[1] = _out;
            _amountOut = _swapV2(_path, _amountIn, _amountOutMin);
        } else {
            bool _twoHops = _poolInfo.pool2 != address(0);
            if (_poolInfo.poolType == PoolType.CURVE) {
                // curve
                _amountOut = _swapCurve(
                    _poolInfo.pool1,
                    curveTokenIdx[_poolInfo.pool1][_in],
                    curveTokenIdx[_poolInfo.pool1][_out],
                    _amountIn,
                    _amountOutMin
                );
            } else if (_poolInfo.poolType == PoolType.V2) {
                // univ2
                address _token0 = IUniswapV2Pair(_poolInfo.pool1).token0();
                address[] memory _path = new address[](_twoHops ? 3 : 2);
                _path[0] = _in;
                _path[1] = !_twoHops ? _out : _token0 == _in ? IUniswapV2Pair(_poolInfo.pool1).token1() : _token0;
                if (_twoHops) {
                    _path[2] = _out;
                }
                _amountOut = _swapV2(_path, _amountIn, _amountOutMin);
            } else {
                // univ3
                if (_twoHops) {
                    address _t0 = IUniswapV3Pool(_poolInfo.pool1).token0();
                    _amountOut = _swapV3Multi(
                        _in,
                        _getPoolFee(_poolInfo.pool1),
                        _t0 == _in ? IUniswapV3Pool(_poolInfo.pool1).token1() : _t0,
                        _getPoolFee(_poolInfo.pool2),
                        _out,
                        _amountIn,
                        _amountOutMin
                    );
                } else {
                    _amountOut = _swapV3Single(_in, _getPoolFee(_poolInfo.pool1), _out, _amountIn, _amountOutMin);
                }
            }
        }
        if (!_isOutPOHM) {
            return _amountOut;
        }
        uint256 _pOHMBefore = IERC20(pOHM).balanceOf(address(this));
        IERC20(OHM).safeIncreaseAllowance(pOHM, _amountOut);
        IDecentralizedIndex(pOHM).bond(OHM, _amountOut, 0);
        return IERC20(pOHM).balanceOf(address(this)) - _pOHMBefore;
    }

    function _getPoolFee(address _pool) internal view returns (uint24) {
        return block.chainid == 42161 ? 0 : IUniswapV3Pool(_pool).fee();
    }

    function _ethToWETH(uint256 _amountETH) internal returns (uint256) {
        uint256 _wethBal = IERC20(WETH).balanceOf(address(this));
        IWETH(WETH).deposit{value: _amountETH}();
        return IERC20(WETH).balanceOf(address(this)) - _wethBal;
    }

    function _swapV3Single(address _in, uint24 _fee, address _out, uint256 _amountIn, uint256 _amountOutMin)
        internal
        returns (uint256)
    {
        address _v3Pool;
        try DEX_ADAPTER.getV3Pool(_in, _out, uint24(10000)) returns (address __v3Pool) {
            _v3Pool = __v3Pool;
        } catch {
            _v3Pool = DEX_ADAPTER.getV3Pool(_in, _out, int24(200));
        }
        if (_amountOutMin == 0) {
            address _token0 = _in < _out ? _in : _out;
            uint256 _poolPriceX96 =
                V3_TWAP_UTILS.priceX96FromSqrtPriceX96(V3_TWAP_UTILS.sqrtPriceX96FromPoolAndInterval(_v3Pool));
            _amountOutMin = _in == _token0
                ? (_poolPriceX96 * _amountIn) / FixedPoint96.Q96
                : (_amountIn * FixedPoint96.Q96) / _poolPriceX96;
        }

        uint256 _outBefore = IERC20(_out).balanceOf(address(this));
        uint256 _finalSlip = _slippage[_v3Pool] > 0 ? _slippage[_v3Pool] : _defaultSlippage;
        IERC20(_in).safeIncreaseAllowance(address(DEX_ADAPTER), _amountIn);
        DEX_ADAPTER.swapV3Single(
            _in, _out, _fee, _amountIn, (_amountOutMin * (1000 - _finalSlip)) / 1000, address(this)
        );
        return IERC20(_out).balanceOf(address(this)) - _outBefore;
    }

    function _swapV3Multi(
        address _in,
        uint24 _fee1,
        address _in2,
        uint24 _fee2,
        address _out,
        uint256 _amountIn,
        uint256 _amountOutMin
    ) internal returns (uint256) {
        uint256 _outBefore = IERC20(_out).balanceOf(address(this));
        IERC20(_in).safeIncreaseAllowance(V3_ROUTER, _amountIn);
        bytes memory _path = abi.encodePacked(_in, _fee1, _in2, _fee2, _out);
        ISwapRouter(V3_ROUTER).exactInput(
            ISwapRouter.ExactInputParams({
                path: _path,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: _amountIn,
                amountOutMinimum: _amountOutMin
            })
        );
        return IERC20(_out).balanceOf(address(this)) - _outBefore;
    }

    function _swapV2(address[] memory _path, uint256 _amountIn, uint256 _amountOutMin) internal returns (uint256) {
        bool _twoHops = _path.length == 3;
        address _out = _twoHops ? _path[2] : _path[1];
        uint256 _outBefore = IERC20(_out).balanceOf(address(this));
        IERC20(_path[0]).safeIncreaseAllowance(address(DEX_ADAPTER), _amountIn);
        DEX_ADAPTER.swapV2Single(_path[0], _path[1], _amountIn, _twoHops ? 0 : _amountOutMin, address(this));
        if (_twoHops) {
            uint256 _intermediateBal = IERC20(_path[1]).balanceOf(address(this));
            IERC20(_path[1]).safeIncreaseAllowance(address(DEX_ADAPTER), _intermediateBal);
            DEX_ADAPTER.swapV2Single(_path[1], _path[2], _intermediateBal, _amountOutMin, address(this));
        }
        return IERC20(_out).balanceOf(address(this)) - _outBefore;
    }

    function _swapCurve(address _pool, int128 _i, int128 _j, uint256 _amountIn, uint256 _amountOutMin)
        internal
        returns (uint256)
    {
        IERC20(ICurvePool(_pool).coins(uint128(_i))).safeIncreaseAllowance(_pool, _amountIn);
        return ICurvePool(_pool).exchange(_i, _j, _amountIn, _amountOutMin, address(this));
    }

    function _wethToYeth(uint256 _ethAmount, uint256 _minYethAmount, bool _stakeToStyeth) internal returns (uint256) {
        uint256 _boughtYeth = _swapCurve(WETH_YETH_POOL, 0, 1, _ethAmount, _minYethAmount);
        if (_stakeToStyeth) {
            IERC20(YETH).safeIncreaseAllowance(STYETH, _boughtYeth);
            return IERC4626(STYETH).deposit(_boughtYeth, address(this));
        }
        return _boughtYeth;
    }

    function _styethToWeth(uint256 _stYethAmount, uint256 _minWethAmount, bool _isYethOnly)
        internal
        returns (uint256)
    {
        uint256 _yethAmount;
        if (_isYethOnly) {
            _yethAmount = _stYethAmount;
        } else {
            _yethAmount = IERC4626(STYETH).redeem(_stYethAmount, address(this), address(this));
        }
        return _swapCurve(WETH_YETH_POOL, 1, 0, _yethAmount, _minWethAmount);
    }

    function _setZapMapFromPoolSingle(PoolType _type, address _pool) internal {
        address _t0;
        address _t1;
        if (_type == PoolType.CURVE) {
            _t0 = ICurvePool(_pool).coins(0);
            _t1 = ICurvePool(_pool).coins(1);
            curveTokenIdx[_pool][_t0] = 0;
            curveTokenIdx[_pool][_t1] = 1;
        } else {
            _t0 = IUniswapV3Pool(_pool).token0();
            _t1 = IUniswapV3Pool(_pool).token1();
        }
        Pools memory _poolConf = Pools({poolType: _type, pool1: _pool, pool2: address(0)});
        zapMap[_t0][_t1] = _poolConf;
        zapMap[_t1][_t0] = _poolConf;
    }

    function setOHM(address _OHM, address _pOHM) external onlyOwner {
        OHM = _OHM == address(0) ? OHM : _OHM;
        pOHM = _pOHM == address(0) ? pOHM : _pOHM;
    }

    function setPoolSlippage(address _pool, uint256 _slip) external onlyOwner {
        require(_slip >= 0 && _slip <= 1000, "B");
        _slippage[_pool] = _slip;
    }

    function setDefaultSlippage(uint256 _slip) external onlyOwner {
        require(_slip >= 0 && _slip <= 1000, "B");
        _defaultSlippage = _slip;
    }

    function setZapMap(address _in, address _out, Pools memory _pools) external onlyOwner {
        zapMap[_in][_out] = _pools;
    }

    function setZapMapFromPoolSingle(PoolType _type, address _pool) external onlyOwner {
        _setZapMapFromPoolSingle(_type, _pool);
    }

    function rescueETH() external onlyOwner {
        (bool _sent,) = payable(owner()).call{value: address(this).balance}("");
        require(_sent);
    }

    function rescueERC20(IERC20 _token) external onlyOwner {
        require(_token.balanceOf(address(this)) > 0);
        _token.safeTransfer(owner(), _token.balanceOf(address(this)));
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ICurvePool {
    function coins(uint256 _idx) external returns (address);

    function exchange(int128 i, int128 j, uint256 dx, uint256 minDy, address receiver) external returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IDexAdapter.sol";

interface IDecentralizedIndex is IERC20 {
    enum IndexType {
        WEIGHTED,
        UNWEIGHTED
    }

    struct Config {
        address partner;
        uint256 debondCooldown;
        bool hasTransferTax;
    }

    // all fees: 1 == 0.01%, 10 == 0.1%, 100 == 1%
    struct Fees {
        uint16 burn;
        uint16 bond;
        uint16 debond;
        uint16 buy;
        uint16 sell;
        uint16 partner;
    }

    struct IndexAssetInfo {
        address token;
        uint256 weighting;
        uint256 basePriceUSDX96;
        address c1; // arbitrary contract/address field we can use for an index
        uint256 q1; // arbitrary quantity/number field we can use for an index
    }

    /// @notice The ```Create``` event fires when a new decentralized index has been created
    /// @param newIdx The CA of the new index contract
    /// @param wallet The creator of the new index
    event Create(address indexed newIdx, address indexed wallet);

    /// @notice The ```FlashLoan``` event fires when someone flash loans assets from the pod
    /// @param executor The sender of the request
    /// @param recipient The recipient of the flashed funds
    /// @param token The token being flash loaned
    /// @param amount The amount of token to flash loan
    event FlashLoan(address indexed executor, address indexed recipient, address token, uint256 amount);

    /// @notice The ```FlashMint``` event fires when someone flash mints pTKN from the pod
    /// @param executor The sender of the request
    /// @param recipient The recipient of the flashed funds
    /// @param amount The amount of pTKN to flash mint
    event FlashMint(address indexed executor, address indexed recipient, uint256 amount);

    /// @notice The ```Initialize``` event fires when the new pod has been initialized,
    /// @notice which is at creation on some and in another txn for others (gas limits)
    /// @param wallet The wallet that initialized
    /// @param v2Pool The new UniV2 derivative pool that was created at initialization
    event Initialize(address indexed wallet, address v2Pool);

    /// @notice The ```Bond``` event fires when someone wraps into the pod which mints new pod tokens
    /// @param wallet The wallet that wrapped
    /// @param token The token that was used as a ref to wrap into, representing an underlying tkn
    /// @param amountTokensBonded Amount of underlying tkns used to wrap/bond
    /// @param amountTokensMinted Amount of new pod tokens (pTKN) minted
    event Bond(address indexed wallet, address indexed token, uint256 amountTokensBonded, uint256 amountTokensMinted);

    /// @notice The ```Debond``` event fires when someone unwraps from a pod and redeems underlying tkn(s)
    /// @param wallet The wallet that unwrapped/debond
    /// @param amountDebonded Amount of pTKNs burned/unwrapped
    event Debond(address indexed wallet, uint256 amountDebonded);

    /// @notice The ```AddLiquidity``` event fires when new liquidity (LP) for a pod is added
    /// @param wallet The wallet that added LP
    /// @param amountTokens Amount of pTKNs used for LP
    /// @param amountDAI Amount of pairedLpAsset used for LP
    event AddLiquidity(address indexed wallet, uint256 amountTokens, uint256 amountDAI);

    /// @notice The ```RemoveLiquidity``` event fires when LP is removed for a pod
    /// @param wallet The wallet that removed LP
    /// @param amountLiquidity Amount of liquidity removed
    event RemoveLiquidity(address indexed wallet, uint256 amountLiquidity);

    event SetPartner(address indexed wallet, address newPartner);

    event SetPartnerFee(address indexed wallet, uint16 newFee);

    function BOND_FEE() external view returns (uint16);

    function DEBOND_FEE() external view returns (uint16);

    function DEX_HANDLER() external view returns (IDexAdapter);

    function FLASH_FEE_AMOUNT_DAI() external view returns (uint256);

    function PAIRED_LP_TOKEN() external view returns (address);

    function config() external view returns (Config calldata);

    function fees() external view returns (Fees calldata);

    function unlocked() external view returns (uint8);

    function indexType() external view returns (IndexType);

    function created() external view returns (uint256);

    function lpStakingPool() external view returns (address);

    function lpRewardsToken() external view returns (address);

    function isAsset(address token) external view returns (bool);

    function getAllAssets() external view returns (IndexAssetInfo[] memory);

    function getInitialAmount(address sToken, uint256 sAmount, address tToken) external view returns (uint256);

    function processPreSwapFeesAndSwap() external;

    function totalAssets() external view returns (uint256 totalManagedAssets);

    function totalAssets(address asset) external view returns (uint256 totalManagedAssets);

    function convertToShares(uint256 assets) external view returns (uint256 shares);

    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    function setup() external;

    function bond(address token, uint256 amount, uint256 amountMintMin) external;

    function debond(uint256 amount, address[] memory token, uint8[] memory percentage) external;

    function addLiquidityV2(uint256 idxTokens, uint256 daiTokens, uint256 slippage, uint256 deadline)
        external
        returns (uint256);

    function removeLiquidityV2(uint256 lpTokens, uint256 minTokens, uint256 minDAI, uint256 deadline) external;

    function flash(address recipient, address token, uint256 amount, bytes calldata data) external;

    function flashMint(address recipient, uint256 amount, bytes calldata data) external;

    function setLpStakingPool(address lpStakingPool) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IDexAdapter {
    function ASYNC_INITIALIZE() external view returns (bool);

    function V2_ROUTER() external view returns (address);

    function V3_ROUTER() external view returns (address);

    function WETH() external view returns (address);

    function getV3Pool(address _token0, address _token1, int24 _tickSpacing) external view returns (address _pool);

    function getV3Pool(address _token0, address _token1, uint24 _poolFee) external view returns (address _pool);

    function getV2Pool(address _token0, address _token1) external view returns (address _pool);

    function createV2Pool(address _token0, address _token1) external returns (address _pool);

    function getReserves(address _pool) external view returns (uint112, uint112);

    function swapV2Single(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _recipient
    ) external returns (uint256 _amountOut);

    function swapV2SingleExactOut(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountInMax,
        uint256 _amountOut,
        address _recipient
    ) external returns (uint256 _amountInUsed);

    function swapV3Single(
        address _tokenIn,
        address _tokenOut,
        uint24 _fee,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _recipient
    ) external returns (uint256 _amountOut);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external;

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./IDecentralizedIndex.sol";

interface IIndexUtils {
    function addLPAndStake(
        IDecentralizedIndex indexFund,
        uint256 amountIdxTokens,
        address pairedLpTokenProvided,
        uint256 amtPairedLpTokenProvided,
        uint256 amountPairedLpTokenMin,
        uint256 slippage,
        uint256 deadline
    ) external payable returns (uint256 amountOut);

    function unstakeAndRemoveLP(
        IDecentralizedIndex indexFund,
        uint256 amountStakedTokens,
        uint256 minLPTokens,
        uint256 minPairedLpToken,
        uint256 deadline
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IStakingPoolToken {
    event Stake(address indexed executor, address indexed user, uint256 amount);

    event Unstake(address indexed user, uint256 amount);

    function INDEX_FUND() external view returns (address);

    function POOL_REWARDS() external view returns (address);

    function stakingToken() external view returns (address);

    function stakeUserRestriction() external view returns (address);

    function stake(address user, uint256 amount) external;

    function unstake(uint256 amount) external;

    function setPoolRewards(address poolRewards) external;

    function setStakingToken(address stakingToken) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ITokenRewards {
    event AddShares(address indexed wallet, uint256 amount);

    event RemoveShares(address indexed wallet, uint256 amount);

    event ClaimReward(address indexed wallet);

    event DistributeReward(address indexed wallet, address indexed token, uint256 amount);

    event DepositRewards(address indexed wallet, address indexed token, uint256 amount);

    event RewardSwapError(uint256 amountIn);

    function totalShares() external view returns (uint256);

    function totalStakers() external view returns (uint256);

    function rewardsToken() external view returns (address);

    function trackingToken() external view returns (address);

    function depositFromPairedLpToken(uint256 amount) external;

    function depositRewards(address token, uint256 amount) external;

    function depositRewardsNoTransfer(address token, uint256 amount) external;

    function claimReward(address wallet) external;

    function getAllRewardsTokens() external view returns (address[] memory);

    function setShares(address wallet, uint256 amount, bool sharesRemoving) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IUniswapV2Pair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IUniswapV2Router02 {
    function factory() external view returns (address);

    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IUniswapV3Pool {
    /// @notice The first of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token0() external view returns (address);

    /// @notice The second of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token1() external view returns (address);

    /// @notice The pool's fee in hundredths of a bip, i.e. 1e-6
    /// @return The fee
    function fee() external view returns (uint24);

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
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

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
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IV3TwapUtilities {
    function getV3Pool(address v3Factory, address token0, address token1) external view returns (address);

    function getV3Pool(address v3Factory, address token0, address token1, uint24 poolFee)
        external
        view
        returns (address);

    function getV3Pool(address v3Factory, address token0, address token1, int24 tickSpacing)
        external
        view
        returns (address);

    function getPoolPriceUSDX96(address pricePool, address nativeStablePool, address WETH9)
        external
        view
        returns (uint256);

    function sqrtPriceX96FromPoolAndInterval(address pool) external view returns (uint160);

    function sqrtPriceX96FromPoolAndPassedInterval(address pool, uint32 interval) external view returns (uint160);

    function priceX96FromSqrtPriceX96(uint160 sqrtPriceX96) external pure returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 _amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IZapper {
    enum PoolType {
        CURVE,
        V2,
        V3
    }

    struct Pools {
        PoolType poolType; // assume same for both pool1 and pool2
        address pool1;
        address pool2;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// https://github.com/Uniswap/v3-core/blob/0.8/contracts/libraries/FullMath.sol

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
    function mulDiv(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256 result) {
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
    function mulDivRoundingUp(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            result = mulDiv(a, b, denominator);
            if (mulmod(a, b, denominator) > 0) {
                require(result < type(uint256).max);
                result++;
            }
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/IERC1363.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC165} from "./IERC165.sol";

/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../utils/introspection/IERC165.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/IERC4626.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
import {IERC20Metadata} from "../token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @dev Interface of the ERC-4626 "Tokenized Vault Standard", as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
 */
interface IERC4626 is IERC20, IERC20Metadata {
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /**
     * @dev Returns the address of the underlying token used for the Vault for accounting, depositing, and withdrawing.
     *
     * - MUST be an ERC-20 token contract.
     * - MUST NOT revert.
     */
    function asset() external view returns (address assetTokenAddress);

    /**
     * @dev Returns the total amount of the underlying asset that is “managed” by Vault.
     *
     * - SHOULD include any compounding that occurs from yield.
     * - MUST be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT revert.
     */
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /**
     * @dev Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be deposited into the Vault for the receiver,
     * through a deposit call.
     *
     * - MUST return a limited value if receiver is subject to some deposit limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of assets that may be deposited.
     * - MUST NOT revert.
     */
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their deposit at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of Vault shares that would be minted in a deposit
     *   call in the same transaction. I.e. deposit should return the same or more shares as previewDeposit if called
     *   in the same transaction.
     * - MUST NOT account for deposit limits like those returned from maxDeposit and should always act as though the
     *   deposit would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewDeposit SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Mints shares Vault shares to receiver by depositing exactly amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   deposit execution, and are accounted for during deposit.
     * - MUST revert if all of assets cannot be deposited (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of the Vault shares that can be minted for the receiver, through a mint call.
     * - MUST return a limited value if receiver is subject to some mint limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of shares that may be minted.
     * - MUST NOT revert.
     */
    function maxMint(address receiver) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their mint at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of assets that would be deposited in a mint call
     *   in the same transaction. I.e. mint should return the same or fewer assets as previewMint if called in the
     *   same transaction.
     * - MUST NOT account for mint limits like those returned from maxMint and should always act as though the mint
     *   would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewMint SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by minting.
     */
    function previewMint(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Mints exactly shares Vault shares to receiver by depositing amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the mint
     *   execution, and are accounted for during mint.
     * - MUST revert if all of shares cannot be minted (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be withdrawn from the owner balance in the
     * Vault, through a withdraw call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their withdrawal at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of Vault shares that would be burned in a withdraw
     *   call in the same transaction. I.e. withdraw should return the same or fewer shares as previewWithdraw if
     *   called
     *   in the same transaction.
     * - MUST NOT account for withdrawal limits like those returned from maxWithdraw and should always act as though
     *   the withdrawal would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewWithdraw SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Burns shares from owner and sends exactly assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   withdraw execution, and are accounted for during withdraw.
     * - MUST revert if all of assets cannot be withdrawn (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * Note that some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of Vault shares that can be redeemed from the owner balance in the Vault,
     * through a redeem call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST return balanceOf(owner) if owner is not subject to any withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxRedeem(address owner) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their redeemption at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of assets that would be withdrawn in a redeem call
     *   in the same transaction. I.e. redeem should return the same or more assets as previewRedeem if called in the
     *   same transaction.
     * - MUST NOT account for redemption limits like those returned from maxRedeem and should always act as though the
     *   redemption would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewRedeem SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by redeeming.
     */
    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Burns exactly shares from owner and sends assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   redeem execution, and are accounted for during redeem.
     * - MUST revert if all of shares cannot be redeemed (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * NOTE: some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.2.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC1363} from "../../../interfaces/IERC1363.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
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
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

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
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.4.0;

/// @title FixedPoint96
/// @notice A library for handling binary fixed point numbers, see https://en.wikipedia.org/wiki/Q_(number_format)
/// @dev Used in SqrtPriceMath.sol
library FixedPoint96 {
    uint8 internal constant RESOLUTION = 96;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Immutable state
/// @notice Functions that return immutable state of the router
interface IPeripheryImmutableState {
    /// @return Returns the address of the Uniswap V3 factory
    function factory() external view returns (address);

    /// @return Returns the address of WETH9
    function WETH9() external view returns (address);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

import '@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol';

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