//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/*
    DoubleEspresso - a bot to build your website and deploy your token in a few minutes!
    (token factory at the bottom of the contract)

    Why just one espresso if you can take two?
    
    tg: https://t.me/DespressoToken
    twitter: @DEspressotoken
    website: https://despresso.eth.limo/

*/

library TransferHelper {
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IERC20 {
    function approve(address spender, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IpinkSale {
    function lock(
        address owner,
        address token,
        bool isLpToken,
        uint256 amount,
        uint256 unlockDate,
        string memory description
    ) external returns (uint256 id);

}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Invalid owner");
        _transferOwnership(newOwner);
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract tokenTemplate is Ownable {
    IDEXRouter public constant router = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IpinkSale constant locker = IpinkSale(0x71B5759d73262FBb223956913ecF4ecC51057641);
    address public pair;

    // ERC20 defaults
    string _name;
    string _ticker;
    uint8 constant _decimals = 18;
    uint256 _totalSupply = 1 * (10**9) * (10**_decimals); // default 1 billion

    // ERC20 mappings
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    uint256 constant divisor = 1_000;

    // Limits
    bool public limitsEnabled = true;
    mapping(address => bool) _isTxLimitExempt;
    uint256 public maxTxAmount = (_totalSupply * 10) / divisor; //1 %
    uint256 public maxWalletAmount = (_totalSupply * 10) / divisor; // 1%

    // Fees
    bool public feesEnabled;
    mapping(address => bool) _isFeeExempt;
    uint256 private sniperTaxTillBlock;
    uint256 private tokensForMarketing;
    uint256 private tokensForLp;
    uint256 private tokensForDev;
    address public lpWallet;
    address public marketingWallet;
    address public devWallet;
    uint256 marketingBuyFee = 20;
    uint256 liquidityBuyFee = 20;
    uint256 developmentBuyFee = 20;
    uint256 public totalBuyFee = marketingBuyFee + liquidityBuyFee + developmentBuyFee;
    uint256 marketingSellFee = 30;
    uint256 liquiditySellFee = 30;
    uint256 developmentSellFee = 20;
    uint256 public totalSellFee = marketingSellFee + liquiditySellFee + developmentSellFee;

    // Lp locker
    uint256 public lpLockId;

    // Swapback
    bool public swapEnabled = true;
    uint256 public swapThreshold = (_totalSupply * 10) / 100_000; // 0.01%
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    // Trade block
    bool tradingAllowed;
    uint256 sniperTaxTill;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(
        string memory __name,
        string memory __ticker,
        address __owner,
        bool __hasFees,
        uint256 __marketingTax,
        address __marketing,
        uint256 __devTax,
        address __dev,
        uint256 __lpTax,
        address __lp
    ) {
        _name = __name;
        _ticker = __ticker;
        transferOwnership(__owner);      

        // Arrange fee and tx exempts
        _isFeeExempt[address(this)] = true;
        _isTxLimitExempt[address(this)] = true;
        _isFeeExempt[__owner] = true;
        _isTxLimitExempt[__owner] = true;
        _isTxLimitExempt[address(router)] = true;

        // Take care of the approvals for the owner and the token itself
        _allowances[address(this)][address(router)] = _totalSupply;
        
        // If fees are disabled entirely we can totally skip them in the transfer
        // to save tx costs.
        feesEnabled = __hasFees;
        swapEnabled = __hasFees; // only need to enable swap in case of fees

        // Set fee wallets
        lpWallet = __lp;
        marketingWallet = __marketing;
        devWallet = __dev;

        // Set taxes
        // - Buy taxes
        require(__marketingTax + __lpTax + __devTax <= 150); // note divisor = 1000
        marketingBuyFee = __marketingTax;
        liquidityBuyFee = __lpTax;
        developmentBuyFee = __devTax;
        totalBuyFee  = marketingBuyFee + liquidityBuyFee + developmentBuyFee;

        // - Sell taxes
        marketingSellFee = __marketingTax;
        liquiditySellFee = __lpTax;
        developmentSellFee = __devTax;
        totalSellFee  = marketingSellFee + liquiditySellFee + developmentSellFee;

        // Mint the tokens to the contract
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }


    // Basic ERC20 functions
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _ticker;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Basic transfer is a transfer without tax - for wallets excluded from fees/limits
    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Insufficient Balance");
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // To configure the buy fees with a limit of 15%
    function setBuyFees(
        uint256 _marketingFee,
        uint256 _liquidityFee,
        uint256 _developFee
    ) external onlyOwner {
        require(_marketingFee + _liquidityFee + _developFee <= 150); // note divisor = 1000
        marketingBuyFee = _marketingFee;
        liquidityBuyFee = _liquidityFee;
        developmentBuyFee = _developFee;
        totalBuyFee = _marketingFee + _liquidityFee + _developFee;
    }

    // To configure the sell fees with a limit of 15%
    function setSellFees(
        uint256 _marketingFee,
        uint256 _liquidityFee,
        uint256 _developFee
    ) external onlyOwner {
        require(_marketingFee + _liquidityFee + _developFee <= 150); // max 15%
        marketingSellFee = _marketingFee;
        liquiditySellFee = _liquidityFee;
        developmentSellFee = _developFee;
        totalSellFee = _marketingFee + _liquidityFee + _developFee;
    }

    // Update tax wallet if necessary
    function updateWallets(
        address _marketingWallet,
        address _lpWallet,
        address _devWallet
    ) external onlyOwner {
        marketingWallet = _marketingWallet;
        lpWallet = _lpWallet;
        devWallet = _devWallet;
    }

    // We can change the max wallet but only to be at least 1% of the supply
    function setMaxWallet(uint256 percent) external onlyOwner {
        require(percent >= 10); // Note divisor = 1000
        maxWalletAmount = (_totalSupply * percent) / divisor;
    }

    // We can change the max tx limit but it should be at least 1% of the supply
    function setTxLimit(uint256 percent) external onlyOwner {
        require(percent >= 10); // Note divisor = 1000
        maxTxAmount = (_totalSupply * percent) / divisor;
    }

    // Check restrictions, mainly to just after launch limit wallets taking up large portions of
    // the supply
    function checkLimits(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        // return if sender and recipient are excluded
        if (_isTxLimitExempt[sender] && _isTxLimitExempt[recipient]) {
            return;
        }

        // Buy
        if (sender == pair && !_isTxLimitExempt[recipient]) {
            require(amount <= maxTxAmount, "Max tx limit");

        // Sell
        } else if (recipient == pair && !_isTxLimitExempt[sender]) {
            require(amount <= maxTxAmount, "Max tx limit");
        }

        // Max wallet
        if (!_isTxLimitExempt[recipient]) {
            require(
                amount + balanceOf(recipient) <= maxWalletAmount,
                "Max wallet"
            );
        }
    }

    // Permanently lift the limits, this can't be reversed
    // limits can also just be loosened instead
    function permanent_lift_limits() external onlyOwner {
        limitsEnabled = false;
    }

    // Let the trading begin! 
    // This will automatically lock the lp for at least 1 month with 
    // the msg.sender (=owner) becoming the owner of the lp tokens that
    // can be withdraw after at least a month or locks can just be extended
    // in the pinksale GUI
    function startTrading(uint256 lock_lp_months) external payable onlyOwner {
        require(!tradingAllowed, "Trading already enabled");
        require(lock_lp_months >= 1, "Lock < 1 month");
        require(msg.value > 0, "No ETH supplied");

        // Create the pair contract 
        pair = IDEXFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        // Exclude the pair from tx limit and approve owner
        _isTxLimitExempt[address(pair)] = true;
        _allowances[owner()][address(pair)] = _totalSupply;

        // Add the lp and send the lp tokens back to the token contract
        inSwap = true;
        addLiquidity(balanceOf(address(this)), msg.value, address(this));
        tradingAllowed = true;
        inSwap = false;

        // Transfer LP tokens to pinksale locker
        uint256 lp_tokens = IERC20(pair).balanceOf(address(this));
        IERC20(pair).approve(address(locker), lp_tokens);
        uint256 unlock_date = block.timestamp + lock_lp_months * 30 days;

        // Lock and assign ownership of the lock to the sender i.e. dev
        lpLockId = locker.lock(
            msg.sender,
            pair,
            true,
            lp_tokens,
            unlock_date,
            "lp lock"
        );

        // Set sniper block
        sniperTaxTill = block.number + 2;
    }

    // To change whether tokens in the contract should be swapped for for ETH
    // and at what threshold
    function setTokenSwapSettings(bool _enabled, uint256 _threshold)
        external
        onlyOwner
    {
        swapEnabled = _enabled;
        swapThreshold = _threshold * (10**_decimals);
    }

    // Check if tokens in the contract should be swapped, only on sells
    function shouldTokenSwap(address recipient) internal view returns (bool) {
        return
            recipient == pair &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= swapThreshold;
    }

    function takeFee(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256) {
        // Exempt from fees so return
        if (_isFeeExempt[from] || _isFeeExempt[to]) {
            return amount;
        }

        uint256 fees;

        // Sniper tax, only first two blocks after lp
        if (block.number <= sniperTaxTill) {
            fees = (amount * 98) / 100; // 98% tax
            tokensForLp += (fees * 50) / 98;
            tokensForMarketing += (fees * 48) / 98;
        }
        // On sell
        else if (to == pair && totalSellFee > 0) {
            fees = (amount * totalSellFee) / divisor;
            tokensForLp += (fees * liquiditySellFee) / totalSellFee;
            tokensForDev += (fees * developmentSellFee) / totalSellFee;
            tokensForMarketing += (fees * marketingSellFee) / totalSellFee;
        }
        // On buy
        else if (from == pair && totalBuyFee > 0) {
            fees = (amount * totalBuyFee) / divisor;
            tokensForLp += (fees * liquidityBuyFee) / totalBuyFee;
            tokensForDev += (fees * developmentBuyFee) / totalBuyFee;
            tokensForMarketing += (fees * marketingBuyFee) / totalBuyFee;
        }

        // Send collected fees
        if (fees > 0) {
            _basicTransfer(from, address(this), fees);
            emit Transfer(from, address(this), fees);
        }

        // Taxed amount
        return amount -= fees;
    }

    function swapBack() internal swapping {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForLp +
            tokensForMarketing +
            tokensForDev;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        // Halve the amount of liquidity tokens
        uint256 liquidityTokens = (contractBalance * tokensForLp) / totalTokensToSwap / 2;
        uint256 amountToSwapForETH = contractBalance - liquidityTokens;

        uint256 initialETHBalance = address(this).balance;

        // Swap the tokens for ETH
        swapTokensForEth(amountToSwapForETH);

        uint256 ethBalance = address(this).balance - initialETHBalance;
        uint256 ethForMarketing = (ethBalance * tokensForMarketing) / totalTokensToSwap;
        uint256 ethForDev = (ethBalance * tokensForDev) / totalTokensToSwap;
        uint256 ethForLiquidity = ethBalance - ethForMarketing - ethForDev;

        // Reset token fee counts
        tokensForLp = 0;
        tokensForMarketing = 0;
        tokensForDev = 0;

        // Send Dev fees
        payable(devWallet).transfer(ethForDev);

        // Add liquidty
        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liquidityTokens, ethForLiquidity, lpWallet);
            emit SwapAndLiquify(
                amountToSwapForETH,
                ethForLiquidity,
                tokensForLp
            );
        }

        // Hand out the marketing ETH
        payable(marketingWallet).transfer(address(this).balance);
    }

    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        if (owner() == msg.sender) {
            return _basicTransfer(msg.sender, recipient, amount);
        } else {
            return _transferFrom(msg.sender, recipient, amount);
        }
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if (_allowances[sender][msg.sender] != _totalSupply) {
            // Get the current allowance
            uint256 curAllowance = _allowances[sender][msg.sender];
            require(curAllowance >= amount, "Insufficient Allowance");
            _allowances[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        // Excluded from limits and fees
        if (sender == owner() || recipient == owner() || inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        // In any other case, check if trading is open already and whether limits/fees should be applied
        require(tradingAllowed, "Trading not open yet");
        if (limitsEnabled) {
            checkLimits(sender, recipient, amount);
        }
        if (shouldTokenSwap(recipient)) {
            swapBack();
        }
        if (feesEnabled) {
            amount = (recipient == pair || sender == pair)
                ? takeFee(sender, recipient, amount)
                : amount;
        }
        _basicTransfer(sender, recipient, amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(
        uint256 tokenAmount,
        uint256 ethAmount,
        address sendTo
    ) private {
        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            sendTo,
            block.timestamp
        );
    }

    function clearStuckWETH(uint256 perc) external {
        require(msg.sender == marketingWallet);
        uint256 amountWETH = address(this).balance;
        payable(marketingWallet).transfer((amountWETH * perc) / 100);
    }

    receive() external payable {}
}

contract DoubleEspresso is tokenTemplate {
    mapping(address => address) public token_owners; // token -> owner
    mapping(address => address[]) public tokens_owned; // owner -> token(s)
    bool factory_enabled;
    uint256 public tokens_created;
    uint256 burnCreationFee = 1_000;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    event TokenCreated(address creator, address token);

    constructor()
        tokenTemplate(
            "DoubleEspresso",
            "DESP",
            msg.sender, //owner
            true,
            20,
            0x76B2c08407133B36F3Fd38fD362DfBd5ed836384, // marketing
            20,
            0x37F60ceA0892B7f1a39811Df4415034f723a54d7, // dev
            10,
            0xcEB53721d782367d9CD11F3aA443418d615C7a26  // lp
        )
    {
        factory_enabled = true;
    }

    function update_burn_creation_fee(uint256 fee) external onlyOwner {
        burnCreationFee = fee;
    }

    // Could also just use regular approve
    function easy_approve_creation_fee() external {
        _allowances[msg.sender][address(this)] = burnCreationFee;
        emit Approval(msg.sender, address(this), burnCreationFee);
    }

    function createToken(
        string memory _name,
        string memory _ticker,
        address owner,
        bool enableFees,
        uint256 marketingTax,
        address marketing,
        uint256 devTax,
        address dev,
        uint256 lpTax,
        address lp
    ) external {
        require(factory_enabled, "Factory is disabled");

        // Check if the sender has enough tokens to burn 
        require(_balances[msg.sender] >= burnCreationFee, "Not enough tokens");

        // Burn tokens to create a token using safeTransfer
        TransferHelper.safeTransferFrom(
            address(this), 
            msg.sender, // Get the tokens from the msg sender
            DEAD,
            burnCreationFee
        );

        tokenTemplate token_clone = new tokenTemplate(
            _name,
            _ticker,
            owner, // Use the "owner" as token owner (usually just the same as msg.sender)
            enableFees,
            marketingTax,
            marketing,
            devTax,
            dev,
            lpTax,
            lp
        );

        address token_address = address(token_clone);

        // Store the creator to verify adjustments later on
        token_owners[token_address] = owner;
        tokens_owned[owner].push(token_address);

        tokens_created++;
        emit TokenCreated(owner, token_address);
    }
}