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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

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

import "./IERC20.sol";

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
pragma solidity ^0.8.0;

interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router {
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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


    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
    function factory() external pure returns (address);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
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

import "./IUniswapV2Router.sol";
import "./IUniswapV2Factory.sol";
import "./ERC20.sol";

contract MemeCoin is ERC20 {
    uint256 public constant TOTAL_SUPPLY = 1000000000 * 10**18; // Total supply tokens = 1bn
    uint256 public constant TOTAL_BUY_TOKENS = 800000000 * 10**18; // Total tokens to buy = 800mn
    uint256 public constant LIQUIDITY_TOKENS = 200000000 * 10**18; // Total tokens to for LP = 200mn
    uint256 public constant BUY_PRICE_DIFFERENCE_PERCENT = 1000; // Difference in buy price as percentage
    uint256 public constant TARGET_LIQUIDITY = 4 * 10**18; // Target liquidity in ETH, assuming 18 decimals
    address payable public constant REVENUE_ACCOUNT = payable(0xCDE357ABBdf15Da7CCE4B51CE70a1d0F08DfB782); // Fee collection address
    uint256 public sanityTokenAmount = 100 * 10 ** 18;
    uint8 public constant FEE_PERCENTAGE = 2; // Fee percentage

    uint8 private buying; //tracks contract buying state to restrict pre-listing transfers
    uint8 private selling;//tracks contract selling state to restrict pre-listing transfers
    IUniswapV2Router public uniswapRouter;
    address public lpAddress;
    string public picture;
    address public taxWallet;
    address public bullaDeployer; //authorized address where all sales of the Memecoin  are done from.
    bool public listed;
    bool public degen;
    uint256 public totalETHBought; // Total ETH paid for tokens buying
    uint256 public totalTokensBought; // Total tokens bought
    uint256 public maxWalletAmount; // Total amount of tokens a wallet can hold
    uint256 public buyTax;
    uint256 public sellTax;
    uint256 public devTaxTokens;// Tax tokens accumulated off all taxes {buy & sell}

    mapping(address => uint256) public contributions; // Track ETH contributions
    mapping(address => uint256) public tokens; // Track bought tokens

    constructor(
        address _bullaDeployer,
        address _router,
        address _taxWallet,
        uint256 _maxWalletAmount,
        uint256 _buyTax,
        uint256 _sellTax,
        string memory _name,
        string memory _ticker,
        string memory _picture,
        bool _degen
    ) ERC20(_name, _ticker) {
        bullaDeployer = _bullaDeployer;
        uniswapRouter = IUniswapV2Router(_router);
        if (_maxWalletAmount == 0) {
            maxWalletAmount = type(uint256).max;//No Wallet limit
        } else if(_maxWalletAmount == 1){
            maxWalletAmount = (TOTAL_SUPPLY * 5) / 1000;//0.5% Wallet limit
        } else if(_maxWalletAmount == 2){
            maxWalletAmount = TOTAL_SUPPLY * 1 / 100; //1% Wallet limit
        }
        require(_maxWalletAmount == 0 || _maxWalletAmount == 1 || _maxWalletAmount == 2,'Invalid Max Wallet Amount');
        picture = _picture;
        taxWallet = _taxWallet;
        buyTax = _buyTax;
        sellTax = _sellTax;
        degen = _degen;
        listed = false;
        totalETHBought = 0;

        //Create Pair
        lpAddress = IUniswapV2Factory(uniswapRouter.factory()).createPair(address(this), uniswapRouter.WETH());
        
        //Max approve token for Router
        _approve(address(this), address(uniswapRouter), type(uint256).max);

        _mint(address(this), TOTAL_SUPPLY);
    }


    modifier onlyTaxWallet() {
        require(tx.origin == taxWallet,"Unauthorized Reset Attempt");
        _;
    }


    modifier onlyBulla() {
        require(msg.sender == bullaDeployer,"Unauthorized Interaction");
        _;
    }


    // @notice transfer function that handles all the buy and sell tax logic.
    // @param sender this is the address of the user where tokens are sent from.
    // @param recepient this the address of the user receiving the tokens.
    // @param amount this is the amount of tokens to be sent.
    function _transfer(address sender, address recipient, uint256 amount) internal override {
            uint256 tax;
            address _weth = uniswapRouter.WETH();
        if (listed){
            updateMaxWalletAmount(lpAddress,_weth);
            
            //Buy tax
            if (buyTax > 0 && sender == lpAddress && recipient != taxWallet){
                    tax = amount * buyTax / 100;
                    uint256 taxedAmount = amount - tax;
                    devTaxTokens = devTaxTokens + tax;
                    amount = taxedAmount;
                    super._transfer(sender, address(this), tax);
            }

            //Sell tax
            if (sellTax > 0 && recipient == lpAddress && sender!= taxWallet){
                    tax = amount * sellTax / 100;
                    uint256 taxedAmount = amount - tax;
                    devTaxTokens = devTaxTokens + tax;
                    amount = taxedAmount;
                    super._transfer(sender, address(this), tax);
            }

            if (recipient != taxWallet && recipient != lpAddress && recipient != address(0x000000000000000000000000000000000000dEaD)) {
                require(balanceOf(address(recipient)) + amount <= maxWalletAmount, "Transfer amount exceeds the max wallet amount");
            }


            super._transfer(sender, recipient, amount);
            if(sender != lpAddress && recipient != lpAddress){
                _swapAndLiquify();
            }
        }else{
            
            //Make sure only token contract can send tokens before listing
            if (recipient != address(this) || sender != address(this)) {
                require(buying > 0 || selling > 0,"Pre-listing transfers Not Allowed");
                buying = 0;
                selling = 0;
            }
            
            if (recipient != taxWallet && recipient != address(this) && recipient != lpAddress) {
                
                require(balanceOf(address(recipient)) + amount <= maxWalletAmount, "Transfer amount exceeds the max wallet amount");
            }

            super._transfer(sender, recipient, amount);
        }
    }

    // @notice allows a user buy a memecoin by sending ETHER.
    // @param buyer this is the address of the user buyingb the tokens.
    // @param slippageAmount this is the minimum amount allowed by user to be received during the purchase.
    function buyTokens(address buyer,uint256 slippageAmount) external payable onlyBulla {
        require(!listed, "Liquidity is already added to Uniswap");
        require(msg.value > 0, "Send ETH to buy tokens");

        buying = 1;

        uint256 fee = msg.value * uint256(FEE_PERCENTAGE) / 100;
        uint256 ethAmount = msg.value - fee;

        uint256 tokenAmount = calculateTokenAmount(ethAmount);
        uint256 currentPrice = tokenAmount/ethAmount;

        uint256 finalprice;

        if (_getRemainingAmount() == msg.value) {

            finalprice = currentPrice;
    
            if(tokenAmount > (TOTAL_BUY_TOKENS - totalTokensBought)){
                tokenAmount = TOTAL_BUY_TOKENS - totalTokensBought;
            }
        }

        totalTokensBought += tokenAmount;    
        contributions[buyer] += ethAmount;
    

        if(finalprice == 0){
            require(tokenAmount >= slippageAmount, "Slippage Amount Restriction");
        }

        if(buyTax > 0 && buyer != taxWallet){
            uint256 tax = tokenAmount * buyTax / 100;
            uint256 buyerTokens = tokenAmount - tax;
            devTaxTokens = devTaxTokens + tax;
            tokens[buyer] += buyerTokens;
            tokenAmount = buyerTokens;
        }else{
            tokens[buyer] += tokenAmount;
        }

        totalETHBought += ethAmount;

        _transfer(address(this), buyer, tokenAmount);
        bool success;
        (success, ) = REVENUE_ACCOUNT.call{value: fee}("");
        require(success, "Transfer failed");

        if (address(this).balance >= TARGET_LIQUIDITY && !listed) {
            _addLiquidity();
            _burnRemainingTokens();
        }
    }

    // @notice allows a user sell a memecoin.
    // @param seller this is the address of the user selling tokens.
    // @param tokenAmount this is the amount of tokens a user wants to sell.
    function sellTokens(address seller,uint256 tokenAmount) external onlyBulla {
        require(!listed, "Liquidity is already added to Uniswap");
        require(tokenAmount > 0, "Amount must be greater than 0");

        selling = 1;

        uint256 ethAmount = calculateEthAmount(seller,tokenAmount);

        if ((balanceOf(address(this)) + tokenAmount) == TOTAL_SUPPLY) {
            ethAmount = address(this).balance;

            if(!degen){
                contributions[seller] = 0;
            }

            totalETHBought = 0;
        } else {

            if(!degen){
                
                    contributions[seller] -= ethAmount;
                    totalETHBought -= ethAmount;
            }else{
                if(contributions[seller] < ethAmount){

                    uint subAmount;
                    if(tokenAmount > 0 && tokenAmount <= (tokens[seller] * 25 / 100)){
                        subAmount = contributions[seller] * 25 / 100;
                    } else if (tokenAmount >= (tokens[seller] * 25 / 100) && tokenAmount <= (tokens[seller] * 50 / 100)){
                        subAmount = contributions[seller] * 50 / 100;
                    } else if (tokenAmount >= (tokens[seller] * 50 / 100) && tokenAmount <= (tokens[seller] * 75 / 100)){
                        subAmount = contributions[seller] * 75 / 100;
                    } else if (tokenAmount >= (tokens[seller] * 75 / 100) && tokenAmount <= (tokens[seller] * 100 / 100)){
                        subAmount = contributions[seller] * 100 / 100;
                    }
                        contributions[seller] = contributions[seller] - subAmount;
                        totalETHBought -= ethAmount;                
                }else{
                  
                        totalETHBought -= ethAmount;
                }
            }

        }

       uint256 fee = ethAmount * uint256(FEE_PERCENTAGE) / 100;

       if(sellTax > 0 && seller != taxWallet){
            uint256 tax = tokenAmount * sellTax / 100;
            uint256 sellerTokens = tokenAmount - tax;
            tokens[seller] -= tokenAmount;
            devTaxTokens = devTaxTokens + tax;
            tokenAmount = sellerTokens;
        }else{
            tokens[seller] -= tokenAmount;
        }

        totalTokensBought -= tokenAmount; 
        
        _transfer(seller, address(this), tokenAmount);
        bool success;
        (success, ) = seller.call{value: ethAmount - fee}("");
        require(success, "Transfer failed");
        (success, ) = REVENUE_ACCOUNT.call{value: fee}("");
        require(success, "Transfer failed");

    }

    // @notice call to get the remaining ETHER amount required to be spent by users for the memecoin to be listed.
    // @returns A uint value indicating the remaining ETHER amount required to be spent by users for the memecoin to be listed.
    function getRemainingAmount() public view returns (uint256) {
        require(TARGET_LIQUIDITY > address(this).balance, "Liquidity target exceeded");

        return _getRemainingAmount();
    }

    // @notice allows the user calculate the minimum amount required to be received during a buy.
    // @param ethAmount this of ETHER to be used for the buy.
    // @param slippageAllowance this is the amount in percentage  used to calculate slippage.
    function slippage(uint256 ethAmount,uint256 slippageAllowance) public view returns(uint256) {
        uint256 fee = ethAmount * uint256(FEE_PERCENTAGE) / 100;
        ethAmount = ethAmount - fee;
         uint256 slippageAmount = calculateTokenAmount(ethAmount);
        if (buyTax > 0) {
            uint256 tax = slippageAmount * buyTax / 100;
            slippageAmount = slippageAmount - tax;
        }
        slippageAllowance = slippageAmount * slippageAllowance / 100;
        slippageAmount = slippageAmount - slippageAllowance;
        return slippageAmount;
    }

    // @notice call to get the remaining ETHER amount required to be spent by users for the memecoin to be listed.
    // @param ethAmount this an amount of ETHER to be used to buy.
    // @returns A uint value indicating the token amount a user would receive.
    function calculateTokenAmount(uint256 ethAmount) public view returns (uint256) {
        require(totalETHBought + ethAmount <= TARGET_LIQUIDITY, "Liquidity target exceeded");

        uint256 initialTokenPrice = _initialTokenPrice();
        uint256 tokenPrice = initialTokenPrice + ((initialTokenPrice * BUY_PRICE_DIFFERENCE_PERCENT / 100) * (totalETHBought + (ethAmount / 6)) / TARGET_LIQUIDITY);
        return ethAmount * 10**18 / tokenPrice;
    }

    // @notice call to get the ETHER amount sent to a user when tokens are sold.
    // @param user this is the address of the user.
    // @param tokenAmount this the amount of tokens a user want to sell.
    // @returns A uint value indicating the ETHER amount a user would receive.
    function calculateEthAmount(address user,uint256 tokenAmount) public view returns (uint256) {
        uint256 userTokens = tokens[user];
        require(userTokens >= tokenAmount, "Insufficient user token balance");

        uint256 value;
        if(!degen){

            return contributions[user] * tokenAmount / userTokens;
        }else{
            if(contributions[user] < totalETHBought){
                value = totalETHBought - contributions[user];
                value = value / 5;
                value = value + contributions[user];
            }else{
                value = totalETHBought;
            }
            return value * tokenAmount / userTokens;
        }
    }


    // @notice allows the creator of a memecoin set the minimum amount required to be met before a swap of the tax tokens occurs.
    // @param value this is the minimum amount required to be met before a swap of the tax tokens.
    function setSanityTokenAmount(uint256 newValue) external onlyBulla onlyTaxWallet {
        sanityTokenAmount = newValue * 10 ** 18;
    }


    // @notice allows the creator of a memecoin tax from the token.
    function removeTaxFees() external onlyBulla onlyTaxWallet {
        buyTax = 0;
        sellTax = 0;
    }


    // @notice function that adds liqudity to Uniswap once the Target Liquidity is met.
    function _addLiquidity() internal {
 
        listed = true;
        uniswapRouter.addLiquidityETH{ value: address(this).balance }(
            address(this),
            LIQUIDITY_TOKENS,
            0,
            0,
            address(this),
            block.timestamp
        );

        uint256 amount = IERC20(lpAddress).balanceOf(address(this));

        //Burn LP
        IERC20(lpAddress).transfer(address(0x000000000000000000000000000000000000dEaD),amount);

        _swapAndLiquify();
    }

    // @notice function that burns the remaining tokens in the contract after liquidity is added.
    function _burnRemainingTokens() internal  {
        
        uint256 amount;
        if(devTaxTokens > 0){
            amount = IERC20(address(this)).balanceOf(address(this)) - devTaxTokens;
        }else{
            amount = IERC20(address(this)).balanceOf(address(this));
        }

        //Burn Remaining Tokens
        IERC20(address(this)).transfer(address(0x000000000000000000000000000000000000dEaD),amount);
    }


    // @notice fucntion that update the maxWalletAmount once the 6 ETHER requirement is met.
    function updateMaxWalletAmount(address _lpToken,address _weth) internal {
        if(maxWalletAmount == type(uint256).max) return;

        uint256 amount = IERC20(_weth).balanceOf(address(_lpToken));

        if (amount >= 6 ether) {
            maxWalletAmount = type(uint256).max;
        }
    }
    
    // @notice call to get the remaining ETHER amount required to be spent by users for the memecoin to be listed.
    // @returns A uint value indicating the remaining ETHER amount required to be spent by users for the memecoin to be listed.
    function _getRemainingAmount() internal view returns (uint256) {
    
        return (TARGET_LIQUIDITY - totalETHBought) * 100 / (100 - uint256(FEE_PERCENTAGE));
    }


    // Get initial ETH normalized price per token
    function _initialTokenPrice() internal pure returns (uint256){
 
        return TARGET_LIQUIDITY * 10**18 / ((TOTAL_BUY_TOKENS * BUY_PRICE_DIFFERENCE_PERCENT) / 375);      
    }

    // @notice function that swaps devTaxToken balance for ETHER.
    function _swapAndLiquify() private {

        if(devTaxTokens < sanityTokenAmount) return;
        _swapTokensForEth(devTaxTokens);
        devTaxTokens = 0;
        
    }

    // @notice function that executes the swaps devTaxToken balance for ETHER.
    function _swapTokensForEth(uint256 tokenAmount) private  {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            taxWallet,
            block.timestamp
        );
    }
}