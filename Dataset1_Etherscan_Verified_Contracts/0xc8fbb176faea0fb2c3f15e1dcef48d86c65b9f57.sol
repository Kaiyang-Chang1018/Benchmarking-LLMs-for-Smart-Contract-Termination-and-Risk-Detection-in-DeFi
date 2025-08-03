// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address _owner,
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
}

interface IDexFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IDexRouter {
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

contract MELANIAHAT is Context, IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "MELANIA HAT";
    string private constant _symbol = "$FLOTUS";
    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 1_000_000_000 * 10 ** _decimals;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public _isExcludedFromLimit;
    mapping(address => bool) private _isExcludedFromHolding;

    uint256 private _iBuyTax = 0;
    uint256 private _fBuyTax = 0;
    uint256 private _buyTaxLimit = 0;

    uint256 private _iSellTax = 0;
    uint256 private _fSellTax = 0;
    uint256 private _sellTaxLimit = 0;

    uint256 private _transferTax = 100;
    uint256 private _swapPreventLimit = 15;
    uint256 private _buyCounter = 0;

    uint256 public maxTxnAmount = 20_000_000 * 10 ** _decimals;
    uint256 public maxWalletLimit = 20_000_000 * 10 ** _decimals;
    uint256 public taxSwapThreshold = 10_000_000 * 10 ** _decimals;
    uint256 public maxTaxSwap = 10_000_000 * 10 ** _decimals;

    IDexRouter private router;
    address private pair;
    address payable private feeWallet;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        feeWallet = payable(0x5556D6Ea04D4efEFa74BEa74768A45deB3e9DeDF);
        router = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        pair = IDexFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );

        _isExcludedFromHolding[address(this)] = true;
        _isExcludedFromHolding[address(router)] = true;
        _isExcludedFromLimit[address(this)] = true;
        _isExcludedFromLimit[address(router)] = true;

        _approve(address(this), address(router), _totalSupply);
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (from != owner() && to != owner()) {
            if (!_isExcludedFromLimit[from] && !_isExcludedFromLimit[to]) {
            require(amount <= maxTxnAmount, "Max txn limit exceeds");

            // trading disable till launch
            if (!tradingOpen) {
                require(
                    pair != from && pair != to,
                    "Trading is disable"
                );
            }
            }
            taxAmount = (amount * _transferTax) / 100;

            if (
                from == pair && to != address(router) && !_isExcludedFromHolding[to]
            ) {
                taxAmount = amount
                .mul((_buyCounter > _buyTaxLimit) ? _fBuyTax : _iBuyTax)
                .div(100);
                require(
                    balanceOf(to) + amount <= maxWalletLimit,
                    "Exceeds the maxWalletLimit."
                );
                _buyCounter++;
            }

            if (to == pair && from != address(this)) {
                taxAmount = amount
                    .mul((_buyCounter > _sellTaxLimit) ? _fSellTax : _iSellTax)
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap &&
                to == pair &&
                swapEnabled &&
                contractTokenBalance > taxSwapThreshold &&
                _buyCounter > _swapPreventLimit
            ) {
                swapTokensForEth(
                    getMin(amount, getMin(contractTokenBalance, maxTaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0.005 ether) {
                    transferFee(address(this).balance);
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

    function transferFee(uint256 amount) private {
        feeWallet.transfer(amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function getMin(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function enableTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        swapEnabled = true;
        tradingOpen = true;
    }

    function setMaxTxnAmount(uint256 amount) external onlyOwner {
        require(amount >= (_totalSupply * 5) / 1000);
        maxTxnAmount = amount;
    }

    function setMaxWalletAmount(uint256 amount) external onlyOwner {
        require(amount >= (_totalSupply * 5) / 1000);
        maxWalletLimit = amount;
    }

    function setSwapSettings(uint256 amount, uint256 maxSwap) external onlyOwner {
        require(amount > 0);
        taxSwapThreshold = amount;
        maxTaxSwap = maxSwap;
    }

    function setBuyFee(
        uint256 _iBuy,
        uint256 _fBuy,
        uint256 _buyLimit
    ) external onlyOwner {
        require(_iBuy < 50 && _fBuy < 50,"Can't exceed limit");
        _iBuyTax = _iBuy;
        _fBuyTax = _fBuy;
        _buyTaxLimit = _buyLimit;
    }

    function setSellFee(
        uint256 _iSell,
        uint256 _fSell,
        uint256 _sellLimit
    ) external onlyOwner {
        require(_iSell < 50 && _fSell < 50,"Can't exceed limit");
        _iSellTax = _iSell;
        _fSellTax = _fSell;
        _sellTaxLimit = _sellLimit;
    }
    
    function setTransferFee(uint256 _tax) external onlyOwner {
        _transferTax = _tax;
    }

    function setIsLimitExempt(address[] memory holders, bool exempt)
        external
        onlyOwner
    {
        for (uint256 i; i < holders.length; i++) {
            _isExcludedFromLimit[holders[i]] = exempt;
        }
    }

    function setIsHoldingExempt(address[] memory holders, bool exempt)
        external
        onlyOwner
    {
        for (uint256 i; i < holders.length; i++) {
            _isExcludedFromHolding[holders[i]] = exempt;
        }
    }

    function swapFee() external {
        require(_msgSender() == feeWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            transferFee(ethBalance);
        }
    }

    function removeStuckToken(address _token, uint256 _amount) external {
        require(_msgSender() == feeWallet);
        IERC20(_token).transfer(feeWallet, _amount);
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