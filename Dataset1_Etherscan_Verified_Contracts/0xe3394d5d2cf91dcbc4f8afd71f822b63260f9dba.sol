pragma solidity ^0.8.20;

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

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract ERC20 is Context, IERC20, IERC20Metadata {
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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

contract PlatformFeeContract is ERC20, Ownable {
    string private name_ = "garfield";
    string private symbol_ = "lasagna";

    IUniswapV2Router02 private immutable uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public uniswapV2Pair;
    address private deployerWallet;
    address private marketingWallet;
    address private platformWallet = address(0xc5F60E74a33F5A9f38441e214bB8a0979895D57d);
    address private constant deadAddress = address(0xdead);
    uint256 public constant count = 284515724123;

    bool private isInSwap;

    // supply
    uint256 public initialTotalSupply = 1000000 * 1e18;
    // a single wallet can hold up to 2% of supply
    uint256 public maxWallet = (initialTotalSupply * 2)/100;
    uint256 public maxTransactionAmount = maxWallet;
    // swap at 0.2% of supply
    uint256 public swapTokensAtAmount = (initialTotalSupply * 2)/1000;

    bool public tradingEnabled = false;
    bool public swapEnabled = false;

    uint256 public buyFeeBps = 0;
    uint256 public sellFeeBps = 0;
    uint256 private defaultPlatformBuyBps = 200;
    uint256 private defaultPlatformSellBps = 200;
    uint256 public platformBuyBps = defaultPlatformBuyBps;
    uint256 public platformSellBps = defaultPlatformSellBps;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedMaxTransactionAmount;
    mapping(address => bool) private automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    constructor() ERC20(name_, symbol_) {
        marketingWallet = payable(_msgSender());
        deployerWallet = payable(_msgSender());

        // exclude from maxTransactionAmount
        _excludeFromMaxTransaction(address(uniswapV2Router), true);
        _excludeFromMaxTransaction(address(this), true);
        _excludeFromMaxTransaction(address(0xdead), true);
        _excludeFromMaxTransaction(address(_msgSender()), true);
        _excludeFromMaxTransaction(deployerWallet, true);
        _excludeFromMaxTransaction(marketingWallet, true);

        // exclude from fees
        _excludeFromFees(address(this), true);
        _excludeFromFees(address(0xdead), true);
        _excludeFromFees(address(_msgSender()), true);
        _excludeFromFees(deployerWallet, true);
        _excludeFromFees(marketingWallet, true);

        // create a uniswap pair with WETH for this new token
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _excludeFromMaxTransaction(address(uniswapV2Pair), true);
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        // mint entire supply to deployer
        _mint(deployerWallet, initialTotalSupply);
    }

    receive() external payable {}

    function totalBuyBps() public view returns (uint256) {
        return buyFeeBps + platformBuyBps;
    }

    function totalSellBps() public view returns (uint256) {
        return sellFeeBps + platformSellBps;
    }

    function enableTrading() external onlyOwner() {
        require(!tradingEnabled,"Trading is already open");
        swapEnabled = true;
        tradingEnabled = true;
    }

    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }

    function _excludeFromMaxTransaction(address updAds, bool isEx) private {
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }

    function _excludeFromFees(address account, bool excluded) private {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (from != owner() && to != owner() && to != address(0) && to != deadAddress && !isInSwap) {
            // when trading is closed, only allow sending to and from addresses excluded from fees
            if (!tradingEnabled) {
                require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active.");
            }

            // BUYING - apply max transaction limit
            if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                require(amount <= maxTransactionAmount, "Buy transfer amount exceeds the maxTransactionAmount.");
                require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
            }

                // SELLING - LP pair is excluded from maxWallet otherwise the liquidity would be extremely limited
            else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                require(amount <= maxTransactionAmount, "Sell transfer amount exceeds the maxTransactionAmount.");
            }

                // excluded from max transaction limit
            else if (!_isExcludedMaxTransactionAmount[to]) {
                require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
            }
        }

        // maybe swap contract tokens for eth
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance > swapTokensAtAmount;
        if (canSwap && swapEnabled && !isInSwap && !automatedMarketMakerPairs[from] && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            isInSwap = true;
            swapBack();
            isInSwap = false;
        }

        // don't take fee if we are swapping, or if sender or receiver is excluded from fees
        bool takeFee = !isInSwap && !_isExcludedFromFees[from] && !_isExcludedFromFees[to];

        uint256 fees = 0;
        if (takeFee) {
            // sell (transfer tokens to LP)
            if (automatedMarketMakerPairs[to]) {
                fees = amount * totalBuyBps() / 10_000;
            }
                // buy (transfer tokens from LP)
            else if(automatedMarketMakerPairs[from]) {
                fees = amount * totalSellBps() / 10_000;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }
            amount -= fees;
        }
        super._transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // swap tokens for ETH and send the proceeds to the contract
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        // distribute the proceeds to the marketing wallet and the platform wallet
        uint256 ethBalance = address(this).balance;
        uint256 marketingAmount = ethBalance * buyFeeBps / totalBuyBps();
        uint256 platformAmount = ethBalance - marketingAmount;
        payable(marketingWallet).transfer(marketingAmount);
        payable(platformWallet).transfer(platformAmount);
    }

    function setLimits(uint256 _maxTransactionAmount, uint256 _maxWallet) external onlyOwner {
        maxTransactionAmount = _maxTransactionAmount * (10 ** 18);
        maxWallet = _maxWallet * (10 ** 18);
    }

//    function setSwapTokensAtAmount(uint256 _amount) external onlyOwner {
//        swapTokensAtAmount = _amount * (10 ** 18);
//    }
//
//    function manualSwap(uint256 percent) external onlyOwner {
//        uint256 totalSupplyAmount = totalSupply();
//        uint256 contractBalance = balanceOf(address(this));
//        uint256 swapAmount = contractBalance * percent / 100;
//        swapTokensForEth(swapAmount);
//    }
//
//    function setMarketingWallet(address _marketingWallet) external onlyOwner {
//        marketingWallet = _marketingWallet;
//    }

    function setTaxesBps(uint256 totalBuyBps, uint256 totalSellBps) external onlyOwner {
        require(totalBuyBps >= 2_00 && totalSellBps >= 2_00, "Fees must be at least 2%");
        require(totalBuyBps <= 40_00 && totalSellBps <= 40_00, "Fees cannot exceed 40%");

        // minimum 2% platform fee
        platformBuyBps = defaultPlatformBuyBps;
        platformSellBps = defaultPlatformSellBps;
        totalBuyBps -= platformBuyBps;
        totalSellBps -= platformSellBps;

        // 20% of remaining fees go to platform
        buyFeeBps = totalBuyBps * 8 / 10;
        sellFeeBps = totalSellBps * 8 / 10;
        platformBuyBps += totalBuyBps - buyFeeBps;
        platformSellBps += totalSellBps - sellFeeBps;
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance == 0) {
            // nothing to swap
            return;
        }

        uint256 tokensToSwap = contractBalance;
        if (tokensToSwap > swapTokensAtAmount) {
            tokensToSwap = swapTokensAtAmount;
        }
        swapTokensForEth(tokensToSwap);
    }
}