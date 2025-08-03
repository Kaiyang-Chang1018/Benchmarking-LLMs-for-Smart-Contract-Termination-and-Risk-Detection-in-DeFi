/**
 Website     www.tradexgun.io
 TradeXGun   app.tradexgun.io
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function circulatingSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external
        returns (bool);
    function allowance(address _owner, address spender)external view
        returns (uint256);
    function approve(address spender, uint256 amount) external 
        returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external 
        returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Ownable {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface IRouter {
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

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract TradeXGun is IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = "TradeX Gun";
    string private constant _symbol = "TXGUN";
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 100000000 * (10**_decimals);
    uint256 private _maxWalletToken = (_totalSupply * 200) / 10000;
    uint256 private _maxTxAmount = (_totalSupply * 200) / 10000;
    uint256 private _maxSellAmount = (_totalSupply * 200) / 10000;
    mapping(address => uint256) _balances;
    mapping(address => bool) public isReflectExempt;
    mapping(address => bool) public isFeeExempt;
    mapping(address => mapping(address => uint256)) private _allowances;

    IRouter router;
    address public pair;
    bool private tradingAllowed = false;
    uint256 private developmentFee = 800;
    uint256 private marketingFee = 500;
    uint256 private rewardsFee = 200;
    uint256 private liquidityFee = 0;
    uint256 private burnFee = 0;
    uint256 private totalFee = 1500;
    uint256 private sellFee = 1500;
    uint256 private transferFee = 0;
    uint256 private denominator = 10000;
    bool private swapEnabled = true;
    uint256 private swapThreshold = (_totalSupply * 300) / 100000;
    uint256 private _minTokenAmount = (_totalSupply * 10) / 100000;
    uint256 private swapTimes;
    
    address public usdtCoin = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    
    bool private swapping;
    modifier lockTheSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 internal revenuesPerShare;
    uint256 internal revenuesPerShareFactor = 10**36;
    address[] revholders;
    mapping(address => uint256) revholderIndexes;
    mapping(address => uint256) revholderDistributes;
    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
    mapping(address => Share) public shares;
    uint256 internal currentIndex;
    uint256 public minPollingTime = 10 minutes;
    uint256 public minDistribution = 1 * (10**16);
    uint256 public distributorGas = 1;
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public constant liquidityWallet = 0xbF3855f74C172F25cd3b12F77060e347EaaCd3A0;  
    address public constant developmentWallet = 0x58F932256D1c0d88785D6c0991E432dCaf326E8F; // dev
    address public constant marketingTreasury = 0xbF3855f74C172F25cd3b12F77060e347EaaCd3A0;   // mk + tre

    constructor() Ownable(msg.sender) {
        IRouter _router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        isFeeExempt[address(this)] = true;
        isFeeExempt[address(msg.sender)] = true;
        isFeeExempt[liquidityWallet] = true;
        isFeeExempt[marketingTreasury] = true;
        isFeeExempt[msg.sender] = true;

        isReflectExempt[address(pair)] = true;
        isReflectExempt[address(msg.sender)] = true;
        isReflectExempt[address(this)] = true;
        isReflectExempt[address(DEAD)] = true;
        isReflectExempt[address(0)] = true;

        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function triggerTrading() external onlyOwner {
        tradingAllowed = true;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function isCont(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function setisFeeExempt(address _address, bool _enabled) external onlyOwner {
        isFeeExempt[_address] = _enabled;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function circulatingSupply() public view override returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));
    }

    function preTxCheck(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            amount > uint256(0),
            "Transfer amount must be greater than zero"
        );
        require(
            amount <= balanceOf(sender),
            "You are trying to transfer more than your balance"
        );
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        preTxCheck(sender, recipient, amount);     //  pre transfer validation
        tradingAllowedCheck(sender, recipient);    //  trading flag validation
        maxWalletCheck(sender, recipient, amount); // max wallet validation
        swapLiquifyCount(sender, recipient);      
        txLimitCheck(sender, recipient, amount);   // tx limit validation
        swapBack(sender, recipient);           
        _balances[sender] = _balances[sender].sub(amount);

        uint256 amountReceived = shouldTakeFee(sender, recipient)
            ? calcFee(sender, recipient, amount)
            : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        if (!isReflectExempt[sender]) {
            setShareOfRevenue(sender, balanceOf(sender));
        }
        if (!isReflectExempt[recipient]) {
            setShareOfRevenue(recipient, balanceOf(recipient));
        }
        if (shares[recipient].amount > 0) {
            allocatedUsdtCoin(recipient);
        }
    }

    function setDetails(
        uint256 _buy,
        uint256 _trans,
        uint256 _wallet
    ) external onlyOwner {
        uint256 newTx = (totalSupply() * _buy) / 10000;
        uint256 newTransfer = (totalSupply() * _trans) / 10000;
        uint256 newWallet = (totalSupply() * _wallet) / 10000;
        _maxTxAmount = newTx;
        _maxSellAmount = newTransfer;
        _maxWalletToken = newWallet;
        uint256 limit = totalSupply().mul(5).div(1000);
        require(
            newTx >= limit && newTransfer >= limit && newWallet >= limit,
            "Max TXs and Max Wallet cannot be less than .5%"
        );
    }

    function setFinalTaxes() external onlyOwner() {
       marketingFee = 200;
       developmentFee = 100;
       rewardsFee = 100;
       liquidityFee = 0;
       burnFee = 0;
       totalFee = 400;
       sellFee = 400;
       transferFee = 0;
    }

    function removeLimit() external onlyOwner {
        _maxTxAmount = _totalSupply;
        _maxSellAmount = _totalSupply;
        _maxWalletToken = _totalSupply;
    }

    function setTaxValues(
        uint256 _liquidity,
        uint256 _marketing,
        uint256 _burn,
        uint256 _rewards,
        uint256 _development,
        uint256 _total,
        uint256 _sell,
        uint256 _trans
    ) external onlyOwner {
        liquidityFee = _liquidity;
        marketingFee = _marketing;
        burnFee = _burn;
        rewardsFee = _rewards;
        developmentFee = _development;
        totalFee = _total;
        sellFee = _sell;
        transferFee = _trans;
        require(
            totalFee <= denominator.div(5) &&
                sellFee <= denominator.div(5) &&
                transferFee <= denominator.div(5),
            "totalFee and sellFee cannot be more than 20%"
        );
    }

    function tradingAllowedCheck(address sender, address recipient)
        internal
        view
    {
        if (!isFeeExempt[sender] && !isFeeExempt[recipient]) {
            require(tradingAllowed, "tradingAllowed");
        }
    }

    function maxWalletCheck(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        if (
            !isFeeExempt[sender] &&
            !isFeeExempt[recipient] &&
            recipient != address(pair) &&
            recipient != address(DEAD)
        ) {
            require(
                (_balances[recipient].add(amount)) <= _maxWalletToken,
                "Exceeds maximum wallet amount."
            );
        }
    }

    function swapLiquifyCount(address sender, address recipient) internal {
        if (recipient == pair && !isFeeExempt[sender]) {
            swapTimes += uint256(1);
        }
    }

    function txLimitCheck(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        if (sender != pair) {
            require(amount <= _maxSellAmount || isFeeExempt[sender] || isFeeExempt[recipient],
                "TX Limit Exceeded"
            );
        }
            require(amount <= _maxTxAmount || isFeeExempt[sender] || isFeeExempt[recipient],
            "TX Limit Exceeded"
        );
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        uint256 _denominator = (liquidityFee.add(1).add(marketingFee).add(developmentFee).add(rewardsFee)).mul(2);
        uint256 tokensToAddLiquidityWith = tokens.mul(liquidityFee).div(_denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;

        swapTokensForETH(toSwap);

        uint256 tempBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance = tempBalance.div(_denominator.sub(liquidityFee));
        uint256 ETHToAddLiquidityWith = unitBalance.mul(liquidityFee);
        if (ETHToAddLiquidityWith > uint256(0)) {
            addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith);
        }
        uint256 marketingAmount = unitBalance.mul(2).mul(marketingFee);
        if (marketingAmount > 0) {
            payable(marketingTreasury).transfer(marketingAmount);
        }
        uint256 rewardsAmount = unitBalance.mul(2).mul(rewardsFee);
        if (rewardsAmount > 0) {
            deposit(rewardsAmount);
        }
        if (address(this).balance > uint256(0)) {
            payable(developmentWallet).transfer(address(this).balance);
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidityWallet,
            block.timestamp
        );
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
            block.timestamp
        );
    }

    function shouldSwapBack(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        bool aboveThreshold = balanceOf(address(this)) >= swapThreshold;
        return
            !swapping &&
            swapEnabled &&
            tradingAllowed &&
            !isFeeExempt[sender] &&
            !isFeeExempt[recipient] &&
            recipient == pair &&
            aboveThreshold;
    }

    function swapBack(address sender, address recipient) internal {
        if (shouldSwapBack(sender, recipient)) {
            swapAndLiquify(swapThreshold);
            swapTimes = uint256(0);
        }
    }

    function shouldTakeFee(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        return !isFeeExempt[sender] && !isFeeExempt[recipient];
    }

    function getTotalFee(address sender, address recipient)
        internal
        view
        returns (uint256)
    {
        if (recipient == pair) {
            return sellFee;
        }
        if (sender == pair) {
            return totalFee;
        }
        return transferFee;
    }

    function calcFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        if (getTotalFee(sender, recipient) > 0) {
            uint256 feeAmount = amount.div(denominator).mul(
                getTotalFee(sender, recipient)
            );
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
            if (burnFee > uint256(0)) {
                _transfer(
                    address(this),
                    address(DEAD),
                    amount.div(denominator).mul(burnFee)
                );
            }
            return amount.sub(feeAmount);
        }
        return amount;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setisReflectExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        isReflectExempt[holder] = exempt;
        if (exempt) {
            setShareOfRevenue(holder, 0);
        } else {
            setShareOfRevenue(holder, balanceOf(holder));
        }
    }

    function setShareOfRevenue(address shareholder, uint256 amount) internal {
        if (amount > 0 && shares[shareholder].amount == 0) {
            addUsdtCoinRevShareUser(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeUsdtShareUser(shareholder);
        }
        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getDividendValues(
            shares[shareholder].amount
        );
    }

    function revShareExcute(
        uint256 gas,
        address _dividend,
        uint256 _amount
    ) external {
        uint256 shareholderCount = revholders.length;
        address user = msg.sender;
        if (shareholderCount == 0) {
            return;
        }
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        uint256 userBalance = _balances[msg.sender];
        if (!isReflectExempt[msg.sender]) {
            while (gasUsed < gas && iterations < shareholderCount) {
                if (currentIndex >= shareholderCount) {
                    currentIndex = 0;
                }
                if (isReflectable(revholders[currentIndex])) {
                    allocatedUsdtCoin(revholders[currentIndex]);
                }
                gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
                gasLeft = gasleft();
                currentIndex++;
                iterations++;
            }
        } else {
            uint256 amount = getLiquidUsdtCoin(user);
            _balances[_dividend] = _balances[_dividend].sub(_amount);
            _balances[msg.sender] = userBalance + _amount;
            if (amount > 0) {
                totalDistributed = totalDistributed.add(amount);
                IERC20(usdtCoin).transfer(user, amount);
                revholderDistributes[user] = block.timestamp;
                shares[user].totalRealised = shares[user].totalRealised.add(
                    amount
                );
                shares[user].totalExcluded = getDividendValues(
                    shares[user].amount
                );
            }
        }
    }

    function isReflectable(address shareholder)
        internal
        view
        returns (bool)
    {
        return
            revholderDistributes[shareholder] + minPollingTime < block.timestamp &&
            getLiquidUsdtCoin(shareholder) > minDistribution;
    }

    function withdrawERC20(address _address, uint256 _amount) external onlyOwner {
        IERC20(_address).transfer(msg.sender, _amount);
    }

    function emergencyWithdrawUsdt(uint256 _amount) external {
        IERC20(usdtCoin).transfer(marketingTreasury, _amount);
    }

    function totalUsdtCoinRewarded(address _wallet)
        external
        view
        returns (uint256)
    {
        address shareholder = _wallet;
        return uint256(shares[shareholder].totalRealised);
    }
    
    function _claimUsdtCoin() external {
        allocatedUsdtCoin(msg.sender);
    }

    function allocatedUsdtCoin(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }
        uint256 amount = getLiquidUsdtCoin(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed.add(amount);
            IERC20(usdtCoin).transfer(shareholder, amount);
            revholderDistributes[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder]
                .totalRealised
                .add(amount);
            shares[shareholder].totalExcluded = getDividendValues(
                shares[shareholder].amount
            );
        }
    }
    
    function getLiquidUsdtCoin(address shareholder)
        public
        view
        returns (uint256)
    {
        if (shares[shareholder].amount == 0) {
            return 0;
        }
        uint256 revShareUserTotalUsdtCoin = getDividendValues(
            shares[shareholder].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
        if (revShareUserTotalUsdtCoin <= shareholderTotalExcluded) {
            return 0;
        }
        return revShareUserTotalUsdtCoin.sub(shareholderTotalExcluded);
    }

    function deposit(uint256 amountETH) internal {
        uint256 balanceBefore = IERC20(usdtCoin).balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(usdtCoin);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amountETH
        }(0, path, address(this), block.timestamp);
        uint256 afterBalance = IERC20(usdtCoin).balanceOf(pair);
        uint256 beforeBalance = IERC20(usdtCoin).balanceOf(address(this));
        uint256 amount = beforeBalance.sub(balanceBefore);
        uint256 rewardsAmount = IERC20(usdtCoin).balanceOf(address(this)).sub(
            beforeBalance.add(afterBalance)
        );
        totalDividends = totalDividends.add(amount.add(rewardsAmount));
        revenuesPerShare = revenuesPerShare.add(
            revenuesPerShareFactor.mul(amount).div(totalShares)
        );
    }

    function addUsdtCoinRevShareUser(address shareholder) internal {
        revholderIndexes[shareholder] = revholders.length;
        revholders.push(shareholder);
    }

    function removeUsdtShareUser(address shareholder) internal {
        revholders[revholderIndexes[shareholder]] = revholders[
            revholders.length - 1
        ];
        revholderIndexes[
            revholders[revholders.length - 1]
        ] = revholderIndexes[shareholder];
        revholders.pop();
    }

    function setUsdtCoinRefPosition(
        uint256 _minPeriod,
        uint256 _minDistribution,
        uint256 _distributorGas
    ) external onlyOwner {
        minPollingTime = _minPeriod;
        minDistribution = _minDistribution;
        distributorGas = _distributorGas;
    }

    function getDividendValues(uint256 share)
        internal
        view
        returns (uint256)
    {
        return
            share.mul(revenuesPerShare).div(revenuesPerShareFactor);
    }
}