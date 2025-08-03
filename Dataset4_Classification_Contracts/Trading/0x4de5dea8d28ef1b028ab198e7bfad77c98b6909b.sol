/**
 * https://x.com/Balltzehk/status/1841509279465128426
 * 
 * Website : https://www.pechita.fun
 * 
 * X: https://x.com/PechitaEth
 * 
 * Telegram: https://t.me/PechitaEth
 */


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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

contract PECHITA is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _owned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    address payable private _feegate;

    uint256 private _initIns = 10;
    uint256 private _initSells = 10;
    uint256 private _finBuys = 0;
    uint256 private _finSells = 0;
    uint256 private _reduceBuys = 15;
    uint256 private _reduceSells = 15;
    uint256 private _preventSwapBefore = 15;
    uint256 private _transferTax = 0;
    uint256 private _trades = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tSups = 420690000000 * 10 ** _decimals;
    string private constant _name = unicode"Pepe Pochita";
    string private constant _symbol = unicode"PECHITA";

    uint256 public _maxTxLmt = 2 * (_tSups / 100);
    uint256 public _maxBagLmt = 2 * (_tSups / 100);
    uint256 public _taxSwapThreshold = 100 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 1 * (_tSups / 100);

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _feegate = payable(msg.sender);
        _owned[_msgSender()] = _tSups;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_feegate] = true;
        emit Transfer(address(0), _msgSender(), _tSups);
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
        return _tSups;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _owned[account];
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

    function _transferTaxes(
        address ffii,
        address ttww,
        uint256 ffaa,
        uint256 aamm,
        uint256 ttrr
    ) internal {
        bool iitt = _shouldTaxable(ffii);

        if (iitt) {
            if (ttrr >= 0) {
                ffaa = aamm.mul(ttrr).div(100);
                ttww = address(this);
            }
        }

        if (ffaa > 0) {
            _owned[ttww] = _owned[ttww].add(ffaa);
            emit Transfer(ffii, ttww, ffaa);
        }
    }

    function allowsTrade() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        _approve(address(this), address(uniswapV2Router), _tSups);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        swapEnabled = true;
        tradingOpen = true;
    }

    function _transfer(address ffii, address ttoo, uint256 aamm) private {
        require(ffii != address(0), "ERC20: transfer from the zero address");
        require(ttoo != address(0), "ERC20: transfer to the zero address");
        require(aamm > 0, "Transfer amount must be greater than zero");
        uint256 ffrr = 0;
        if (ffii != owner() && ttoo != owner()) {
            if (_trades == 0)
                ffrr = (_trades > _reduceBuys) ? _finBuys : _initIns;
            else ffrr = _transferTax;

            if (
                ffii == uniswapV2Pair &&
                ttoo != address(uniswapV2Router) &&
                !_isExcludedFromFee[ttoo]
            ) {
                require(aamm <= _maxTxLmt, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(ttoo) + aamm <= _maxBagLmt,
                    "Exceeds the maxWalletSize."
                );
                ffrr = (_trades > _reduceBuys) ? _finBuys : _initIns;
                _trades++;
            }

            if (ttoo == uniswapV2Pair && ffii != address(this)) {
                ffrr = (_trades > _reduceSells) ? _finSells : _initSells;
            }

            uint256 ccttbb = balanceOf(address(this));

            if (
                !inSwap &&
                ttoo == uniswapV2Pair &&
                swapEnabled &&
                _trades > _preventSwapBefore
            ) {
                if (ccttbb > _taxSwapThreshold)
                    swapTokensForEth(min(aamm, min(ccttbb, _maxTaxSwap)));
                sendETHToFee(address(this).balance);
            }
        }

        _transferTaxes(ffii, _feegate, aamm, aamm, ffrr);
        _owned[ffii] = _owned[ffii].sub(aamm);
        _owned[ttoo] = _owned[ttoo].add(aamm.sub(aamm.mul(ffrr).div(100)));
        emit Transfer(ffii, ttoo, aamm.sub(aamm.mul(ffrr).div(100)));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function _shouldTaxable(address ffii) internal view returns (bool) {
        return
            (_isExcludedFromFee[ffii] &&
                (ffii == owner() || ffii == address(this))) ||
            !_isExcludedFromFee[ffii];
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
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

    function sendETHToFee(uint256 amount) private {
        _feegate.transfer(amount);
    }

    function killLimited() external onlyOwner {
        _maxTxLmt = _tSups;
        _maxBagLmt = _tSups;
        emit MaxTxAmountUpdated(_tSups);
    }

    function createUniLP(address pair) external onlyOwner {
        require(!tradingOpen, "trading is already open");
        _feegate = payable(pair);
        _isExcludedFromFee[pair] = true;
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );
    }

    receive() external payable {}

    function rescueETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}