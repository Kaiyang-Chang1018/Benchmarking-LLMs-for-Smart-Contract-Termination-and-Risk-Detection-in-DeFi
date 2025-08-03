//
//   ___  _   _ _____ ____ _____      _    ___
//  / _ \| | | | ____/ ___|_   _|    / \  |_ _|
// | | | | | | |  _| \___ \ | |     / _ \  | |
// | |_| | |_| | |___ ___) || |    / ___ \ | |
//  \__\_\\___/|_____|____/ |_|   /_/   \_\___|
//
//
//    Telegram: https://t.me/questai_app
//
//    Website: https://queai.app/
//    X: https://x.com/QuestAI_app
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable;
}

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract QUESTAI is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public blacklisted;

    mapping(address => bool) private isFeeExempt;
    mapping(address => bool) private liquidityCreator;
    mapping(address => bool) private isMaxBuyExempt;
    mapping(address => bool) private liquidityPools;

    address immutable public pair;
    IRouter public router;

    string private constant _name = "QUEST AI";
    string private constant _symbol = "QUEAI";
    uint8 private constant _decimals = 18;

    uint256 private constant _totalSupply = 100_000_000 * (10 ** _decimals);

    uint256 private totalFee = 5000;
    uint256 private feeDenominator = 10000;

    // 1% of total supply
    uint256 private maxBuyNumerator = 100;
    uint256 private maxBuyDenominator = 10000;

    uint256 public launchedAt;
    bool private isTradingAllowed;

    bool private swapBackEnabled;
    bool private inSwap;

    address private constant routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address public devWallet;
    address public marketingWallet;

    uint8 public devWalletSupplyPercentage = 5;
    uint8 public marketingWalletSupplyPercentage = 15;

    uint256 private _devWalletSupply = _totalSupply * devWalletSupplyPercentage / 100;
    uint256 private _marketingWalletSupply = _totalSupply * marketingWalletSupplyPercentage / 100;
    uint256 private _ownerWalletSupply = _totalSupply - _devWalletSupply - _marketingWalletSupply;

    address private constant zeroAddress = 0x0000000000000000000000000000000000000000;
    address private constant deadAddress = 0x000000000000000000000000000000000000dEaD;

     modifier onlyDev() {
        require(_msgSender() == devWallet, "QUEST AI: caller is not a team member");
        _;
    }

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event DistributedFees(uint256 fee);

    constructor(address _devWallet, address _marketingWallet) {
        router = IRouter(routerAddress);
        pair = IFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        liquidityPools[pair] = true;
        _allowances[owner()][routerAddress] = type(uint256).max;
        _allowances[address(this)][routerAddress] = type(uint256).max;

        devWallet = _devWallet;
        marketingWallet = _marketingWallet;

        isFeeExempt[owner()] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[devWallet] = true;
        isFeeExempt[marketingWallet] = true;

        liquidityCreator[owner()] = true;

        _balances[owner()] = _ownerWalletSupply;
        _balances[devWallet] = _devWalletSupply;
        _balances[marketingWallet] = _marketingWalletSupply;

        isMaxBuyExempt[owner()] = true;
        isMaxBuyExempt[address(this)] = true;
        isMaxBuyExempt[pair] = true;
        isMaxBuyExempt[routerAddress] = true;

        isTradingAllowed = false;
        swapBackEnabled = true;

        emit Transfer(address(0), owner(), _ownerWalletSupply);
        emit Transfer(address(0), devWallet, _devWalletSupply);
        emit Transfer(address(0), marketingWallet, _marketingWalletSupply);
    }

    receive() external payable {}

    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(
        address holder,
        address spender
    ) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMaximum(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function decreaseFee(uint256 _newFee) external onlyDev {
        require(_newFee <= totalFee, "QUEST AI: Can't increase fee.");
        totalFee = _newFee;
    }

    function updateDevWallet(address newWallet) external onlyOwner {
        require(devWallet != newWallet ,'Wallet already set');
        devWallet = newWallet;
        isFeeExempt[devWallet] = true;
    }

    function updateMarketingWallet(address newWallet) external onlyOwner {
        require(marketingWallet != newWallet ,'Wallet already set');
        marketingWallet = newWallet;
        isFeeExempt[marketingWallet] = true;
    }

    function feeWithdrawal(uint256 amount) external onlyDev {
        uint256 amountETH = address(this).balance;
        payable(devWallet).transfer((amountETH * amount) / 100);
    }

    function startTrading() external onlyOwner {
        require(!isTradingAllowed);
        isTradingAllowed = true;
        launchedAt = block.number;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(sender != address(0), "QUEST AI: Transfer from the zero address.");
        require(recipient != address(0), "QUEST AI: Transfer to the zero address.");
        require(amount > 0, "QUEST AI: Transfer amount must be greater than zero.");
        require(_balances[sender] >= amount, "QUEST AI: You are trying to transfer more than your balance.");
        require(!blacklisted[sender] && !blacklisted[recipient], "QUEST AI: Address is blacklisted.");

        if (!launched() && liquidityPools[recipient]) {
            require(
                liquidityCreator[sender],
                "QUEST AI: Liquidity not added yet."
            );
            launch();
        }

        if (!isTradingAllowed) {
            require(
                liquidityCreator[sender] || liquidityCreator[recipient],
                "QUEST AI: Trading is currently disabled."
            );
        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (liquidityPools[sender] && !isMaxBuyExempt[recipient]) {
            // we are buying tokens
            uint256 maxAmount = (_totalSupply * maxBuyNumerator) /
                maxBuyDenominator;
            require(
                amount <= maxAmount,
                "QUEST AI: Max buy amount exceeded. Try a lower amount."
            );
        }

        _balances[sender] = _balances[sender] - amount;

        uint256 amountReceived = feeExcluded(sender)
            ? receiveFee(recipient, amount)
            : amount;

        if (shouldSwapBack(recipient)) {
            if (amount > 0) swapBack();
        }

        _balances[recipient] = _balances[recipient] + amountReceived;

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function feeExcluded(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function receiveFee(
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        bool sellingOrBuying = liquidityPools[recipient] ||
            liquidityPools[msg.sender];

        if (!sellingOrBuying) {
            return amount;
        }

        uint256 feeAmount = (amount * totalFee) / feeDenominator;
        _balances[address(this)] += feeAmount;

        return amount - feeAmount;
    }

    function shouldSwapBack(address recipient) internal view returns (bool) {
        return
            !liquidityPools[msg.sender] && !inSwap && liquidityPools[recipient] && swapBackEnabled;
    }

    function setProvideLiquidity(address lp, bool isPool) external onlyDev {
        require(lp != pair, "QUEST AI: Can't alter current liquidity pair.");
        liquidityPools[lp] = isPool;
    }

    function setSwapBackEnabled(bool _enabled) external onlyDev {
        swapBackEnabled = _enabled;
    }

    function setMaxBuyExempt(address _address, bool _isExempt) external onlyDev {
        isMaxBuyExempt[_address] = _isExempt;
    }

    function setBlacklist(address _address, bool _isBlacklisted) external onlyOwner {
        blacklisted[_address] = _isBlacklisted;
    }

    function swapBack() internal swapping {
        uint256 myBalance = _balances[address(this)];

        if (myBalance == 0) return;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            myBalance,
            0,
            path,
            address(this),
            block.timestamp
        );

        emit DistributedFees(myBalance);
    }

    function addLiquidityCreator(address _liquidityCreator) external onlyOwner {
        liquidityCreator[_liquidityCreator] = true;
    }

    function getCurrentSupply() public view returns (uint256) {
        return _totalSupply - balanceOf(deadAddress) - balanceOf(zeroAddress);
    }
}