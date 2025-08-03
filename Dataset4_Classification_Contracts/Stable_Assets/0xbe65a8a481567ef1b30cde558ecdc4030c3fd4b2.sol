// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";

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


/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
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
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
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


//
// Moneypot. The Good Pot
//

// https://t.me/moneypotethportal

/* 

Please read carefully:

- You can not sell any tokens you buy. 

- It's better to think of the tokens that you buy as 'tickets'. 

- 50% of the Eth that is used to buy tickets, will be distributed. This 50% is broken down into:
    - 43% reflected, as eth, to current ticket holders.
    - 2% each to the deployer and dev
    - 2% to Cuck holders
    - 1% to the person that calls the function to distribute the eth (called 'getSum')
    
- The other 50% will remain in the liquidity pool. 

- Every buy will add 5 blocks to a timer (Up to a maximum of about 3 days worth of blocks)

- When the timer runs out, the last person to buy will be sent ALL of the LP tokens, and thus effectivly, 
  all of the Eth in the liquidity pool. That is the end prize!

- When the timer runs out, all trading will stop and the only action permitted will be the winner 
  withdrawing the LP, and ticket holders claiming their reflected eth

- You can only buy a whole number of tickets at a time (eg: 1, 2, 3 etc.. - not 1.3 or 3.14)
- You can only buy up to 10 tickets in one TX, but there is no wallet limit. 
- The contract has an automatic pricing function to keep price increases linear, instead of the curve that Uniswap would apply. 
  This allows for an infinite supply. You will see lots of mints/transfers from 0x0 address to the pair address because of this. 

*/
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
pragma solidity ^0.8;


interface IUniswapRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IUniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapPair {
	function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function sync() external;
}

interface IWETH9 {
    function deposit() external payable;
    function withdraw(uint wad) external;
    function transfer(address dst, uint wad) external returns (bool);
    function balanceOf(address owner) external view returns (uint256);
}

// The Middleman contract is created because when the main contract sells tokens for eth
// the pair contract doesn't allow transferring the eth directly back to the token contract, so we need to have a 
// middleman contract.

contract Middleman {
    address immutable wethAddress;
    address immutable MoneyPotAddress;
    IWETH9 private _weth;

    constructor(address _wethAddress, address _MoneyPotAddress){
        wethAddress = _wethAddress;
        MoneyPotAddress = _MoneyPotAddress;
        _weth = IWETH9(_wethAddress);
    }

    function send() public {
        uint256 balance = _weth.balanceOf(address(this));
        if (balance != 0){
            _weth.transfer(MoneyPotAddress, balance);
        }
    }
}

contract MoneyPot is ERC20 {
    // Maps
    // These keep track of the reflected eth balances
    mapping (address => uint256) internal withdrawnDividends;
    mapping (address => uint256) internal magnifiedDividendCorrections;

    // Interfaces
    IUniswapRouter private _swapRouter;
    IUniswapPair private _swapPair;
    IWETH9 private _weth;

    // Addresses
    address private _wethAddress;
    address private _swapRouterAddress;
    address private _cuckPairAddress;
    address public swapPairAddress;
    address public lastBuyer;
    address private constant deployer = 0x0A62891336667b540045A10F87B1fd6c0Dadf94f;
    address private constant dev = 0xbb8e9B891a1f8298219bDde868B2EcbEc7f71190;

    // Booleans
    bool private immutable _isToken0;
    bool private reeeeeeee;

    // Numbers
    uint8 private constant _decimals = 18;

    uint256 public maxBlocksAhead = 21600; //3 days ish at 12 second blocks
    uint256 public maxTokensPerTx = 5*10**_decimals;
    uint256 public finishBlock;
    uint256 public tradingStartBlock;
    uint256 public ethToBeSwapped;
    uint256 public totalEthDistributed;

    uint256 public targetPrice = 5000000000000000; //0.05 eth start price
    uint256 public priceIncrease = 500000000000000; //0.005 added to each buy
    uint256 public tokensPurchased = 0;

    uint256 constant internal magnitude = 2**128;
    uint256 internal magnifiedDividendPerShare;

    // Starting supply of 40 to match 0.05 price @ 0.2 eth liquidity
    uint256 private _totalSupply = 40*10**_decimals; 
 
    bool public gameOver;
    bool private liquidityAdded;

    Middleman public middleman;

    event FinishBlockEvent(uint256 blockNumber);
    event DividendsDistributed(uint256 amount, uint256 totalethToBeSwapped);
    event LastBuyerUpdate(address lastBuyer);
    
    constructor (address swapRouterAddress, address cuckPairAddress) payable ERC20("MoneyPot", "MONEY")  {
        _swapRouter = IUniswapRouter(swapRouterAddress);
        _swapRouterAddress = swapRouterAddress;
        _cuckPairAddress = cuckPairAddress;
        _wethAddress = _swapRouter.WETH();
        _weth = IWETH9(_wethAddress);
        _weth.deposit{value: msg.value}();
        tradingStartBlock = block.number + 14400; // Approx 2 days @ 12s blocks
        finishBlock = tradingStartBlock + 300; // Approx 1 hour after launch
        swapPairAddress = IUniswapFactory(_swapRouter.factory()).createPair(address(this), _wethAddress);
        _swapPair = IUniswapPair(swapPairAddress);
        _isToken0 = address(this) < _wethAddress ? true : false;
        middleman = new Middleman(_wethAddress, address(this));
    }

    receive() external payable {
  	}

    // Re entry protection
    modifier reeeeeee {
        require(!reeeeeeee);
        reeeeeeee = true;
        _;
        reeeeeeee = false;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(tradingStartBlock < block.number, "Too early");
        require(amount > 0);

        // First off, let's see if the game is over or not
        checkGameIsOver();
        
        if (gameOver){
            // Only the 'winner' can receive tokens after the game is over 
            // This is to allow them to withdraw the liquidity easily. 
            require(to == lastBuyer, "Game is Over. Last Buyer Wins");
        } else {
            // Check that user is buying a whole number of tokens only
            // Uniswap GUI has a rounding error so if you request '1' token
            // it will ask for something slightly off, like 1.000000000000000178.
            // So we round the number slightly to make it work with the modulo check
            uint256 rounded = (amount/200)*200;
            require(rounded >= 1**_decimals, 'Min of 1 ticket buy!');
            require(rounded % (10**_decimals) == 0, "Whole number buys only!");

            // Buys only!
            require(from == swapPairAddress, "No sell for you!");

            // Can't be too greedy!
            require(rounded <= maxTokensPerTx, "Only 10 tokens per TX sers/madams");

            // We know how much the buyer paid in eth due to the difference between the pair contract's weth reserves
            // figure and the actual weth balance. So we take that difference and divide by two to create the 50% "tax"
            // that will be re-distributed to holders when someone calls the getSum function.
            uint wethReserve = _getWethReserve();
            uint pairBalance = IERC20(_swapRouter.WETH()).balanceOf(swapPairAddress); 
            ethToBeSwapped += ((pairBalance - wethReserve)/2);
            tokensPurchased += amount;
            lastBuyer = to;
            emit LastBuyerUpdate(to);
        }
        
        
        // Transfer the tokens using the standard ERC20 transfer function
        super._transfer(from, to, amount);

        //set new target price 
        targetPrice += priceIncrease;
        if (!gameOver){
            setTargetPrice();
            // We add 5 blocks to the countdown timer. 
            // If adding those 5 blocks causes it to exceed the maximum block number ahead, we keep it at max blocks ahead
            // So the the timer can never be longer than max blocks ahead.
            finishBlock = (finishBlock + 5)-block.number >= maxBlocksAhead ? block.number + maxBlocksAhead : finishBlock + 5;
            emit FinishBlockEvent(finishBlock);
        }       
    }

    // 
    // Public Functions
    //

    // Anyone can call this, and get paid 1% of the eth to be swapped for doing so. 
    function getSum() public payable reeeeeee {
        
        if (ethToBeSwapped > 0){
            
            // Figure out how much (w)eth is in the liquidity pool
            uint wethReserve;
            uint tokenReserve;
            {
                (uint reserve0, uint reserve1,) = _swapPair.getReserves();
                (wethReserve, tokenReserve) = _isToken0 ? (reserve1, reserve0) : (reserve0, reserve1);
            }
            
            // Figure out how many tokens to send (mint) to the pool to get the equivelent eth back
            // This code is pretty much the same as what is in the uniswap libraries
            // https://docs.uniswap.org/contracts/v2/reference/smart-contracts/library#getamountin
            uint numerator = tokenReserve*ethToBeSwapped*1000;
            uint denominator = (wethReserve-ethToBeSwapped)*997;
            uint amountIn = (numerator / denominator)+1;
            super._mint(swapPairAddress, amountIn);

            // Swap the now minted tokens that are in the liquidity pool for eth, sending it to the middle man contract 
            // See line 169 of the uniswap pair code as to why we need the middleman contract:
            // https://github.com/Uniswap/v2-core/blob/master/contracts/UniswapV2Pair.sol
            // (Most contracts that have a swapBack kind of function use the uniswap router contract to execute the trade
            // which is why they dont need the middleman contract. Moneypot is better than that.
            (uint amount0Out, uint amount1Out) = _isToken0 ? (uint(0), ethToBeSwapped) : (ethToBeSwapped, uint(0));
            _swapPair.swap(amount0Out,amount1Out,address(middleman),new bytes(0));
            
            // Ask the middleman to pretty please send the weth back to us.
            middleman.send();
            ethToBeSwapped = 0;

            uint bal = _weth.balanceOf(address(this));

            //Send some weth to Cuck token LP
            uint cuckAmount = (bal*2)/100;
            _weth.transfer(_cuckPairAddress, cuckAmount);
            IUniswapPair(_cuckPairAddress).sync();
            
            // Unwrap Weth for Eth and distribute to ticket holder balances
            _weth.withdraw(bal-cuckAmount);
            _distribute();

            // Make sure the price is at or near our target price.
            setTargetPrice();
            _swapPair.sync();
           
        }
    }

    function checkGameIsOver() public returns (bool gameIsOver){
        if(!gameOver){
            if(block.number >= finishBlock){
                 //Call getsum for the last time
                getSum();
                gameOver = true;
            }
        } 
        return gameOver;
    }

    // This function needs to be called to send the winnings to the winner
    // You might have to call checkGameIsOver first.
    function chickenDinner() public {
        require(gameOver);
        uint256 lpBalance = _swapPair.balanceOf(address(this));
        if (lpBalance != 0){
            // Transfer LP tokens to the LP pair, ready for calling the burn function
            _swapPair.transfer(swapPairAddress, lpBalance);
            // The burn function of the LP pair contract burns the LP tokens and sends all WETH and Tokens 
            // in the pair contract to the lastBuyer address
            _swapPair.burn(lastBuyer);
        }
    }

    function claim() public reeeeeee {
        // Calculate how much sers/maaaams can have
        uint256 _withdrawableDividend = withdrawableDividendOf(msg.sender);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[msg.sender] += _withdrawableDividend;
            bool success = _safeSend(msg.sender, _withdrawableDividend);
            if(!success) {
                withdrawnDividends[msg.sender] -= _withdrawableDividend;
            }
        }
    }

    // Can only be called once
    function addLiquidity() public {
        require(!liquidityAdded);
        _weth.transfer(swapPairAddress, _weth.balanceOf(address(this)));
        super._mint(swapPairAddress, _totalSupply);
        _swapPair.mint(address(this));
        liquidityAdded = true;
    }

    function withdrawableDividendOf(address _owner) public view returns(uint256) {
        return accumulativeDividendOf(_owner) - withdrawnDividends[_owner];
    }

    function accumulativeDividendOf(address _owner) public view returns(uint256) {
        return (magnifiedDividendPerShare*balanceOf(_owner) + magnifiedDividendCorrections[_owner]) / magnitude;
    }

    //
    // Private Functions 
    // 

    // distribute eth to dev and to hodlers, 1% of eth distributed goes to whoever calls it
    function _distribute() private {
        require(tokensPurchased > 0);
        uint256 amount = address(this).balance;
        require(amount > 0);

        // Calculate tax for dev/deployer
        // div by 50 cause 'amount' is 50% of the eth revenue, so div'ing by 100 would equate to 1%, not 2%.
        uint256 taxLol = (amount*2)/50; 

        // Calculate 1% reward for whoever calls this function
        uint256 reward = (amount*1)/100;

        // Send tax
        bool dev1Success = _safeSend(deployer, taxLol);
        bool dev2Success =_safeSend(dev, taxLol);
        bool rewardSuccess = _safeSend(_msgSender(), reward);
        
        require(dev1Success && dev2Success && rewardSuccess, 'Failed to distribute');

        // Distribute what remains to holders
        uint256 dividends = amount-reward-(taxLol*2);
        totalEthDistributed += dividends;
        magnifiedDividendPerShare += (dividends*magnitude) / tokensPurchased;
        emit DividendsDistributed(dividends, totalEthDistributed);
        
    }

    function _getWethReserve() private view returns (uint wethReserve){
        (uint reserve0, uint reserve1,) = _swapPair.getReserves();
        return wethReserve = _isToken0 ? reserve1 : reserve0;
    }

    // Self explanatory. I was having a bad day.
    function _fuckingUintToIntconverterBullshitIHateLifeSometimes(uint cock, uint balls) private pure returns (uint, bool) {
        return cock >= balls ? (uint(cock - balls), true) : (uint(balls - cock),false);
    }

    // Set the trading pair price back down to the target price if the price goes above teh target price
    // Side note: If you buy max tokens (10) at a time, you may be paying more than if you bought them 
    // one at a time...because of this function!
    function setTargetPrice() internal {
        // We do this by adding (minting) tokens into the swap pair contract 
        // This effectivly decreases the price per token
        uint256 wethBalance = _weth.balanceOf(swapPairAddress);
        uint256 currentBalance = balanceOf(swapPairAddress);
        uint256 targetBalance = (wethBalance*10000)/((targetPrice*10000)/(10**_decimals));

        (uint256 diff, bool positive) = _fuckingUintToIntconverterBullshitIHateLifeSometimes(targetBalance, currentBalance);

        if (diff != 0 && positive){
            super._mint(swapPairAddress, diff);
        }
    }

    function _safeSend(address recipient, uint256 value) private returns(bool success){
        (success,) = recipient.call{value: value}("");
    }
    
}