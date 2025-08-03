// SPDX-License-Identifier: MIT  

//Telegram - https://t.me/BradPortal  
//Twitter - https://twitter.com/Bradcoin_
//Website - https://bradcoin.wtf/  

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&&&&&&&&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@#BG5YYJJJJJJJJJYYY55PPGB#&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@&#G5J??77!!~~~~~~~~~~~!!!77?JJY555PGB#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@&B5J?77!~~~~~~~~~~~~~~~~~~~~~~~~~!7JPY7??JYYPG#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@BY??7!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!~~~~!!77?JY5G#@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@BY??!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!77?J5G#@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@#YJ?!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!7??YG&@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@P7J!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!7?JP&@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@Y??~~~~~~~~~~~~~~~~~~~~~~~~~!7?J!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~7JJP@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@?J?~~~~~7??YJ~!7?J5~~~~~~!7??7!:YJ~~~~~!YY?~~~~~~~~~~~~7?!~~~~~~~~~~~7J?B@@@@@@@@@@@@@@@@
//@@@@@@@@@B?J7~!7???!^^GY??~:.57~!?J?7~:.   ?Y~~~!JJ^.~J?7~~~~~~!?J7!5?~~~~~~~~~~~!J?P@@@@@@@@@@@@@@@
//@@@@@@@#J?BP??7~^.   :7:.    !P?7~:        .P7~JJ~     :7J?7!!JJ~.  .?Y!~~~~~~~~~~~YJ5@@@@@@@@@@@@@@
//@@@@@@57JPP^.                 .             :5J~          :!77^       ^JJ7!!!!!!7?J?5J5@@@@@@@@@@@@@
//@@@@@@BGYJ~                 .~!!7!^                     ^~~~^.          :!!!!~~~!~.  P?G@@@@@@@@@@@@
//@@@@@@@@YY:               ^J5!^^^~5:                   ~G?!~7Y?.                     ^B7&@@@@@@@@@@@
//@@@@@@@@JY              ^?7^7P!~!!P^                 .??^^~~~~7Y:                     !YY@@@@@@@@@@@
//@@@@@@@@5J!^~^        ^55!:.!5.  ^5.                 5~  :GG.  :5.                     Y?@@@@@@@@@@@
//@@@@@@@@#!5?#?       :P:.^~777!~7?:                 .G!!~75Y^:..P.                     Y?@@@@@@@@@@@
//@@@@@@@@@G!B&B~.      77~^~!77!:    :^J7 .  .   7.  .Y!^::::^~!PJ                   .!PYY@@@@@@@@@@@
//@@@@@@@@@@G7P&&BY?     .:::.^! ^!!!YY#@BP#P5BGPP@BB?.~77!!~^^!?!                   :Y@@7B@@@@@@@@@@@
//@@@@@@@@@@@#JYGBPG57:       P#P&@G!7 ~?.^J?!^~~7PYYP?5@J .::::            : .^ ^J??5#@B?G@@@@@@@@@@@
//@@@@@@@@@@@@@G7J&&#@GGP! ~5P##@&5.~!7!!!~^^^~~~~!:   J##G?.             .^PYY#JP!Y#@BJJB@@@@@@@@@@@@
//@@@@@@@@@@@@@@@PJY!Y&@@@G5#@#J7P     ..:::::::::.      !#@#P7:.       .!5J#P&#&&&PYGY5@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@GJ?JP@#&&&@&GY?                         Y&@#B#G?. !~~B&#Y&P5J?GY5#G#@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@#5JY?5&&B&@JJ!.   !77!^        :J7:~^JB&@@@@#&#G#P&@GJ5YYPPPG#@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@#PYJY#@@##BBYYYPPBGPP?5^PY~^B&#B@#@@B5&#BP&@Y5PP57B@&@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@#PY55?PB#P##@@@5JB@@&@#@@&G#@BG#5YYJY5JYYY&#BB#@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&#GGPPP55PPPGGPYGY5BGP55Y55JB###@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&&&&&GP#BBBB###&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


pragma solidity 0.8.19;

import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "./IUniswapV2Router02.sol";

contract BRAD is ERC20, Ownable {

    IUniswapV2Router02 public immutable uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    uint256 public tradingStartTimeStamp;
    uint256 public maxHoldingAmount;
    uint256 public maxTransactionAmount;
    uint256 private swapTokensAt;

    address public deployerWallet;
    address public marketingWallet;
    address public uniswapV2Pair;

    bool public limited;
    bool public swapEnabled;
    bool private swapping;
    

    mapping (address => bool) private _ExcludedFromFees;
    mapping (address => bool) private _ExcludedFromTransactionAmount;

    error CanOnlySetPairOnce(address);
    error InvalidPresalePrice(uint256);
    error ExceedsHoldingAmount(uint256);
    error ExceedsMaxTransactionAmount(uint256);
    error TradingHasNotStarted();
    error WithdrawFailed();

    constructor(
        uint256 _totalSupply, 
        address _marketingWallet
    ) ERC20("Brad Coin", "BRAD") {

        _mint(msg.sender, _totalSupply);

        swapTokensAt = (_totalSupply * 9) / 10_000;

        swapEnabled = true;

        deployerWallet = msg.sender;

        marketingWallet = _marketingWallet;


        excludeFromFees(msg.sender, true);
        excludeFromFees(address(this), true);
        excludeFromFees(marketingWallet, true);
        excludeFromMaxTransaction(marketingWallet, true);
        excludeFromMaxTransaction(address(uniswapV2Router), true);
        excludeFromMaxTransaction(msg.sender, true);
        excludeFromMaxTransaction(address(this), true);
    }

    receive() external payable {}

    function commenceTrading(address _uniswapV2Pair) external onlyOwner {

        if (tradingStartTimeStamp != 0) revert CanOnlySetPairOnce(uniswapV2Pair);

        uniswapV2Pair = _uniswapV2Pair;
        tradingStartTimeStamp = block.timestamp;
    }

    function setLimits(
        bool _limited, 
        uint256 _maxHoldingAmount,
        uint256 _maxTransactionAmount
    ) external onlyOwner {
        limited = _limited;
        maxTransactionAmount = _maxTransactionAmount;
        maxHoldingAmount = _maxHoldingAmount;
    }

    function toggleSwapping(bool _bool) external onlyOwner {
        swapEnabled = _bool;
    }

    function excludeFromFees(address _account, bool _excluded) public onlyOwner {
        _ExcludedFromFees[_account] = _excluded;
    }

    function excludeFromMaxTransaction(address _account, bool _excluded) public onlyOwner {
        _ExcludedFromTransactionAmount[_account] = _excluded;
    }

    function withdrawFunds(address payable _address) external onlyOwner {
        (bool success, ) = _address.call{value: address(this).balance}("");
        if (!success) revert WithdrawFailed();
    }

    function withdrawTokens(address payable _address, address _tokenContract) external onlyOwner {
        uint256 balanceInContract = IERC20(_tokenContract).balanceOf(address(this));
        _transfer(address(this), _address, balanceInContract);
    }


    function _getTaxes(
        uint256 _currentTimestamp
    ) internal view returns (uint256 _buyTax, uint256 _sellTax, bool _eligibleForTax) {
        uint256 elapsedTime = _currentTimestamp - tradingStartTimeStamp;
        uint256 buyTax = 0;
        uint256 sellTax = 0;
        bool eligibleForTax = true;
        if (elapsedTime < 1 minutes) {
            buyTax = 0;
            sellTax = 0;
            eligibleForTax = true;
        } else if (elapsedTime >= 1 minutes && elapsedTime < 3 minutes) {
            buyTax = 0;
            sellTax = 0;
            eligibleForTax = true;
        } 

        return (buyTax, sellTax, eligibleForTax);
    }

    function _transfer(
        address from, 
        address to, 
        uint256 amount
    ) internal override {
        if (uniswapV2Pair == address(0) && from != address(0) && from != owner()) revert TradingHasNotStarted();

        if(
            from != owner() &&
            to != owner() &&
            to != address(0) &&
            to != address(0xdead) &&
            !swapping
        )
            {
                if (limited) {
                    if (from == uniswapV2Pair && !_ExcludedFromTransactionAmount[to]) {
                        if (amount > maxTransactionAmount) revert ExceedsMaxTransactionAmount(amount);
                        if (balanceOf(to) + amount > maxHoldingAmount) revert ExceedsHoldingAmount(amount);
                    }
                    else if (to == uniswapV2Pair && !_ExcludedFromTransactionAmount[from]) {
                        if (amount > maxTransactionAmount) revert ExceedsMaxTransactionAmount(amount);
                    }
                    else if (!_ExcludedFromTransactionAmount[to]) {
                        if (balanceOf(to) + amount > maxHoldingAmount) revert ExceedsHoldingAmount(amount);
                    }
                }
            }
        
        uint256 contractBalance = balanceOf(address(this));

        
        bool canSwap = contractBalance >= swapTokensAt;

        if( 
            canSwap &&
            swapEnabled &&
            !swapping &&
            from != uniswapV2Pair &&
            !_ExcludedFromFees[from] &&
            !_ExcludedFromFees[to]
        ) {
            swapping = true;
            
            _swapBack(contractBalance);

            swapping = false;
        }

        bool takeFee = !swapping;

        
        if(_ExcludedFromFees[from] || _ExcludedFromFees[to]) {
            takeFee = false;
        }

        if (takeFee) {
            (uint256 buyTax, uint256 sellTax, bool eligibleForTax) = _getTaxes(block.timestamp);
            if (from == uniswapV2Pair && eligibleForTax) {
                uint256 tax = (amount * buyTax) / 100;
                super._transfer(from, address(this), tax);
                amount -= tax;
            }

            if (to == uniswapV2Pair && eligibleForTax) {
                uint256 tax = (amount * sellTax) / 100;
                super._transfer(from, address(this), tax);
                amount -= tax;
            }
        }
        super._transfer(from, to, amount);
    }

    function _swapBack(uint256 _contractBalance) private {
        if (_contractBalance == 0) { return; }

        // Swap tokens for ETH
        _swapTokensForEth(_contractBalance); 

        uint256 totalEth = address(this).balance;

        // Send ETH to marketing wallet
        (bool success,) = address(marketingWallet).call{value: totalEth}("");
    }


    function _swapTokensForEth(uint256 _tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), _tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }
}
// SPDX-License-Identifier: MIT

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
// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../GSN/Context.sol";
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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../GSN/Context.sol";
import "./IERC20.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}