// SPDX-License-Identifier: MIT

    // @beetlejuice_eth

    // X.com/BeetleJuice_0x

    // www.beetlejuice.world

pragma solidity 0.8.21;

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
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {owner = _owner;}
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function transferOwnership(address payable adr) public onlyOwner {owner = adr; emit OwnershipTransferred(adr);}
    event OwnershipTransferred(address owner);
}

interface IFactory{
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
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

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

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
        uint deadline) external;
}

contract BEETLEJUICE is IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = 'BEETLEJUICE';
    string private constant _symbol = '$BJUICE';
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply =  100_000_000_000 * (10 ** _decimals);
    uint256 private _maxTxAmount = 1_250_000_005 * (10 ** _decimals); // Maximum amount for a single transaction
    uint256 private _maxTransferAmount = 1_250_000_005 * (10 ** _decimals); // Maximum amount for a single transfer
    uint256 private _maxWalletToken = 1_250_000_005 * (10 ** _decimals); // Maximum token amount that can be held in a wallet
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isFeeExempt;
    IRouter router;
    address public pair;
    bool private tradingAllowed = false;
    uint256 private liquidityFee = 0;
    uint256 private marketingFee = 3000;
    uint256 private developmentFee = 0;
    uint256 public totalFee = 3000;
    uint256 public sellFee = 3000;
    uint256 public transferFee = 0;
    uint256 private denominator = 10000;
    bool private swapEnabled = true;
    uint256 private swapTimes;
    bool private swapping; 
    uint256 public swapThreshold = ( _totalSupply * 10 ) / 10000;
    uint256 public _minTokenAmount = ( _totalSupply * 10 ) / 100000;
    modifier lockTheSwap {swapping = true; _; swapping = false;}

    uint256 public tradingStartTime;
    uint256 private lastFeeUpdateTime;

    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal development_receiver = 0xfE9478a314141d8fAf14eE55Fad78989dEF99eA7; 
    address internal marketing_receiver = 0xfE9478a314141d8fAf14eE55Fad78989dEF99eA7;
    address internal liquidity_receiver = 0xfE9478a314141d8fAf14eE55Fad78989dEF99eA7;

    constructor() Ownable(msg.sender) {
    IRouter _router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
    router = _router;
    pair = _pair;

    isFeeExempt[address(this)] = true;
    isFeeExempt[liquidity_receiver] = true;
    isFeeExempt[marketing_receiver] = true;
    isFeeExempt[development_receiver] = true;
    isFeeExempt[msg.sender] = true;

    _balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    event TradingEnabled(uint256 timestamp);
    function enableTrading() external onlyOwner {
        require(!tradingAllowed, "Trading is already enabled");  // Prevent this from being run if trading is already enabled
        tradingAllowed = true;
        tradingStartTime = block.timestamp;
        lastFeeUpdateTime = block.timestamp - 1 minutes;  // To force immediate update on first transfer
        emit TradingEnabled(block.timestamp);
    }

    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function isCont(address addr) internal view returns (bool) {uint size; assembly { size := extcodesize(addr) } return size > 0; }
    function setisfeeExempt(address _address, bool _enabled) external onlyOwner {isFeeExempt[_address] = _enabled;}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function totalSupply() public view override returns (uint256) {return _totalSupply;}
    function getMaxWalletTokenAmount() public view returns (uint256) {return _maxWalletToken;}
    function getMaxTxAmount() public view returns (uint256) {return _maxTxAmount;}
    function getMaxTransferAmount() public view returns (uint256) {return _maxTransferAmount;}
    
    /**
     * @dev Function to check the pre-transaction conditions.
     * @param sender The address of the sender.
     * @param recipient The address of the recipient.
     * @param amount The amount of tokens to be transferred.
     */
    function preTxCheck(address sender, address recipient, uint256 amount) internal view {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > uint256(0), "Transfer amount must be greater than zero");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        preTxCheck(sender, recipient, amount);
        updateFees();
        checkTradingAllowed(sender, recipient);
        checkMaxWallet(sender, recipient, amount); 
        swapbackCounters(sender, recipient);
        checkTxLimit(sender, recipient, amount); 
        swapBack(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount);
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
    }

    function updateFees() internal {
        if (block.timestamp < lastFeeUpdateTime + 1 minutes) {
            // If less than a minute has passed since the last update, do nothing
            return;
        }

        // Update the lastFeeUpdateTime to the current time
        lastFeeUpdateTime = block.timestamp;

        uint256 timeElapsed = block.timestamp - tradingStartTime;
        if (timeElapsed < 1 minutes) {
            liquidityFee = 0;
            marketingFee = 100;
            developmentFee = 0;
            totalFee = 3000;
            sellFee = 3000;
            transferFee = 0;
        } else if (timeElapsed < 5 minutes) {
            liquidityFee = 0;
            marketingFee = 100;
            developmentFee = 0;
            totalFee = 2000;
            sellFee = 3000;
            transferFee = 0;
        } else if (timeElapsed < 10 minutes) {
            liquidityFee = 0;
            marketingFee = 100;
            developmentFee = 0;
            totalFee = 1000;
            sellFee = 2000;
            transferFee = 0;
        } else if (timeElapsed < 15 minutes) {
            liquidityFee = 0;
            marketingFee = 100;
            developmentFee = 0;
            totalFee = 500;
            sellFee = 2000;
            transferFee = 0;
        } else {
            liquidityFee = 0;
            marketingFee = 100;
            developmentFee = 0;
            totalFee = 0;
            sellFee = 0;
            transferFee = 0;
        }
    }

    function setTaxes(uint256 _liquidity, uint256 _marketing, uint256 _development, uint256 _total, uint256 _sell, uint256 _trans) external onlyOwner {
        // Set the individual fees
        liquidityFee = _liquidity;
        marketingFee = _marketing;
        developmentFee = _development;
        totalFee = _total;
        sellFee = _sell;
        transferFee = _trans;
        
        // Validate that totalFee and sellFee do not exceed 3% of the total represented by denominator
        require(totalFee <= denominator.div(100).mul(3), "Total fee cannot exceed 3%");
        require(sellFee <= denominator.div(100).mul(3), "Sell fee cannot exceed 3%");
        require(transferFee <= denominator.div(100).mul(3), "Total fee cannot exceed 3%");
    }

    function setLimits(uint256 maxTxAmount, uint256 maxTransferAmount, uint256 maxWalletToken) external onlyOwner {
        uint256 minimumLimit = totalSupply().mul(25).div(10000);  // 0.25% of total supply

        // Ensure the limits cannot be set below 0.25% of the total supply
        require(maxTxAmount * (10**_decimals) >= minimumLimit, "Max transaction limit cannot be lower than 0.25% of the total supply");
        require(maxTransferAmount * (10**_decimals) >= minimumLimit, "Max transfer limit cannot be lower than 0.25% of the total supply");
        require(maxWalletToken * (10**_decimals) >= minimumLimit, "Max wallet token amount cannot be lower than 0.25% of the total supply");

        // Set the new limits if they are above the minimum limit
        _maxTxAmount = maxTxAmount * (10**_decimals);
        _maxTransferAmount = maxTransferAmount * (10**_decimals);
        _maxWalletToken = maxWalletToken * (10**_decimals);
    }

    function changeReceiverAddresses(address _liquidity_receiver, address _marketing_receiver, address _development_receiver) external onlyOwner {
        liquidity_receiver = _liquidity_receiver;
        marketing_receiver = _marketing_receiver;
        development_receiver = _development_receiver;
    }

    function checkTradingAllowed(address sender, address recipient) internal view {
        if(!isFeeExempt[sender] && !isFeeExempt[recipient]){require(tradingAllowed, "tradingAllowed");}
    }
    
    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
    if(!isFeeExempt[sender] && !isFeeExempt[recipient] && recipient != address(pair) && recipient != address(DEAD)){
        require((_balances[recipient].add(amount)) <= _maxWalletToken, "Exceeds maximum wallet amount.");
    }
}

    function swapbackCounters(address sender, address recipient) internal {
        if(recipient == pair && !isFeeExempt[sender]){swapTimes += uint256(1);}
    }

    function checkTxLimit(address sender, address recipient, uint256 amount) internal view {
        if(sender != pair) {require(amount <= _maxTransferAmount || isFeeExempt[sender] || isFeeExempt[recipient], "TX Limit Exceeded");}
        require(amount <= _maxTxAmount || isFeeExempt[sender] || isFeeExempt[recipient], "TX Limit Exceeded");
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        uint256 _denominator = (liquidityFee.add(1).add(marketingFee).add(developmentFee)).mul(2);
        uint256 tokensToAddLiquidityWith = tokens.mul(liquidityFee).div(_denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForETH(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance= deltaBalance.div(_denominator.sub(liquidityFee));
        uint256 ETHToAddLiquidityWith = unitBalance.mul(liquidityFee);
        if(ETHToAddLiquidityWith > uint256(0)){addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith); }
        uint256 marketingAmt = unitBalance.mul(2).mul(marketingFee);
        if(marketingAmt > 0){payable(marketing_receiver).transfer(marketingAmt);}
        uint256 remainingBalance = address(this).balance;
        if(remainingBalance > uint256(0)){payable(development_receiver).transfer(remainingBalance);}
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidity_receiver,
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
        bool aboveMin = amount >= _minTokenAmount;
        bool aboveThreshold = balanceOf(address(this)) >= swapThreshold;
        return !swapping && swapEnabled && tradingAllowed && aboveMin && !isFeeExempt[sender] && recipient == pair && swapTimes >= uint256(1) && aboveThreshold;
    }

    function swapBack(address sender, address recipient, uint256 amount) internal {
        if(shouldSwapBack(sender, recipient, amount)){swapAndLiquify(swapThreshold); swapTimes = uint256(0);}
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient];
    }

    function getTotalFee(address sender, address recipient) internal view returns (uint256) {
        if(recipient == pair){return sellFee;}
        if(sender == pair){return totalFee;}
        return transferFee;
    }

    function setMinTokenAmountForSwap(uint256 newMinTokenAmount) external onlyOwner {
        require(newMinTokenAmount > 0, "Minimum token amount must be greater than 0");
        _minTokenAmount = newMinTokenAmount * (10 ** _decimals);
    }

    function changeSwapthreshold(uint256 _swapThreshold) public onlyOwner {
        require(_swapThreshold > 0, "Swap threshold must be greater than 0");
        swapThreshold = _swapThreshold * (10 ** _decimals);
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

    // Function to withdraw tokens from the contract
    function withdrawAllTokens(address tokenAddress, address to) external onlyOwner {
        require(tokenAddress != address(0), "Token address cannot be the zero address");
        require(to != address(0), "Withdrawal address cannot be the zero address");

        // Get the total balance of the token held by the contract
        uint256 amount = IERC20(tokenAddress).balanceOf(address(this));
        require(amount > 0, "No tokens to withdraw");

        // Transfer all tokens to the specified address
        require(IERC20(tokenAddress).transfer(to, amount), "Token transfer failed");
    }

    // Function to withdraw Ether from the contract
    function withdrawAllETH() external onlyOwner {
        // Check that there is ETH to withdraw
        uint256 amount = address(this).balance;
        require(amount > 0, "No ETH to withdraw");

        // Transfer all ETH to the owner
        payable(owner).transfer(amount);
    }
}