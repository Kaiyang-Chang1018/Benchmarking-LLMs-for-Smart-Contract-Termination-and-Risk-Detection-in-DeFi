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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

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
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC20.sol";

import "./interfaces/IEthCoin.sol";
import "./interfaces/uniswap-v3-periphery/INonfungiblePositionManager.sol";
import "./interfaces/uniswap-v3-periphery/ISwapRouter.sol";

contract FeeCollector is Ownable {
    /// @notice Uniswap v3 swapRouter
    ISwapRouter public immutable swapRouter;

    /// @notice Uniswap v3 nonfungiblePositionManager contract
    INonfungiblePositionManager public immutable nonfungiblePositionManager;

    /// @notice The address of Ethcoin
    address public immutable ETHC;

    /// @notice The address of WETH
    address public immutable WETH;

    /// @notice The token id of uniswap v3 ETHC/WETH position that this contract would add liquidity to
    uint256 public immutable tokenId;

    /// @notice The fee tier of the ETHC/WETH uniswap v3 pool
    uint24 public immutable fee;

    /// @notice The address of the operator
    address public operator;

    constructor(
        address _ETHC,
        address _WETH,
        address _swapRouter,
        address _nonfungiblePositionManager,
        uint256 _tokenId,
        address _operator
    ) Ownable(msg.sender) {
        operator = _operator;
        ETHC = _ETHC;
        WETH = _WETH;
        swapRouter = ISwapRouter(_swapRouter);
        nonfungiblePositionManager = INonfungiblePositionManager(_nonfungiblePositionManager);
        tokenId = _tokenId;
        (,,,, fee,,,,,,,) = nonfungiblePositionManager.positions(tokenId);

        IERC20(ETHC).approve(address(nonfungiblePositionManager), type(uint256).max);
    }

    receive() external payable {}

    /// @notice Collect all fee (ETH) in Ethcoin
    function collect() external {
        require(msg.sender == operator, "FeeCollector: not operator");

        IEthCoin(ETHC).collect(ETHC.balance);
    }

    /**
     * @notice Increase liquidity by using ETH that collected from Ethcoin
     * @param amountIn the amount of ETH that we want to swap for ETHC
     * @param amountOutMinimum the minimum amount of ETHC that we want to received
     */
    function increaseLiquidity(uint256 amountIn, uint256 amountOutMinimum, uint256 dustTolerance, uint256 allowedExtra)
        external
    {
        require(msg.sender == operator, "FeeCollector: not operator");
        uint256 extra = IERC20(ETHC).balanceOf(address(this));
        if (extra > allowedExtra) {
            extra = allowedExtra;
        }

        // Buy ETHC
        uint256 amountOut = swapRouter.exactInputSingle{value: amountIn}(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: WETH,
                tokenOut: ETHC,
                fee: fee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: amountOutMinimum,
                sqrtPriceLimitX96: 0
            })
        );

        uint256 amount0Desired = address(this).balance;
        uint256 amount1Desired = amountOut + extra;
        uint256 amount0Min = 0;
        uint256 amount1Min = amountOut - dustTolerance;
        if (ETHC < WETH) {
            (amount0Desired, amount1Desired) = (amount1Desired, amount0Desired);
            (amount0Min, amount1Min) = (amount1Min, amount0Min);
        }

        // increase liquidity
        nonfungiblePositionManager.increaseLiquidity{value: address(this).balance}(
            INonfungiblePositionManager.IncreaseLiquidityParams({
                tokenId: tokenId,
                amount0Desired: amount0Desired,
                amount1Desired: amount1Desired,
                amount0Min: amount0Min,
                amount1Min: amount1Min,
                deadline: block.timestamp
            })
        );

        nonfungiblePositionManager.refundETH();
    }

    /**
     * @notice deployer can rescue ETH
     */
    function rescue() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /**
     * @notice set operator
     * @param _operator The address of the operator
     */
    function setOperator(address _operator) external onlyOwner {
        operator = _operator;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IEthCoin {
    function collect(uint256 amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


interface INonfungiblePositionManager {
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

    function mint(MintParams calldata params)
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    function positions(uint256 tokenId)
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
            uint256 tokensOwed0,
            uint256 tokensOwed1
        );

    function refundETH() external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ISwapRouter {
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

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
}