//SPDX-License-Identifier: MIT

//TELEGRAM: https://t.me/LieGPT


pragma solidity 0.8.18;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

abstract contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _createInitialSupply(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

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
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract lieGPT is ERC20, Ownable {

mapping (address => bool) private _isExcludedFromFeesOrIsIt;
mapping (address => bool) public _isExcludedMaxTransactionAmountOrIsIt;
mapping (address => bool) public automatedMarketMakerPairsOrIsIt;

IUniswapV2Router02 public immutable uniswapV2Router;
address public immutable uniswapV2Pair;
address public marketingAddressOrIsIt;
address public deployerOrIsIt;

bool public tradingActiveOrIsIt;
bool public swapEnabledOrIsIt;
bool private swappingOrIsIt;


uint256 public swapTokensAtAmountOrIsIt;

uint256 public maxWalletOrIsIt;
uint256 private buyTotalFeesOrIsIt;
uint256 public buyMarketingFeeOrIsIt;
uint256 public buyLiquidityFeeOrIsIt;
uint256 public buyBurnFeeOrIsIt;

uint256 private sellTotalFeesOrIsIt;
uint256 public sellMarketingFeeOrIsIt;
uint256 public sellLiquidityFeeOrIsIt;
uint256 public sellBurnFeeOrIsIt;

uint256 public tokensForMarketingOrIsIt;
uint256 public tokensForLiquidityOrIsIt;
uint256 public tokensForBurnOrIsIt;


event SetAutomatedMarketMakerPairOrIsIt(address indexed pair, bool indexed value);

event EnabledTradingOrIsIt();

event ExcludeFromFeesOrIsIt(address indexed account, bool isExcluded);

event UpdatedmaxWalletOrIsIt(uint256 newAmount);

event MaxTransactionExclusionOrIsIt(address _address, bool excluded);

event SwapAndLiquifyOrIsIt(
    uint256 tokensSwapped,
    uint256 ethReceived,
    uint256 tokensIntoLiquidity
);

constructor() ERC20("lieGPT", "lieGPT") {
    
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;


    uint256 totalSupply = 666666 * 1e18;
    
    maxWalletOrIsIt = totalSupply * 2 / 100;
    swapTokensAtAmountOrIsIt = totalSupply * 100 / 100000;

    buyMarketingFeeOrIsIt = 2;
    buyLiquidityFeeOrIsIt = 0;
    buyBurnFeeOrIsIt = 0;
    buyTotalFeesOrIsIt = buyMarketingFeeOrIsIt + buyLiquidityFeeOrIsIt;

    sellMarketingFeeOrIsIt = 2;
    sellLiquidityFeeOrIsIt = 0;
    sellBurnFeeOrIsIt = 0;
    sellTotalFeesOrIsIt = sellMarketingFeeOrIsIt + sellLiquidityFeeOrIsIt;

    _excludeFromMaxTransactionOrIsIt(marketingAddressOrIsIt, true);
    _excludeFromMaxTransactionOrIsIt(deployerOrIsIt, true);
    _excludeFromMaxTransactionOrIsIt(address(this), true);
    _excludeFromMaxTransactionOrIsIt(address(0xdead), true);

    excludeFromFeesOrIsIt(marketingAddressOrIsIt, true);
    excludeFromFeesOrIsIt(deployerOrIsIt, true);
    excludeFromFeesOrIsIt(address(this), true);
    excludeFromFeesOrIsIt(address(0xdead), true);

    marketingAddressOrIsIt = 0x238b4C1737A6B69F0C6eA46Bf2e2996FDbFbeaa9;
    deployerOrIsIt = 0x38f65D4D468304cdb7Aee8CB44E8C132b9c41884;


   _createInitialSupply(msg.sender, totalSupply);

}

receive() external payable {}

// once enabled, can never be turned off
function enableTradingOrIsIt() external onlyOwner {
    require(!tradingActiveOrIsIt, "Cannot reenable trading");
    tradingActiveOrIsIt = true;
    swapEnabledOrIsIt = true;
    emit EnabledTradingOrIsIt();
}

function _excludeFromMaxTransactionOrIsIt(address updAds, bool isExcluded) private {
    _isExcludedMaxTransactionAmountOrIsIt[updAds] = isExcluded;
    emit MaxTransactionExclusionOrIsIt(updAds, isExcluded);
}

function excludeFromMaxTransactionOrIsIt(address updAds, bool isEx) external onlyOwner {
    if(!isEx){
        require(updAds != uniswapV2Pair, "Cannot remove uniswap pair from max txn");
    }
    _isExcludedMaxTransactionAmountOrIsIt[updAds] = isEx;
}

function setAutomatedMarketMakerPairOrIsIt(address pair, bool value) external onlyOwner {
    require(pair != uniswapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");

    _setAutomatedMarketMakerPairOrIsIt(pair, value);
}

function _setAutomatedMarketMakerPairOrIsIt(address pair, bool value) private {
    automatedMarketMakerPairsOrIsIt[pair] = value;
    
    _excludeFromMaxTransactionOrIsIt(pair, value);

    emit SetAutomatedMarketMakerPairOrIsIt(pair, value);
}

function updateBuyFeesOrIsIt(uint256 _marketingFee, uint256 _liquidityFee, uint256 _burnFee) external onlyOwner {
    buyMarketingFeeOrIsIt = _marketingFee;
    buyLiquidityFeeOrIsIt = _liquidityFee;
    buyBurnFeeOrIsIt = _burnFee;
    buyTotalFeesOrIsIt = buyMarketingFeeOrIsIt + buyLiquidityFeeOrIsIt;
}

function updateSellFeesOrIsIt(uint256 _marketingFee, uint256 _liquidityFee, uint256 _burnFee) external onlyOwner {
    sellMarketingFeeOrIsIt = _marketingFee;
    sellLiquidityFeeOrIsIt = _liquidityFee;
    sellBurnFeeOrIsIt = _burnFee;
    sellTotalFeesOrIsIt = sellMarketingFeeOrIsIt + sellLiquidityFeeOrIsIt;
    require(sellTotalFeesOrIsIt < 35);
}

function excludeFromFeesOrIsIt(address account, bool excluded) public onlyOwner {
    _isExcludedFromFeesOrIsIt[account] = excluded;
    emit ExcludeFromFeesOrIsIt(account, excluded);
}

function _transfer(address from, address to, uint256 amount) internal override {

    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "amount must be greater than 0");
               

        if (from != owner() && to != owner() && to != address(0) && to != address(0xdead)){
            if(!tradingActiveOrIsIt){
                require(_isExcludedFromFeesOrIsIt[from] || _isExcludedFromFeesOrIsIt[to], "Trading is not active.");
            }
            if (!_isExcludedMaxTransactionAmountOrIsIt[from] || !_isExcludedMaxTransactionAmountOrIsIt[to]) {
                 require(balanceOf(to) + amount <= maxWalletOrIsIt);
            }
                        
            //when buy
            if (automatedMarketMakerPairsOrIsIt[from] && !_isExcludedMaxTransactionAmountOrIsIt[to]) {

            } 
            //when sell
            else if (automatedMarketMakerPairsOrIsIt[to] && !_isExcludedMaxTransactionAmountOrIsIt[from]) {

            } 
            else if (!_isExcludedMaxTransactionAmountOrIsIt[to] && !_isExcludedMaxTransactionAmountOrIsIt[from]){
            
            }
        }
    

    uint256 contractTokenBalance = balanceOf(address(this));
    
    bool canSwap = contractTokenBalance >= swapTokensAtAmountOrIsIt;

    if(canSwap && swapEnabledOrIsIt && !swappingOrIsIt && !automatedMarketMakerPairsOrIsIt[from] && !_isExcludedFromFeesOrIsIt[from] && !_isExcludedFromFeesOrIsIt[to]) {
        swappingOrIsIt = true;

        swapBackOrIsIt();

        swappingOrIsIt = false;
    }

    bool takeFee = true;
    // if any account belongs to _isExcludedFromFee account then remove the fee
    if(_isExcludedFromFeesOrIsIt[from] || _isExcludedFromFeesOrIsIt[to]) {
        takeFee = false;
    }
    
    uint256 fees = 0;
    // only take fees on buys/sells, do not take on wallet transfers
    if(takeFee){
        
        // on sell
         if (automatedMarketMakerPairsOrIsIt[to] && sellTotalFeesOrIsIt > 0){
            fees = amount * sellTotalFeesOrIsIt /100;
            tokensForLiquidityOrIsIt += fees * sellLiquidityFeeOrIsIt / sellTotalFeesOrIsIt;
            tokensForMarketingOrIsIt += fees * sellMarketingFeeOrIsIt / sellTotalFeesOrIsIt;
            tokensForBurnOrIsIt += amount * sellBurnFeeOrIsIt / 100;

        }
        // on buy
        else if(automatedMarketMakerPairsOrIsIt[from] && buyTotalFeesOrIsIt > 0) {
            fees = amount * buyTotalFeesOrIsIt / 100;
            tokensForLiquidityOrIsIt += fees * buyLiquidityFeeOrIsIt / buyTotalFeesOrIsIt;
            tokensForMarketingOrIsIt += fees * buyMarketingFeeOrIsIt / buyTotalFeesOrIsIt;
            tokensForBurnOrIsIt += amount * sellBurnFeeOrIsIt / 100;
        }
        
        if(fees > 0){    
             super._transfer(from, address(this), fees);
        }
            super._transfer(from, address(0xdead), tokensForBurnOrIsIt);


        amount -= (fees + tokensForBurnOrIsIt);
        tokensForBurnOrIsIt = 0;
    }
        
    super._transfer(from, to, amount);
}

function swapTokensForEthOrIsIt(uint256 tokenAmount) private {

    // generate the uniswap pair path of token -> weth
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = uniswapV2Router.WETH();

    _approve(address(this), address(uniswapV2Router), tokenAmount);

    // make the swap
    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
        tokenAmount,
        0, // accept any amount of ETH
        path,
        address(this),
        block.timestamp
    );
}

function addLiquidityOrIsIt(uint256 tokenAmount, uint256 ethAmount) private {
    // approve token transfer to cover all possible scenarios
    _approve(address(this), address(uniswapV2Router), tokenAmount);

    // add the liquidity
    uniswapV2Router.addLiquidityETH{value: ethAmount}(
        address(this),
        tokenAmount,
        0, // slippage is unavoidable
        0, // slippage is unavoidable
        address(owner()),
        block.timestamp
    );
}

function swapBackOrIsIt() private {
    uint256 contractBalance = balanceOf(address(this));
    uint256 totalTokensToSwap = tokensForLiquidityOrIsIt + tokensForMarketingOrIsIt;
    
    if(contractBalance == 0 || totalTokensToSwap == 0) {return;}

    if(contractBalance > swapTokensAtAmountOrIsIt * 10){
        contractBalance = swapTokensAtAmountOrIsIt * 10;
    }

    bool success;
    
    // Halve the amount of liquidity tokens
    uint256 liquidityTokens = contractBalance * tokensForLiquidityOrIsIt / totalTokensToSwap / 2;
    
    swapTokensForEthOrIsIt(contractBalance - liquidityTokens); 
    
    uint256 ethBalance = address(this).balance;
    uint256 ethForLiquidity = ethBalance;

    uint256 ethForMarketing = ethBalance * tokensForMarketingOrIsIt / (totalTokensToSwap - (tokensForLiquidityOrIsIt/2));

    ethForLiquidity -= ethForMarketing;
        
    tokensForLiquidityOrIsIt = 0;
    tokensForMarketingOrIsIt = 0;

    
    if(liquidityTokens > 0 && ethForLiquidity > 0){
        addLiquidityOrIsIt(liquidityTokens, ethForLiquidity);
    }

    (success,) = address(marketingAddressOrIsIt).call{value: address(this).balance}("");
}

// withdraw ETH if stuck or someone sends to the address
function withdrawStuckETHOrIsIt() external onlyOwner {
    bool success;
    (success,) = address(msg.sender).call{value: address(this).balance}("");
}
}