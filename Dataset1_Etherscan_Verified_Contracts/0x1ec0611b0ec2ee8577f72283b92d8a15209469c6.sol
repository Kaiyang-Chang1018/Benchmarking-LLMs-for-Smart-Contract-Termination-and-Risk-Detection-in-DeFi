// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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

interface IToken {
    function totalSupply() external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function decimals() external view returns (uint8);
}

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract PetroPresale is Ownable {
    uint256 public amountRaisedETH;
    uint256 public amountRaisedUSDT;
    uint256 public amountRaisedUSDC;
    address payable public wallet;
    uint256 public referralPercentage;
    AggregatorV3Interface public priceFeedETH;

    bool public CanBuy;

    enum SalePhase {
        Phase1,
        Phase2,
        Phase3,
        Phase4,
        Phase5,
        Closed
    }
    SalePhase private currentPhase;

    struct PhaseDetail {
        uint256 price;
        uint256 maxTokens;
        uint256 soldTokens;
        uint256 amountRaisedETH;
        uint256 amountRaisedUSDT;
        uint256 amountRaisedUSDC;
    }

    struct TokenPurchase {
        uint256 phase;
        address buyer;
        uint256 payAmount;
        uint256 receiveToken;
        uint256 timestamp;
        string amountType;
        bool purchased;
        bool claimed;
    }

    struct referralDetails {
        bool purchased;
        uint256 referralBonus;
    }

    address[] public tokenList;
    address[] public referralAddrss;
    TokenPurchase[] public allTokenPurchases;
    mapping(address => bool) private refExists;
    mapping(address => address) public _referral;
    mapping(SalePhase => PhaseDetail) private phaseDetails;
    mapping(address => mapping(uint256 => referralDetails))
        public _referralDetails;

    constructor(address payable _wallet) Ownable(msg.sender) {
        wallet = _wallet;
        priceFeedETH = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 //ETH
        );

        tokenList.push(address(0)); // ETH
        tokenList.push(0xdAC17F958D2ee523a2206206994597C13D831ec7); // USDT
        tokenList.push(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC
        referralPercentage = 10;
        CanBuy = true;
        phaseDetails[SalePhase.Phase1] = PhaseDetail({
            price: 500 ether,
            maxTokens: 80_000_000 * 10**18,
            soldTokens: 0,
            amountRaisedETH: 0,
            amountRaisedUSDT: 0,
            amountRaisedUSDC: 0
        });
        phaseDetails[SalePhase.Phase2] = PhaseDetail({
            price: 250 ether,
            maxTokens: 80_000_000 * 10**18,
            soldTokens: 0,
            amountRaisedETH: 0,
            amountRaisedUSDT: 0,
            amountRaisedUSDC: 0
        });
        phaseDetails[SalePhase.Phase3] = PhaseDetail({
            price: 125 ether,
            maxTokens: 80_000_000 * 10**18,
            soldTokens: 0,
            amountRaisedETH: 0,
            amountRaisedUSDT: 0,
            amountRaisedUSDC: 0
        });
        phaseDetails[SalePhase.Phase4] = PhaseDetail({
            price: 66.67 ether,
            maxTokens: 80_000_000 * 10**18,
            soldTokens: 0,
            amountRaisedETH: 0,
            amountRaisedUSDT: 0,
            amountRaisedUSDC: 0
        });

        phaseDetails[SalePhase.Phase5] = PhaseDetail({
            price: 40 ether,
            maxTokens: 80_000_000 * 10**18,
            soldTokens: 0,
            amountRaisedETH: 0,
            amountRaisedUSDT: 0,
            amountRaisedUSDC: 0
        });
        currentPhase = SalePhase.Phase1;

        _referralDetails[owner()][0].purchased = true;
        _referralDetails[owner()][1].purchased = true;
        _referralDetails[owner()][2].purchased = true;
        _referralDetails[owner()][3].purchased = true;
        _referralDetails[owner()][4].purchased = true;
        _referral[owner()] = owner();
    }

    receive() external payable {}

    function getLatestPriceETH() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedETH.latestRoundData();
        return uint256(price);
    }

    function buyTokenETH(address referrer) public payable {
        require(CanBuy == true, "disabled");
        require(currentPhase != SalePhase.Closed, "closed");
        uint256 numberOfTokens = calculateTokens(0, msg.value);
        PhaseDetail storage phase = phaseDetails[currentPhase];
        require(
            phase.soldTokens + numberOfTokens <= phase.maxTokens,
            "Exceeds limit"
        );

        if (
            referrer != address(0) &&
            referrer != msg.sender &&
            _referralDetails[referrer][uint256(currentPhase)].purchased
        ) {
            if (_referral[msg.sender] == address(0)) {
                _referral[msg.sender] = referrer;
            }
            if (_referral[msg.sender] == referrer) {
                _referralDetails[referrer][uint256(currentPhase)]
                    .referralBonus +=
                    (numberOfTokens * referralPercentage) /
                    100;
                if (!refExists[referrer]) {
                    referralAddrss.push(referrer);
                    refExists[referrer] = true;
                }
            }
        }
        allTokenPurchases.push(
            TokenPurchase({
                phase: uint256(currentPhase),
                buyer: msg.sender,
                payAmount: msg.value,
                receiveToken: numberOfTokens,
                timestamp: block.timestamp,
                amountType: "ETH",
                purchased: true,
                claimed: false
            })
        );

        _referralDetails[msg.sender][uint256(currentPhase)].purchased = true;

        phase.soldTokens += numberOfTokens;
        phase.amountRaisedETH += msg.value;
        amountRaisedETH += msg.value;
        (bool success, ) = wallet.call{value: msg.value}("");
        require(success, "ETH Transfer failed");

        if (phase.soldTokens >= phase.maxTokens) {
            currentPhase = SalePhase.Closed;
        }
    }

    function buyToken(
        address referrer,
        uint256 tokenIn,
        uint256 _amount
    ) public {
        require(CanBuy, "disabled");
        require(tokenIn > 0 && tokenIn < tokenList.length, "Invalid index");
        require(currentPhase != SalePhase.Closed, "closed");
        require(_amount > 0, "greater than zero");

        uint256 numberOfTokens = calculateTokens(tokenIn, _amount);
        PhaseDetail storage phase = phaseDetails[currentPhase];
        require(
            phase.soldTokens + numberOfTokens <= phase.maxTokens,
            "exceeds limit"
        );

        if (
            referrer != address(0) &&
            referrer != msg.sender &&
            _referralDetails[referrer][uint256(currentPhase)].purchased
        ) {
            if (_referral[msg.sender] == address(0)) {
                _referral[msg.sender] = referrer;
            }
            if (_referral[msg.sender] == referrer) {
                _referralDetails[referrer][uint256(currentPhase)]
                    .referralBonus +=
                    (numberOfTokens * referralPercentage) /
                    100;
                if (!refExists[referrer]) {
                    referralAddrss.push(referrer);
                    refExists[referrer] = true;
                }
            }
        }

        IToken paymentToken = IToken(tokenList[tokenIn]);
        require(
            paymentToken.transferFrom(msg.sender, wallet, _amount),
            "Payment transfer failed"
        );

        if (tokenIn == 1) {
            phase.amountRaisedUSDT += _amount;
            amountRaisedUSDT += _amount;
        } else if (tokenIn == 2) {
            phase.amountRaisedUSDC += _amount;
            amountRaisedUSDC += _amount;
        }

        allTokenPurchases.push(
            TokenPurchase({
                phase: uint256(currentPhase),
                buyer: msg.sender,
                payAmount: _amount,
                receiveToken: numberOfTokens,
                timestamp: block.timestamp,
                amountType: tokenIn == 1 ? "USDT" : "USDC",
                purchased: true,
                claimed: false
            })
        );
        _referralDetails[msg.sender][uint256(currentPhase)].purchased = true;
        phase.soldTokens += numberOfTokens;

        if (phase.soldTokens >= phase.maxTokens) {
            currentPhase = SalePhase.Closed;
        }
    }

    function calculateTokens(uint256 _tokenIndex, uint256 _amount)
        public
        view
        returns (uint256)
    {
        require(_tokenIndex < tokenList.length, "Invalid index");

        uint256 tokenAmount;

        if (_tokenIndex == 0) {
            tokenAmount = ETHToToken(_amount);
        } else {
            tokenAmount = calculate(_tokenIndex, _amount);
        }

        return tokenAmount;
    }

    function ETHToToken(uint256 _amount) internal view returns (uint256) {
        uint256 ETHToUsd = (_amount * getLatestPriceETH()) / (1 ether);
        uint256 numberOfTokens = (ETHToUsd * phaseDetails[currentPhase].price) /
            1 ether;
        uint256 tokens = (numberOfTokens * (10**18)) / 1e8;
        return tokens;
    }

    function calculate(uint256 tokenIn, uint256 _amount)
        internal
        view
        returns (uint256)
    {
        IToken token = IToken(tokenList[tokenIn]);
        uint8 tokenDecimals = token.decimals();

        uint256 totalTokens = (_amount * phaseDetails[currentPhase].price) /
            (10**tokenDecimals);
        uint256 tokens = (totalTokens * (10**18)) / (1 ether);
        return tokens;
    }

    function setReferralPercentage(uint256 _referralPercentage)
        external
        onlyOwner
    {
        referralPercentage = _referralPercentage;
    }

    function getTotalTokensSold() external view returns (uint256) {
        uint256 totalSoldTokens = 0;
        for (uint8 i = 0; i <= uint8(SalePhase.Closed); i++) {
            totalSoldTokens += phaseDetails[SalePhase(i)].soldTokens;
        }
        return totalSoldTokens;
    }

    function setBuying(bool enable) external onlyOwner {
        require(enable != CanBuy, "Already in that state");
        CanBuy = enable;
    }

    function withdrawETH(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(msg.sender).transfer(amount);
    }

    function withdrawTokens(address _tokenAddress, uint256 _amount)
        external
        onlyOwner
    {
        IToken token = IToken(_tokenAddress);
        require(
            token.balanceOf(address(this)) >= _amount,
            "Insufficient balance"
        );
        token.transfer(owner(), _amount);
    }

    function updateToken(uint256 index, address newToken) external onlyOwner {
        require(index < tokenList.length, "Index out of bounds");
        tokenList[index] = newToken;
    }

    function getTokenListLength() external view returns (uint256) {
        return tokenList.length;
    }

    function setPhase(SalePhase _phase) external onlyOwner {
        require(_phase != currentPhase, "Already in that phase");
        currentPhase = _phase;
    }

    function getActivePhase() external view returns (SalePhase) {
        return currentPhase;
    }

    function closePhase(SalePhase _phase) external onlyOwner {
        require(_phase != SalePhase.Closed, "Phase is already closed");
        currentPhase = SalePhase.Closed;
    }

    function setWallet(address payable newWallet) external onlyOwner {
        wallet = newWallet;
    }

    function setPhasePrice(SalePhase _phase, uint256 _price)
        external
        onlyOwner
    {
        phaseDetails[_phase].price = _price;
    }

    function setPhaseMaxTokens(SalePhase _phase, uint256 _maxTokens)
        external
        onlyOwner
    {
        phaseDetails[_phase].maxTokens = _maxTokens;
    }

    function setPriceFeed(address _priceFeed) external onlyOwner {
        priceFeedETH = AggregatorV3Interface(_priceFeed);
    }

    function getPhaseDetails(SalePhase _phase)
        external
        view
        returns (
            uint256 _price,
            uint256 _maxTokens,
            uint256 _soldTokens,
            uint256 _amountRaisedETH,
            uint256 _amountRaisedusdt,
            uint256 _amountRaisedUSDC
        )
    {
        PhaseDetail memory phase = phaseDetails[_phase];
        return (
            phase.price,
            phase.maxTokens,
            phase.soldTokens,
            phase.amountRaisedETH,
            phase.amountRaisedUSDT,
            phase.amountRaisedUSDC
        );
    }

    function getAllTokenPurchases()
        public
        view
        returns (TokenPurchase[] memory)
    {
        return allTokenPurchases;
    }

    function getReferralDetails()
        external
        view
        returns (
            address[] memory refAddresses,
            referralDetails[] memory userRefDetails
        )
    {
        uint256 totalReferrals = referralAddrss.length;

        refAddresses = new address[](totalReferrals);
        userRefDetails = new referralDetails[](totalReferrals);

        for (uint256 i = 0; i < totalReferrals; i++) {
            address refAddress = referralAddrss[i];
            refAddresses[i] = refAddress;
            userRefDetails[i] = _referralDetails[refAddress][0];
        }

        return (refAddresses, userRefDetails);
    }

    function getUserData()
        external
        view
        returns (address[] memory users, uint256[] memory totalTokens)
    {
        address[] memory tempUsers = new address[](allTokenPurchases.length);
        uint256[] memory tempTotals = new uint256[](allTokenPurchases.length);
        uint256 uniqueUserCount = 0;
        for (uint256 i = 0; i < allTokenPurchases.length; i++) {
            TokenPurchase memory purchase = allTokenPurchases[i];
            uint256 referralBonus = _referralDetails[purchase.buyer][
                purchase.phase
            ].referralBonus;

            bool isExistingUser = false;
            for (uint256 j = 0; j < uniqueUserCount; j++) {
                if (tempUsers[j] == purchase.buyer) {
                    tempTotals[j] += purchase.receiveToken;
                    isExistingUser = true;
                    break;
                }
            }
            if (!isExistingUser) {
                tempUsers[uniqueUserCount] = purchase.buyer;
                tempTotals[uniqueUserCount] =
                    purchase.receiveToken +
                    referralBonus;
                uniqueUserCount++;
            }
        }
        users = new address[](uniqueUserCount);
        totalTokens = new uint256[](uniqueUserCount);
        for (uint256 i = 0; i < uniqueUserCount; i++) {
            users[i] = tempUsers[i];
            totalTokens[i] = tempTotals[i];
        }
    }
}