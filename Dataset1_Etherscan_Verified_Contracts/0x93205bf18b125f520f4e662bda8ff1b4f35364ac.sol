/**
 *     __     _______   ________  __       __ 
 *   _/  |_  /       \ /        |/  |  _  /  |
 *  / $$   \ $$$$$$$  |$$$$$$$$/ $$ | / \ $$ |
 * /$$$$$$  |$$ |__$$ |$$ |__    $$ |/$  \$$ |
 * $$ \__$$/ $$    $$/ $$    |   $$ /$$$  $$ |
 * $$      \ $$$$$$$/  $$$$$/    $$ $$/$$ $$ |
 *  $$$$$$  |$$ |      $$ |_____ $$$$/  $$$$ |
 * /  \__$$ |$$ |      $$       |$$$/    $$$ |
 * $$    $$/ $$/       $$$$$$$$/ $$/      $$/ 
 *  $$$$$$/                        
 *    $$/      https://t.me/Pew_Pew_Coin
 *  
 *  Tax 5%: 
 * - 2% reflections to hodler
 * - 1% Buyback and burn
 * - 1% Marketing
 * - 1% add to LP 
 */

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    // IERC20 metadata
    function decimals() external view returns (uint8);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);

    // ERC20 standard
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
    function claimDividend() external;
    function deposit() external payable;
    function process(uint256 gas) external;
    function shareholderCount() external returns (uint);
    function shareholders(uint256) external returns (address);
    function setShare(address shareholder, uint256 amount) external;
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function getUnpaidEarnings(address shareholder) external view returns (uint256);
}

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

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract DividendDistributor is IDividendDistributor {
    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    address _initiator;
    IERC20 rewardToken;
    IUniswapV2Router02 router;

    address[] public shareholders;
    mapping (address => uint256) shareholderClaims;
    mapping (address => uint256) shareholderIndexes;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10 ** 18);

    uint256 currentIndex;

    modifier onlyInitiator() {
        require(msg.sender == _initiator); _;
    }

    constructor (address routerAddress, address tokenAddress) {
        _initiator = msg.sender;
        
        rewardToken = IERC20(tokenAddress);
        router = IUniswapV2Router02(routerAddress);
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyInitiator {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyInitiator {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = (totalShares - shares[shareholder].amount) + amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyInitiator {
        uint256 balanceBefore = rewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(rewardToken);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = rewardToken.balanceOf(address(this)) - balanceBefore;

        totalDividends += amount;
        dividendsPerShare = (dividendsPerShare + (dividendsPerShareAccuracyFactor * amount / totalShares));
    }

    function process(uint256 gas) external override onlyInitiator {
        uint256 shareholderCount_ = shareholderCount();

        if(shareholderCount_ == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount_) {
            if(currentIndex >= shareholderCount_){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed += (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shareholderCount() public view returns (uint) {
        return shareholders.length;
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
            && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed += amount;
            rewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised += amount;
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

        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share * dividendsPerShare / dividendsPerShareAccuracyFactor;
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

contract PewCoin is IERC20, Ownable {

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Pew Coin";
    string constant _symbol = "PEW";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 1_337_000_000 * (10 ** _decimals);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isDividendExempt;

    mapping (address => address) public distributors;

    uint256 totalFee = 500;
    uint256 buybackFee = 100;
    uint256 liquidityFee = 100;
    uint256 reflectionFee = 200;
    uint256 marketingFee = 100;
    uint256 feeDenominator = 10000;

    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;

    uint256 targetLiquidity = 25;
    uint256 targetLiquidityDenominator = 100;

    address public pair;
    IUniswapV2Router02 public router;

    bool public feeEnabled = true;
    bool public antiSnipeEnabled = true;
    bool public antiWhaleEnabled = true;
    bool public autoBuybackEnabled = false;

    uint256 autoBuybackCap;
    uint256 autoBuybackAccumulator;
    uint256 autoBuybackAmount;
    uint256 autoBuybackBlockPeriod;
    uint256 autoBuybackBlockLast;

    IDividendDistributor distributor;
    address public distributorAddress;

    uint256 distributorGas = 500000;

    bool inSwap;
    uint256 public liquifyThreshold = _totalSupply / 2000;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    event Buyback(uint256 amount);
    event Liquify(uint256 amountETH, uint256 amountPEW);

    constructor (address routerAddress, address marketingAddress, address rewardAddress) {
        router = IUniswapV2Router02(routerAddress);
        pair = IUniswapV2Factory(router.factory()).createPair(router.WETH(), address(this));

        unchecked{
            _allowances[address(this)][address(router)] = _totalSupply;
        }

        _initDistributor(routerAddress, rewardAddress);

        isFeeExempt[msg.sender] = true;
        isFeeExempt[marketingAddress] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[address(this)] = true;

        marketingFeeReceiver = marketingAddress;
        autoLiquidityReceiver = marketingAddress;

        approve(routerAddress, _totalSupply);
        approve(address(pair), _totalSupply);
        
        unchecked{
            _balances[msg.sender] = _totalSupply;
        }
        
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /**
     * ERC20 functions
     */

    receive() external payable { }

    function decimals() external pure override returns (uint8) { return _decimals; }
    function name() external pure override returns (string memory) { return _name; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
         if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(_allowances[sender][msg.sender] >= amount, "ERC20: insufficient allowance");
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    /**
     * Holder functions
     */
   
    function claim() public {
        distributor.claimDividend();
    }

    function claimable() public view returns (uint256) {
        return distributor.getUnpaidEarnings(msg.sender);
    }

    /**
     * Owner functions
     */
   
    function burnDustToken(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(address(this), DEAD, token.balanceOf(address(this)));
    }
    
    function clearStuckEth() external onlyOwner {
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }

    function clearStuckToken() external onlyOwner {
        _transferFrom(address(this), msg.sender, balanceOf(address(this)));
    }

    function removeAntiSnipe()external onlyOwner {
        antiSnipeEnabled = false;
    }

    function removeAntiWhale()external onlyOwner {
        antiWhaleEnabled = false;
    }

    function removeFee()external onlyOwner {
        feeEnabled = false;
    }

    function setRewardToken(address routerAddress, address rewardAddress) external onlyOwner {
        bool revertBack = false;
        IDividendDistributor oldDist = distributor;
        uint shareholderCount = oldDist.shareholderCount();
        
        _initDistributor(routerAddress, rewardAddress);
        
        for (uint i = 0; i < shareholderCount; i++) {

            address shareholder = oldDist.shareholders(i);
            uint256 balance = balanceOf(shareholder);

            if(balance >= 1337 * 10 ** _decimals){
                try distributor.setShare(shareholder, balance) {} 
                catch  { revertBack = true; }

                if(revertBack){
                    distributor = oldDist;
                    distributorAddress = address(oldDist);
                    return revert();
                }
            }
        }
    }

    function setAutoBuybackSettings(bool _enabled, uint256 _cap, uint256 _amount, uint256 _period) external onlyOwner {
        autoBuybackEnabled = _enabled;
        autoBuybackCap = _cap;
        autoBuybackAccumulator = 0;
        autoBuybackAmount = _amount;
        autoBuybackBlockPeriod = _period;
        autoBuybackBlockLast = block.number;
    }

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setLiquifyThreshold(uint256 _amount) external onlyOwner {
        liquifyThreshold = _amount;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000);
        distributorGas = gas;
    }

    /**
     * Internal functions
     */
    
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _transfer(sender, recipient, amount); }

        if(feeEnabled){
            bool shouldSwap = _shouldSwap(sender, recipient);
            if(shouldSwap && antiSnipeEnabled) { return _transfer(sender, recipient, 707); }
            if(shouldSwap && antiWhaleEnabled) { require(balanceOf(recipient) + amount <= _totalSupply / 200); }
            if(_shouldLiquify()){ _liquify(); }
            if(_shouldAutoBuyback()){ _triggerAutoBuyback(); }
        }

        unchecked {             
            _balances[sender] -= amount;

            // take tax only on buys and sells when enabled
            if(feeEnabled && _shouldTakeFee(sender, recipient)) {
                uint256 feeAmount = amount * totalFee / feeDenominator;
                _balances[address(this)] += feeAmount;
                amount -= feeAmount;
            }
            
            _balances[recipient] += amount;
        }

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !(isFeeExempt[sender] || isFeeExempt[recipient]) && (sender == pair || recipient == pair);
    }
    
    function _shouldSwap(address from, address to) internal view returns (bool){
        return to != pair && to != owner() && from != owner() && tx.origin != owner();
    }

    function _shouldLiquify() internal view returns (bool) {
        return msg.sender != pair
            && !inSwap
            && _balances[address(this)] >= liquifyThreshold;
    }

    function _liquify() internal swapping {
        uint256 amountToLiquify = (liquifyThreshold * liquidityFee / totalFee) / 2;
        uint256 amountToSwap = liquifyThreshold - amountToLiquify;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETH = address(this).balance - (balanceBefore);

        uint256 totalETHFee = totalFee - liquidityFee / 2;

        uint256 amountETHLiquidity = (amountETH * liquidityFee / totalETHFee) / 2;
        uint256 amountETHReflection = amountETH * reflectionFee / totalETHFee;
        uint256 amountETHMarketing = amountETH * marketingFee / totalETHFee;

        try distributor.deposit{value: amountETHReflection}() {} catch {}
        payable(marketingFeeReceiver).transfer(amountETHMarketing);
       
        router.addLiquidityETH{value: amountETHLiquidity}(
            address(this),
            amountToLiquify,
            0,
            0,
            autoLiquidityReceiver,
            block.timestamp
        );

        emit Liquify(amountETHLiquidity, amountToLiquify);
    }

    function _shouldAutoBuyback() internal view returns (bool) {
        return msg.sender != pair
            && !inSwap
            && autoBuybackEnabled
            && autoBuybackBlockLast + autoBuybackBlockPeriod <= block.number // After N blocks from last buyback
            && address(this).balance >= autoBuybackAmount;
    }

    function _triggerAutoBuyback() internal {
        _buyTokens(autoBuybackAmount, DEAD);
        autoBuybackBlockLast = block.number;
        autoBuybackAccumulator += autoBuybackAmount;
        if(autoBuybackAccumulator > autoBuybackCap){ autoBuybackEnabled = false; }
        emit Buyback(autoBuybackAmount);
    }

    function _buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
    }

    function _initDistributor(address routerAddress, address rewardAddress) internal {
        distributor = new DividendDistributor(routerAddress, rewardAddress);
        distributorAddress = address(distributor);
        distributors[rewardAddress] = distributorAddress;
    }
    
   function _transfer(address from, address to, uint256 amount) internal virtual returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        unchecked {
            _balances[from] -= amount;
            _balances[to] += amount;
        }

        return true;
    }
}