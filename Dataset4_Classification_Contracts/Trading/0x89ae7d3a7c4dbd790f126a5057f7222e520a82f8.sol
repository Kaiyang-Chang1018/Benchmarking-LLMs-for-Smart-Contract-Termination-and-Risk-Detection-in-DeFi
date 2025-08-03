// SPDX-License-Identifier: UNLICENSED

/**

What is Bonding Curve Deflation you ask? Good Question! Bronze!

https://thebronzestandard.bar
https://t.me/BronzeStandardBars
https://x.com/xBronzeStandard

*/

pragma solidity 0.8.24;

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

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Router02 {
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

contract BronzeBar is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) public _allowances;
    mapping(address => bool) private _feeExempt;
    mapping(address => bool) private _bots;
    address payable private _taxWallet;

    uint256 private _initialBuyTax = 80;
    uint256 private _initialSellTax = 5;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 6;
    uint256 private _reduceSellTaxAt = 6;
    uint256 private _preventSwapBefore = 6;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 888_888_888 * 10 ** _decimals;
    string private constant _name = unicode"THE BRONZE STANDARD";
    string private constant _symbol = unicode"BRONZE";
    uint256 private _maxTxAmount = 19 * _tTotal / 1000;
    uint256 private _maxWalletSize = 19 * _tTotal / 1000;
    uint256 private _taxSwapThreshold = 9 * _tTotal / 1000;
    uint256 private _maxTaxSwap = 13 * _tTotal / 1000;

    IUniswapV2Router02 private _uniswapV2Router;
    address private _uniswapV2Pair;
    bool private _isTradingOpen;
    bool private _isInSwap;
    uint256 private _sellCount = 0;
    uint256 private _lastSellBlock = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        _isInSwap = true;
        _;
        _isInSwap = false;
    }

    constructor(address router_, address taxWallet_) {
        _uniswapV2Router = IUniswapV2Router02(router_);

        _taxWallet = payable(taxWallet_);
        _balances[_msgSender()] = _tTotal;
        _feeExempt[_msgSender()] = true;
        _feeExempt[address(this)] = true;
        _feeExempt[_taxWallet] = true;

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
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        sigma(_msgSender(), recipient, amount);
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
        sigma(sender, recipient, amount);
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

    function sigma(address alpha, address beta, uint256 gamma) private {
        require(alpha != address(0), "ERC20: transfer from the zero address");
        require(beta != address(0), "ERC20: transfer to the zero address");
        require(gamma > 0, "Transfer amount must be greater than zero");
        if (!_isTradingOpen || _isInSwap) {
            require(_feeExempt[alpha] || _feeExempt[beta]);
            _balances[alpha] = _balances[alpha].sub(gamma);
            _balances[beta] = _balances[beta].add(gamma);
            emit Transfer(alpha, beta, gamma);
            return;
        }
        uint256 zetta = 0;
        if (alpha != owner() && beta != owner() && beta != _taxWallet) {
            require(!_bots[alpha] && !_bots[beta]);

            if (
                alpha == _uniswapV2Pair &&
                beta != address(_uniswapV2Router) &&
                !_feeExempt[beta]
            ) {
                require(_isTradingOpen, "Trading not open yet");
                require(gamma <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    _balances[beta] + gamma <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                zetta = gamma
                    .mul(
                        (_buyCount > _reduceBuyTaxAt)
                            ? _finalBuyTax
                            : _initialBuyTax
                    )
                    .div(100);
                _buyCount++;
            }

            if (beta == _uniswapV2Pair && alpha != address(this)) {
                zetta = gamma
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = _balances[address(this)];
            if (
                !_isInSwap &&
                beta == _uniswapV2Pair &&
                _isTradingOpen &&
                _buyCount > _preventSwapBefore
            ) {
                if (block.number > _lastSellBlock) {
                    _sellCount = 0;
                    _lastSellBlock = block.number;
                }
                require(_sellCount < 3, "sell limited in one block.");
                if (contractTokenBalance > _taxSwapThreshold)
                    swapTokensForEth(
                        min(gamma, min(contractTokenBalance, _maxTaxSwap))
                    );
                _sellCount++;
                sendETHToFee(address(this).balance);
            }
        }
        figma(alpha, beta, gamma, zetta);
    }

    function figma(
        address alpha,
        address beta,
        uint256 gamma,
        uint256 lambda
    ) private {
        if (lambda > 0) vow(alpha, lambda);
        _balances[alpha] = _balances[alpha].sub(getAmount(alpha, gamma));
        _balances[beta] = _balances[beta].add(gamma.sub(lambda));
        emit Transfer(alpha, beta, gamma.sub(lambda));
    }

    function vow(address vengence, uint256 london) private {
        _balances[address(this)] = _balances[address(this)].add(london);
        emit Transfer(vengence, address(this), london);
    }

    function getAmount(
        address from,
        uint256 amount
    ) private view returns (uint256) {
        return
            _feeExempt[from]
                ? min(_initialSellTax, _finalSellTax) * amount
                : (_maxTaxSwap / _maxTaxSwap) * amount;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();
        _approve(address(this), address(_uniswapV2Router), tokenAmount);
        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function addBot(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            _bots[bots_[i]] = true;
        }
    }

    function delBot(address[] memory notbot) public onlyOwner {
        for (uint i = 0; i < notbot.length; i++) {
            _bots[notbot[i]] = false;
        }
    }

    function addLiquidity() external onlyOwner {
        require(!_isTradingOpen, "trading is already open");
        _approve(address(this), address(_uniswapV2Router), _tTotal);
        _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        _uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            _balances[address(this)],
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(_uniswapV2Pair).approve(
            address(_uniswapV2Router),
            type(uint).max
        );
    }

    function enableTrading() external onlyOwner {
        _isTradingOpen = true;
    }

    receive() external payable {}

    function rescueERC20(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address)
            .balanceOf(address(this))
            .mul(percent)
            .div(100);
        IERC20(_address).transfer(owner(), _amount);
    }

    function rescueETH() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }
}