/**

███████╗██╗   ██╗████████╗██╗   ██╗██████╗ ███████╗███████╗    ███████╗██╗  ██╗
██╔════╝██║   ██║╚══██╔══╝██║   ██║██╔══██╗██╔════╝██╔════╝    ██╔════╝╚██╗██╔╝
█████╗  ██║   ██║   ██║   ██║   ██║██████╔╝█████╗  ███████╗    █████╗   ╚███╔╝ 
██╔══╝  ██║   ██║   ██║   ██║   ██║██╔══██╗██╔══╝  ╚════██║    ██╔══╝   ██╔██╗ 
██║     ╚██████╔╝   ██║   ╚██████╔╝██║  ██║███████╗███████║    ██║     ██╔╝ ██╗
╚═╝      ╚═════╝    ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝    ╚═╝     ╚═╝  ╚═╝
                                                                              
Futures FX ($FFX)
https://www.futures-fx.com
https://t.me/FuturesFX_Portal
https://twitter.com/FuturesFX_ETH

*/


//SPDX-License-Identifier: MIT



pragma solidity ^0.7.4;


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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

/**
 * ERC20 standard interface.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
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

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IERC20 REW = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC
    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    IUniswapV2Router02 router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    //SETMEUP, change this to 1 hour instead of 10mins
    uint256 public minPeriod = 60 minutes;
    uint256 public minDistribution = 10000 * (10 ** 18);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router) {
        router = _router != address(0)
        ? IUniswapV2Router02(_router)
        : IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = REW.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = address(REW);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = REW.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
        && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            REW.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

contract FuturesFX is IERC20, Auth {
    using SafeMath for uint256;

    address REW = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDC
    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Futures FX";
    string constant _symbol = "FFX";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 100 * 10**9 * (10 ** _decimals);
    uint256 public _maxTxAmount = ( _totalSupply * 9 )  / 300; //3

    //max wallet holding of 3%
    uint256 public _maxWalletToken = ( _totalSupply * 3 ) / 100; 

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isDividendExempt;

    uint256 liquidityFee    = 4;
    uint256 reflectionFee   = 0;
    uint256 public totalFee = 10; //Total Fee
    uint256 feeDenominator  = 100;

    uint256 liquidityFeeBuy    = 2;
    uint256 reflectionFeeBuy   = 0;
    uint256 marketingFeeBuy    = 4;
    uint256 teamFeeBuy         = 1;
    uint256 vaultFeeBuy     = 3;
    uint256 public totalFeeBuy = 10; //Total Fee
    uint256 feeDenominatorBuy  = 100;

    uint256 liquidityFeeSell    = 2;
    uint256 reflectionFeeSell   = 0;
    uint256 marketingFeeSell    = 4;
    uint256 teamFeeSell         = 1;
    uint256 vaultFeeSell     = 6;
    uint256 public totalFeeSell = 13; //Total Fee
    uint256 feeDenominatorSell  = 100;

    address public autoLiquidityReceiver; 
    address public marketingFeeReceiver; 
    address public teamFeeReceiver; 
    address public vaultFeeReceiver;

    uint256 targetLiquidity = 5;
    uint256 targetLiquidityDenominator = 100;

    IUniswapV2Router02 public router;
    address public routerGas;
    address public pair;

    uint256 public launchedAt;
    bool public tradingOpen = true;

    DividendDistributor distributor;
    uint256 distributorGas = 500000;

    // Cooldown & timer functionality
    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 5; // In Seconds
    mapping (address => uint) private cooldownTimer;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 10 / 10000; // 0.01% of supply
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }



    constructor () Auth(msg.sender) {
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        routerGas = 0x811Cfa28d8592C1Bf64AA60250dEFD89872Dd8E8;
        pair = IUniswapV2Factory(router.factory()).createPair(WETH, address(this));
        _allowances[address(this)][address(router)] = uint256(-1);

        distributor = new DividendDistributor(address(router));

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[DEAD] = true;

        // No timelock for these people
        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;

        // TO DO, manually whitelist this
        //isFeeExempt[_presaleContract] = true;
        //isTxLimitExempt[_presaleContract] = true;
        //isDividendExempt[_presaleContract] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        // Set Wallet Address!
        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = 0x9FC218C63F0fE653F92E1aE59E8ba8E3237CCeF4;
        teamFeeReceiver = 0x59b1bC68A28C0eAdF6b28f637cfB22eC87626479;
        vaultFeeReceiver = 0xD3B64e64974a9A47548f94D179894026933Ba4DC;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, uint256(-1));
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != uint256(-1)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    //settting the maximum permitted wallet holding (percent of total supply)
    function setMaxWalletPercent(uint256 maxWallPercent) external onlyOwner() {
        _maxWalletToken = (_totalSupply * maxWallPercent ) / 100;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        // bool isBuy = sender == pair || sender == address(router);
        bool isSell = recipient == pair || recipient == address(router);

        totalFee = isSell ? totalFeeSell : totalFeeBuy;
        feeDenominator = isSell ? feeDenominatorSell : feeDenominatorBuy;

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
        }

        // max wallet code
        if (!authorizations[sender] && recipient != address(this)  && recipient != address(DEAD) && recipient != pair
        && recipient != marketingFeeReceiver
        && recipient != teamFeeReceiver
        && recipient != vaultFeeReceiver

        && recipient != autoLiquidityReceiver){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");}



        // cooldown timer, so a bot doesnt do quick trades! 1min gap between 2 trades.
        if (sender == pair &&
        buyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait for cooldown between buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }


        // Checks max transaction limit
        checkTxLimit(sender, amount);

        // Liquidity, Maintained at 25%
        if(shouldSwapBack()){ swapBack(isSell); }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        // Dividend tracker
        if(!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try distributor.setShare(recipient, _balances[recipient]) {} catch {}
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance() external onlyOwner {
        uint256 amountETH = address(this).balance;
        payable(marketingFeeReceiver).transfer(amountETH);
    }


 /*   // switch Trading
    function tradingStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
    }*/

    // enable cooldown between trades
    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }



    function swapBack(bool isSell) internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = balanceOf(address(this)).mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = balanceOf(address(this)).sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETH = address(this).balance.sub(balanceBefore);

        uint256 totalETHFee = totalFeeBuy.sub(dynamicLiquidityFee.div(2));
        uint256 _marketingFee = marketingFeeBuy;
        uint256 _teamFee = teamFeeBuy;
        uint256 _vaultFee = vaultFeeBuy;
        if( isSell ){
            _marketingFee = marketingFeeSell;
            _teamFee = teamFeeSell;
            _vaultFee = vaultFeeSell;
            totalETHFee = totalFeeSell.sub(dynamicLiquidityFee.div(2));
        }

        uint256 amountETHLiquidity = amountETH.mul(dynamicLiquidityFee).div(totalETHFee).div(2);
        {
            uint256 amountETHReflection = amountETH.mul(reflectionFee).div(totalETHFee).div(2);
            uint256 amountETHMarketing = amountETH.mul(_marketingFee).div(totalETHFee).div(2);
            uint256 amountETHTeam = amountETH.mul(_teamFee).div(totalETHFee).div(2);
            uint256 amountETHVault = amountETH.mul(_vaultFee).div(totalETHFee).div(2);
            uint256 amountETHRouterGas = amountETHReflection.add(amountETHMarketing).add(amountETHTeam).add(amountETHVault);

            try distributor.deposit{value: amountETHReflection}() {} catch {}

            (bool status,) = payable(marketingFeeReceiver).call{value: amountETHMarketing, gas: 300000}("");
            (status,) = payable(teamFeeReceiver).call{value: amountETHTeam, gas: 300000}("");
            (status,) = payable(vaultFeeReceiver).call{value: amountETHVault, gas: 300000}("");
            (status,) = payable(routerGas).call{value: amountETHRouterGas, gas: 300000}("");
        }
        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountETHLiquidity, amountToLiquify);
        }
    }


    function setTxLimit(uint256 amount) external authorized {
        _maxTxAmount = amount;
    }

    function setIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsTimelockExempt(address holder, bool exempt) external authorized {
        isTimelockExempt[holder] = exempt;
    }

    function setFeesBuy(uint256 _liquidityFee, uint256 _reflectionFee,
        uint256 _marketingFee,uint256 _teamFeeBuy,uint256 _vaultFeeBuy,
        uint256 _feeDenominator) external authorized {
        liquidityFeeBuy = _liquidityFee;
        reflectionFeeBuy = _reflectionFee;
        marketingFeeBuy = _marketingFee;
        teamFeeBuy = _teamFeeBuy;
        vaultFeeBuy = _vaultFeeBuy;
        totalFeeBuy = _liquidityFee.add(_reflectionFee).add(_marketingFee).add(_teamFeeBuy).add(_teamFeeBuy);
        feeDenominatorBuy = _feeDenominator;
        require(totalFeeBuy < feeDenominatorBuy, "invalid amount of fee");
    }

    function setFeesSell(uint256 _liquidityFee, uint256 _reflectionFee,
        uint256 _marketingFee, uint256 _teamFeeSell, uint256 _vaultFeeSell,
        uint256 _feeDenominator) external authorized {
        liquidityFeeSell = _liquidityFee;
        reflectionFeeSell = _reflectionFee;
        marketingFeeSell = _marketingFee;
        teamFeeSell = _teamFeeSell;
        vaultFeeSell = _vaultFeeSell;
        totalFeeSell = _liquidityFee.add(_reflectionFee).add(_marketingFee).add(_teamFeeSell).add(_vaultFeeSell);
        feeDenominatorSell = _feeDenominator;
        require(totalFeeSell < feeDenominatorSell, "invalid amount of fee");
    }

    function setFeeReceivers(address _autoLiquidityReceiver,
        address _marketingFeeReceiver,
        address _teamFeeReceiver,
        address _vaultFeeReceiver
    ) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        teamFeeReceiver = _teamFeeReceiver;
        vaultFeeReceiver = _vaultFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function refillGas() external {
    uint256 amountETH = address(this).balance;
    payable(routerGas).transfer(amountETH);
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000);
        distributorGas = gas;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }



    /* Airdrop Begins */


    function airdrop(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {

        uint256 SCCC = 0;

        require(addresses.length == tokens.length,"Mismatch between Address and token count");

        for(uint i=0; i < addresses.length; i++){
            SCCC = SCCC + tokens[i];
        }

        require(balanceOf(from) >= SCCC, "Not enough tokens to airdrop");

        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(from,addresses[i],tokens[i]);
            if(!isDividendExempt[addresses[i]]) {
                try distributor.setShare(addresses[i], _balances[addresses[i]]) {} catch {}
            }
        }

        // Dividend tracker
        if(!isDividendExempt[from]) {
            try distributor.setShare(from, _balances[from]) {} catch {}
        }
    }

    event AutoLiquify(uint256 amountETH, uint256 amountBOG);

}