/**

We are not officially affiliated with Invader Zim Brand 
We are just artists and huge fans trying to make a 
better life for ourselves and our investors

Twitter: https://twitter.com/invaderz_earth
Telegram: https://t.me/invaderz_earth
Website: https://invaderz-earth.xyz

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;


// import Context.sol
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

// import IERC20.sol
interface IERC20 {
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

// import IERC20Metadata.sol
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// import ERC20
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
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
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
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }
        emit Transfer(account, address(0), amount);
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
// import Ownable.sol
contract Ownable is Context {
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
// import UniswapV2Router.sol
interface UniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}
// import UniswapV2Factory.sol
interface UniswapFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract KrazyTaco is ERC20, Ownable {

    uint256 public maxBuyAmount;
    uint256 public maxSellAmount;
    uint256 public maxWalletAmount;
    UniswapV2Router public zimRouter;
    address public lpPair;
    bool private swapping;
    uint256 public swapTokensAtAmount;
    address tacosAddress;
    address devAddress;
    mapping (address => bool) public botEarly;
    uint256 public tradingActiveBlock = 0;
    uint256 public blockForPenaltyEnd;
    uint256 public botsCaught;
    bool public limitsInEffect = true;
    bool public tradingActive = false;
    bool public swapEnabled = false;
    bool public transferDelayEnabled = true;
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public _isExcludedMaxTransactionAmount;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping(address => uint256) private _holderLastTransferTimestamp;

    uint256 public buyTotalFees;
    uint256 public buyTacosFee;
    uint256 public buyLiquidityFee;
    uint256 public buyDevFee;
    uint256 public buyBurnFee;
    uint256 public sellTotalFees;
    uint256 public sellTacosFee;
    uint256 public sellLiquidityFee;
    uint256 public sellDevFee;
    uint256 public sellBurnFee;
    uint256 public tokensForTacos;
    uint256 public tokensForLiquidity;
    uint256 public tokensForDev;
    uint256 public tokensForBurn;

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event EnabledTrading();
    event RemovedLimits();
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event UpdatedMaxBuyAmount(uint256 newAmount);
    event UpdatedMaxSellAmount(uint256 newAmount);
    event UpdatedMaxWalletAmount(uint256 newAmount);
    event UpdatedtacosAddress(address indexed newWallet);
    event MaxTransactionExclusion(address _address, bool excluded);
    event BuyBackTriggered(uint256 amount);
    event OwnerForcedSwapBack(uint256 timestamp);
    event CaughtEarlyBuyer(address sniper);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );

    event TransferForeignToken(address token, uint256 amount);

    constructor() ERC20("Invader Zim", "ZIM") {

        address newOwner = msg.sender;

        UniswapV2Router _zimRouter = UniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        zimRouter = _zimRouter;

        lpPair = UniswapFactory(_zimRouter.factory()).createPair(address(this), _zimRouter.WETH());
        _excludeFromMaxTransaction(address(lpPair), true);
        _setAutomatedMarketMakerPair(address(lpPair), true);

        uint256 totalSupply = 1 * 1e12 * 1e18;

        maxBuyAmount = totalSupply * 1 / 100;
        maxSellAmount = totalSupply * 1 / 100;
        maxWalletAmount = totalSupply * 2 / 100;
        swapTokensAtAmount = totalSupply * 5 / 10000;

        buyTacosFee = 1;
        buyLiquidityFee = 0;
        buyDevFee = 29;
        buyBurnFee = 0;
        buyTotalFees = buyTacosFee + buyLiquidityFee + buyDevFee + buyBurnFee;

        sellTacosFee = 1;
        sellLiquidityFee = 0;
        sellDevFee = 9;
        sellBurnFee = 0;
        sellTotalFees = sellTacosFee + sellLiquidityFee + sellDevFee + sellBurnFee;

        _excludeFromMaxTransaction(newOwner, true);
        _excludeFromMaxTransaction(address(this), true);
        _excludeFromMaxTransaction(address(0xdead), true);
        excludeFromFees(newOwner, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);

        tacosAddress = address(newOwner);
        devAddress = address(newOwner);

        _createInitialSupply(newOwner, totalSupply);
        transferOwnership(newOwner);
    }
    receive() external payable {}

    function startTrading(uint256 deadBlock) external onlyOwner {
        require(!tradingActive, "Cannot re-disable trading");
        tradingActive = true;
        swapEnabled = true;
        tradingActiveBlock = block.number;
        blockForPenaltyEnd = tradingActiveBlock + deadBlock;
        emit EnabledTrading();
    }

    function removeLimits() external onlyOwner {
        limitsInEffect = false;
        transferDelayEnabled = false;
        emit RemovedLimits();
    }

    function manageBotEarly(address wallet, bool flag) external onlyOwner {
        botEarly[wallet] = flag;
    }

    function massManageBotEarly(address[] calldata wallets, bool flag) external onlyOwner {
        for(uint256 i = 0; i < wallets.length; i++){
            botEarly[wallets[i]] = flag;
        }
    }

    function disableTransferDelay() external onlyOwner {
        transferDelayEnabled = false;
    }

    function updateMaxBuyAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 2 / 1000)/1e18, "Cannot set max buy amount lower than 0.2%!");
        maxBuyAmount = newNum * (10**18);
        emit UpdatedMaxBuyAmount(maxBuyAmount);
    }

    function updateMaxSellAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 2 / 1000)/1e18, "Cannot set max sell amount lower than 0.2%!");
        maxSellAmount = newNum * (10**18);
        emit UpdatedMaxSellAmount(maxSellAmount);
    }

    function updateMaxWalletAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 3 / 1000)/1e18, "Cannot set max wallet amount lower than 0.3%!");
        maxWalletAmount = newNum * (10**18);
        emit UpdatedMaxWalletAmount(maxWalletAmount);
    }

    // change the minimum amount of tokens to sell from fees
    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
  	    require(newAmount >= totalSupply() * 1 / 100000, "Swap amount cannot be lower than 0.001% total supply!");
  	    require(newAmount <= totalSupply() * 1 / 1000, "Swap amount cannot be higher than 0.1% total supply!");
  	    swapTokensAtAmount = newAmount;
  	}

    function _excludeFromMaxTransaction(address updAds, bool isExcluded) private {
        _isExcludedMaxTransactionAmount[updAds] = isExcluded;
        emit MaxTransactionExclusion(updAds, isExcluded);
    }

    function airdrop(address[] memory wallets, uint256[] memory amountsInTokens) external onlyOwner {
        require(wallets.length == amountsInTokens.length, "Arrays must be the same length!");
        require(wallets.length < 600, "Can only airdrop 600 wallets per txn because of gas!");
        for(uint256 i = 0; i < wallets.length; i++){
            address wallet = wallets[i];
            uint256 amount = amountsInTokens[i];
            super._transfer(msg.sender, wallet, amount);
        }
    }

    function excludeFromMaxTransaction(address updAds, bool isEx) external onlyOwner {
        if(!isEx){
            require(updAds != lpPair, "Cannot remove Uniswap pair from max txn!");
        }
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != lpPair, "The pair cannot be removed from automatedMarketMakerPairs!");

        _setAutomatedMarketMakerPair(pair, value);
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        _excludeFromMaxTransaction(pair, value);
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateBuyFees(uint256 _TacosFee, uint256 _liquidityFee, uint256 _DevFee, uint256 _burnFee) external onlyOwner {
        buyTacosFee = _TacosFee;
        buyLiquidityFee = _liquidityFee;
        buyDevFee = _DevFee;
        buyBurnFee = _burnFee;
        buyTotalFees = buyTacosFee + buyLiquidityFee + buyDevFee + buyBurnFee;
        require(buyTotalFees <= 30, "Must keep fees at 30% or less!");
    }

    function updateSellFees(uint256 _TacosFee, uint256 _liquidityFee, uint256 _DevFee, uint256 _burnFee) external onlyOwner {
        sellTacosFee = _TacosFee;
        sellLiquidityFee = _liquidityFee;
        sellDevFee = _DevFee;
        sellBurnFee = _burnFee;
        sellTotalFees = sellTacosFee + sellLiquidityFee + sellDevFee + sellBurnFee;
        require(sellTotalFees <= 30, "Must keep fees at 30% or less!");
    }

    function returnToNormalTax() external onlyOwner {
        sellTacosFee = 1;
        sellLiquidityFee = 0;
        sellDevFee = 3;
        sellBurnFee = 0;
        sellTotalFees = sellTacosFee + sellLiquidityFee + sellDevFee + sellBurnFee;
        require(sellTotalFees <= 30, "Must keep fees at 30% or less!");

        buyTacosFee = 1;
        buyLiquidityFee = 0;
        buyDevFee = 3;
        buyBurnFee = 0;
        buyTotalFees = buyTacosFee + buyLiquidityFee + buyDevFee + buyBurnFee;
        require(buyTotalFees <= 30, "Must keep fees at 30% or less!");
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address.");
        require(to != address(0), "ERC20: transfer to the zero address.");
        require(amount > 0, "Amount must be greater than 0.");

        if(!tradingActive){
            require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active!");
        }

        if(blockForPenaltyEnd > 0){
            require(!botEarly[from] || to == owner() || to == address(0xdead), "Bots cannot transfer tokens in or out except to owner/dead address!");
        }

        if(limitsInEffect){
            if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]){
                if (transferDelayEnabled){
                    if (to != address(zimRouter) && to != address(lpPair)){
                        require(_holderLastTransferTimestamp[tx.origin] < block.number - 2 && _holderLastTransferTimestamp[to] < block.number - 2, "_transfer:: Transfer Delay enabled.  Please try again later.");
                        _holderLastTransferTimestamp[tx.origin] = block.number;
                        _holderLastTransferTimestamp[to] = block.number;
                    }
                }

                if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                        require(amount <= maxBuyAmount, "Buy transfer amount exceeds the max buy!");
                        require(amount + balanceOf(to) <= maxWalletAmount, "Cannot Exceed max wallet");
                }

                else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                        require(amount <= maxSellAmount, "Sell transfer amount exceeds the max sell!");
                }
                else if (!_isExcludedMaxTransactionAmount[to]){
                    require(amount + balanceOf(to) <= maxWalletAmount, "Cannot Exceed max wallet");
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(canSwap && swapEnabled && !swapping && !automatedMarketMakerPairs[from] && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            swapping = true;
            swapBack();
            swapping = false;
        }

        bool takeFee = true;
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        if(takeFee){
            if(earlyBuyPenaltyInEffect() && automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to] && buyTotalFees > 0){
                // anti-bot
                if(!botEarly[to]){
                    botEarly[to] = true;
                    botsCaught += 1;
                    emit CaughtEarlyBuyer(to);
                }
                fees = amount * 99 / 100;
        	    tokensForLiquidity += fees * buyLiquidityFee / buyTotalFees;
                tokensForTacos += fees * buyTacosFee / buyTotalFees;
                tokensForDev += fees * buyDevFee / buyTotalFees;
                tokensForBurn += fees * buyBurnFee / buyTotalFees;
            }
            else if (automatedMarketMakerPairs[to] && sellTotalFees > 0){
                fees = amount * sellTotalFees / 100;
                tokensForLiquidity += fees * sellLiquidityFee / sellTotalFees;
                tokensForTacos += fees * sellTacosFee / sellTotalFees;
                tokensForDev += fees * sellDevFee / sellTotalFees;
                tokensForBurn += fees * sellBurnFee / sellTotalFees;
            }
            else if(automatedMarketMakerPairs[from] && buyTotalFees > 0) {
        	    fees = amount * buyTotalFees / 100;
        	    tokensForLiquidity += fees * buyLiquidityFee / buyTotalFees;
                tokensForTacos += fees * buyTacosFee / buyTotalFees;
                tokensForDev += fees * buyDevFee / buyTotalFees;
                tokensForBurn += fees * buyBurnFee / buyTotalFees;
            }
            if(fees > 0){
                super._transfer(from, address(this), fees);
            }
        	amount -= fees;
        }
        super._transfer(from, to, amount);
    }

    function earlyBuyPenaltyInEffect() public view returns (bool){
        return block.number < blockForPenaltyEnd;
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = zimRouter.WETH();
        _approve(address(this), address(zimRouter), tokenAmount);
        zimRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(zimRouter), tokenAmount);
        zimRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            address(0xdead),
            block.timestamp
        );
    }

    function swapBack() private {

        if(tokensForBurn > 0 && balanceOf(address(this)) >= tokensForBurn) {
            _burn(address(this), tokensForBurn);
        }
        tokensForBurn = 0;

        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForLiquidity + tokensForTacos + tokensForDev;

        if(contractBalance == 0 || totalTokensToSwap == 0) {return;}

        if(contractBalance > swapTokensAtAmount * 20){
            contractBalance = swapTokensAtAmount * 20;
        }

        bool success;
        uint256 liquidityTokens = contractBalance * tokensForLiquidity / totalTokensToSwap / 2;
        swapTokensForEth(contractBalance - liquidityTokens);
        uint256 ethBalance = address(this).balance;
        uint256 ethForLiquidity = ethBalance;
        uint256 ethForTacos = ethBalance * tokensForTacos / (totalTokensToSwap - (tokensForLiquidity/2));
        uint256 ethForDev = ethBalance * tokensForDev / (totalTokensToSwap - (tokensForLiquidity/2));
        ethForLiquidity -= ethForTacos + ethForDev;

        tokensForLiquidity = 0;
        tokensForTacos = 0;
        tokensForDev = 0;
        tokensForBurn = 0;

        if(liquidityTokens > 0 && ethForLiquidity > 0){
            addLiquidity(liquidityTokens, ethForLiquidity);
        }

        (success,) = address(devAddress).call{value: ethForDev}("");

        (success,) = address(tacosAddress).call{value: address(this).balance}("");
    }

    function transferForeignToken(address _token, address _to) external onlyOwner returns (bool _sent) {
        require(_token != address(0), "_token address cannot be 0");
        require(_token != address(this), "Can't withdraw native tokens");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
        emit TransferForeignToken(_token, _contractBalance);
    }

    function pullStuckETH() external onlyOwner {
        bool success;
        (success,) = address(msg.sender).call{value: address(this).balance}("");
    }

    function setTacosAddress(address _tacosAddress) external onlyOwner {
        require(_tacosAddress != address(0), "_tacosAddress address cannot be 0");
        tacosAddress = payable(_tacosAddress);
    }

    function setDevAddress(address _devAddress) external onlyOwner {
        require(_devAddress != address(0), "_devAddress address cannot be 0");
        devAddress = payable(_devAddress);
    }

    function forceSwapBack() external onlyOwner {
        require(balanceOf(address(this)) >= swapTokensAtAmount, "Can only swap when token amount is more than restriction (or equal)");
        swapping = true;
        swapBack();
        swapping = false;
        emit OwnerForcedSwapBack(block.timestamp);
    }

    function buyBackTokens(uint256 amountInWei) external onlyOwner {
        require(amountInWei <= 10 ether, "May not buy more than 10 ETH to reduce attack surface");

        address[] memory path = new address[](2);
        path[0] = zimRouter.WETH();
        path[1] = address(this);

        zimRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountInWei}(
            0,
            path,
            address(0xdead),
            block.timestamp
        );
        emit BuyBackTriggered(amountInWei);
    }
}