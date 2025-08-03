// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract KekotronErrors {
    /*
    error OnlyOwner();

    error WethDeposit();
    error WethWithdraw();
    error EthTransfer();
    error TokenTransfer();
    error TokenTransferFrom();

    error TooLittleReceived();
    error InsufficientInputAmount();
    error InsufficientOutputAmount();
    error InsufficientLiquidity();
    error InvalidCallbackPool();

    error InvalidVersion();
    */
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "src/interfaces/IERC20.sol";
import "src/interfaces/IWETH.sol";
import "./KekotronErrors.sol";

library KekotronLib {
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        if (!(success && (data.length == 0 || abi.decode(data, (bool))))) { 
            revert("KekotronErrors.TokenTransfer"); 
        }
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        if (!(success && (data.length == 0 || abi.decode(data, (bool))))) { 
            revert("KekotronErrors.TokenTransferFrom"); 
        }
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success,) = to.call{value: value}(new bytes(0));
        if (!success) { 
            revert("KekotronErrors.EthTransfer"); 
        }
    }

    function depositWETH(address weth, uint256 value) internal {
        (bool success, ) = weth.call{value: value}(new bytes(0));
        if (!success) { 
            revert("KekotronErrors.WethDeposit"); 
        }
    }

    function withdrawWETH(address weth, uint256 value) internal {
        (bool success, ) = weth.call(abi.encodeWithSelector(IWETH.withdraw.selector, value));
        if (!success) { 
            revert("KekotronErrors.WethWithdraw"); 
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "solmate/auth/Owned.sol";
import "./KekotronSwapV2.sol";
import "./KekotronSwapV3.sol";
import "./KekotronErrors.sol";

contract KekotronRouterV1 is Owned, KekotronSwapV2, KekotronSwapV3 {

    uint8 public fee = 100; // 1%
    address public feeReceiver;

    constructor(address owner, address receiver, address weth) Owned(owner) KekotronSwapV2(weth) KekotronSwapV3(weth) {
        feeReceiver = receiver;
    }

    function _requireIsOwner() internal view {
        if (msg.sender != owner) { 
            revert("KekotronErrors.OnlyOwner"); 
        }
    }

    function updateFee(uint8 newFee) external {
        _requireIsOwner();
        fee = newFee;
    }

    function updateFeeReceiver(address newFeeReceiver) external {
        _requireIsOwner();
        feeReceiver = newFeeReceiver;
    }

    fallback() payable external {

        bytes4 selector = bytes4(msg.data[:4]);

        if (selector == 0x10d1e85c) {
            (address sender, uint256 amount0, uint256 amount1, bytes memory data) = abi.decode(msg.data[4:], (address, uint256, uint256, bytes));
            return _callbackV2(sender, amount0, amount1, data);
        }

        if (selector == 0xfa461e33) {
            (int256 amount0Delta, int256 amount1Delta, bytes memory data) = abi.decode(msg.data[4:], (int256, int256, bytes));
            return _callbackV3(amount0Delta, amount1Delta, data);
        }
        
        uint8 version;
        uint8 feeOn;

        assembly {
            version := byte(0, calldataload(0))
            feeOn := byte(1, calldataload(0))
        }

        if (version == 0) { // v2
            SwapV2 memory swapV2;

            assembly {
                let offset := 0x02
                calldatacopy(add(swapV2, 0x0c), offset, 0x14)               // pool
                calldatacopy(add(swapV2, 0x2c), add(offset, 0x14), 0x14)    // tokenIn
                calldatacopy(add(swapV2, 0x4c), add(offset, 0x28), 0x14)    // tokenIn
                calldatacopy(add(swapV2, 0x70), add(offset, 0x3c), 0x10)    // amountIn
                calldatacopy(add(swapV2, 0x90), add(offset, 0x4c), 0x20)    // amountOut
            }

            return _swapExactInputV2(swapV2, feeReceiver, fee, feeOn);
        }

        if (version == 1) { // v3 
            SwapV3 memory swapV3;

            assembly {
                let offset := 0x02
                calldatacopy(add(swapV3, 0x0c), offset, 0x14)               // pool
                calldatacopy(add(swapV3, 0x2c), add(offset, 0x14), 0x14)    // tokenIn
                calldatacopy(add(swapV3, 0x4c), add(offset, 0x28), 0x14)    // tokenIn
                calldatacopy(add(swapV3, 0x70), add(offset, 0x3c), 0x10)    // amountIn
                calldatacopy(add(swapV3, 0x90), add(offset, 0x4c), 0x20)    // amountOut
            }

            return _swapExactInputV3(swapV3, feeReceiver, fee, feeOn);
        }

        revert("KekotronErrors.InvalidVersion");
    }

    receive() payable external {}
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./interfaces/IWETH.sol";
import "./interfaces/IPoolV2.sol";
import "./KekotronLib.sol";
import "./KekotronErrors.sol";

contract KekotronSwapV2 {
    address private immutable WETH;

    constructor(address weth) {
        WETH = weth;
    }

    struct SwapV2 {
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 amountOut;
    }

    function _getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) private pure returns (uint256) {
        if (amountIn == 0) { 
            revert("KekotronErrors.InsufficientInputAmount"); 
        }
        if (reserveIn == 0 || reserveOut == 0) { 
            revert("KekotronErrors.InsufficientLiquidity"); 
        }

        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;

        return numerator / denominator;
    }

    function _swapV2(SwapV2 memory param, address to) private returns(uint256) {
        bool zeroForOne = param.tokenIn < param.tokenOut;

        uint256 amountOut;
        {
            (uint256 reserve0, uint256 reserve1, ) = IPoolV2(param.pool).getReserves();
            (uint256 reserveInput, uint256 reserveOutput) = zeroForOne ? (reserve0, reserve1) : (reserve1, reserve0);
            amountOut = _getAmountOut(IERC20(param.tokenIn).balanceOf(param.pool) - reserveInput, reserveInput, reserveOutput);
        }

        (uint256 amount0Out, uint256 amount1Out) = zeroForOne ? (uint256(0), amountOut) : (amountOut, uint256(0));

        uint256 balanceBefore = IERC20(param.tokenOut).balanceOf(to);
        IPoolV2(param.pool).swap(amount0Out, amount1Out, to, new bytes(0));
        uint256 balanceAfter = IERC20(param.tokenOut).balanceOf(to);

        return balanceAfter - balanceBefore;
    }

    function _swapExactEthForTokensV2(
        SwapV2 memory param,
        address feeReceiver,
        uint8 fee,
        uint8 feeOn
    ) private {      
        (bool feeIn, bool feeOut) = fee > 0 ? (feeOn == 0, feeOn == 1) : (false, false);
        uint256 amountFee;

        if (feeIn) {
            amountFee = param.amountIn * fee / 10_000;
            KekotronLib.safeTransferETH(feeReceiver, amountFee);
            param.amountIn -= amountFee;
            amountFee = 0;
        }

        KekotronLib.depositWETH(WETH, param.amountIn);
        KekotronLib.safeTransfer(WETH, param.pool, param.amountIn);

        uint256 amountOut = _swapV2(param, feeOut ? address(this) : msg.sender);

        if (feeOut) {
            amountFee = amountOut * fee / 10_000;
            amountOut = amountOut - amountFee;
        }

        if (amountOut < param.amountOut) { 
            revert("KekotronErrors.TooLittleReceived"); 
        }

        if (amountFee > 0) {
            KekotronLib.safeTransfer(param.tokenOut, feeReceiver, amountFee);
        }

        if (feeOut) {
            KekotronLib.safeTransfer(param.tokenOut, msg.sender, amountOut);
        }
    }

    function _swapExactTokensForEthV2(
        SwapV2 memory param,
        address feeReceiver,
        uint8 fee,
        uint8 feeOn
    ) private {
        (bool feeIn, bool feeOut) = fee > 0 ? (feeOn == 0, feeOn == 1) : (false, false);
        uint256 amountFee;

        if (feeIn) {
            amountFee = param.amountIn * fee / 10_000;
            KekotronLib.safeTransferFrom(param.tokenIn, msg.sender, feeReceiver, amountFee);
            param.amountIn -= amountFee;
            amountFee = 0;
        } 

        KekotronLib.safeTransferFrom(param.tokenIn, msg.sender, param.pool, param.amountIn);

        uint256 amountOut = _swapV2(param, address(this));

        KekotronLib.withdrawWETH(WETH, amountOut);

        if (feeOut) {
            amountFee = amountOut * fee / 10_000;
            amountOut = amountOut - amountFee;
        }

        if (amountOut < param.amountOut) { 
            revert("KekotronErrors.TooLittleReceived"); 
        }

        if (amountFee > 0) {
            KekotronLib.safeTransferETH(feeReceiver, amountFee);
        }

        KekotronLib.safeTransferETH(msg.sender, amountOut);
    }
    
    function _swapExactTokensForTokensV2(
        SwapV2 memory param,
        address feeReceiver,
        uint8 fee,
        uint8 feeOn
    ) private {
        (bool feeIn, bool feeOut) = fee > 0 ? (feeOn == 0, feeOn == 1) : (false, false);
        uint256 amountFee;

        if (feeIn) {
            amountFee = param.amountIn * fee / 10_000;
            KekotronLib.safeTransferFrom(param.tokenIn, msg.sender, feeReceiver, amountFee);
            param.amountIn -= amountFee;
            amountFee = 0;
        } 

        KekotronLib.safeTransferFrom(param.tokenIn, msg.sender, param.pool, param.amountIn);

        uint256 amountOut = _swapV2(param, feeOut ? address(this) : msg.sender);

        if (feeOut) {
            amountFee = amountOut * fee / 10_000;
            amountOut = amountOut - amountFee;
        }

        if (amountOut < param.amountOut) { 
            revert("KekotronErrors.TooLittleReceived"); 
        }

        if (amountFee > 0) {
            KekotronLib.safeTransfer(param.tokenOut, feeReceiver, amountFee);
        }

        if (feeOut) {
            KekotronLib.safeTransfer(param.tokenOut, msg.sender, amountOut);
        }
    }

    function _swapExactInputV2(
        SwapV2 memory param,
        address feeReceiver,
        uint8 fee,
        uint8 feeOn
    ) internal {
        if (param.tokenIn == address(0)) {
            param.tokenIn = WETH;
            return _swapExactEthForTokensV2(param, feeReceiver, fee, feeOn);
        }

        if (param.tokenOut == address(0)) {
            param.tokenOut = WETH;
            return _swapExactTokensForEthV2(param, feeReceiver, fee, feeOn);
        }

        return _swapExactTokensForTokensV2(param, feeReceiver, fee, feeOn);
    }

    function _callbackV2(
        address,
        uint256,
        uint256,
        bytes memory
    ) internal {}
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./interfaces/IWETH.sol";
import "./interfaces/IPoolV3.sol";
import "./KekotronLib.sol";
import "./KekotronErrors.sol";

contract KekotronSwapV3 {
    address private immutable WETH;

    address private constant FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    bytes32 private constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    constructor(address weth) {
        WETH = weth;
    }

    struct SwapV3 {
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 amountOut;
    }

    function _computePool(address tokenIn, address tokenOut, uint24 fee) private pure returns(address) {
        address tokenA;
        address tokenB;

        if (tokenIn < tokenOut) {
            tokenA = tokenIn;
            tokenB = tokenOut;
        } else {
            tokenA = tokenOut;
            tokenB = tokenIn;
        }

        address pool = address(uint160(uint256(
            keccak256(
                abi.encodePacked(
                    hex'ff',
                    FACTORY,
                    keccak256(abi.encode(tokenA, tokenB, fee)),
                    POOL_INIT_CODE_HASH
                )
            )
        )));

        return pool;
    }

    function _deriveData(SwapV3 memory param, address payer) private view returns(bool, int256, uint160, bytes memory) {
        bool zeroForOne = param.tokenIn < param.tokenOut;

        int256 amountSpecified = int256(param.amountIn);
        uint160 sqrtPriceLimitX96 = (zeroForOne ? 4295128749 : 1461446703485210103287273052203988822378723970341);
        bytes memory data = abi.encode(param.tokenIn, param.tokenOut, IPoolV3(param.pool).fee(), param.amountOut, payer);

        return (zeroForOne, amountSpecified, sqrtPriceLimitX96, data);
    }

    function _swapV3(SwapV3 memory param, address to, address payer) private returns(uint256) {
        (
            bool zeroForOne, 
            int256 amountSpecified, 
            uint160 sqrtPriceLimitX96, 
            bytes memory data
        ) = _deriveData(param, payer);

        (int256 amount0, int256 amount1) = IPoolV3(param.pool).swap(to, zeroForOne, amountSpecified, sqrtPriceLimitX96, data);
        uint256 amountOut = uint256(-(zeroForOne ? amount1 : amount0));

        return amountOut;
    }

    function _swapExactEthForTokensV3(
        SwapV3 memory param,
        address feeReceiver,
        uint8 fee,
        uint8 feeOn
    ) private {   
        (bool feeIn, bool feeOut) = fee > 0 ? (feeOn == 0, feeOn == 1) : (false, false);
        uint256 amountFee;

        if (feeIn) {
            amountFee = param.amountIn * fee / 10_000;
            KekotronLib.safeTransferETH(feeReceiver, amountFee);
            param.amountIn -= amountFee;
            amountFee = 0;
        }

        KekotronLib.depositWETH(WETH, param.amountIn);

        uint256 amountOut = _swapV3(param, feeOut ? address(this) : msg.sender, address(this));

        if (feeOut) {
            amountFee = amountOut * fee / 10_000;
            amountOut = amountOut - amountFee;
        }

        if (amountOut < param.amountOut) { 
            revert("KekotronErrors.TooLittleReceived"); 
        }

        if (amountFee > 0) {
            KekotronLib.safeTransfer(param.tokenOut, feeReceiver, amountFee);
        }

        if (feeOut) {
            KekotronLib.safeTransfer(param.tokenOut, msg.sender, amountOut);
        }
    }

    function _swapExactTokensForEthV3(
        SwapV3 memory param,
        address feeReceiver,
        uint8 fee,
        uint8 feeOn
    ) private {
        (bool feeIn, bool feeOut) = fee > 0 ? (feeOn == 0, feeOn == 1) : (false, false);
        uint256 amountFee;

        if (feeIn) {
            amountFee= param.amountIn * fee / 10_000;
            KekotronLib.safeTransferFrom(param.tokenIn, msg.sender, feeReceiver, amountFee);
            param.amountIn -= amountFee;
            amountFee = 0;
        } 
 
        uint256 amountOut = _swapV3(param, address(this), msg.sender);
        
        KekotronLib.withdrawWETH(WETH, amountOut);
        
        if (feeOut) {
            amountFee = amountOut * fee / 10_000;
            amountOut = amountOut - amountFee;
        }

        if (amountOut < param.amountOut) { 
            revert("KekotronErrors.TooLittleReceived"); 
        }

        if (amountFee > 0) {
            KekotronLib.safeTransferETH(feeReceiver, amountFee);
        }

        KekotronLib.safeTransferETH(msg.sender, amountOut);
    }

    function _swapExactTokensForTokensV3(
        SwapV3 memory param,
        address feeReceiver,
        uint8 fee,
        uint8 feeOn
    ) private {
        (bool feeIn, bool feeOut) = fee > 0 ? (feeOn == 0, feeOn == 1) : (false, false);
        uint256 amountFee;

        if (feeIn) {
            amountFee = param.amountIn * fee / 10_000;
            KekotronLib.safeTransferFrom(param.tokenIn, msg.sender, feeReceiver, amountFee);
            param.amountIn -= amountFee;
            amountFee = 0;
        } 

        uint256 amountOut = _swapV3(param, feeOut ? address(this) : msg.sender, msg.sender);

        if (feeOut) {
            amountFee = amountOut * fee / 10_000;
            amountOut = amountOut - amountFee;
        }

        if (amountOut < param.amountOut) { 
            revert("KekotronErrors.TooLittleReceived"); 
        }

        if (amountFee > 0) {
            KekotronLib.safeTransfer(param.tokenOut, feeReceiver, amountFee);
        }

        if (feeOut) {
            KekotronLib.safeTransfer(param.tokenOut, msg.sender, amountOut);
        }
    }

    function _swapExactInputV3(
        SwapV3 memory param,
        address feeReceiver,
        uint8 fee,
        uint8 feeOn
    ) internal {
        if (param.tokenIn == address(0)) {
            param.tokenIn = WETH;
            return _swapExactEthForTokensV3(param, feeReceiver, fee, feeOn);
        }

        if (param.tokenOut == address(0)) {
            param.tokenOut = WETH;
            return _swapExactTokensForEthV3(param, feeReceiver, fee, feeOn);
        }

        return _swapExactTokensForTokensV3(param, feeReceiver, fee, feeOn);
    }

    function _callbackV3(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes memory data
    ) internal {
        if (amount0Delta == 0 && amount1Delta == 0) {
            revert("KekotronErrors.InsufficientLiquidity");
        }

        (
            address tokenIn,
            address tokenOut,
            uint24 fee,
            uint256 limit,
            address payer
        ) = abi.decode(data, (address, address, uint24, uint256, address));

        if (msg.sender != _computePool(tokenIn, tokenOut, fee)) {
            revert("KekotronErrors.InvalidCallbackPool");
        }

        bool zeroForOne = tokenIn < tokenOut;

        if(uint256(-(zeroForOne ? amount1Delta : amount0Delta)) < limit) {
            revert("KekotronErrors.TooLittleReceived");
        }

        if (payer == address(this)) {
            KekotronLib.safeTransfer(tokenIn, msg.sender, uint256(zeroForOne ? amount0Delta : amount1Delta));
        } else {
            KekotronLib.safeTransferFrom(tokenIn, payer, msg.sender, uint256(zeroForOne ? amount0Delta : amount1Delta));
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IPoolV2 {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IPoolV3 {
    function fee() external view returns (uint24);
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IWETH {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}