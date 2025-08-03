// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: Esportplayer/Esportplayer.sol


pragma solidity ^0.8.24;




/*
    Company: Esportplayer
    Based: Norway
    Total initial supply: 1,000,000,000 PLAYER
    Token name: Esportplayer
    Token Symbol: PLAYER

    Contract created for the Esportplayer platform. The PLAYER token will be used throughout the platform and can be earned through different activities. 
    To read more about how this token will be used, go to https://www.esportplayer.tv/token

    Website - https://www.esportplayer.tv
    Telegram - https://t.me/+GjAqrIrVQ25lZTE0
    Twitter - https://x.com/esportplayertv

*/
 
interface ERC20Interface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
 
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

abstract contract Ownable is Context {
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

    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
 
contract Esportplayer is ERC20Interface, Ownable, ReentrancyGuard, Pausable  {

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;
    mapping(address => bool) public _isExcludedFromFee;
    mapping(address => bool) public _isExcludedFromCooldown; // For exclduing cooldown
    mapping(address => uint256) private _lastTransferTimestamp;

    string public constant SYMBOL = "PLAYER";
    string public constant NAME = "Esportplayer";
    uint256 public constant DECIMALS = 18;
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000_000_000_000_000_000_000;
    address payable public FEE_WALLET = payable(0x836B60e5dAF2F158Bd08380260f1175A8f8D8700);
    address payable public REVENUE_SHARE_WALLET = payable(0x78230211adaCA550Ee47e9020586F92085B6d4f7);
    address payable public MARKETING_WALLET = payable(0xEf5a214084a04D050CDA8026880089f0eC406683);
    address payable public LIQUIDITY_WALLET = payable(0x37744Ac4329B0eF07AEe2A03676d8dDC71BcD4B6);

    address public contract_address;

    uint256 public transferCooldown = 0; // Cooldown in seconds
    uint256 public walletLimit = 10000000 * 10 ** DECIMALS;
    uint256 public taxSwapThreshold= 100000 * 10 ** DECIMALS;
    uint256 public maxTxAmount = 10000000 * 10 ** DECIMALS; 
    bool public tradingOpen = false;

    uint256 private constant MAXIMUM_ALLOWED_FEE = 5;
    uint256 public FEE_ON_BUY = 5;
    uint256 public FEE_ON_SELL = 5; 
    uint256 public FEE_ON_TRANSFER = 5; 

    event TransferCooldownUpdated(address indexed from, uint256 newTimestamp);
    event TaxFeesUpdated(uint256 _newBuyFee, uint256 _newSellFee, uint256 _newTransferFee, uint256 newTimestamp);
    event ExclusionListUpdated(address _address, uint256 newTimestamp);
    event CooldownExclusionListUpdated(address indexed _address, bool isExcluded, uint256 timestamp);
    event PauseStatusUpdated(uint256 newTimestamp);
    event WalletLimitUpdated(uint256 _limit, uint256 newTimestamp);
    event CooldownUpdated(uint256 _cd, uint256 newTimestamp);
    event SwapLimitUpdated(uint256 _swapLimit, uint256 newTimestamp);
    event TaxSwapThresholdUpdated(uint256 _newThreshold, uint256 newTimestamp);
    event ETHDistributed(address indexed wallet, uint256 amount);




    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private inSwap = false;
    bool private swapEnabled = true;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
 
    constructor() {
        contract_address = address(this);

        balances[_msgSender()] = TOTAL_SUPPLY;


        // Fee
        _isExcludedFromFee[address(0)] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[contract_address] = true;
        _isExcludedFromFee[FEE_WALLET] = true;
        _isExcludedFromFee[REVENUE_SHARE_WALLET] = true;
        _isExcludedFromFee[MARKETING_WALLET] = true;
        _isExcludedFromFee[LIQUIDITY_WALLET] = true;

        // Cooldown
        _isExcludedFromCooldown[address(0)] = true; 
        _isExcludedFromCooldown[owner()] = true;
        _isExcludedFromCooldown[contract_address] = true;
        _isExcludedFromCooldown[FEE_WALLET] = true;
        _isExcludedFromCooldown[REVENUE_SHARE_WALLET] = true;
        _isExcludedFromCooldown[MARKETING_WALLET] = true;
        _isExcludedFromCooldown[LIQUIDITY_WALLET] = true;

        emit Transfer(address(0), _msgSender(), TOTAL_SUPPLY);

         _pause(); // Pausing initially
    }

     function name() public pure returns (string memory) {
        return NAME;
    }

    function symbol() public pure returns (string memory) {
        return SYMBOL;
    }

    function decimals() public pure returns (uint256) {
        return DECIMALS;
    }
 
    function totalSupply() public pure returns (uint256) {
        return TOTAL_SUPPLY;
    }
 
    function balanceOf(address tokenOwner) public view returns (uint256 balance) {
        return balances[tokenOwner];
    }
 
    function transfer(address receiver, uint256 tokens) public whenNotPausedOrOwner cooldownCheck(receiver) returns (bool success) {
        _transferTokens(_msgSender(), receiver, tokens);
        return true;
    }

    //  @dev Atomically increases the allowance granted to 'spender' by the caller.
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");
        allowed[_msgSender()][spender] += addedValue;
        emit Approval(_msgSender(), spender, allowed[_msgSender()][spender]);
        return true;
    }

    // @dev Atomically decreases the allowance granted to 'spender' by the caller.
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");
        require(allowed[_msgSender()][spender] >= subtractedValue, "ERC20: decreased allowance below zero");
        allowed[_msgSender()][spender] -= subtractedValue;
        emit Approval(_msgSender(), spender, allowed[_msgSender()][spender]);
        return true;
    }
 
      function approve(address spender, uint256 amount) public override returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");
        allowed[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }
 
    function transferFrom(address from, address to, uint256 tokens) public whenNotPausedOrOwner cooldownCheck(to) override returns (bool) {
        uint256 currentAllowance = allowed[from][_msgSender()];
        require(currentAllowance >= tokens, "ERC20: transfer amount exceeds allowance");

        allowed[from][_msgSender()] = currentAllowance - tokens;
        emit Approval(from, _msgSender(), allowed[from][_msgSender()]);

        _transferTokens(from, to, tokens);
        return true;
    }

    // @dev: Transfer tokens and swap fee to eth.
    function _transferTokens(address from, address to, uint256 tokens) private {
        require(tokens > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        // Calculate tax if applicable
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {

            if(to != uniswapV2Pair){
               require(balanceOf(to) + tokens <= walletLimit, "higher than the walletLimit for tokens.");
                require(tokens <= maxTxAmount, "Transfer exceeds the maxTxAmount");
            }
             if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
                taxAmount = (tokens * FEE_ON_BUY) / 100;
            } else if (to == uniswapV2Pair) {
                taxAmount = (tokens * FEE_ON_SELL) / 100;
            } else {
                taxAmount = (tokens * FEE_ON_TRANSFER) / 100;
            }
        }

        balances[from] = balances[from] - tokens;
        balances[to] = balances[to] + (tokens - taxAmount);

        if (taxAmount > 0) {
            balances[contract_address] = balances[contract_address] + taxAmount;
            emit Transfer(from, contract_address, taxAmount);
        }

        if (!inSwap && to == uniswapV2Pair && swapEnabled && balanceOf(contract_address) >= taxSwapThreshold) {
            uint256 swapAmount = balanceOf(address(this));

            swapTokensForEth(swapAmount);
        }

        emit Transfer(from, to, tokens - taxAmount);
    }

    // @dev: Swap tokens from fee to ETH
     function swapTokensForEth(uint256 tokenAmount) private nonReentrant lockTheSwap {
        if(tokenAmount==0){
            return;
        }

        // The contract's balnce now.
        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = contract_address;
        path[1] = uniswapV2Router.WETH();
        
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            contract_address,
            block.timestamp
        );

        // What was sawpped now.
        uint256 swappedETHAmount = address(this).balance - initialBalance;

        // Distrubate eth.
        sendETHToFee(swappedETHAmount);
    }


    function sendETHToFee(uint256 amount) private nonReentrant  {
        uint256 totalFeePercentage = 100; // Total percentage

        // Different distrubution
        uint256 feeWalletPercentage = 40;       // 40% for FEE_WALLET
        uint256 liquidityWalletPercentage = 20; // 20% for LIQUIDITY_WALLET
        uint256 revenueSharePercentage = 20;    // 20% for REVENUE_SHARE_WALLET
        //uint256 marketingPercentage = 20;        20% for MARKETING_WALLET (not necessary since we send the remaining below)

        // Calculations for each of wallets
        uint256 feeWalletAmount = amount * feeWalletPercentage / totalFeePercentage;
        uint256 liquidityWalletAmount = amount * liquidityWalletPercentage / totalFeePercentage;
        uint256 revenueShareAmount = amount * revenueSharePercentage / totalFeePercentage;
        uint256 marketingAmount = amount - feeWalletAmount - liquidityWalletAmount - revenueShareAmount;

        // Transfer -> FEE_WALLET
        (bool feeSuccess, ) = FEE_WALLET.call{value: feeWalletAmount}("");
        require(feeSuccess, "FEE_WALLET transfer failed");
        emit ETHDistributed(FEE_WALLET, feeWalletAmount);


        // Transfer -> LIQUIDITY_WALLET
        (bool liquiditySuccess, ) = LIQUIDITY_WALLET.call{value: liquidityWalletAmount}("");
        require(liquiditySuccess, "LIQUIDITY_WALLET transfer failed");
        emit ETHDistributed(LIQUIDITY_WALLET, liquidityWalletAmount);

        // Transfer -> REVENUE_SHARE_WALLET
        (bool revenueSuccess, ) = REVENUE_SHARE_WALLET.call{value: revenueShareAmount}("");
        require(revenueSuccess, "REVENUE_SHARE_WALLET transfer failed");
        emit ETHDistributed(REVENUE_SHARE_WALLET, revenueShareAmount);

        // Transfer -> MARKETING_WALLET
        (bool marketingSuccess, ) = MARKETING_WALLET.call{value: marketingAmount}("");
        require(marketingSuccess, "MARKETING_WALLET transfer failed");
        emit ETHDistributed(MARKETING_WALLET, marketingAmount);
    }


    function allowance(address tokenOwner, address spender) public view returns (uint256) {
        return allowed[tokenOwner][spender];
    }

    function withdrawETH() external payable nonReentrant onlyOwner {
        uint256 contractBalance = contract_address.balance;
        require(contractBalance > 0, "No ETH to withdraw");

        (bool success, ) = payable(owner()).call{value: contractBalance}("");
        require(success, "Transfer failed");
    }

    function changeWalletLimit(uint256 _limit) external payable onlyOwner {
        require(_limit > totalSupply() / 200,"Limit very low");
        walletLimit = _limit;
        emit WalletLimitUpdated(_limit, block.timestamp);
    }

    // @dev: Change tax fees. Can never be set higher than maximum allowed fee (5%)
    function changeTaxFees(uint256 _newBuyFee, uint256 _newSellFee, uint256 _newTransferFee) external payable onlyOwner {
        FEE_ON_SELL = _newSellFee > MAXIMUM_ALLOWED_FEE ? MAXIMUM_ALLOWED_FEE : _newSellFee;
        FEE_ON_BUY = _newBuyFee > MAXIMUM_ALLOWED_FEE ? MAXIMUM_ALLOWED_FEE : _newBuyFee;
        FEE_ON_TRANSFER = _newTransferFee > MAXIMUM_ALLOWED_FEE ? MAXIMUM_ALLOWED_FEE : _newTransferFee;
        emit TaxFeesUpdated(_newBuyFee, _newSellFee, _newTransferFee, block.timestamp);
    }

    function changeTransferCooldown(uint256 _cd) external payable onlyOwner {
        require(_cd < 60, "Cooldown too high");
        transferCooldown = _cd;
        emit CooldownUpdated(_cd, block.timestamp);
    }

    function addToExclusionList(address _address) external payable onlyOwner {
        _isExcludedFromFee[_address] = true;
        emit ExclusionListUpdated(_address, block.timestamp);
    }

    function removeFromExclusionList(address _address) external payable onlyOwner {
        _isExcludedFromFee[_address] = false;
        emit ExclusionListUpdated(_address, block.timestamp);
    }

    // Cooldown excl list management funcstions.
    function addToCooldownExclusionList(address _address) external onlyOwner {
        _isExcludedFromCooldown[_address] = true;
        emit CooldownExclusionListUpdated(_address, true, block.timestamp);
    }

    function removeFromCooldownExclusionList(address _address) external onlyOwner {
        _isExcludedFromCooldown[_address] = false;
        emit CooldownExclusionListUpdated(_address, false, block.timestamp);
    }

    function changeTaxSwapThreshold(uint256 _newThreshold) external payable onlyOwner {
        taxSwapThreshold = _newThreshold;
        emit TaxSwapThresholdUpdated(_newThreshold, block.timestamp);
    }

    function changeMaxTXAmount(uint256 _newMaxTXAmount) external payable onlyOwner {
        require(_newMaxTXAmount > totalSupply() / 200, "Max TX amount too low");
        maxTxAmount = _newMaxTXAmount;
    }

    function openTrading() external payable nonReentrant onlyOwner {
        require(!tradingOpen,"trading is already open");
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(contract_address, _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        // Do the approval here with max to ensure no manul adding.
        allowed[contract_address][address(uniswapV2Router)] = type(uint256).max;
        emit Approval(contract_address, address(uniswapV2Router), type(uint256).max);

        // remove it from the cooldowns.
        _isExcludedFromCooldown[address(uniswapV2Router)] = true;
        _isExcludedFromCooldown[uniswapV2Pair] = true;

        tradingOpen = true;
    }

    receive() external payable {}

    // @dev: Functionality to pause and unpause in case of emergency
    function pause() external payable onlyOwner {
        _pause();
         emit PauseStatusUpdated(block.timestamp);
    }

    function unpause() external payable onlyOwner {
        _unpause();
        emit PauseStatusUpdated(block.timestamp);
    }
        
    // @dev: Anti bot mechanisms

    modifier cooldownCheck(address to) {
        if (!_isExcludedFromCooldown[to]) {
            require(block.timestamp >= _lastTransferTimestamp[to] + transferCooldown, "Transfer cooldown in effect");
            _lastTransferTimestamp[to] = block.timestamp;
            emit TransferCooldownUpdated(to, block.timestamp);
        }
        _;
    }

    // Paused not to affect the owner to ensure correct config before trading is opened.
    modifier whenNotPausedOrOwner() {
        require(!paused() || _msgSender() == owner(), "Pausable: paused");
        _;
    }
}