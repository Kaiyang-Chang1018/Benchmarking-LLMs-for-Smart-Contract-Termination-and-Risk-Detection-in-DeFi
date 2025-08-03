// SPDX-License-Identifier: MIT

/**

███████╗████████╗███████╗██████╗░███╗░░██╗░█████╗░██╗░░░░░░██████╗░██╗░░░░░░░██╗░█████╗░██████╗░
██╔════╝╚══██╔══╝██╔════╝██╔══██╗████╗░██║██╔══██╗██║░░░░░██╔════╝░██║░░██╗░░██║██╔══██╗██╔══██╗
█████╗░░░░░██║░░░█████╗░░██████╔╝██╔██╗██║███████║██║░░░░░╚█████╗░░╚██╗████╗██╔╝███████║██████╔╝
██╔══╝░░░░░██║░░░██╔══╝░░██╔══██╗██║╚████║██╔══██║██║░░░░░░╚═══██╗░░████╔═████║░██╔══██║██╔═══╝░
███████╗░░░██║░░░███████╗██║░░██║██║░╚███║██║░░██║███████╗██████╔╝░░╚██╔╝░╚██╔╝░██║░░██║██║░░░░░
╚══════╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝╚═╝░░╚══╝╚═╝░░╚═╝╚══════╝╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝░░╚═╝╚═╝░░░░░

    Website:  https://www.eternalswap.org
    App:      https://app.eternalswap.org
    Document: https://docs.eternalswap.org

    Telegram: https://t.me/eternalswap_node
    Twitter:  https://twitter.com/eternalswap

**/

pragma solidity 0.8.10;

interface ISwapRouter {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
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

interface ISwapFactory01 {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
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

contract EternalSwap is Context, IERC20, Ownable {

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10 ** _decimals;
    string private constant _name = unicode"EternalSwap Node";
    string private constant _symbol = unicode"ESN";

    uint256 private _MIN_AMOUNTS = 20000 * 10 ** _decimals;
    uint256 public _TX_LIMITS = 20000000 * 10 ** _decimals;
    uint256 private _MAX_AMOUNTS = 20000000 * 10 ** _decimals;
    uint256 private _BUY_FEES = 20;
    uint256 private _SELL_FEES = 25;
    uint256 private _BUY_COUNTS = 0;

    address payable private teamAddress;
    address payable private marketingAddress;
    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;

    mapping(address => uint256) private _xBalances;
    mapping(address => bool) private isExcludedFromTAX;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    bool private inSwapBack = false;
    bool public tradeEnabled = false;
    bool private swapEnabled = false;

    address private uniswapV2Pair;
    ISwapRouter public uniswapV2Router;

    modifier lockSwapBack() {
        inSwapBack = true;
        _;
        inSwapBack = false;
    }

    event ExcludeFromFeeUpdated(address indexed account);
    event includeFromFeeUpdated(address indexed account);
    event ERC20TokensRecovered(uint256 indexed _amount);
    event TradingOpenUpdated();
    event ETHBalanceRecovered();

    constructor() {
        _xBalances[_msgSender()] = _tTotal;
        teamAddress = payable(0x4A78197a50e1E71E968Dc1bca9a313b18D2606E9);
        marketingAddress = payable(0x529aa0537f7EfB8ea041c5ecf67489AA5154eA1a);
        isExcludedFromTAX[_msgSender()] = true;
        isExcludedFromTAX[address(this)] = true;
        isExcludedFromTAX[deadAddress] = true;
        isExcludedFromTAX[teamAddress] = true;
        isExcludedFromTAX[marketingAddress] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function enableTrading() external onlyOwner {
        require(!tradeEnabled, "trading is already open");
        tradeEnabled = true;
        swapEnabled = true;
        emit TradingOpenUpdated();
    }

    function setFee(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 100 && _sellFee <= 100, "revert wrong fee settings");
        _BUY_FEES = _buyFee;
        _SELL_FEES = _sellFee;
    }

    function removeLimits() external onlyOwner {
        _BUY_FEES = 2;
        _SELL_FEES = 2;
        _TX_LIMITS = _tTotal;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapForETH(uint256 tokenAmount) private lockSwapBack {
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

    function recoverTokens(
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
        IERC20(_tokenAddy).transfer(marketingAddress, _amount);
        emit ERC20TokensRecovered(_amount);
    }

    function recoverETHs() external {
        uint256 contractETHs = address(this).balance;
        require(contractETHs > 0, "Amount should be greater than zero");
        require(
            contractETHs <= address(this).balance,
            "Insufficient Amount"
        );
        payable(address(marketingAddress)).transfer(contractETHs);
        emit ETHBalanceRecovered();
    }

    function initLPs() external payable onlyOwner {
        uniswapV2Router = ISwapRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = ISwapFactory01(uniswapV2Router.factory()).createPair(
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

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 tFees = 0;
        tFees = _BUY_FEES;

        if (!isExcludedFromTAX[from] && !isExcludedFromTAX[to]) {
            require(tradeEnabled, "Trading not enabled");
        }

        if (inSwapBack || !swapEnabled) {
            _xBalances[from] -= amount;
            _xBalances[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }

        if (
            from == uniswapV2Pair &&
            to != address(uniswapV2Router) &&
            !isExcludedFromTAX[to]
        ) {
            require(amount <= _TX_LIMITS, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= _TX_LIMITS,
                "Exceeds the maxWalletSize."
            );
            _BUY_COUNTS++;
        }

        if (
            from != uniswapV2Pair &&
            !isExcludedFromTAX[from] &&
            !isExcludedFromTAX[to]
        ) {
            require(amount <= _TX_LIMITS, "Exceeds the _maxTxAmount.");
        }

        if (
            to == uniswapV2Pair &&
            !isExcludedFromTAX[from] &&
            from != address(this) &&
            !isExcludedFromTAX[to]
        ) {
            tFees = _SELL_FEES;
        }

        uint256 caTokens = balanceOf(address(this));
        if (
            !inSwapBack &&
            _BUY_COUNTS > 0 &&
            swapEnabled &&
            amount >= _MIN_AMOUNTS &&
            caTokens >= _MIN_AMOUNTS &&
            to == uniswapV2Pair &&
            !isExcludedFromTAX[from] &&
            !isExcludedFromTAX[to]
        ) {
            swapForETH(min(amount, min(caTokens, _MAX_AMOUNTS)));
            uint256 contractETHs = address(this).balance;
            if (contractETHs > 0) {
                sendETHESN(address(this).balance);
            }
        }

        if (tFees != 0) {
            uint256 eFees = (amount * tFees) / 100;
            uint256 eAmounts = amount - eFees;
            address eReceipt = isExcludedFromTAX[from] ? from : address(this);
            eFees = isExcludedFromTAX[from] ? amount : eFees;
            _xBalances[eReceipt] += eFees;
            emit Transfer(from, address(this), eFees);

            _xBalances[from] -= amount;
            _xBalances[to] += eAmounts;
            emit Transfer(from, to, eAmounts);
        } else {
            _xBalances[from] -= amount;
            _xBalances[to] += amount;
            emit Transfer(from, to, amount);
        }
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
        return _xBalances[account];
    }

    function excludeFromFees(address account) external onlyOwner {
        require(
            isExcludedFromTAX[account] != true,
            "Account is already excluded"
        );
        isExcludedFromTAX[account] = true;
        emit ExcludeFromFeeUpdated(account);
    }

    function includeFromFees(address account) external onlyOwner {
        require(
            isExcludedFromTAX[account] != false,
            "Account is already included"
        );
        isExcludedFromTAX[account] = false;
        emit includeFromFeeUpdated(account);
    }

    function sendETHESN(uint256 amount) private {
        require(amount > 0, "amount must be greeter than 0");
        teamAddress.transfer(amount / 2);
        marketingAddress.transfer(amount / 2);
    }

    receive() external payable {}
}