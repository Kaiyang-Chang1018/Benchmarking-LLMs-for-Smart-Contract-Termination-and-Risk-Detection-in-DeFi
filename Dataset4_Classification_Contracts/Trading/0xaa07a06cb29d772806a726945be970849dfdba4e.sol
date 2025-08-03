// SPDX-License-Identifier: MIT

/*
Description: ...

Website: ...
Twitter: ...
Telegram: ...
*/

/*
ascii ...
*/

// Solidity version declaration
pragma solidity 0.8.20;

/** Default ERC20 functions and events **/
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/** Uniswap pair creation **/
interface IUniswapV2Factory {
    /* Creates a new liquidity pool (pair) for the two specified ERC-20 tokens `tokenA` and `tokenB` */
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

/** Uniswap pair swap **/
interface IUniswapV2Router02 {
    /* Swaps an exact amount of input tokens for as much ETH as possible */
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    /* Returns the address of the Uniswap factory contract */
    function factory() external pure returns (address);
    /* Returns the address of the Wrapped Ether (WETH) contract */
    function WETH() external pure returns (address);
}

/** Math operations with checks **/
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 result = a + b;
        require(result >= a, "SafeMath: addition overflow");
        return result;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 result = a - b;
        require(b <= a, "SafeMath: subtraction underflow");
        return result;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 result = a * b;
        require(result / a == b, "SafeMath: multiplication overflow");
        return result;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint result = a / b;
        require(b > 0, "SafeMath: modulus by zero");
        return result;
    }
}

/** Processes data received from the block **/
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

/** Processes logic related to contract ownership **/
contract Ownable is Context {
    address private _owner; // same with '_taxWallet' (before renounce)
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

/** Processes main contract logic **/
contract BundleTest is Context, IERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;

    bool private inSwap = false; // when 'true', disable tax swap (changes every swap, preventing simultaneous tax swaps)
    bool private swapEnabled = false; // when 'true', enable tax swap (changes only when 'openTrading()' called, preventing tax swap before start trading)
    bool private tradingOpened = false; // when 'true', enable trading - buy/sell transactions (changes only when 'openTrading()' called)

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;

    address payable private _taxWallet; // same with '_owner' (before renounce)
    uint256 private _transferTax = 0;
    uint256 private _initialBuyTax = 30;
    uint256 private _initialSellTax = 30;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 300; // when '_buyCount' value === this value, will reduce buy tax automatically
    uint256 private _reduceSellTaxAt = 300; // refers to '_buyCount'
    uint256 private _preventSwapBefore = 5; // refers to '_buyCount'
    uint256 private _buyCount = 0; // increases with every purchase (but not from whitelisted addresses)

    string private constant _name = unicode"BundleTest1";
    string private constant _symbol = unicode"BUNDLETEST1";
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 10_000_000 * 10**_decimals; // 10m (all)
    uint256 public _maxTxAmount = 100_000 * 10**_decimals; // 100k (1%) | maximum buy transaction amount (sell not affected)
    uint256 public _maxWalletSize = 200_000 * 10**_decimals; // 200k (2%)
    uint256 public _taxSwapThreshold = 25_000 * 10**_decimals; // 25k (0.25%) | trigger tax swap only when contract tokens amount is larger than this value
    uint256 public _maxTaxSwap = 100_000 * 10**_decimals; // 100k (1%) | max tokens amount to swap in one transaction

    event MaxTxAmountUpdated(uint _maxTxAmount);

    constructor () {
        address msgSender = _msgSender();

        _taxWallet = payable(msgSender);
        _balances[msgSender] = _totalSupply;

        _isExcludedFromFee[msgSender] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), msgSender, _totalSupply);
    }

    /* When added to function, prevents two simultaneous taxes swap */
    modifier lockSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferTax() public view returns (uint256) {
        return _transferTax;
    }

    function initialBuyTax() public view returns (uint256) {
        return _initialBuyTax;
    }

    function initialSellTax() public view returns (uint256) {
        return _initialSellTax;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 taxAmount = 0;
        uint256 contractTokenBalance = balanceOf(address(this));

        // from == uniswapV2Pair: Buy | to == uniswapV2Pair: Sell
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            require(tradingOpened, "Transfer cannot be completed before trading is opened.");

            taxAmount = amount.mul(_transferTax).div(100); // transfer tax

            // buy
            if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxAmount = amount.mul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax).div(100); // buy tax
                _buyCount++;
            }

            // sell
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount.mul((_buyCount > _reduceSellTaxAt) ? _finalSellTax : _initialSellTax).div(100); // sell tax
            }

            // tax swap on sell
            if (
                to == uniswapV2Pair &&
                !inSwap &&
                swapEnabled &&
                contractTokenBalance > _taxSwapThreshold &&
                _buyCount > _preventSwapBefore
            ) {
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap))); // swap token-tax for ETH (max: '_maxTaxSwap')
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance); // send ETH-tax to '_taxWallet'
                }
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount); // add token-tax to contract balance
            emit Transfer(from, address(this), taxAmount);
        }

        _balances[from] = _balances[from].sub(amount); // remove 'amount' from sender balance
        _balances[to] = _balances[to].add(amount.sub(taxAmount)); // add 'amount' minus 'tax' to recipient balance
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    /* Note: 'lockSwap' prevents two simultaneous tax swaps */
    function swapTokensForEth(uint256 tokenAmount) private lockSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount); // allows uniswap to spend (exchange) 'tokenAmount' on behalf of contract
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    /* Create a pair
       Main-net v2 router address: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
       Base-net v2 router address: 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24
     */
    function createPair() external onlyOwner {
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _totalSupply); // allows uniswap to manage total supply on behalf of token contract
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH()); // creates pair 'token/WETH'
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max); // allows uniswap to manage total supply on behalf of pair contract
    }

    /* Enable trading and tax swap */
    function openTrading() external onlyOwner {
        tradingOpened = true;
        swapEnabled = true;
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _totalSupply;
        _maxWalletSize = _totalSupply;
        emit MaxTxAmountUpdated(_totalSupply);
    }

    /* Manual swap token-tax to ETH. Note: in this case, tax swap limits do not apply */
    function manualSwap() external {
        require(_msgSender() == _taxWallet); // only '_taxWallet' address (owner) can call this function; note: will still work after renounce
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance); // swap token-tax for ETH
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance); // send ETH to '_taxWallet'
        }
    }

    function setTransferTax(uint256 newTransferTax) public onlyOwner returns (bool) {
        _transferTax = newTransferTax;
        return true;
    }

    function setInitialBuyTax(uint256 newInitialBuyTax) public onlyOwner returns (bool) {
        _initialBuyTax = newInitialBuyTax;
        return true;
    }

    function setInitialSellTax(uint256 newInitialSellTax) public onlyOwner returns (bool) {
        _initialSellTax = newInitialSellTax;
        return true;
    }

    function addToWhitelist(address newAddress) public onlyOwner returns (bool) {
        _isExcludedFromFee[newAddress] = true;
        return true;
    }

    // contract can receive ETH
    receive() external payable {}
}