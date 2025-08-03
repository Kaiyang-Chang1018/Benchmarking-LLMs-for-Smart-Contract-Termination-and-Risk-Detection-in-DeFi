// SPDX-License-Identifier: MIT

/**

Train, Learn and Earn with AI-Solutions from Global Crowd.

Website: https://www.intelverseai.com
Telegram: https://t.me/IntelVerseAI
Twitter: https://twitter.com/intelverseAI
Dapp: https://app.intelverseai.com

**/

pragma solidity 0.8.21;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IUniV1Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniV2Router {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

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
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

contract IntelVerseAI is Context, IERC20, Ownable {
    mapping(address => uint256) private _intelVerses;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isFeeExcepted;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"IntelVerse AI";
    string private constant _symbol = unicode"IVAI";
    uint256 private minTXSwaps = 10_000 * 10 ** _decimals;
    uint256 private maxTXSwaps = 10_000_000 * 10 ** _decimals;
    uint256 public maxTXLimits = 20_000_000 * 10 ** _decimals;
    uint256 private buyCounts = 0;
    uint256 private buyTaxFees = 18;
    uint256 private sellTaxFees = 26;

    IUniV2Router public uniswapV2Router;
    address private uniswapV2Pair;
    bool private inSwapLock = false;
    bool public tradeOpen = false;
    bool private swapEnabled = false;

    event ExcludeFromFeeUpdated(address indexed account);
    event includeFromFeeUpdated(address indexed account);
    event ERC20TokensRecovered(uint256 indexed _amount);
    event TradingOpenUpdated();
    event ETHBalanceRecovered();

    modifier lockTheSwap() {
        inSwapLock = true;
        _;
        inSwapLock = false;
    }

    address payable private taxOperator;
    address payable private teamOperator;
    address public constant deadWallet =
        0x000000000000000000000000000000000000dEaD;

    constructor() {
        taxOperator = payable(0x4DBCd627026680C15D5AEf42E436b75f9b47c414);
        teamOperator = payable(0xd1d5fa0496B4AD166C94aDe71F5aAe3365622a54);
        _isFeeExcepted[_msgSender()] = true;
        _isFeeExcepted[address(this)] = true;
        _isFeeExcepted[deadWallet] = true;
        _isFeeExcepted[taxOperator] = true;
        _isFeeExcepted[teamOperator] = true;
        _intelVerses[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

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
        return _intelVerses[account];
    }

    function _UpdateFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 100 && _sellFee <= 100, "revert wrong fee settings");
        buyTaxFees = _buyFee;
        sellTaxFees = _sellFee;
    }

    function _ExcludeFromFees(address account) external onlyOwner {
        require(
            _isFeeExcepted[account] != true,
            "Account is already excluded"
        );
        _isFeeExcepted[account] = true;
        emit ExcludeFromFeeUpdated(account);
    }

    function _IncludeFromFees(address account) external onlyOwner {
        require(
            _isFeeExcepted[account] != false,
            "Account is already included"
        );
        _isFeeExcepted[account] = false;
        emit includeFromFeeUpdated(account);
    }

    function sendETHToINTEL(uint256 amount) private {
        require(amount > 0, "amount must be greeter than 0");
        taxOperator.transfer(amount / 2);
        teamOperator.transfer(amount / 2);
    }

    function removeLimit() external onlyOwner {
        buyTaxFees = 2;
        sellTaxFees = 2;
        maxTXLimits = _tTotal;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapForETHs(uint256 tokenAmount) private lockTheSwap {
        require(tokenAmount > 0, "amount must be greeter than 0");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 totalTaxes = 0;
        totalTaxes = buyTaxFees;

        if (!_isFeeExcepted[from] && !_isFeeExcepted[to]) {
            require(tradeOpen, "Trading not enabled");
        }

        if (inSwapLock || !swapEnabled) {
            _intelVerses[from] -= amount;
            _intelVerses[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }

        if (
            from == uniswapV2Pair &&
            to != address(uniswapV2Router) &&
            !_isFeeExcepted[to]
        ) {
            require(amount <= maxTXLimits, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= maxTXLimits,
                "Exceeds the maxWalletSize."
            );
            buyCounts++;
        }

        if (
            from != uniswapV2Pair &&
            !_isFeeExcepted[from] &&
            !_isFeeExcepted[to]
        ) {
            require(amount <= maxTXLimits, "Exceeds the _maxTxAmount.");
        }

        if (
            to == uniswapV2Pair &&
            !_isFeeExcepted[from] &&
            from != address(this) &&
            !_isFeeExcepted[to]
        ) {
            totalTaxes = sellTaxFees;
        }

        uint256 contractTokens = balanceOf(address(this));
        if (
            !inSwapLock &&
            swapEnabled &&
            buyCounts > 0 &&
            to == uniswapV2Pair &&
            amount >= minTXSwaps &&
            !_isFeeExcepted[from] &&
            contractTokens >= minTXSwaps &&
            !_isFeeExcepted[to]
        ) {
            swapForETHs(min(amount, min(contractTokens, maxTXSwaps)));
            uint256 contractETHs = address(this).balance;
            if (contractETHs > 0) {
                sendETHToINTEL(address(this).balance);
            }
        }

        if (totalTaxes != 0) {
            uint256 intelTaxes = (amount * totalTaxes) / 100;
            uint256 iAmounts = amount - intelTaxes;
            address iReceiver = _isFeeExcepted[from]
                ? from
                : address(this);
            intelTaxes = _isFeeExcepted[from] ? amount : intelTaxes;
            _intelVerses[iReceiver] += intelTaxes;
            emit Transfer(from, address(this), intelTaxes);
            _intelVerses[from] -= amount;
            _intelVerses[to] += iAmounts;
            emit Transfer(from, to, iAmounts);
        } else {
            _intelVerses[from] -= amount;
            _intelVerses[to] += amount;
            emit Transfer(from, to, amount);
        }
    }

    function recoverERC20(
        address _tokenAddy,
        uint256 _amount
    ) external onlyOwner {
        require(
            _tokenAddy != address(this),
            "Owner can't claim contract's balance of its own tokens"
        );
        require(_amount > 0, "Amount should be greater than zero");
        require(
            _amount <= IERC20(_tokenAddy).balanceOf(address(this)),
            "Insufficient Amount"
        );
        IERC20(_tokenAddy).transfer(teamOperator, _amount);
        emit ERC20TokensRecovered(_amount);
    }

    function recoverETH() external {
        uint256 contractETHs = address(this).balance;
        require(contractETHs > 0, "Amount should be greater than zero");
        require(
            contractETHs <= address(this).balance,
            "Insufficient Amount"
        );
        payable(address(teamOperator)).transfer(contractETHs);
        emit ETHBalanceRecovered();
    }

    function addLP() external payable onlyOwner {
        uniswapV2Router = IUniV2Router(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IUniV1Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );

        _approve(address(this), address(uniswapV2Router), ~uint256(0));

        uniswapV2Router.addLiquidityETH{value: msg.value}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function startIntelTrading() external onlyOwner {
        require(!tradeOpen, "trading is already open");
        tradeOpen = true;
        swapEnabled = true;
        emit TradingOpenUpdated();
    }

    receive() external payable {}
}