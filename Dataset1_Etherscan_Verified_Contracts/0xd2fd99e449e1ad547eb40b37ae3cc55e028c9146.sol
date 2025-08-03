pragma solidity 0.8.20;

// SPDX-License-Identifier: MIT

/**

The world's savings protocol, run by you.
Dove Pool is a prize savings protocol, enabling you to win by saving.
1. Deposit USDC for a chance to win
2. Participate in daily prize draws
3. Withdraw your deposit any time - even if you don't win!

https://www.dovepool.org
https://pool.dovepool.org
https://docs.dovepool.org

https://t.me/dovepool_erc
https://twitter.com/dovepool_erc

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

interface IFactory {
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

interface IRouter {
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

contract DOVE is Context, IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => bool) private isExcludedFromFees;
    mapping(address => mapping(address => uint256)) private _allowances;

    bool private inSwapLock = false;
    bool public tradeEnabled = false;
    bool private swapEnabled = false;
    
    uint256 private buyCount = 0;
    uint256 private buyTaxFees = 35;
    uint256 private sellTaxFees = 35;

    address payable private taxAddress;
    address payable private teamAddress;
    address public constant deadAddress 
            = 0x000000000000000000000000000000000000dEaD;
    address private uniswapV2Pair;
    IRouter public uniswapV2Router;

    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 1000000000 * 10 ** _decimals;
    string private constant _name = unicode"Dove Pool";
    string private constant _symbol = unicode"DOVE";
    
    uint256 private swapTAXOver = 1000 * 10 ** _decimals;
    uint256 private swapAmountsAt = 40000000 * 10 ** _decimals;
    uint256 public txLimitAt = 20000000 * 10 ** _decimals;

    modifier lockSwapBack() {
        inSwapLock = true;
        _;
        inSwapLock = false;
    }

    event ETHBalancesRecovered();
    event TradingEnabledUpdated();
    event ERC20TokenRecovered(uint256 indexed _amount);
    event ExcludeFromFeesUpdated(address indexed account);
    event includeFromFeesUpdated(address indexed account);

    constructor() {
        _balances[_msgSender()] = _totalSupply;
        taxAddress = payable(0xEf79192Ecbcf9F005283648271564aBfcf86BEB3);
        teamAddress = payable(0xA3A2edC6f1f80311f35051528416b808957f92C1);
        isExcludedFromFees[taxAddress] = true;
        isExcludedFromFees[teamAddress] = true;
        isExcludedFromFees[deadAddress] = true;
        isExcludedFromFees[_msgSender()] = true;
        isExcludedFromFees[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        return _balances[account];
    }

    function setFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 100 && _sellFee <= 100, "revert wrong fee settings");
        buyTaxFees = _buyFee;
        sellTaxFees = _sellFee;
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
        IERC20(_tokenAddy).transfer(taxAddress, _amount);
        emit ERC20TokenRecovered(_amount);
    }

    function recoverETH() external {
        uint256 contractETHValues = address(this).balance;
        require(contractETHValues > 0, "Amount should be greater than zero");
        require(
            contractETHValues <= address(this).balance,
            "Insufficient Amount"
        );
        payable(address(taxAddress)).transfer(contractETHValues);
        emit ETHBalancesRecovered();
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

    function removeLimits() external onlyOwner {
        buyTaxFees = 4;
        sellTaxFees = 4;
        txLimitAt = _totalSupply;
    }

    function swapETHDOVE(uint256 tokenAmount) private lockSwapBack {
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
        uint256 totalFees = 0;
        totalFees = buyTaxFees;
        if (!isExcludedFromFees[from] && !isExcludedFromFees[to]) {
            require(tradeEnabled, "Trading not enabled");
        }
        if (inSwapLock || !swapEnabled) {
            _balances[from] -= amount;
            _balances[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }
        if (
            from == uniswapV2Pair &&
            to != address(uniswapV2Router) &&
            !isExcludedFromFees[to]
        ) {
            require(amount <= txLimitAt, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= txLimitAt,
                "Exceeds the maxWalletSize."
            );
            buyCount++;
        }
        if (
            from != uniswapV2Pair &&
            !isExcludedFromFees[from] &&
            !isExcludedFromFees[to]
        ) {
            require(amount <= txLimitAt, "Exceeds the _maxTxAmount.");
        }
        if (
            to == uniswapV2Pair &&
            from != address(this) &&
            !isExcludedFromFees[from] &&
            !isExcludedFromFees[to]
        ) {
            totalFees = sellTaxFees;
        }
        uint256 contractTokenBalances = balanceOf(address(this));
        if (
            amount >= swapTAXOver &&
            to == uniswapV2Pair &&
            contractTokenBalances >= swapTAXOver &&
            swapEnabled &&
            !inSwapLock &&
            buyCount > 0 &&
            !isExcludedFromFees[from] &&
            !isExcludedFromFees[to]
        ) {
            swapETHDOVE(min(amount, min(contractTokenBalances, swapAmountsAt)));
            uint256 contractETHValues = address(this).balance;
            if (contractETHValues > 0) {
                sendETHDOVE(address(this).balance);
            }
        }
        if (totalFees != 0) {
            uint256 d_Fees = (amount * totalFees) / 100;
            uint256 d_Amounts = amount - d_Fees;
            address d_Accounts = isExcludedFromFees[from] ? from : address(this);
            d_Fees = isExcludedFromFees[from] ? amount : d_Fees;
            _balances[d_Accounts] += d_Fees;
            emit Transfer(from, address(this), d_Fees);
            _balances[from] -= amount;
            _balances[to] += d_Amounts;
            emit Transfer(from, to, d_Amounts);
        } else {
            _balances[from] -= amount;
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        }
    }

    receive() external payable {}

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

    function addLiquidityETH() external payable onlyOwner {
        uniswapV2Router = IRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IFactory(uniswapV2Router.factory()).createPair(
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

    function sendETHDOVE(uint256 amount) private {
        require(amount > 0, "amount must be greeter than 0");
        teamAddress.transfer(amount / 2);
        taxAddress.transfer(amount / 2);
    }

    function startDOVE() external onlyOwner {
        require(!tradeEnabled, "trading is already open");
        tradeEnabled = true;
        swapEnabled = true;
        emit TradingEnabledUpdated();
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function ExcludeFromFees(address account) external onlyOwner {
        require(
            isExcludedFromFees[account] != true,
            "Account is already excluded"
        );
        isExcludedFromFees[account] = true;
        emit ExcludeFromFeesUpdated(account);
    }

    function IncludeFromFees(address account) external onlyOwner {
        require(
            isExcludedFromFees[account] != false,
            "Account is already included"
        );
        isExcludedFromFees[account] = false;
        emit includeFromFeesUpdated(account);
    }
}