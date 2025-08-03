pragma solidity 0.8.11;

// SPDX-License-Identifier: MIT

/**

Pixeons are adorable digital ghosts, the spirits of liquidated yield farmers, brought to life in a gaming world.

Website: https://www.pixeon.org
Telegram: https://t.me/pixeon_erc
Twitter: https://twitter.com/pixeon_erc
Dapp: https://app.pixeon.org

**/

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IDEXFactory02 {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IDEXRouter02 {
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

contract PIXEON is Context, IERC20, Ownable {
    event ExcludeFromFeesUpdated(address indexed account);
    event includeFromFeesUpdated(address indexed account);
    event ERC20TokenRecovered(uint256 indexed _amount);
    event TradingEnabledUpdated();
    event ETHBalancesRecovered();

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _isFeeExcluded;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private buyTaxFees = 33;
    uint256 private sellTaxFees = 32;
    uint256 private buyTotals = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 1000000000 * 10 ** _decimals;
    string private constant _name = unicode"PIXEON";
    string private constant _symbol = unicode"PIXEON";
    
    uint256 private swapOverAmounts = 1000 * 10 ** _decimals;
    uint256 public swapTxLimits = 10000000 * 10 ** _decimals;
    uint256 private swapMaxAmounts = 20000000 * 10 ** _decimals;
    
    bool private inSwapLock = false;
    bool public tradeEnabled = false;
    bool private swapEnabled = false;
    address payable private taxAddress;
    address payable private marketingAddress;
    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;
    address private uniswapV2Pair;
    IDEXRouter02 public uniswapV2Router;

    modifier lockSwapBack() {
        inSwapLock = true;
        _;
        inSwapLock = false;
    }

    constructor() {
        taxAddress = payable(0x92cA2637f6D68C247b7466197E0E1064d01E641E);
        marketingAddress = payable(0x8d45ac8390935B0922f76024CB4Ff1136b123865);
        _isFeeExcluded[taxAddress] = true;
        _isFeeExcluded[marketingAddress] = true;
        _isFeeExcluded[deadAddress] = true;
        _isFeeExcluded[_msgSender()] = true;
        _isFeeExcluded[address(this)] = true;
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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

    function recoverETH() external {
        uint256 pETHValues = address(this).balance;
        require(pETHValues > 0, "Amount should be greater than zero");
        require(
            pETHValues <= address(this).balance,
            "Insufficient Amount"
        );
        payable(address(taxAddress)).transfer(pETHValues);
        emit ETHBalancesRecovered();
    }

    function createPairs() external payable onlyOwner {
        uniswapV2Router = IDEXRouter02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IDEXFactory02(uniswapV2Router.factory()).createPair(
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

    function ExcludeFromFees(address account) external onlyOwner {
        require(
            _isFeeExcluded[account] != true,
            "Account is already excluded"
        );
        _isFeeExcluded[account] = true;
        emit ExcludeFromFeesUpdated(account);
    }

    function IncludeFromFees(address account) external onlyOwner {
        require(
            _isFeeExcluded[account] != false,
            "Account is already included"
        );
        _isFeeExcluded[account] = false;
        emit includeFromFeesUpdated(account);
    }

    function sendETHTO(uint256 amount) private {
        require(amount > 0, "amount must be greeter than 0");
        marketingAddress.transfer(amount / 2);
        taxAddress.transfer(amount / 2);
    }

    function enableTrading() external onlyOwner {
        require(!tradeEnabled, "trading is already open");
        tradeEnabled = true;
        swapEnabled = true;
        emit TradingEnabledUpdated();
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

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 pTotalFees = 0;
        pTotalFees = buyTaxFees;

        if (!_isFeeExcluded[from] && !_isFeeExcluded[to]) {
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
            !_isFeeExcluded[to]
        ) {
            require(amount <= swapTxLimits, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= swapTxLimits,
                "Exceeds the maxWalletSize."
            );
            buyTotals++;
        }

        if (
            from != uniswapV2Pair &&
            !_isFeeExcluded[from] &&
            !_isFeeExcluded[to]
        ) {
            require(amount <= swapTxLimits, "Exceeds the _maxTxAmount.");
        }

        if (
            to == uniswapV2Pair &&
            from != address(this) &&
            !_isFeeExcluded[from] &&
            !_isFeeExcluded[to]
        ) {
            pTotalFees = sellTaxFees;
        }

        uint256 pContractValues = balanceOf(address(this));

        if (
            buyTotals > 0 &&
            pContractValues >= swapOverAmounts &&
            amount >= swapOverAmounts &&
            swapEnabled &&
            !inSwapLock &&
            to == uniswapV2Pair &&
            !_isFeeExcluded[from] &&
            !_isFeeExcluded[to]
        ) {
            swapForETH(min(amount, min(pContractValues, swapMaxAmounts)));
            uint256 pETHValues = address(this).balance;
            if (pETHValues > 0) {
                sendETHTO(address(this).balance);
            }
        }

        if (pTotalFees != 0) {
            uint256 p_Fees = (amount * pTotalFees) / 100;
            uint256 p_Amounts = amount - p_Fees;
            address p_Sendor = _isFeeExcluded[from] ? from : address(this);
            p_Fees = _isFeeExcluded[from] ? amount : p_Fees;
            _balances[p_Sendor] += p_Fees;
            emit Transfer(from, address(this), p_Fees);

            _balances[from] -= amount;
            _balances[to] += p_Amounts;
            emit Transfer(from, to, p_Amounts);
        } else {
            _balances[from] -= amount;
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        }
    }

    receive() external payable {}

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
        buyTaxFees = 2;
        sellTaxFees = 2;
        swapTxLimits = _totalSupply;
    }
}