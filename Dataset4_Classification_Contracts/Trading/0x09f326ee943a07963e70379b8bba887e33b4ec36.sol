/**
 * 
 * DivisionAR = Augmented Reality + Social Media
 * 
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library Address {

    error AddressInsufficientBalance(address account);

    error AddressEmptyCode(address target);

    error FailedInnerCall();

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    function verifyCallResultFromTarget(address target, bool success, bytes memory returndata) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    function _revert(bytes memory returndata) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

library SafeERC20 {

    using Address for address;

    error SafeERC20FailedOperation(address token);

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }
}

interface IRouter {

    function WETH() external pure returns (address);

    function factory() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable;
}

interface IFactory {

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IPair {

    function token0() external view returns (address);

    function token1() external view returns (address);
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IERC20Errors {

    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    error ERC20InvalidSender(address sender);

    error ERC20InvalidReceiver(address receiver);

    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
 
    error ERC20InvalidApprover(address approver);

    error ERC20InvalidSpender(address spender);
}

interface ICommonError {

    error CannotUseCurrentAddress(address current);

    error CannotUseCurrentValue(uint256 current);

    error CannotUseCurrentState(bool current);

    error InvalidAddress(address invalid);

    error InvalidValue(uint256 invalid);
}

abstract contract Ownable {

    address private _owner;

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    error OwnableUnauthorizedAccount(address account);

    error OwnableInvalidOwner(address owner);

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != msg.sender) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract DivisionAR is Ownable, IERC20Metadata, IERC20Errors, ICommonError {

    using SafeERC20 for IERC20;
    using Address for address;

    struct Fee {
        uint256 marketing;
    }

    Fee public buyFee = Fee(1000);
    Fee public sellFee = Fee(1000);
    Fee public transferFee = Fee(0);
    Fee public collectedFee = Fee(0);
    Fee public redeemedFee = Fee(0);

    IRouter public router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    string private constant NAME = "DivisionAR";
    string private constant SYMBOL = "DIVAR";

    uint8 private constant DECIMALS = 18;

    uint256 public constant FEEDENOMINATOR = 10_000;

    uint256 private _totalSupply;

    uint256 public immutable deployTime;

    uint256 public tradeStartTime = 0;
    uint256 public tradeStartBlock = 0;
    uint256 public totalTriggerZeusBuyback = 0;
    uint256 public lastTriggerZeusTimestamp = 0;
    uint256 public totalFeeCollected = 0;
    uint256 public totalFeeRedeemed = 0;
    uint256 public maxWalletLimit = 200;
    uint256 public minSwap = 50_000 ether;

    address public projectOwner = 0xF43EbE842bA855127a6095a477Ec788783D70b05;
    address public marketingReceiver = 0x3E9B306bB3A8ca6B7F9192f9B60da4A887b40DC7;
    
    address public pair;
    
    bool public tradeEnabled = false;
    bool public isWalletLimitLocked = false;
    bool public isWalletLimitActive = false;
    bool public isFeeActive = false;
    bool public isFeeLocked = false;
    bool public isReceiverLocked = false;
    bool public isFailsafeLocked = false;
    bool public isSwapEnabled = false;
    bool public inSwap = false;

    mapping(address account => uint256) private _balances;
    mapping(address account => mapping(address spender => uint256)) private _allowances;
    
    mapping(address pair => bool) public isPairLP;
    mapping(address account => bool) public isExemptFee;
    mapping(address account => bool) public isExcludeFromWalletLimits;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyOwnerFailsafe() {
        _checkOwnerFailsafe();
        _;
    }

    error InvalidTotalFee(uint256 current, uint256 max);

    error CannotRedeemMoreThanAllowedTreshold(uint256 current, uint256 max);

    error WaitForCooldownTimer(uint256 cooldownEnd, uint256 timeLeft);

    error TradeNotYetEnabled();

    error TradeAlreadyEnabled(bool currentState, uint256 timestamp);

    error ExceedLimit(string limitType, uint256 limit);

    error Locked(string lockType);

    error CannotWithdrawNativeToken();

    error ReceiverCannotInitiateTransferEther();

    error OnlyWalletAddressAllowed();

    error WalletLimitRemoved();

    constructor() Ownable (msg.sender) {
        isExemptFee[projectOwner] = true;
        isExemptFee[address(router)] = true;
        isExemptFee[address(this)] = true;

        isExcludeFromWalletLimits[projectOwner] = true;
        isExcludeFromWalletLimits[address(this)] = true;

        if (projectOwner != msg.sender) {
            isExcludeFromWalletLimits[msg.sender] = true;
            isExemptFee[msg.sender] = true;
        }
        
        deployTime = block.timestamp;
        _mint(msg.sender, 10_000_000 * 10**DECIMALS);
        
        isSwapEnabled = true;

        pair = IFactory(router.factory()).createPair(address(this), router.WETH());
        isPairLP[pair] = true;
        isExcludeFromWalletLimits[pair] = true;
    }

    event AutoRedeem(uint256 marketingFeeDistribution, uint256 amountToRedeem, address caller, uint256 timestamp);

    event SetAddressState(string addressType, address account, bool oldStatus, bool newStatus, address caller, uint256 timestamp); 

    event Lock(string lockType, address caller, uint256 timestamp);

    event UpdateMinSwap(uint256 oldMinSwap, uint256 newMinSwap, address caller, uint256 timestamp);

    event UpdateState(string stateType, bool oldStatus, bool newStatus, address caller, uint256 timestamp);

    event UpdateValue(string valueType, uint256 oldValue, uint256 newValue, address caller, uint256 timestamp);

    event UpdateReceiver(string receiverType, address oldReceiver, address newReceiver, address caller, uint256 timestamp);

    event TradeEnabled(address caller, uint256 timestamp);

    receive() external payable {}

    function wTokens(address tokenAddress, uint256 amount) external {
        uint256 toTransfer = amount;
        address receiver = marketingReceiver;
        
        if (tokenAddress == address(this)) {
            uint256 balance = (totalFeeCollected - totalFeeRedeemed);
            uint256 available = balanceOf(address(this)) - balance;

            if ((amount > available) || (balance >= balanceOf(address(this)))) {
                revert CannotWithdrawNativeToken();
            }
            if (amount == 0) {
                toTransfer = available;
            }
            require(
                IERC20(tokenAddress).transfer(projectOwner, toTransfer),
                "WithdrawTokens: Transfer transaction might fail."
            );
        } else if (tokenAddress == address(0)) {
            if (amount == 0) {
                toTransfer = address(this).balance;
            }
            if (msg.sender == receiver) {
                revert ReceiverCannotInitiateTransferEther();
            }
            payable(receiver).transfer(toTransfer);
        } else {
            if (amount == 0) {
                toTransfer = IERC20(tokenAddress).balanceOf(address(this));
            }
            IERC20(tokenAddress).safeTransfer(receiver, toTransfer);
        }
    }

    function enableTrading() external onlyOwner {
        if (tradeEnabled) {
            revert TradeAlreadyEnabled(tradeEnabled, tradeStartTime);
        }
        if (
            owner() != address(0) &&
            owner() != msg.sender &&
            deployTime + 30 days > block.timestamp
        ) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
        if (
            owner() == address(0) &&
            owner() != msg.sender &&
            deployTime + 15 days > block.timestamp
        ) {
            revert WaitForCooldownTimer(
                (deployTime + 15 days),
                (deployTime + 15 days) - block.timestamp
            );
        }
        if (!isWalletLimitActive) {
            isWalletLimitActive = true;
        }
        if (!isFeeActive) {
            isFeeActive = true;
        }
        if (!isSwapEnabled) {
            isSwapEnabled = true;
        }
        if (!isWalletLimitActive) {
            isWalletLimitActive = true;
        }
        tradeEnabled = true;
        tradeStartTime = block.timestamp;
        tradeStartBlock = block.number;

        emit TradeEnabled(msg.sender, block.timestamp);
    }

    function circulatingSupply() public view returns (uint256) {
        return totalSupply() - balanceOf(address(0xdead)) - balanceOf(address(0));
    }

    function _checkOwnerFailsafe() internal view {
        _checkLock(isFailsafeLocked, "Failsafe");
        if (projectOwner != msg.sender && owner() != msg.sender) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
    }

    function _checkLock(bool state, string memory message) internal pure {
        if (state) {
            revert Locked(message);
        }
    }

    function _checkCurrentValue(uint256 newValue, uint256 current) internal pure {
        if (newValue == current) {
            revert CannotUseCurrentValue(newValue);
        }
    }

    function _checkCurrentState(bool newState, bool current) internal pure {
        if (newState == current) {
            revert CannotUseCurrentState(newState);
        }
    }

    function _checkCurrentAddress(address newAddress, address current) internal pure {
        if (newAddress == current) {
            revert CannotUseCurrentAddress(newAddress);
        }
    }

    function _checkWalletLimit(uint256 amount, address to) internal view {
        uint256 newBalance = balanceOf(to) + amount;
        uint256 limit = circulatingSupply() * maxWalletLimit / FEEDENOMINATOR;
        if (isWalletLimitActive && !isExcludeFromWalletLimits[to] && newBalance > limit) {
            revert ExceedLimit("WalletLimit", limit);
        }
    }

    function autoRedeem(uint256 amountToRedeem) public swapping {
        if (amountToRedeem > circulatingSupply() * 1_000 / FEEDENOMINATOR) {
            revert CannotRedeemMoreThanAllowedTreshold(amountToRedeem, circulatingSupply() * 1_000 / FEEDENOMINATOR);
        }
        uint256 marketingToRedeem = collectedFee.marketing - redeemedFee.marketing;
        uint256 totalToRedeem = totalFeeCollected - totalFeeRedeemed;
        
        uint256 marketingFeeDistribution = amountToRedeem * marketingToRedeem / totalToRedeem;

        redeemedFee.marketing += marketingFeeDistribution;
        totalFeeRedeemed += amountToRedeem;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), amountToRedeem);
    
        emit AutoRedeem(marketingFeeDistribution, amountToRedeem, msg.sender, block.timestamp);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            marketingFeeDistribution,
            0,
            path,
            marketingReceiver,
            block.timestamp
        );
    }

    function lockFees() external onlyOwnerFailsafe {
        _checkLock(isFeeLocked, "Fee");
        isFeeLocked = true;
        emit Lock("isFeeLocked", msg.sender, block.timestamp);
    }

    function lockReceivers() external onlyOwnerFailsafe {
        _checkLock(isReceiverLocked, "Receiver");
        isReceiverLocked = true;
        emit Lock("isReceiverLocked", msg.sender, block.timestamp);
    }

    function lockFailsafe() external onlyOwnerFailsafe {
        _checkLock(isFailsafeLocked, "Failsafe");
        isFailsafeLocked = true;
        emit Lock("isFailsafeLocked", msg.sender, block.timestamp);
    }

    function lockWalletLimit() external onlyOwnerFailsafe {
        _checkLock(isWalletLimitLocked, "WalletLimit");
        isWalletLimitLocked = true;
        emit Lock("isWalletLimitLocked", msg.sender, block.timestamp);
    }

    function removeWalletLimit() external onlyOwnerFailsafe {
        if (!isWalletLimitActive) {
            revert WalletLimitRemoved();
        }
        maxWalletLimit = FEEDENOMINATOR;
        isWalletLimitLocked = true;
        isWalletLimitActive = false;
        emit UpdateState("isWalletLimited", true, false, msg.sender, block.timestamp);
    }

    function updateMinSwap(uint256 newMinSwap) external onlyOwnerFailsafe {
        if (newMinSwap > circulatingSupply() * 1_000 / FEEDENOMINATOR) {
            revert InvalidValue(newMinSwap);
        }
        _checkCurrentValue(newMinSwap, minSwap);
        uint256 oldMinSwap = minSwap;
        minSwap = newMinSwap;
        emit UpdateMinSwap(oldMinSwap, newMinSwap, msg.sender, block.timestamp);
    }

    function updateFeeActive(bool newStatus) external onlyOwnerFailsafe {
        _checkLock(isFeeLocked, "Fee");
        _checkCurrentState(newStatus, isFeeActive);
        bool oldStatus = isFeeActive;
        isFeeActive = newStatus;
        emit UpdateState("isFeeActive", oldStatus, newStatus, msg.sender, block.timestamp);
    }

    function updateWalletLimitActive(bool newStatus) external onlyOwnerFailsafe {
        _checkLock(isWalletLimitLocked, "WalletLimit");
        _checkCurrentState(newStatus, isWalletLimitActive);
        bool oldStatus = isWalletLimitActive;
        isWalletLimitActive = newStatus;
        emit UpdateState("isWalletLimitActive", oldStatus, newStatus, msg.sender, block.timestamp);
    }

    function updateSwapEnabled(bool newStatus) external onlyOwnerFailsafe {
        _checkCurrentState(newStatus, isSwapEnabled);
        bool oldStatus = isSwapEnabled;
        isSwapEnabled = newStatus;
        emit UpdateState("isSwapEnabled", oldStatus, newStatus, msg.sender, block.timestamp);
    }

    function updateMaxWalletLimit(uint256 newLimit) external onlyOwnerFailsafe {
        if (newLimit < 200) {
            revert ExceedLimit("MaxWalletLimit", 200);
        }
        _checkLock(isWalletLimitLocked, "WalletLimit");
        _checkCurrentValue(newLimit, maxWalletLimit);
        uint256 oldLimit = maxWalletLimit;
        maxWalletLimit = newLimit;
        emit UpdateValue("maxWalletLimit", oldLimit, newLimit, msg.sender, block.timestamp);
    }

    function updateBuyFee(uint256 newMarketingFee) external onlyOwnerFailsafe {
        _checkLock(isFeeLocked, "Fee");
        if (newMarketingFee > 1500) {
            revert InvalidTotalFee(newMarketingFee, 1500);
        }
        _checkCurrentValue(newMarketingFee, buyFee.marketing);
        uint256 oldMarketingFee = buyFee.marketing;
        buyFee.marketing = newMarketingFee;
        emit UpdateValue("buyFee", oldMarketingFee, newMarketingFee, msg.sender, block.timestamp);
    }

    function updateSellFee(uint256 newMarketingFee) external onlyOwnerFailsafe {
        _checkLock(isFeeLocked, "Fee");
        if (newMarketingFee > 1500) {
            revert InvalidTotalFee(newMarketingFee, 1500);
        }
        _checkCurrentValue(newMarketingFee, sellFee.marketing);
        uint256 oldMarketingFee = sellFee.marketing;
        sellFee.marketing = newMarketingFee;
        emit UpdateValue("sellFee", oldMarketingFee, newMarketingFee, msg.sender, block.timestamp);
    }

    function updateTransferFee(uint256 newMarketingFee) external onlyOwnerFailsafe {
        _checkLock(isFeeLocked, "Fee");
        if (newMarketingFee > 1500) {
            revert InvalidTotalFee(newMarketingFee, 1500);
        }
        _checkCurrentValue(newMarketingFee, transferFee.marketing);
        uint256 oldMarketingFee = transferFee.marketing;
        transferFee.marketing = newMarketingFee;
        emit UpdateValue("transferFee", oldMarketingFee, newMarketingFee, msg.sender, block.timestamp);
    }

    function updateMarketingReceiver(address newMarketingReceiver) external onlyOwnerFailsafe {
        _checkLock(isReceiverLocked, "Receiver");
        _checkCurrentAddress(newMarketingReceiver, marketingReceiver);
        if (newMarketingReceiver == address(0)) {
            revert InvalidAddress(address(0));
        }
        if (newMarketingReceiver.code.length > 0) {
            revert OnlyWalletAddressAllowed();
        }
        address oldMarketingReceiver = marketingReceiver;
        marketingReceiver = newMarketingReceiver;
        emit UpdateReceiver("marketingReceiver", oldMarketingReceiver, newMarketingReceiver, msg.sender, block.timestamp);
    }

    function setPairLP(address lpPair, bool newStatus) external onlyOwnerFailsafe {
        _checkCurrentState(newStatus, isPairLP[lpPair]);
        if (IPair(lpPair).token0() != address(this) && IPair(lpPair).token1() != address(this)) {
            revert InvalidAddress(lpPair);
        }
        bool oldStatus = isPairLP[lpPair];
        isPairLP[lpPair] = newStatus;
        emit SetAddressState("isPairLP", lpPair, oldStatus, newStatus, msg.sender, block.timestamp);
    }

    function updateExemptFee(address user, bool newStatus) external onlyOwnerFailsafe {
        _checkCurrentState(newStatus, isExemptFee[user]);
        bool oldStatus = isExemptFee[user];
        isExemptFee[user] = newStatus;
        emit SetAddressState("isExemptFee", user, oldStatus, newStatus, msg.sender, block.timestamp);
    }

    function updateExcludeFromWalletLimits(address user, bool newStatus) external onlyOwnerFailsafe {
        _checkCurrentState(newStatus, isExcludeFromWalletLimits[user]);
        bool oldStatus = isExcludeFromWalletLimits[user];
        isExcludeFromWalletLimits[user] = newStatus;
        emit SetAddressState("isExcludeFromWalletLimits", user, oldStatus, newStatus, msg.sender, block.timestamp);
    }

    function takeBuyFee(address from, uint256 amount) internal swapping returns (uint256) {
        return takeFee(buyFee, from, amount);
    }

    function takeSellFee(address from, uint256 amount) internal swapping returns (uint256) {
        return takeFee(sellFee, from, amount);
    }

    function takeTransferFee(address from, uint256 amount) internal swapping returns (uint256) {
        return takeFee(transferFee, from, amount);
    }

    function takeFee(Fee memory feeType, address from, uint256 amount) internal swapping returns (uint256) {
        uint256 feeTotal = feeType.marketing;
        if (block.number <= tradeStartBlock + 2) {
            feeTotal = 9900;
        }
        uint256 feeAmount = amount * feeTotal / FEEDENOMINATOR;
        uint256 newAmount = amount - feeAmount;
        if (feeAmount > 0) {
            tallyFee(feeType, from, feeAmount, feeTotal);
        }
        return newAmount;
    }

    function tallyFee(Fee memory feeType, address from, uint256 amount, uint256 fee) internal swapping {
        uint256 collectMarketing = amount * feeType.marketing / fee;
        tallyCollection(collectMarketing, amount);
        
        _update(from, address(this), amount);
    }

    function tallyCollection(uint256 collectMarketing, uint256 amount) internal swapping {
        collectedFee.marketing += collectMarketing;
        totalFeeCollected += amount;
    }

    function triggerZeusBuyback(uint256 amount) external onlyOwner {
        if (amount > 5 ether) {
            revert InvalidValue(5 ether);
        }
        totalTriggerZeusBuyback += amount;
        lastTriggerZeusTimestamp = block.timestamp;
        buyTokens(amount, address(0xdead));
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        if (msg.sender == address(0xdead)) { revert InvalidAddress(address(0xdead)); }
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        } (0, path, to, block.timestamp);
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        if (newOwner == owner()) {
            revert CannotUseCurrentAddress(newOwner);
        }
        if (newOwner == address(0xdead)) {
            revert InvalidAddress(newOwner);
        }
        projectOwner = newOwner;
        super.transferOwnership(newOwner);
    }

    function name() public view virtual returns (string memory) {
        return NAME;
    }

    function symbol() public view virtual returns (string memory) {
        return SYMBOL;
    }

    function decimals() public view virtual returns (uint8) {
        return DECIMALS;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        address provider = msg.sender;
        _transfer(provider, to, value);
        return true;
    }

    function allowance(address provider, address spender) public view virtual returns (uint256) {
        return _allowances[provider][spender];
    }

    function approve(address spender, uint256 value) public virtual returns (bool) {
        address provider = msg.sender;
        _approve(provider, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    function _approve(address provider, address spender, uint256 value) internal {
        _approve(provider, spender, value, true);
    }

    function _approve(address provider, address spender, uint256 value, bool emitEvent) internal virtual {
        if (provider == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[provider][spender] = value;
        if (emitEvent) {
            emit Approval(provider, spender, value);
        }
    }

    function _spendAllowance(address provider, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(provider, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(provider, spender, currentAllowance - value, false);
            }
        }
    }

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        if (!tradeEnabled) {
            if (!isExemptFee[from] && !isExemptFee[to]) {
                revert TradeNotYetEnabled();
            }
        }

        if (inSwap || isExemptFee[from]) {
            return _update(from, to, value);
        }
        if (from != pair && isSwapEnabled && totalFeeCollected - totalFeeRedeemed >= minSwap && balanceOf(address(this)) >= minSwap) {
            uint256 swapAmount = minSwap;

            if (isFailsafeLocked && owner() == address(0)) {
                uint256 failsafeAmount = circulatingSupply() * 10 / FEEDENOMINATOR;
                swapAmount = failsafeAmount <= swapAmount ? failsafeAmount : swapAmount;
            }

            autoRedeem(swapAmount);
        }

        uint256 newValue = value;

        if (isFeeActive && !isExemptFee[from] && !isExemptFee[to]) {
            newValue = _beforeTokenTransfer(from, to, value);
        }

        if (isWalletLimitActive) {
            _checkWalletLimit(newValue, to);
        }

        _update(from, to, newValue);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal swapping virtual returns (uint256) {
        if (isPairLP[from] && (buyFee.marketing > 0)) {
            return takeBuyFee(from, amount);
        }
        if (isPairLP[to] && (sellFee.marketing > 0)) {
            return takeSellFee(from, amount);
        }
        if (!isPairLP[from] && !isPairLP[to] && (transferFee.marketing > 0)) {
            return takeTransferFee(from, amount);
        }
        return amount;
    }

    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }
}