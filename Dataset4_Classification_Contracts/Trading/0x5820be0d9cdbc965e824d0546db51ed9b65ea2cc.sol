/*
  ______ ______ ______ 
 |____  |____  |____  |
     / /    / /    / / 
    / /    / /    / /  
   / /    / /    / /   
  /_/    /_/    /_/    

 https://777eth.fun

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

library Address {
    function sendValue(address payable recipient, uint256 amount) internal returns(bool){
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        return success; // always proceeds
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mintOnce(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

contract eth777 is ERC20, Ownable, ReentrancyGuard {
    using Address for address payable;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (uint256 => address) public holderTickets;
    mapping (address => uint256) public wins;
    mapping (address => uint256) public claimTime;

    uint256 public  previousTickets;
    uint256 public  totalTickets;

    uint256 public  lastLottery;
    uint256 public  lotteryTime;

    uint256 public  feeOnBuy;
    uint256 public  feeOnSell;

    uint256 public  feeOnTransfer;
    uint256 public  totalWon;

    uint256 public  feeForFeeReceiver;

    address public  feeReceiver;
    uint256 public  SUPPLY_DIVIDER;

    uint256 public  swapTokensAtAmount;
    bool    private swapping;

    bool    public swapEnabled;
    bool    public drawEnabled;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SwapAndSendFee(uint256 tokensSwapped, uint256 bnbSend);
    event SwapTokensAtAmountUpdated(uint256 swapTokensAtAmount);
    event Winners(address one,address two,address three,address four,address five);

    constructor () ERC20("777", "777") 
    {   
        address router;
        address pinkLock;
        
        if (block.chainid == 56) {
            router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // BSC Pancake Mainnet Router
            pinkLock = 0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE; // BSC PinkLock
        } else if (block.chainid == 97) {
            router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // BSC Pancake Testnet Router
            pinkLock = 0x5E5b9bE5fd939c578ABE5800a90C566eeEbA44a5; // BSC Testnet PinkLock
        } else if (block.chainid == 1 || block.chainid == 5) {
            router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // ETH Uniswap Mainnet % Testnet
            pinkLock = 0x71B5759d73262FBb223956913ecF4ecC51057641; // ETH PinkLock
        } else {
            revert();
        }

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair   = _uniswapV2Pair;

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        feeOnBuy  = 25;
        feeOnSell = 25;

        feeOnTransfer = 0;

        SUPPLY_DIVIDER = 1_000; // will result in 0.1%;

        lotteryTime = 15 minutes;

        feeReceiver = 0xc9062d545c23933C5173B351146b5F7e49C38c65;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(0xdead)] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[pinkLock] = true;

        maxWalletLimitEnabled = true;

        _isExcludedFromMaxWalletLimit[owner()] = true;
        _isExcludedFromMaxWalletLimit[address(this)] = true;
        _isExcludedFromMaxWalletLimit[address(0xdead)] = true;
        _isExcludedFromMaxWalletLimit[feeReceiver] = true;
        _isExcludedFromMaxWalletLimit[pinkLock] = true;

        _mintOnce(owner(), 777_777 * (10 ** decimals()));
        swapTokensAtAmount = 3_000 * (10 ** decimals());

        maxWalletAmount = totalSupply() * 5 / 1000;

        swapEnabled = false;
    }

    receive() external payable {}

    function claimStuckTokens(address token) external onlyOwner {
        if (token == address(0x0)) {
            payable(msg.sender).sendValue(address(this).balance);
            return;
        }
        
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function drawRandomWinner() internal nonReentrant {
        lastLottery = block.timestamp;
        uint256 newTickets = totalTickets - previousTickets;

        uint256 newWins = address(this).balance - totalWon;
        uint256 winMoney = newWins / 5;

        totalWon += newWins;

        // pseudo random, but due to min buy and claim after 1 hours without sell no issue
        uint256 rand1 = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.prevrandao, block.timestamp, msg.sender, totalTickets))) % (newTickets + 1);
        uint256 rand2 = uint256(keccak256(abi.encodePacked(block.prevrandao, blockhash(block.number - 1), block.timestamp, totalTickets, msg.sender))) % (newTickets + 1);
        uint256 rand3 = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, totalTickets, blockhash(block.number - 1)))) % (newTickets + 1);
        uint256 rand4 = uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, blockhash(block.number - 1), totalTickets, block.prevrandao))) % (newTickets + 1);
        uint256 rand5 = uint256(keccak256(abi.encodePacked(totalTickets, msg.sender, block.prevrandao, block.timestamp, blockhash(block.number - 1)))) % (newTickets + 1);

        address winner1 = holderTickets[previousTickets + rand1];
        address winner2 = holderTickets[previousTickets + rand2];
        address winner3 = holderTickets[previousTickets + rand3];
        address winner4 = holderTickets[previousTickets + rand4];
        address winner5 = holderTickets[previousTickets + rand5];

        previousTickets = totalTickets;

        claimTime[winner1] = block.timestamp + 1 hours;
        wins[winner1] += winMoney;

        claimTime[winner2] = block.timestamp + 1 hours;
        wins[winner2] += winMoney;

        claimTime[winner3] = block.timestamp + 1 hours;
        wins[winner3] += winMoney;

        claimTime[winner4] = block.timestamp + 1 hours;
        wins[winner4] += winMoney;

        claimTime[winner5] = block.timestamp + 1 hours;
        wins[winner5] += winMoney;

        emit Winners(winner1, winner2, winner3, winner4, winner5);
    }

    function claimWins() external nonReentrant payable {
        require(wins[msg.sender] > 0, "You have no wins...");
        require(address(this).balance >= wins[msg.sender], "Not enough balance, try another time");
        require(block.timestamp >= claimTime[msg.sender], "You cannot claim yet.");

        uint256 toSend = wins[msg.sender];
        wins[msg.sender] = 0;
        claimTime[msg.sender] = 0;

        payable(msg.sender).sendValue(toSend);
    }

    function excludeFromFees(address account, bool excluded) external onlyOwner{
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    event UpdateFees(uint256 feeOnBuy, uint256 feeOnSell);

    function updateFees(uint256 _feeOnSell, uint256 _feeOnBuy, uint256 _feeOnTransfer, uint256 _SUPPLY_DIVIDER, uint256 _lotteryTime) external onlyOwner {
        require(_SUPPLY_DIVIDER >= 50, "Must be maximum 2% total supply");
        
        feeOnBuy = _feeOnBuy;
        feeOnSell = _feeOnSell;
        feeOnTransfer = _feeOnTransfer;
        SUPPLY_DIVIDER = _SUPPLY_DIVIDER;
        lotteryTime = _lotteryTime;

        require(feeOnBuy <= 25, "CSLT: Total Fees cannot exceed the maximum");
        require(feeOnSell <= 25, "CSLT: Total Fees cannot exceed the maximum");
        require(feeOnTransfer <= 25, "CSLT: Total Fees cannot exceed the maximum");

        emit UpdateFees(feeOnSell, feeOnBuy);
    }

    event FeeReceiverChanged(address feeReceiver);

    function changeFeeReceiver(address _feeReceiver) external onlyOwner{
        require(_feeReceiver != address(0), "CSLT: Fee receiver cannot be the zero address");
        feeReceiver = _feeReceiver;

        emit FeeReceiverChanged(feeReceiver);
    }
    
    event TradingEnabled(bool tradingEnabled);

    bool public tradingEnabled;

    function enableTrading() external onlyOwner{
        require(!tradingEnabled, "CSLT: Trading already enabled.");
        tradingEnabled = true;
        swapEnabled = true;
        drawEnabled = true;
        lastLottery = block.timestamp;

        emit TradingEnabled(tradingEnabled);
    }

    function _transfer(address from,address to,uint256 amount) internal override {
        require(from != address(0), "CSLT: transfer from the zero address");
        require(to != address(0), "CSLT: transfer to the zero address");
        require(tradingEnabled || _isExcludedFromFees[from] || _isExcludedFromFees[to], "CSLT: Trading not yet enabled!");
       
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

		uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (canSwap &&
            !swapping &&
            to == uniswapV2Pair &&
            !_isExcludedFromFees[from] &&
            swapEnabled
        ) {
            swapping = true;
            
            swapAndSendFee(swapTokensAtAmount);     

            swapping = false;
        }

        if (
            drawEnabled &&
            !swapping &&
            to == uniswapV2Pair &&
            block.timestamp > lastLottery + lotteryTime &&
            address(this).balance > 0
        ) {
            swapping = true;
            
            drawRandomWinner();    

            swapping = false;
        }

        uint256 _totalFees;
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to] || swapping) {
            _totalFees = 0;
        } else if (from == uniswapV2Pair) {
            if (drawEnabled && amount >= (totalSupply() / SUPPLY_DIVIDER)) {
                holderTickets[totalTickets] = to;
                totalTickets++;
            }
            _totalFees = feeOnBuy;
        } else if (to == uniswapV2Pair) {
            _totalFees =  feeOnSell;
            wins[from] = 0;
            claimTime[from] = 0;
        } else {
            _totalFees = feeOnTransfer;
            wins[from] = 0;
            claimTime[from] = 0;
        }

        if (_totalFees > 0) {
            uint256 fees = (amount * _totalFees) / 100;
            amount = amount - fees;
            super._transfer(from, address(this), fees);
        }

        if (maxWalletLimitEnabled) 
        {
            if (!_isExcludedFromMaxWalletLimit[from] && 
                !_isExcludedFromMaxWalletLimit[to] &&
                to != uniswapV2Pair
            ) {
                uint256 balance  = balanceOf(to);
                require(
                    balance + amount <= maxWalletAmount, 
                    "MaxWallet: Recipient exceeds the maxWalletAmount"
                );
            }
        }

        super._transfer(from, to, amount);
    }

    function setSwapTokensAtAmount(uint256 newAmount, bool _swapEnabled, bool _drawEnabled) external onlyOwner{
        require(newAmount > totalSupply() / 1_000_000, "CSLT: SwapTokensAtAmount must be greater than 0.0001% of total supply");
        swapTokensAtAmount = newAmount;
        swapEnabled = _swapEnabled;
        drawEnabled = _drawEnabled;

        emit SwapTokensAtAmountUpdated(swapTokensAtAmount);
    }

    function swapAndSendFee(uint256 tokenAmount) private {
        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        try uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        ) {} catch {
            return;
        }

        uint256 newBalance = address(this).balance - initialBalance;
        uint256 tFee = (feeOnBuy + feeOnSell);
        uint256 forFeeReceiver = newBalance * (tFee) / (tFee + 2);

        if (forFeeReceiver > 0) {
            payable(feeReceiver).sendValue(forFeeReceiver);
        }

        emit SwapAndSendFee(tokenAmount, newBalance);
    }

    mapping(address => bool) private _isExcludedFromMaxWalletLimit;
    bool    public maxWalletLimitEnabled;
    uint256 public maxWalletAmount;

    event ExcludedFromMaxWalletLimit(address indexed account, bool isExcluded);
    event MaxWalletLimitStateChanged(bool maxWalletLimit);
    event MaxWalletLimitAmountChanged(uint256 maxWalletAmount);

    function setEnableMaxWalletLimit(bool enable) external onlyOwner {
        require(enable != maxWalletLimitEnabled,"Max wallet limit is already set to that state");
        maxWalletLimitEnabled = enable;

        emit MaxWalletLimitStateChanged(maxWalletLimitEnabled);
    }

    function setMaxWalletAmount(uint256 _maxWalletAmount) external onlyOwner {
        require(_maxWalletAmount >= (totalSupply() / (10 ** decimals())) / 100, "Max wallet percentage cannot be lower than 1%");
        maxWalletAmount = _maxWalletAmount * (10 ** decimals());

        emit MaxWalletLimitAmountChanged(maxWalletAmount);
    }

    function excludeFromMaxWallet(address account, bool exclude) external onlyOwner {
        require( _isExcludedFromMaxWalletLimit[account] != exclude,"Account is already set to that state");
        require(account != address(this), "Can't set this address.");

        _isExcludedFromMaxWalletLimit[account] = exclude;

        emit ExcludedFromMaxWalletLimit(account, exclude);
    }

    function isExcludedFromMaxWalletLimit(address account) public view returns(bool) {
        return _isExcludedFromMaxWalletLimit[account];
    }
}