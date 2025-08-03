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
/*
   _____                           _ _      _____            _ _        _ 
  / ____|                         (_) |    / ____|          (_) |      | |
 | (___  _   _ _ __ ___  _ __ ___  _| |_  | |     __ _ _ __  _| |_ __ _| |
  \___ \| | | | '_ ` _ \| '_ ` _ \| | __| | |    / _` | '_ \| | __/ _` | |
  ____) | |_| | | | | | | | | | | | | |_  | |___| (_| | |_) | | || (_| | |
 |_____/ \__,_|_| |_| |_|_| |_| |_|_|\__|  \_____\__,_| .__/|_|\__\__,_|_|
                                                      | |                 
                                                      |_|              
                                                         
  Website:    https://summitcapital.xyz/
  Twitter:    https://twitter.com/summitalgo
  Telegram:   https://t.me/summitcapital
  Medium:     https://summitcapital.medium.com/
  Docs:       https://docs.summitcapital.xyz/
  ENS:        summitdeployer.eth

*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interfaces/INonfungiblePositionManager.sol";
import "./interfaces/ISwapRouter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Summit {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => bool) public noMax;
    string public name = "Summit Capital";
    string public symbol = "SUMT";
    uint8 public decimals = 18;

    INonfungiblePositionManager public nonfungiblePositionManager = INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
    ISwapRouter constant router = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint256 public buyFee = 10000;
    uint256 public bolsterReward = 5000;
    uint256 public maxWalletPercent = 500;
    uint256 public buyFeeBalance;
    address public pool;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner!");
        _;
    }

    constructor() {
      owner = msg.sender;

      uint amount = 10_000_000 * (10 ** decimals);
      balanceOf[msg.sender] += amount;
      totalSupply += amount;
      emit Transfer(address(0), msg.sender, amount);

      address token0 = address(this) < WETH ? address(this) : WETH;
      address token1 = address(this) < WETH ? WETH : address(this);
      uint24 fee = 10000;
      uint160 sqrtPriceX96 = token0 == address(this) ? 56022770974786140000000000 : 112045541949572280000000000000000;

      pool = initializePool(token0, token1, fee, sqrtPriceX96);
    }

    function initializePool(address token0, address token1, uint24 fee, uint160 sqrtPriceX96) public returns (address) {
      return nonfungiblePositionManager.createAndInitializePoolIfNecessary(token0, token1, fee, sqrtPriceX96);
    }

    function transfer(address recipient, uint amount) public returns (bool) {

        if (msg.sender == pool) {

          balanceOf[msg.sender] -= amount;

          uint amountNoFee = handleTaxedTokens(msg.sender, amount);

          if (!noMax[recipient]) {
            uint256 maxWallet = totalSupply * maxWalletPercent / 100_000;
            require(balanceOf[recipient] + amountNoFee <=  maxWallet, "Max wallet exceeded!");
          }

          balanceOf[recipient] += amountNoFee;
          emit Transfer(msg.sender, recipient, amountNoFee);
          return true;

        } else {
          balanceOf[msg.sender] -= amount;
          balanceOf[recipient] += amount;
          emit Transfer(msg.sender, recipient, amount);
          return true;
        }
    }

    function approve(address spender, uint amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) public returns (bool) {

        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
    

    function swapExactInputSingleHop(
        address tokenIn,
        address tokenOut,
        uint24 poolFee,
        uint amountIn,
        uint amountOutMinimum
    ) private returns (uint amountOut) {
        IERC20(tokenIn).approve(address(router), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: amountOutMinimum,
                sqrtPriceLimitX96: 0
            });

        amountOut = router.exactInputSingle(params);
    }

    function handleTaxedTokens(address sender, uint amount) private returns (uint) {
          uint256 _fee = amount * buyFee / 100_000;
          balanceOf[address(this)] += _fee;
          buyFeeBalance += _fee;
          emit Transfer(sender, address(this), _fee);

          return amount - _fee;
    }

    function callToEarn() public {
        require(buyFeeBalance > 0);
        uint amountOut = swapExactInputSingleHop(address(this), WETH, 10000, buyFeeBalance, 0);
        buyFeeBalance = 0;

        uint reward = amountOut * bolsterReward / 100_000;
        IERC20(WETH).transfer(msg.sender, reward);
    }

    function upgradeOwner(address _owner) public onlyOwner {
      owner = _owner;
    }

    function modulateFees(uint256 _buyFee, uint256 _bolsterReward, uint256 _maxWalletPercent) public onlyOwner {
      buyFee = _buyFee;
      bolsterReward = _bolsterReward;
      maxWalletPercent = _maxWalletPercent;
    }

    function changeNoMax(address target, bool value) public onlyOwner {
      noMax[target] = value;
    }

    // Emergency
    function rescue(address token) public onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, balance);
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface INonfungiblePositionManager {
    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint amount0Desired;
        uint amount1Desired;
        uint amount0Min;
        uint amount1Min;
        address recipient;
        uint deadline;
    }

    function mint(
        MintParams calldata params
    )
        external
        payable
        returns (uint tokenId, uint128 liquidity, uint amount0, uint amount1);

    struct IncreaseLiquidityParams {
        uint tokenId;
        uint amount0Desired;
        uint amount1Desired;
        uint amount0Min;
        uint amount1Min;
        uint deadline;
    }

    function increaseLiquidity(
        IncreaseLiquidityParams calldata params
    ) external payable returns (uint128 liquidity, uint amount0, uint amount1);

    struct DecreaseLiquidityParams {
        uint tokenId;
        uint128 liquidity;
        uint amount0Min;
        uint amount1Min;
        uint deadline;
    }

    function decreaseLiquidity(
        DecreaseLiquidityParams calldata params
    ) external payable returns (uint amount0, uint amount1);

    struct CollectParams {
        uint tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    function collect(
        CollectParams calldata params
    ) external payable returns (uint amount0, uint amount1);

    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint deadline;
        uint amountIn;
        uint amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps amountIn of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as ExactInputSingleParams in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint amountOut);

}