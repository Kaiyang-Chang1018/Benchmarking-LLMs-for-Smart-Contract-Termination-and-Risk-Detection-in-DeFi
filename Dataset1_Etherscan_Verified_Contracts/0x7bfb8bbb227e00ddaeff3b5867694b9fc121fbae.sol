// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_,uint256 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint256) {
        return _decimals;
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
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

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

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


}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function feeTo() external view returns (address);
}

interface IUniswapV2Pair {

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function kLast() external view returns (uint);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

}

contract usdtReceiver {
    address public usdt;
    address public owner;
    constructor(address _u) {
        usdt = _u;
        owner = msg.sender;
        IERC20(usdt).approve(msg.sender,~uint256(0));
    }
}

contract Token is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapPair;

    bool private swapping;

    uint256 public swapTokensAtAmount;

    uint256 public buyTokenRewardsFee;
    uint256 public sellTokenRewardsFee;

    uint256 public buyLiquidityFee;
    uint256 public sellLiquidityFee;

    uint256 public buyMarketingFee;
    uint256 public sellMarketingFee;

    uint256 public buyDeadFee;
    uint256 public sellDeadFee;

    uint256 public AmountLiquidityFee;
    uint256 public AmountTokenRewardsFee;
    uint256 public AmountMarketingFee;

    uint256 public addLiquidityFee;
    uint256 public removeLiquidityFee;


    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public usdtAddress;
    address public _marketingWalletAddress;
    address private receiveAddress;
    address public rewardsAddress;
    uint256 public gasForProcessing = 300000;
    bool public swapAndLiquifyEnabled = true;
    uint256 currentIndex;
    uint256 public LPFeeRewardsTimes;
    uint256 public minLPFeeRewards;
    uint256 public first;
    uint256 public kill = 0;
    uint256 public airdropNumbs;
    usdtReceiver public _usdtReceiver;
    uint256 public processRewardWaitBlock = 20;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping(address => bool) public _isBlacklisted;
    uint256 public _maxTxAmount;
    uint256 public _walletMax;
    bool public checkWalletLimit = true;
    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isExcludedFromFees;
    // Whether to distribute dividends in local currency
    bool public currencyFlag;
    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping(address => bool) public automatedMarketMakerPairs;


    mapping(address => bool) private _updated;
    address[] public shareholders;
    mapping(address => uint256) shareholderIndexes;
    bool public antiSYNC = true;
    bool public enableOffTrade;
    uint256 public startTradeBlock;
    uint256 public version = 4_1_0;


    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SendDividends(
        uint256 tokensSwapped,
        uint256 amount
    );

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );
    mapping(address => bool) public _swapRouters;
    function setSwapRouter(address addr, bool enable) external onlyOwner {
        _swapRouters[addr] = enable;
    }

    constructor(
        string[] memory stringParams,
        address[] memory addrs,
        uint256[] memory numberParams,
        bool[] memory boolParams

    ) payable ERC20(stringParams[0], stringParams[1],numberParams[8])  {
        _marketingWalletAddress = addrs[1];
        usdtAddress = addrs[2];
        _usdtReceiver = new usdtReceiver(usdtAddress);
        receiveAddress = _msgSender();
        currencyFlag = boolParams[0];
        enableOffTrade = boolParams[1];
        antiSYNC = boolParams[2];
        if(currencyFlag){
          rewardsAddress = address(this);
        }else{
          rewardsAddress = addrs[3];
        }
        buyTokenRewardsFee = numberParams[0];
        buyLiquidityFee = numberParams[1];
        buyMarketingFee = numberParams[2];
        buyDeadFee = numberParams[3];

        sellTokenRewardsFee = numberParams[4];
        sellLiquidityFee = numberParams[5];
        sellMarketingFee = numberParams[6];
        sellDeadFee = numberParams[7];

        require(buyTokenRewardsFee.add(buyLiquidityFee).add(buyMarketingFee).add(buyDeadFee) <= 10000, "Total buy fee is over 100%");
        require(sellTokenRewardsFee.add(sellLiquidityFee).add(sellMarketingFee).add(sellDeadFee) <= 10000, "Total sell fee is over 100%");

        uint256 totalSupply = numberParams[9] * (10 ** numberParams[8]);
        swapTokensAtAmount = totalSupply.mul(2).div(10**6); // 0.002%
        _maxTxAmount = totalSupply;
        _walletMax = totalSupply;
        if(currencyFlag){
          minLPFeeRewards = (10 ** numberParams[8]); // min Lp Rewards Dividend
        }else{
          minLPFeeRewards = (10 ** IERC20(rewardsAddress).decimals()); // min Lp Rewards Dividend
        }

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(addrs[0]);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), usdtAddress);
        uniswapV2Router = _uniswapV2Router;
        uniswapPair = _uniswapV2Pair;
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        _swapRouters[address(uniswapV2Router)] = true;

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(_marketingWalletAddress, true);
        excludeFromFees(address(this), true);

        isWalletLimitExempt[owner()] = true;
        isWalletLimitExempt[address(uniswapPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[deadWallet] = true;
        isWalletLimitExempt[_marketingWalletAddress] = true;

        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[deadWallet] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[_marketingWalletAddress] = true;

        _mint(owner(), totalSupply);
        payable(addrs[4]).transfer(msg.value);
    }
    receive() external payable {}



    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
        .createPair(address(this), uniswapV2Router.WETH());
        uniswapPair = _uniswapV2Pair;
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
        isWalletLimitExempt[address(uniswapPair)] = true;
    }
    function enableDisableWalletLimit(bool newValue) external onlyOwner {
       checkWalletLimit = newValue;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        if (_isExcludedFromFees[account] != excluded) {
            _isExcludedFromFees[account] = excluded;
            emit ExcludeFromFees(account, excluded);
        }
    }
    function multipleBotlistAddress(address[] calldata accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isBlacklisted[accounts[i]] = excluded;
        }
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }
    function setMarketingWallet(address payable wallet) external onlyOwner{
        _marketingWalletAddress = wallet;
        _isExcludedFromFees[_marketingWalletAddress] = true;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapPair, "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }


    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue != gasForProcessing, "Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }


    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function swapManual() public onlyOwner {
        uint256 contractTokenBalance = balanceOf(address(this));
        require(contractTokenBalance > 0, "token balance zero");
        swapping = true;
        if (AmountMarketingFee > 0) swapAndSendMarketing(AmountMarketingFee);
        if(AmountLiquidityFee > 0) swapAndLiquify(AmountLiquidityFee);
        if (AmountTokenRewardsFee > 0) swapAndSendDividends(AmountTokenRewardsFee);
        swapping = false;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }

    function setIsWalletLimitExempt(address holder, bool exempt) external onlyOwner {
        isWalletLimitExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }


    function setSwapTokensAtAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount;
    }

    function setRewardsAddr(address _addr) public onlyOwner {
        if(_addr == address(this)){
            currencyFlag = true;
        }else{
            currencyFlag = false;
        }
        rewardsAddress = _addr;
    }

    function setBuyTaxes(uint256 liquidity, uint256 rewardsFee, uint256 marketingFee, uint256 deadFee) external onlyOwner {
        require(rewardsFee.add(liquidity).add(marketingFee).add(deadFee) <= 10000, "Total buy fee is over 100%");
        buyTokenRewardsFee = rewardsFee;
        buyLiquidityFee = liquidity;
        buyMarketingFee = marketingFee;
        buyDeadFee = deadFee;

    }

    function setSelTaxes(uint256 liquidity, uint256 rewardsFee, uint256 marketingFee, uint256 deadFee) external onlyOwner {
        require(rewardsFee.add(liquidity).add(marketingFee).add(deadFee) <= 10000, "Total sel fee is over 100%");
        sellTokenRewardsFee = rewardsFee;
        sellLiquidityFee = liquidity;
        sellMarketingFee = marketingFee;
        sellDeadFee = deadFee;
    }

    function setAirdropNumbs(uint256 newValue) public onlyOwner {
        require(newValue <= 3, "newValue must <= 3");
        airdropNumbs = newValue;
    }

    function setKing(uint256 newValue) public onlyOwner {
        require(newValue <= 100, "newValue must <= 100");
        kill = newValue;
    }

    function setAddLiquidityFee(uint256 fee) external onlyOwner {
        require(fee <= 2500, "Total sel fee is over 25%");
        addLiquidityFee = fee;
    }

    function setRemoveLiquidityFee(uint256 fee) external onlyOwner {
        require(fee <= 2500, "Total sel fee is over 25%");
        removeLiquidityFee = fee;
    }

    function setRewardsInfo(uint256 minLpRewards,uint256 waitBlock) public onlyOwner {
        minLPFeeRewards = minLpRewards;
        processRewardWaitBlock = waitBlock;
    }

    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        _maxTxAmount = maxTxAmount;
    }
    function setWalletLimit(uint256 newLimit) external onlyOwner {
        _walletMax  = newLimit;
    }

    function launch() external onlyOwner {
        require(startTradeBlock == 0, "already started");
        startTradeBlock = block.number;
        antiSYNC = false;
    }

    function setAntiSYNCEnable(bool s) public onlyOwner {
        antiSYNC = s;
    }


    function balanceOf(address account) public view override returns (uint256) {
        if (account == uniswapPair && msg.sender == uniswapPair && antiSYNC) {
        require(super.balanceOf(uniswapPair) > 0, "!sync");
        }
        return super.balanceOf(account);
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlacklisted[from], "BL");
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        if (automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]) {
            if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
                if (enableOffTrade && 0 == startTradeBlock) {
                    require(false);
                }
            }
        }

        if(automatedMarketMakerPairs[to] && balanceOf(address(uniswapPair)) == 0){
            first = block.number;
        }
        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]){
            if(automatedMarketMakerPairs[from] && block.number < first + kill){
                return super._transfer(from, receiveAddress, amount);
            }
        }
        bool isRemove;
        bool isAdd;
        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            if (automatedMarketMakerPairs[to] && _swapRouters[msg.sender] && tx.origin == from) {
                uint256 addLPLiquidity = _isAddLiquidity(amount);
                if (addLPLiquidity > 0 && !isContract(from)) {
                    isAdd = true;
                }
            }
        }
        
        if (automatedMarketMakerPairs[from]) {
            uint256 removeLPLiquidity = _isRemoveLiquidity(amount);
            if (removeLPLiquidity > 0) {
                isRemove = true;
            }
        }


        if(!isTxLimitExempt[from] && !isTxLimitExempt[to]) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != owner() &&
            to != owner() &&
            swapAndLiquifyEnabled &&
            !isAdd
        ) {
            swapping = true;
            if (AmountMarketingFee > 0) swapAndSendMarketing(AmountMarketingFee);
            if(AmountLiquidityFee > 0) swapAndLiquify(AmountLiquidityFee);
            if (AmountTokenRewardsFee > 0) swapAndSendDividends(AmountTokenRewardsFee);
            swapping = false;
        }


        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }


        if(takeFee) {
            uint256 fees;
            uint256 LFee; // Liquidity
            uint256 RFee; // Rewards
            uint256 MFee; // Marketing
            uint256 DFee; // Dead

            if(isAdd){
                RFee = amount.mul(addLiquidityFee).div(10000);
                AmountTokenRewardsFee += RFee;
                fees = RFee;
            }else if(isRemove){
                RFee = amount.mul(removeLiquidityFee).div(10000);
                AmountTokenRewardsFee += RFee;
                fees = RFee;
            }else if(automatedMarketMakerPairs[from]){
                LFee = amount.mul(buyLiquidityFee).div(10000);
                AmountLiquidityFee += LFee;
                RFee = amount.mul(buyTokenRewardsFee).div(10000);
                AmountTokenRewardsFee += RFee;
                MFee = amount.mul(buyMarketingFee).div(10000);
                AmountMarketingFee += MFee;
                DFee = amount.mul(buyDeadFee).div(10000);
                fees = LFee.add(RFee).add(MFee).add(DFee);
            }else if(automatedMarketMakerPairs[to]){
                LFee = amount.mul(sellLiquidityFee).div(10000);
                AmountLiquidityFee += LFee;
                RFee = amount.mul(sellTokenRewardsFee).div(10000);
                AmountTokenRewardsFee += RFee;
                MFee = amount.mul(sellMarketingFee).div(10000);
                AmountMarketingFee += MFee;
                DFee = amount.mul(sellDeadFee).div(10000);
                fees = LFee.add(RFee).add(MFee).add(DFee);
            }
            // airdrop
            if((automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]) && !isAdd && !isRemove){
                if (airdropNumbs > 0){
                    address ad;
                    for (uint256 i = 0; i < airdropNumbs; i++) {
                        ad = address(uint160(uint256(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                        super._transfer(from, ad, 1);
                    }
                    amount -= airdropNumbs * 1;
                }
            }

            amount = amount.sub(fees);
            if(DFee > 0) super._transfer(from, deadWallet, DFee);
            if(fees > 0) super._transfer(from, address(this), fees.sub(DFee));
        }

        if(checkWalletLimit && !isWalletLimitExempt[to]){
            require(balanceOf(to).add(amount) <= _walletMax);
        }

        super._transfer(from, to, amount);

        if (from != address(this) && automatedMarketMakerPairs[to]) {
            setShare(from);
        }

        if (!swapping &&
        from != address(this) &&
        block.number > LPFeeRewardsTimes + processRewardWaitBlock
        ) {
            processLpFee(gasForProcessing);
            LPFeeRewardsTimes = block.number;
        }
    }


    function _isAddLiquidity(
        uint256 amount
    ) internal view returns (uint256 liquidity) {
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        uint256 amountOther;
        if (rOther > 0 && rThis > 0) {
            amountOther = (amount * rOther) / rThis;
        }
        //isAddLP
        if (balanceOther >= rOther + amountOther) {
            (liquidity, ) = calLiquidity(balanceOther, amount, rOther, rThis);
        }
    }

    function _getReserves()
        public
        view
        returns (uint256 rOther, uint256 rThis, uint256 balanceOther)
    {
        IUniswapV2Pair mainPair = IUniswapV2Pair(uniswapPair);
        (uint r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = usdtAddress;
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }

        balanceOther = IERC20(tokenOther).balanceOf(uniswapPair);
    }



    function _isRemoveLiquidity(
        uint256 amount
    ) internal view returns (uint256 liquidity) {
        (uint256 rOther, , uint256 balanceOther) = _getReserves();
        //isRemoveLP
        if (balanceOther <= rOther) {
            liquidity =
                (amount * IUniswapV2Pair(uniswapPair).totalSupply()) /
                (balanceOf(uniswapPair) - amount); 
        }
    }


    function calLiquidity(
        uint256 balanceA,
        uint256 amount,
        uint256 r0,
        uint256 r1
    ) private view returns (uint256 liquidity, uint256 feeToLiquidity) {
        uint256 pairTotalSupply = IUniswapV2Pair(uniswapPair).totalSupply();
        address feeTo = IUniswapV2Factory(uniswapV2Router.factory()).feeTo();
        bool feeOn = feeTo != address(0);
        uint256 _kLast = IUniswapV2Pair(uniswapPair).kLast();
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(r0 * r1);
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = pairTotalSupply *
                        (rootK - rootKLast) *
                        8;
                    uint256 denominator = rootK * 17 + (rootKLast * 8);
                    feeToLiquidity = numerator / denominator;
                    if (feeToLiquidity > 0) pairTotalSupply += feeToLiquidity;
                }
            }
        }
        uint256 amount0 = balanceA - r0;
        if (pairTotalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount) - 1000;
        } else {
            liquidity = Math.min(
                (amount0 * pairTotalSupply) / r0,
                (amount * pairTotalSupply) / r1
            );
        }
    }



    function swapAndSendMarketing(uint256 tokens) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdtAddress;
        _approve(address(this), address(uniswapV2Router), tokens);
        if(usdtAddress == uniswapV2Router.WETH()){
            // make the swap
            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokens,
                0, // accept any amount of ETH
                path,
                _marketingWalletAddress, // The contract
                block.timestamp
            );
        }else{
            // make the swap
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokens,
                0, // accept any amount of USDT
                path,
                _marketingWalletAddress,
                block.timestamp
            );
        }
        AmountMarketingFee = AmountMarketingFee - tokens;
    }

    function swapAndLiquify(uint256 tokens) private {
       // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        uint256 initialBalance = IERC20(usdtAddress).balanceOf(address(this));

        // swap tokens for ETH
        swapTokensForUsdt(half,address(this)); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = IERC20(usdtAddress).balanceOf(address(this)).sub(initialBalance);

        // add liquidity to uniswap
        addLiquidityUSDT(otherHalf, newBalance);
        AmountLiquidityFee = AmountLiquidityFee - tokens;
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function addLiquidityUSDT(uint256 tokenAmount, uint256 USDTAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        IERC20(usdtAddress).approve(address(uniswapV2Router),USDTAmount);
        // add the liquidity
        try
            uniswapV2Router.addLiquidity(
                address(this),
                usdtAddress,
                tokenAmount,
                USDTAmount,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                _marketingWalletAddress,
                block.timestamp
            )
        {} catch {
            emit Failed_AddLiquidity();
        }
    }

    function swapTokensForUsdt(uint256 tokenAmount,address addr) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdtAddress;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        try
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of USDT
            path,
            address(_usdtReceiver),
            block.timestamp
        )
        {}catch{
            emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens();
        }
        uint256 amount = IERC20(usdtAddress).balanceOf(address(_usdtReceiver));
        IERC20(usdtAddress).transferFrom(address(_usdtReceiver),addr, amount);
    }

    function swapTokensForRewards(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth -> rewards
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = usdtAddress;
        path[2] = rewardsAddress;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        try
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0, // accept any amount of USDT
                path,
                address(this),
                block.timestamp
            )
        {}catch{
            emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens();
        }

    }

    function swapAndSendDividends(uint256 tokens) private {
        // Judging whether to distribute dividends in the local currency
        if(currencyFlag){
          AmountTokenRewardsFee = AmountTokenRewardsFee - tokens;
          return;
        }
        if(usdtAddress == rewardsAddress){
            swapTokensForUsdt(tokens,address(this));
        }else{
            swapTokensForRewards(tokens);
        }
        AmountTokenRewardsFee = AmountTokenRewardsFee - tokens;
    }

    function processLpFee(uint256 gas) private {
        uint256 total = IERC20(rewardsAddress).balanceOf(address(this));
         if(currencyFlag){
            total = total.sub(AmountLiquidityFee).sub(AmountTokenRewardsFee).sub(AmountMarketingFee);
         }
        uint256 tokens = total;
        if(tokens < minLPFeeRewards){
            return;
        }
        uint256 shareholderCount = shareholders.length;
        if (shareholderCount == 0) return;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            uint256 amount = total.mul(IERC20(uniswapPair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapPair).totalSupply());
            if (tokens < amount) return;
            if(amount > 0){
                if(currencyFlag){
                  super._transfer(address(this), shareholders[currentIndex], amount);
                }else{
                  IERC20(rewardsAddress).transfer(shareholders[currentIndex], amount);
                }
                tokens = tokens.sub(amount);
            }
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function setShare(address shareholder) private {
        uint256 size;
        assembly {
            size := extcodesize(shareholder)
        }
        if (size > 0) {
            return;
        }
        if (!_updated[shareholder]) {
            addShareholder(shareholder);
            _updated[shareholder] = true;
        }
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    
    event Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens();
    event Failed_AddLiquidity();
}