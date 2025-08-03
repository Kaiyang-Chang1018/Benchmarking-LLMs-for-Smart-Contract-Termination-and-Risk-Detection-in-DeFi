//SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(
        address _owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!NOT OWNER");
        _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!NOT AUTHORIZED");
        _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IUniswapV2Router {
    function WETH() external pure returns (address);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

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
    function setDistributionCriteria(
        uint _minPeriod,
        uint _minDistribution
    ) external;

    function setShare(address shareholder, uint amount) external;

    function updateDivs(uint _amount) external;

    function process(uint gas) external;
}

contract DividendDistributor is IDividendDistributor {
    address Token;

    struct Share {
        uint amount;
        uint totalExcluded;
        uint totalRealised;
    }

    address public RewardToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; //USDC address

    IUniswapV2Router public router;
    IERC20 private rewardToken = IERC20(RewardToken);
    IERC20 private token = IERC20(Token);

    address[] shareholders;

    mapping(address => uint) shareholderIndexes;
    mapping(address => uint) shareholderClaims;
    mapping(address => Share) public shares;

    uint public totalShares;
    uint public totalDividends;
    uint public totalDistributed;
    uint public dividendsPerShare;
    uint public dividendsPerShareAccuracyFactor = 10 ** 36;
    uint public minPeriod = 1 hours;
    uint public minDistribution = 1 * 1e6; //Shareholder must have at least $1 USDC in unpaid earnings
    uint currentIndex;

    event DividendClaimed(address indexed shareholder, uint amount);
    event RewardTokenUpdated(address newToken);
    event DistributionCriteriaUpdated(uint minPeriod, uint minDistribution);

    bool initialized;

    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == Token);
        _;
    }

    constructor() {
        router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D != address(0)
            ? IUniswapV2Router(router)
            : IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        Token = msg.sender;
    }

    receive() external payable {}

    function updateRouterAddress(address newRouter) external onlyToken {
        require(
            newRouter != address(0),
            "Router address cannot be zero address"
        );
        router = IUniswapV2Router(newRouter);
    }

    function setDistributionCriteria(
        uint _minPeriod,
        uint _minDistribution
    ) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;

        emit DistributionCriteriaUpdated(_minPeriod, _minDistribution);
    }

    function setShare(
        address shareholder,
        uint amount
    ) external override onlyToken {
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares - shares[shareholder].amount + amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }

    function updateDivs(uint _amount) external override onlyToken {
        totalDividends = totalDividends + _amount;
        dividendsPerShare =
            dividendsPerShare +
            ((dividendsPerShareAccuracyFactor * _amount) / totalShares);
    }

    function process(uint gas) external override onlyToken {
        uint shareholderCount = shareholders.length;

        if (shareholderCount == 0) {
            return;
        }

        uint gasUsed = 0;
        uint gasLeft = gasleft();

        uint iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldDistribute(shareholders[currentIndex])) {
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed + (gasLeft - (gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(
        address shareholder
    ) internal view returns (bool) {
        return
            shareholderClaims[shareholder] + minPeriod < block.timestamp &&
            getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed + amount;
            rewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised =
                shares[shareholder].totalRealised +
                amount;
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );

            emit DividendClaimed(shareholder, amount);
        }
    }

    function getDividendPercentage(
        address shareholder
    ) external view returns (uint) {
        require(totalDistributed > 0, "No dividends distributed yet");

        uint shareholderTotalReceived = shares[shareholder].totalRealised;
        return (shareholderTotalReceived * 100) / totalDistributed;
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getTotalDividendsForAddress(
        address shareholder
    ) public view returns (uint) {
        return shares[shareholder].totalRealised;
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint) {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint shareholderTotalDividends = getCumulativeDividends(
            shares[shareholder].amount
        );
        uint shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    function getCumulativeDividends(uint share) internal view returns (uint) {
        return (share * dividendsPerShare) / dividendsPerShareAccuracyFactor;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function setRewardToken(address _rewardToken) external onlyToken {
        RewardToken = address(_rewardToken);
        rewardToken = IERC20(_rewardToken);

        emit RewardTokenUpdated(address(RewardToken));
    }

    function withdrawETH(address payable _to) external onlyToken {
        uint balanceETH = address(this).balance - 1;
        require(balanceETH >= 0, "ETH balance is zero");
        bool sent = _to.send(balanceETH);
        require(sent, "Failure, ETH not sent");
    }

    function withdrawToken(address _token) external onlyToken {
        require(_token != address(0x0));
        uint remainingBalance = IERC20(_token).balanceOf(address(this));
        require(remainingBalance > 0, "Token balance is zero");
        IERC20(_token).transfer(msg.sender, remainingBalance);
    }
}

contract VidiacETH is IERC20, Auth {

    address public RewardToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; //USDC address

    IUniswapV2Router public router;
    IERC20 private rewardToken = IERC20(RewardToken);

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    address public featuredWallet;
    address private uniswapRouter;
    address[] public featuredWallets;
    event RouterUpdated(address newRouter);

    string constant _name = "Vidiac";
    string constant _symbol = "VIDI";
    uint8 constant _decimals = 18;

    uint _totalSupply = 1000000 * (10 ** _decimals);

    mapping(address => uint) _balances;
    mapping(address => uint) public accumulatedFeaturedFees;
    mapping(address => mapping(address => uint)) _allowances;
    mapping(address => bool) private lpPair1;
    mapping(address => bool) private lpPair2;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) public isApprovedAddress;
    mapping(address => bool) public isWalletFeatured;

    uint public minTokensBeforeSwap = 2000 * 1e18; // Min tokens in contract before Swap will engage
    uint public minTokensHeld = 1000 * 1e18; // Min tokens held in the contract to cover referral payouts
    uint public minTokens = 0; // Min token limit to be used for referrals
    uint public totalTokensSwapped = 0; // Initialize to 0
    uint public buyFee = 20;
    uint public sellFee = 20;
    uint public dividendDistribution = 90;
    uint public featuredDistribution = 10;
    uint public distDenominator = 100;
    event FeesUpdated(uint _buyFee, uint _sellFee);
    event DistributionUpdated(
        uint _dividendDistribution,
        uint _featuredDistribution,
        uint distDenominator
    );

    address public pair1;
    address public pair2;
    bool public lpPairsSet;
    event LiquidityPairsSet(address _pair1, address _pair2);

    DividendDistributor distributor;
    address public distributorAddress;
    uint distributorGas = 500000;

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event TokensSwapped(
        uint tokenBalance,
        uint amountRewardToken,
        uint amountDividend,
        uint amountFeatured
    );

    event FeaturedWalletUpdated(address _featuredWallet);

    // Presale
    mapping(address => bool) public presaleWhitelisted;
    uint public maxPresaleLimit = 2500 * 1e18; // Maximum wallet presale buy limited to 0.1 ETH
    uint public minPresaleLimit = 250 * 1e18; // Minimum wallet presale buy limited to 0.01 ETH
    uint public totalPresaleSold = 0; // Initialize to 0
    bool public presaleActive = false;
    event PresaleStatus(bool _status);
    event TokensPurchased(uint tokenAmount, address user);

    // Referral
    struct Referral {
        string code;
        address referredAddress;
    }

    mapping(string => address) public referralCodeToCreator;
    mapping(address => string) public creatorToReferralCode;
    mapping(string => bool) public referralCodeTaken;
    mapping(address => bool) public referralCodeApplied;
    mapping(address => bool) public refAddressWhitelisted;
    uint public referralAmount = 100 * 1e18;
    uint public creatorAmount = 20 * 1e18;
    uint public referralReserveRatio = 5;
    bool public isReferralEnabled = false;

    event ReferralCodeCreated(string _code, address creator);
    event ReferralCodeApplied(string code);
    event ReferralAmountUpdated(uint _newAmount, uint factor);
    event ReferralStatusUpdated(bool _status);

    constructor() Auth(msg.sender) {
        uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        router = IUniswapV2Router(uniswapRouter);
        _allowances[address(this)][address(router)] = _totalSupply;
        distributor = new DividendDistributor();
        distributorAddress = address(distributor);
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(distributor)] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[uniswapRouter] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[ZERO] = true;
        isApprovedAddress[msg.sender] = true;
        isApprovedAddress[address(this)] = true;
        lpPairsSet = false;
        featuredWallet = msg.sender;
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }

    function allowance(
        address holder,
        address spender
    ) external view override returns (uint) {
        return _allowances[holder][spender];
    }

    function updateRouterAddress(address newRouter) external onlyOwner {
        require(
            newRouter != address(0),
            "Router address cannot be zero address"
        );
        uniswapRouter = newRouter;
        router = IUniswapV2Router(newRouter);
        distributor.updateRouterAddress(newRouter);

        emit RouterUpdated(newRouter);
    }

    function createReferralCode(
        string memory _code,
        address creator
    ) external authorized {
        require(!referralCodeTaken[_code], "Referral code already used");
        require(
            balanceOf(creator) >= minTokens,
            "Insufficient tokens for referral creation"
        );
        referralCodeToCreator[_code] = creator;
        creatorToReferralCode[creator] = _code;
        referralCodeTaken[_code] = true;

        emit ReferralCodeCreated(_code, creator);
    }

    function getReferralCodeByAddress(
        address user
    ) public view returns (string memory) {
        return creatorToReferralCode[user];
    }

    function addRefWhitelistWallet(address user) external authorized {
        refAddressWhitelisted[user] = true;
    }

    function addRefWhitelistWalletBulk(
        address[] memory users
    ) external authorized {
        for (uint i = 0; i < users.length; i++) {
            refAddressWhitelisted[users[i]] = true;
        }
    }

    function removeRefWhitelistWallet(address user) external authorized {
        refAddressWhitelisted[user] = false;
    }

    function removeRefWhitelistWalletBulk(
        address[] memory users
    ) external authorized {
        for (uint i = 0; i < users.length; i++) {
            refAddressWhitelisted[users[i]] = false;
        }
    }

    function setReferralReserveRatio(
        uint _referralReserveRatio
    ) external authorized {
        require(_referralReserveRatio >= 1, "Must be integer greater than 0");
        referralReserveRatio = _referralReserveRatio;
    }

    function applyReferralCode(string memory _code) external payable {
        require(isReferralEnabled, "Referral rewards not enabled");
        require(
            !referralCodeApplied[msg.sender],
            "Referral code already applied"
        );
        require(refAddressWhitelisted[msg.sender], "Address not whitelisted");
        require(
            balanceOf(address(this)) >= (referralReserveRatio * referralAmount),
            "Insufficient contract balance"
        );
        require(balanceOf(msg.sender) >= minTokens, "Insufficient tokens held");

        address creatorAddress = referralCodeToCreator[_code];
        require(creatorAddress != address(0), "Referral code not found");

        referralCodeApplied[msg.sender] = true;

        _transfer(address(this), msg.sender, referralAmount);
        _transfer(address(this), creatorAddress, creatorAmount);

        emit ReferralCodeApplied(_code);
    }

    function setReferralAmount(
        uint _newAmount,
        uint factor
    ) external authorized {
        require(factor >= 1, "Factor must be greater than zero");
        referralAmount = _newAmount * 1e16;
        creatorAmount = referralAmount / factor;

        emit ReferralAmountUpdated(_newAmount, factor);
    }

    function toggleReferral(bool _status) external authorized {
        isReferralEnabled = _status;

        emit ReferralStatusUpdated(_status);
    }

    function withdrawToken(address _token) external onlyOwner {
        require(_token != address(0x0));
        uint remainingBalance = IERC20(_token).balanceOf(address(this));
        require(remainingBalance > 0, "Token balance is zero");
        IERC20(_token).transfer(owner, remainingBalance);
    }

    function withdrawETH(address payable _to) external onlyOwner {
        uint balanceETH = address(this).balance - 1;
        require(balanceETH >= 0, "ETH balance is zero");
        bool sent = _to.send(balanceETH);
        require(sent, "Failure, ETH not sent");
    }

    function withdrawETHdist(address payable _to) external onlyOwner {
        distributor.withdrawETH(_to);
    }

    function withdrawTokendist(address _token) external onlyOwner {
        distributor.withdrawToken(_token);
    }

    function setRewardToken(address _rewardToken) external authorized {
        distributor.setRewardToken(_rewardToken);
        rewardToken = IERC20(_rewardToken);
        RewardToken = address(_rewardToken);
    }

    function approve(
        address spender,
        uint amount
    ) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address the_owner,
        address spender,
        uint amount
    ) internal virtual {
        require(
            the_owner != address(0),
            "ERC20: approve from the zero address"
        );
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[the_owner][spender] = amount;
        emit Approval(the_owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint amount
    ) internal virtual {
        if (
            (!isApprovedAddress[sender] && !lpPairsSet) //Prevents bots from sniping liquidity prior to LP pairs being set and taxes engaged. No longer in effect once LP Pairs are set.
        ) {
            revert();
        } else {
            require(
                sender != address(0),
                "ERC20: transfer from the zero address"
            );
            require(
                recipient != address(0),
                "ERC20: transfer to the zero address"
            );

            uint senderBalance = _balances[sender];
            require(
                senderBalance >= amount,
                "ERC20: transfer amount exceeds balance"
            );
            unchecked {
                _balances[sender] = senderBalance - amount;
            }
            _balances[recipient] += amount;

            if (!isDividendExempt[sender]) {
                try distributor.setShare(sender, _balances[sender]) {} catch {}
            }
            if (!isDividendExempt[recipient]) {
                try
                    distributor.setShare(recipient, _balances[recipient])
                {} catch {}
            }

            emit Transfer(sender, recipient, amount);
        }
    }

    function transfer(
        address _recipient,
        uint _amount
    ) public override returns (bool) {
        _transferFrom(msg.sender, _recipient, _amount);
        return true;
    }

    function transferFrom(
        address the_owner,
        address _recipient,
        uint _amount
    ) public override returns (bool) {
        _transferFrom(the_owner, _recipient, _amount);

        uint currentAllowance = _allowances[the_owner][msg.sender];
        require(
            currentAllowance >= _amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(the_owner, msg.sender, currentAllowance - _amount);
        }

        return true;
    }

    function _transferFrom(
        address _sender,
        address _recipient,
        uint _amount
    ) private returns (bool) {
        if (
            isFeeExempt[_sender] ||
            isFeeExempt[_recipient] ||
            inSwap ||
            (!lpPair1[_recipient] &&
                !lpPair1[_sender] &&
                !lpPair2[_recipient] &&
                !lpPair2[_sender])
        ) {
            _transfer(_sender, _recipient, _amount);
        } else {
            // Sell
            if ((lpPair1[_recipient]) || (lpPair2[_recipient])) {
                uint sellTax = (_amount * sellFee) / 100;
                _transfer(_sender, _recipient, _amount - sellTax);
                _transfer(_sender, address(this), sellTax);
            }
            // Buy
            else if ((lpPair1[_sender]) || (lpPair2[_sender])) {
                uint buyTax = (_amount * buyFee) / 100;
                _transfer(_sender, _recipient, _amount - buyTax);
                _transfer(_sender, address(this), buyTax);
            }

            try distributor.process(distributorGas) {} catch {}
        }

        return true;
    }

    function setMinTokensBeforeSwap(
        uint _minTokensBeforeSwap
    ) external authorized {
        minTokensBeforeSwap = _minTokensBeforeSwap * 1e16;
    }

    function setMinTokensHeld(uint _minTokensHeld) external authorized {
        minTokensHeld = _minTokensHeld * 1e16;
    }

    function setMinTokens(uint _minTokens) external authorized {
        minTokens = _minTokens * 1e16;
    }

    function swap() public swapping authorized {
        require(balanceOf(address(this)) >= minTokensBeforeSwap);
        uint tokenBalance = balanceOf(address(this)) - minTokensHeld;
        //uint256 balanceBefore = rewardToken.balanceOf(address(this));

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = RewardToken;

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenBalance,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint amountRewardToken = rewardToken.balanceOf(address(this));
        uint amountDividend = (amountRewardToken * dividendDistribution) /
            distDenominator;
        uint amountFeatured = (amountRewardToken * featuredDistribution) /
            distDenominator;

        // Trasfer amountDividend Reward Token to distributor
        rewardToken.transfer(address(distributor), amountDividend);
        try distributor.updateDivs(amountDividend) {} catch {}
        // Trasfer amountFeatured Reward Token to featuredWallet
        rewardToken.transfer(featuredWallet, amountFeatured);

        accumulatedFeaturedFees[featuredWallet] += amountFeatured; // Update the accumulated amount
        totalTokensSwapped += tokenBalance; // Update the amount of totalTokensSwapped

        emit TokensSwapped(
            tokenBalance,
            amountRewardToken,
            amountDividend,
            amountFeatured
        );
    }

    function getAccumulatedFeesForAddress(
        address _address
    ) external view returns (uint) {
        return accumulatedFeaturedFees[_address];
    }

    function getAllFeaturedWallets() external view returns (address[] memory) {
        return featuredWallets;
    }

    function setIsDividendExempt(
        address holder,
        bool exempt
    ) public authorized {
        require(holder != address(this));
        isDividendExempt[holder] = exempt;
        if (exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setApprovedAddress(
        address holder,
        bool approved
    ) external onlyOwner {
        isApprovedAddress[holder] = approved;
    }

    function setLPPairs(address _pair1, address _pair2) external onlyOwner {
        lpPair1[_pair1] = true;
        lpPair2[_pair2] = true;
        _approve(address(this), address(_pair1), _totalSupply);
        _approve(address(this), address(_pair2), _totalSupply);
        setIsDividendExempt(_pair1, true);
        setIsDividendExempt(_pair2, true);
        pair1 = _pair1;
        pair2 = _pair2;
        lpPairsSet = true;

        emit LiquidityPairsSet(_pair1, _pair2);
    }

    function setFees(uint _buyFee, uint _sellFee) public authorized {
        require(_buyFee <= 20);
        require(_sellFee <= 20);
        buyFee = _buyFee;
        sellFee = _sellFee;

        emit FeesUpdated(_buyFee, _sellFee);
    }

    function setDistSplit(
        uint _dividendDistribution,
        uint _featuredDistribution
    ) external authorized {
        dividendDistribution = _dividendDistribution;
        featuredDistribution = _featuredDistribution;
        distDenominator = _dividendDistribution + _featuredDistribution;
        require(distDenominator == 100);

        emit DistributionUpdated(
            _dividendDistribution,
            _featuredDistribution,
            distDenominator
        );
    }

    function setFeaturedWallet(address _featuredWallet) external authorized {
        featuredWallet = _featuredWallet;
        // Check if the wallet was already added to the array
        if (!isWalletFeatured[_featuredWallet]) {
            featuredWallets.push(_featuredWallet);
            isWalletFeatured[_featuredWallet] = true;
        }

        emit FeaturedWalletUpdated(_featuredWallet);
    }

    function setDistributionCriteria(
        uint _minPeriod,
        uint _minDistribution
    ) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint gas) external authorized {
        require(gas < 750000);
        distributorGas = gas;
    }

    function addPresaleWhitelist(address _address) external authorized {
        presaleWhitelisted[_address] = true;
    }

    function addPresaleWhitelistBulk(
        address[] memory _addresses
    ) external authorized {
        for (uint i = 0; i < _addresses.length; i++) {
            presaleWhitelisted[_addresses[i]] = true;
        }
    }

    function removePresaleWhitelist(address _address) external authorized {
        presaleWhitelisted[_address] = false;
    }

    function removePresaleWhitelistBulk(
        address[] memory _addresses
    ) external authorized {
        for (uint i = 0; i < _addresses.length; i++) {
            presaleWhitelisted[_addresses[i]] = false;
        }
    }

    function setMinPresaleLimit(uint _minPresaleLimit) external authorized {
        minPresaleLimit = _minPresaleLimit * 1e18;
    }

    function setMaxPresaleLimit(uint _maxPresaleLimit) external authorized {
        maxPresaleLimit = _maxPresaleLimit * 1e18;
    }

    function purchaseTokens(uint tokenAmount) external payable {
        require(
            presaleWhitelisted[msg.sender],
            "Account not eligible for presale"
        );
        require(presaleActive, "Presale not active");
        require(
            totalPresaleSold + (tokenAmount * 1e18) <= 500000 * 1e18,
            "All presale tokens sold"
        );

        uint ethAmountRequired = (tokenAmount * 1e18) / 25000; //1 ETH equals 25,000 tokens
        address user = msg.sender;

        require(msg.value >= ethAmountRequired, "Insufficient ETH sent");
        require(
            _balances[msg.sender] + (tokenAmount * 1e18) <= maxPresaleLimit,
            "Exceeds maximum purchase limit"
        );
        require(
            _balances[msg.sender] + (tokenAmount * 1e18) >= minPresaleLimit,
            "Below minimum purchase limit"
        );

        // Transfer tokens from the contract to the user
        _transfer(address(this), msg.sender, (tokenAmount * 1e18));

        // Update totalPresaleSold in the same scale as the token
        totalPresaleSold += (tokenAmount * 1e18);

        emit TokensPurchased(tokenAmount, user);
    }

    function togglePresale(bool _status) external onlyOwner {
        presaleActive = _status;

        emit PresaleStatus(_status);
    }
}