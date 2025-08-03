pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

import "lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "lib/v2-periphery/contracts/interfaces/IERC20.sol";

contract TokenSwap {
    /// @notice Address of the DeepBotRouterV1
    address public immutable DEEP_BOT_ROUTER_V1;

    constructor(address _deepBotRouterV1) public {
        DEEP_BOT_ROUTER_V1 = _deepBotRouterV1;
    }
    
    /// @notice Function to swap exact amount of ERC20 tokens to as much ETH as possible.
    /// @param _tokenIn Address of the input token.
    /// @param _amountIn The amount of input tokens to send.
    /// @param _amountOutMin The minimum amount of ETH that must be received for the transaction not to revert. 
    /// @param _to Recipient of the ETH.
    /// @param _deadline Unix timestamp after which the transaction will revert.
    /// @return Amount of ETH received.
    function swapExactTokensForETH(
        address _tokenIn,
        uint256 _amountIn, 
        uint256 _amountOutMin,  
        address _to, 
        uint256 _deadline
    ) external returns (uint256) {
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenIn).approve(DEEP_BOT_ROUTER_V1, _amountIn);

        address[] memory _path = new address[](2);
        _path[0] = _tokenIn;
        _path[1] = IUniswapV2Router02(DEEP_BOT_ROUTER_V1).WETH();
        
        uint256[] memory amounts = IUniswapV2Router02(DEEP_BOT_ROUTER_V1).swapExactTokensForETH(
            _amountIn, 
            _amountOutMin, 
            _path, 
            _to, 
            _deadline
        );

        return amounts[1];
    }

    /// @notice Function to swap exact amount of ETH for as many ERC20 tokens as possible.
    /// @dev Reverts if 'msg.value' sent along is zero.
    /// @param _tokenOut Address of the output token.
    /// @param _amountOutMin The minimum amount of output tokens that must be received for the transaction not to revert.
    /// @param _to Recipient of the output tokens.
    /// @param _deadline Unix timestamp after which the transaction will revert.
    /// @return Amount of ERC20 tokens received.
    function swapExactETHForTokens(
        address _tokenOut,
        uint256 _amountOutMin,  
        address _to, 
        uint256 _deadline
    ) external payable returns (uint256) {
        require(msg.value > 0, "Insufficient ETH sent.");

        address[] memory _path = new address[](2);
        _path[0] = IUniswapV2Router02(DEEP_BOT_ROUTER_V1).WETH();
        _path[1] = _tokenOut;

        uint256[] memory amounts = IUniswapV2Router02(DEEP_BOT_ROUTER_V1).swapExactETHForTokens{value: msg.value}(
            _amountOutMin, 
            _path, 
            _to, 
            _deadline
        );

        return amounts[1];
    }

    /// @notice Function to swap exact amount of ERC20 tokens that take a fee on transfer to as much ETH as possible.
    /// @param _amountIn The amount of ERC20 tokens to send.
    /// @param _amountOutMin The minimum amount of ETH that must be received for the transaction not to revert.
    /// @param _to Recipient of the ETH.
    /// @param _deadline Unix timestamp after which the transaction will revert.
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        address _tokenIn,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to,
        uint256 _deadline
    ) external {
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenIn).approve(DEEP_BOT_ROUTER_V1, _amountIn);

        address[] memory _path = new address[](2);
        _path[0] = _tokenIn;
        _path[1] = IUniswapV2Router02(DEEP_BOT_ROUTER_V1).WETH();

        IUniswapV2Router02(DEEP_BOT_ROUTER_V1).swapExactTokensForETHSupportingFeeOnTransferTokens(
            _amountIn,
            _amountOutMin,
            _path,
            _to,
            _deadline
        );
    }

    /// @notice Function to swap exact amount of ETH for as many ERC20 tokens as possible that take a fee on transfer.
    /// @dev Reverts if 'msg.value' sent along is zero.
    /// @param _amountOutMin The minimum amount of ERC20 tokens that must be received for the transaction not to revert.
    /// @param _to Recipient of the ERC20 tokens.
    /// @param _deadline Unix timestamp after which the transaction will revert.
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        address _tokenOut,
        uint256 _amountOutMin,
        address _to,
        uint256 _deadline
    ) external payable {
        require(msg.value > 0, "Insufficient ETH sent.");

        address[] memory _path = new address[](2);
        _path[0] = IUniswapV2Router02(DEEP_BOT_ROUTER_V1).WETH();
        _path[1] = _tokenOut;

        IUniswapV2Router02(DEEP_BOT_ROUTER_V1).swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            _amountOutMin,
            _path,
            _to,
            _deadline
        );
    }
}