/*
 * Https://t.me/ethyleneerc
 *
 * 
 * SPDX-License-Identifier: None
 */

pragma solidity 0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IDEXPair {function sync() external;}

interface IDEXRouter {
    function factory() external pure returns (address);    
    function WETH() external pure returns (address);
    function addLiquidityETH(address token,uint amountTokenDesired,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable;
}

contract AutoDoubleRewards is IERC20 {
    string private _name;
    string private _symbol;
    uint8 constant _decimals = 18;
    uint256 _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public limitless;
    mapping(address => bool) public ai;
    mapping(address => bool) public isExludedFromMaxWallet;
    mapping(address => address) public chosenReward;

    bool public renounced = false;

    uint256 public tax;
    uint256 public rewards = 1;
    uint256 public liq = 10;
    uint256 public marketing = 4;
    uint256 private swapAt = _totalSupply / 10_000;
    uint256 public maxWalletInPermille = 25;
    uint256 private maxTx = 100;
    uint256 public maxRewardsPerTx = 5;

    uint256 public sellMultiplier = 200;
    uint256 public sellDivisor = 100;

    address public ceo;
    address public router;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public immutable WETH;
    address public mainReward;
    address public marketingWallet;

    address public immutable pair;
    address[] public pairs;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised; 
    }

    mapping (address => uint256) public shareholderIndexes;
    mapping (address => uint256) public lastClaim;
    mapping (address => Share) public shares;
    mapping (address => bool) public addressNotGettingRewards;

    uint256 public totalShares;
    uint256 public totalDistributed;
    uint256 public rewardsPerShare;
    uint256 private veryLargeNumber = 10 ** 36;
    uint256 private rewardTokenBalanceBefore;
    uint256 private currentHolder;

    address[] private shareholders;

    modifier onlyCEO(){
        require (msg.sender == ceo, "Only the ceo can do that");
        _;
    }

    constructor(string memory name_, string memory symbol_, uint256 totalSupply_, address marketing_, address rewardsAddress, address router_, address weth_, uint256 maxWalletInPermille_) payable {
        require(msg.value >= 0.005 ether, "Need 0.005 ETH to test the new reward");
        ceo = msg.sender;
        _name = name_;
        _symbol = symbol_;
        _totalSupply = totalSupply_ * (10**_decimals);
        marketingWallet = marketing_;
        router = router_;
        maxWalletInPermille = maxWalletInPermille_;
        WETH = weth_;

        pair = IDEXFactory(IDEXRouter(router).factory()).createPair(WETH, address(this));
        _allowances[address(this)][router] = type(uint256).max;
        _allowances[ceo][router] = type(uint256).max;
        isExludedFromMaxWallet[pair] = true;
        isExludedFromMaxWallet[address(this)] = true;
        pairs.push(pair);

        addressNotGettingRewards[pair] = true;
        addressNotGettingRewards[address(this)] = true;

        limitless[ceo] = true;
        limitless[address(this)] = true;
        tax = rewards + liq + marketing;

        _balances[ceo] = _totalSupply;
        emit Transfer(address(0), ceo, _totalSupply);        

        mainReward = rewardsAddress;
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = mainReward;

        IDEXRouter(router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            ceo,
            block.timestamp
        );
    }

    receive() external payable {}
    function name() public view override returns (string memory) {return _name;}
    function totalSupply() public view override returns (uint256) {return _totalSupply - _balances[DEAD];}
    function decimals() public pure override returns (uint8) {return _decimals;}
    function symbol() public view override returns (string memory) {return _symbol;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function rescueEth(uint256 amount) external onlyCEO {(bool success,) = address(ceo).call{value: amount}("");success = true;}
    function rescueToken(address token, uint256 amount) external onlyCEO {IERC20(token).transfer(ceo, amount);}
    function allowance(address holder, address spender) public view override returns (uint256) {return _allowances[holder][spender];}
    function transfer(address recipient, uint256 amount) external override returns (bool) {return _transferFrom(msg.sender, recipient, amount);}
    function approveMax(address spender) external returns (bool) {return approve(spender, type(uint256).max);}
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        require(spender != address(0), "Can't use zero address here");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0), "Can't use zero address here");
        _allowances[msg.sender][spender]  = allowance(msg.sender, spender) + addedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0), "Can't use zero address here");
        require(allowance(msg.sender, spender) >= subtractedValue, "Can't subtract more than current allowance");
        _allowances[msg.sender][spender]  = allowance(msg.sender, spender) - subtractedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(_allowances[sender][msg.sender] >= amount, "Insufficient Allowance");
            _allowances[sender][msg.sender] -= amount;
            emit Approval(sender, msg.sender, _allowances[sender][msg.sender]);
        }
        return _transferFrom(sender, recipient, amount);
    }

    function setTaxes(uint256 rewardsTax, uint256 liqTax, uint256 marketingTax, uint256 newSellMultiplier, uint256 newSellDivisor) external onlyCEO {
        if(renounced) require(rewardsTax + liqTax + marketingTax <= tax , "Once renounced, taxes can only be lowered");
        rewards = rewardsTax;
        liq = liqTax;
        marketing = marketingTax;
        tax = rewards + liq + marketing;
        sellMultiplier = newSellMultiplier;
        sellDivisor = newSellDivisor;
        require(tax * sellMultiplier / sellDivisor < 100, "Tax safety limit");     
    }
    
    function setMaxWalletInPermille(uint256 permille) external onlyCEO {
        if(renounced) {
            maxWalletInPermille = 1000;
            return;
        }
        maxWalletInPermille = permille;
        require(maxWalletInPermille >= 10, "MaxWallet safety limit");
    }

    function setMaxTxInPercentOfMaxWallet(uint256 percent) external onlyCEO {
        if(renounced) {maxTx = 100; return;}
        maxTx = percent;
        require(maxTx >= 75, "MaxTx safety limit");
    }
    
    function setNameAndSymbol(string memory newName, string memory newSymbol) external onlyCEO {
        _name = newName;
        _symbol = newSymbol;
    }

    function setMaxRewardsPerTx(uint256 howMany) external onlyCEO {
        maxRewardsPerTx = howMany;
    }    
    
    function setLimitlessWallet(address limitlessWallet, bool status) external onlyCEO {
        if(renounced) return;
        isExludedFromMaxWallet[limitlessWallet] = status;
        addressNotGettingRewards[limitlessWallet] = status;
        limitless[limitlessWallet] = status;
    }

    function excludeFromRewards(address excludedWallet, bool status) external onlyCEO {
        addressNotGettingRewards[excludedWallet] = status;
    }
    
    function changeMarketingWallet(address newMarketingWallet) external onlyCEO {
        marketingWallet = newMarketingWallet;
    }    
    
    function changeMainRewards(address newRewards) external payable onlyCEO {
        require(msg.value >= 0.005 ether, "Need 0.005 ETH to test the new reward");
        mainReward = newRewards;
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = mainReward;

        IDEXRouter(router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            ceo,
            block.timestamp
        );
    }

    function excludeFromMax(address excludedWallet, bool status) external onlyCEO {
        isExludedFromMaxWallet[excludedWallet] = status;
    }    

    function setAi(address aiWallet, bool status) external onlyCEO {
        ai[aiWallet] = status;
    }    

    function renounceOnwrship() external onlyCEO {
        if(renounced) return;
        renounced = true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (limitless[sender] || limitless[recipient])  _lowGasTransfer(sender, recipient, amount);
        else {
            amount = takeTax(sender, recipient, amount);
            _lowGasTransfer(sender, recipient, amount);
            if(maxRewardsPerTx > 0) payRewards(maxRewardsPerTx);
        }
        if(!addressNotGettingRewards[sender]) setShare(sender);
        if(!addressNotGettingRewards[recipient]) setShare(recipient);
        return true;
    }

    function takeTax(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if(maxWalletInPermille <= 1000) {    
            if(!isExludedFromMaxWallet[recipient]) require(_balances[recipient] + amount <= _totalSupply * maxWalletInPermille / 1000, "MaxWallet");
            if(!isExludedFromMaxWallet[sender]) require(amount <= _totalSupply * maxWalletInPermille * maxTx / 1000 / 100, "MaxTx");
        }

        if(ai[sender] || ai[recipient]) {
            require(amount <= _totalSupply / 200, "MaxTxAi");
            uint256 aiTax = amount * 75 / 100;
            if(isPair(recipient)) _lowGasTransfer(sender, recipient, aiTax);
            else if(isPair(sender)) _lowGasTransfer(sender, sender, aiTax);
            else _lowGasTransfer(sender, pair, aiTax);
            return amount * 75 / 100;           
        } else if(!isPair(sender) && !isPair(recipient)) return amount;

        if(tax == 0) return amount;
        uint256 taxToSwap = isPair(recipient) ? amount * (rewards + marketing) * sellMultiplier / sellDivisor / 100 : amount * (rewards + marketing) / 100;
        if(taxToSwap > 0) _lowGasTransfer(sender, address(this), taxToSwap);
        
        if(liq > 0) {
            uint256 liqTax = amount * liq / 100;
            if(isPair(recipient)) _lowGasTransfer(sender, recipient, liqTax * sellMultiplier / sellDivisor);
            else _lowGasTransfer(sender, pair, liqTax);
        }

        if(!isPair(sender)) {
            swapForRewards();
            IDEXPair(pair).sync();
        }
        return isPair(recipient) ? amount - (amount * tax * sellMultiplier / sellDivisor / 100) : amount - (amount * tax / 100);
    }

    function _lowGasTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(sender != address(0), "Can't use zero addresses here");
        require(amount <= _balances[sender], "Can't transfer more than you own");
        if(amount == 0) return true;
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapForRewards() internal {
        if(_balances[address(this)] < swapAt || rewards + marketing == 0) return;
        rewardTokenBalanceBefore = address(this).balance;

        address[] memory pathForSelling = new address[](2);
        pathForSelling[0] = address(this);
        pathForSelling[1] = WETH;

        IDEXRouter(router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            _balances[address(this)],
            0,
            pathForSelling,
            address(this),
            block.timestamp
        );

        uint256 newRewardTokenBalance = address(this).balance;
        if(newRewardTokenBalance <= rewardTokenBalanceBefore) return;
        uint256 amount = newRewardTokenBalance - rewardTokenBalanceBefore;
        if(totalShares > 0){
            if(rewards + marketing > 0){
                uint256 marketingShare = amount * marketing / (rewards + marketing);
                (bool success,) = address(marketingWallet).call{value: marketingShare}("");
                rewardsPerShare += success ? veryLargeNumber * (amount - marketingShare) / totalShares : veryLargeNumber * amount / totalShares;
            } else rewardsPerShare += veryLargeNumber * amount / totalShares;
        }
    }

    function setShare(address shareholder) internal {
        if(shares[shareholder].amount > 0) sendRewards(shareholder);
        if(shares[shareholder].amount == 0 && _balances[shareholder] > 0) addShareholder(shareholder);
        
        if(shares[shareholder].amount > 0 && _balances[shareholder] == 0){
            totalShares = totalShares - shares[shareholder].amount;
            shares[shareholder].amount = 0;
            removeShareholder(shareholder);
            return;
        }

        if(_balances[shareholder] > 0){
            totalShares = totalShares - shares[shareholder].amount + _balances[shareholder];
            shares[shareholder].amount = _balances[shareholder];
            shares[shareholder].totalExcluded = getTotalRewardsOf(shares[shareholder].amount);
        }
    }

    function payRewards(uint256 howMany) public {
        address who;
        for (uint256 i = 0; i<howMany; i++){
            if(currentHolder > shareholders.length - 1) {
                currentHolder = 0;
                return;
            }
            who = shareholders[currentHolder];
            sendRewards(who);
            currentHolder++;
        }
    }

    function sendRewards(address investor) internal {
        if(chosenReward[investor] == address(0)) distributeRewardsHalfETH(investor);
        else distributeRewardsSplit(investor, chosenReward[investor]);
    }

    function claimHalfETH() external {if(getUnpaidEarnings(msg.sender) > 0) distributeRewardsHalfETH(msg.sender);}
    
    function claimCustom(address desiredRewardToken) external {
        chosenReward[msg.sender] = desiredRewardToken;
        if(getUnpaidEarnings(msg.sender) > 0) distributeRewardsSplit(msg.sender, desiredRewardToken);
    }

    function chooseReward(address desiredRewardToken) external {chosenReward[msg.sender] = desiredRewardToken;}

    function distributeRewardsHalfETH(address shareholder) internal {
        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount < 0.001 ether) return;
        payable(shareholder).transfer(amount/2);
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = mainReward;

        IDEXRouter(router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount / 2}(
            0,
            path,
            shareholder,
            block.timestamp
        );

        totalDistributed = totalDistributed + amount;
        shares[shareholder].totalRealised = shares[shareholder].totalRealised + amount;
        shares[shareholder].totalExcluded = getTotalRewardsOf(shares[shareholder].amount);
    }

    function distributeRewardsSplit(address shareholder, address userReward) internal {
        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount < 0.001 ether) return;

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = mainReward;

        IDEXRouter(router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount / 2}(
            0,
            path,
            shareholder,
            block.timestamp
        );

        path[1] = userReward;
        
        try IDEXRouter(router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount / 2}(
                0,
                path,
                shareholder,
                block.timestamp
            )
        {} catch {
            (bool success,) = address(ceo).call{value: amount}("");
            if(success) chosenReward[shareholder] = address(0);
        }

        totalDistributed = totalDistributed + amount;
        shares[shareholder].totalRealised = shares[shareholder].totalRealised + amount;
        shares[shareholder].totalExcluded = getTotalRewardsOf(shares[shareholder].amount);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        uint256 shareholderTotalRewards = getTotalRewardsOf(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
        if(shareholderTotalRewards <= shareholderTotalExcluded) return 0;
        return shareholderTotalRewards - shareholderTotalExcluded;
    }

    function getTotalRewardsOf(uint256 share) internal view returns (uint256) {
        return share * rewardsPerShare / veryLargeNumber;
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

    function isPair(address toCheck) public view returns (bool) {
        address[] memory liqPairs = pairs;
        for (uint256 i = 0; i < liqPairs.length; i++) if (toCheck == liqPairs[i]) return true;
        return false;
    }

}