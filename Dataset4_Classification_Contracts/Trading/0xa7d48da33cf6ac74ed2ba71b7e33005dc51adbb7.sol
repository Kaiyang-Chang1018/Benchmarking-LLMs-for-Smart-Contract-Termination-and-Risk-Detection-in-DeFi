// SPDX-License-Identifier: MIT
/*

Create your own AI Chatbots and AI Agents with ease on our website:
https://kanzzai.com

Stay updated with the latest announcements and developments by following us on Twitter:
https://x.com/Kanzz_AI

Join our Telegram community to connect with us and fellow enthusiasts:
https://t.me/KanzzAICommunity

Explore our whitepaper for an in-depth look at KanzzAI's technology and vision:
https://docs.kanzzai.com

Watch our tutorials and updates on KanzzAI's YouTube channel:
https://www.youtube.com/@KanzzAI

Find all our resources in one place on Linktree:
https://linktr.ee/kanzzai

*/

pragma solidity ^0.8.27;

// Context Contract
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

// IERC20 Interface
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

// Ownable Contract
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

    function changeOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }    
    function sub(uint256 a, uint256 b, string memory errorMessage) 
        internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }    
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }    
    function div(uint256 a, uint256 b, string memory errorMessage) 
        internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }    
    function mod(uint256 a, uint256 b, string memory errorMessage) 
        internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// Interfaces for Uniswap
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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
}


contract KAAI is Context, IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "KANZZAI";
    string private constant _symbol = "KAAI";
    uint8 private constant _decimals = 9;

    uint256 private constant _tTotal = 100000000 * 10**9;
    uint256 private _tFeeTotal;

    uint256 private _taxFeeOnBuy = 4;
    uint256 private _taxFeeOnSell = 4;

    uint256 private _taxFee;

    uint256 private _previousTaxFee;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address payable private _feeWallet =
        payable(0xb129a14E8D3162Ba295aB8509e916534FA2Eb54b);

    mapping(address => bool) private _isExcludedFromFee;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private tradingEnabled = false;
    bool private inSwap = false;
    bool private swapEnabled = true;
    bool private autoTaxEnabled = true;
    uint256 private launchBlock;

    uint256 public _maxTransactionAmount = 1000000 * 10**9;
    uint256 public _maxWalletSize = 1000000 * 10**9;
    uint256 public _swapTokensAtTreshold = 1000000 * 10**9;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    event TradingEnabled(uint256 launchBlock);
    event FeesUpdated(uint256 taxFeeOnBuy, uint256 taxFeeOnSell);
    event SwapEnabledUpdated(bool enabled);
    event AutoTaxEnabledUpdated(bool enabled);

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _balances[_msgSender()] = _tTotal;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        ); // Uniswap V2 Router
        uniswapV2Router = _uniswapV2Router;

        // Create a uniswap pair for this token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // Exclude addresses from fees
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_feeWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    // ERC20 standard functions
    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    // Internal functions
    function removeAllFee() private {
        if (_taxFee == 0) return;

        _previousTaxFee = _taxFee;

        _taxFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
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

    // Main transfer function
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from zero address");
        require(to != address(0), "ERC20: transfer to zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (from != owner() && to != owner()) {
            // Trading enabled check
            if (!tradingEnabled) {
                require(from == owner(), "TOKEN: Trading is not enabled yet");
            }

            require(
                amount <= _maxTransactionAmount,
                "TOKEN: Exceeds max transaction limit"
            );

            if (to != uniswapV2Pair) {
                require(
                    _balances[to].add(amount) <= _maxWalletSize,
                    "TOKEN: Exceeds max wallet size"
                );
            }

            uint256 contractTokenBalance = _balances[address(this)];
            bool canSwap = contractTokenBalance >= _swapTokensAtTreshold;

            if (contractTokenBalance >= _maxTransactionAmount) {
                contractTokenBalance = _maxTransactionAmount;
            }

            if (
                canSwap &&
                !inSwap &&
                from != uniswapV2Pair &&
                swapEnabled &&
                !_isExcludedFromFee[from] &&
                !_isExcludedFromFee[to]
            ) {
                swapTokensForEth(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(contractETHBalance);
                }
            }
        }

        bool takeFee = true;

        // Exclude from fee
        if (
            _isExcludedFromFee[from] ||
            _isExcludedFromFee[to] ||
            (from != uniswapV2Pair && to != uniswapV2Pair)
        ) {
            takeFee = false;
        } else {
            // Set Fee for Buys and Sells ( Snipe Protection )
            if (autoTaxEnabled) {
                uint256 blocksSinceLaunch = block.number.sub(launchBlock);
                if (from == uniswapV2Pair) {
                    // Buy
                    if ( blocksSinceLaunch <= 4) {
                        _taxFee = 50;
                    } else if (blocksSinceLaunch > 4 && blocksSinceLaunch <= 20) {
                        _taxFee = 25;
                     } else if (blocksSinceLaunch > 20 && blocksSinceLaunch <= 60) {
                        _taxFee = 10;
                    } else {
                        _taxFee = _taxFeeOnBuy;
                    }
                } else if (to == uniswapV2Pair) {
                    // Sell
                     if ( blocksSinceLaunch <= 4) {
                        _taxFee = 50;
                    } else if (blocksSinceLaunch > 4 && blocksSinceLaunch <= 20) {
                        _taxFee = 25;
                     } else if (blocksSinceLaunch > 20 && blocksSinceLaunch <= 60) {
                        _taxFee = 10;
                    } else {
                        _taxFee = _taxFeeOnSell;
                    }
                }
            } else {
                if (from == uniswapV2Pair) {
                    // Buy
                    _taxFee = _taxFeeOnBuy;
                } else if (to == uniswapV2Pair) {
                    // Sell
                    _taxFee = _taxFeeOnSell;
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    // Swap tokens for ETH
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        // Generate the uniswap pair path of token -> WETH (ETH)
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // Make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // Accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    // Send ETH to fee wallet
    function sendETHToFee(uint256 amount) private {
        _feeWallet.transfer(amount);
    }

    // Enable trading
    function enableTrading() public onlyOwner {
        tradingEnabled = true;
        launchBlock = block.number;
        emit TradingEnabled(launchBlock);
    }

    function isTradingEnabled() public view returns (bool) {
        return tradingEnabled;
    }

    // Manual swap and send functions
    function manualSwap() external {
        require(_msgSender() == _feeWallet, "Not authorized");
        uint256 contractBalance = _balances[address(this)];
        swapTokensForEth(contractBalance);
    }

    function manualSend() external {
        require(_msgSender() == _feeWallet, "Not authorized");
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    // Token transfer function
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();

        uint256 fee = amount.mul(_taxFee).div(100);
        uint256 transferAmount = amount.sub(fee);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(transferAmount);
        _balances[address(this)] = _balances[address(this)].add(fee);

        emit Transfer(sender, recipient, transferAmount);

        if (takeFee) {
            emit Transfer(sender, address(this), fee);
        }

        if (!takeFee) restoreAllFee();
    }

    // Receive ETH from Uniswap
    receive() external payable {}

    // Owner functions to update settings
    function updateFees(uint256 taxFeeOnBuy, uint256 taxFeeOnSell)
        public
        onlyOwner
    {
        _taxFeeOnBuy = taxFeeOnBuy;
        _taxFeeOnSell = taxFeeOnSell;
        emit FeesUpdated(taxFeeOnBuy, taxFeeOnSell);
    }

    function updateSwapTokensThreshold(uint256 swapTokensAtAmount)
        public
        onlyOwner
    {
        _swapTokensAtTreshold = swapTokensAtAmount;
    }

    function setSwapEnabled(bool enabled) public onlyOwner {
        swapEnabled = enabled;
        emit SwapEnabledUpdated(enabled);
    }

    function setAutoTaxEnabled(bool enabled) public onlyOwner {
        autoTaxEnabled = enabled;
        emit AutoTaxEnabledUpdated(enabled);
    }

    function updateMaxTransactionAmount(uint256 maxTxAmount) public onlyOwner {
        _maxTransactionAmount = maxTxAmount;
        emit MaxTxAmountUpdated(maxTxAmount);
    }

    function setMaxWalletSize(uint256 maxWalletSize) public onlyOwner {
        _maxWalletSize = maxWalletSize;
    }

    function setExcludeFromFees(address[] calldata accounts, bool excluded)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }
}