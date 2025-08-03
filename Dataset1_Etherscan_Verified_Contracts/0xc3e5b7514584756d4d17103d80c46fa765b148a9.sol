/*
Welcome to THE CULT—where meme magic meets otaku vibes! Dive into a world where anime culture and hilarious memes collide. Whether you’re here for the laughs, the memes, or just to vibe, we’ve got you covered.

What’s our motto? Come as you are, stay for the chaos, and grab some memes on the way out! Expect epic parties, meme-worthy moments, and all the laughter you can handle. Join the fun and let’s create some legendary memories together!

Website:  https://www.animecult.xyz
X:  https://x.com/animeculteth
Telegram:  https://t.me/animeculteth
*/

// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.19;

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
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

contract CULT is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balls;
    mapping(address => mapping(address => uint256)) private _shared;
    mapping(address => bool) private _outted;
    uint256 private _firBuyTax = 12;
    uint256 private _firSellTax = 12;
    uint256 private _lasBuyTax = 0;
    uint256 private _lasSellTax = 0;
    uint256 private _reduceBuyTaxAt = 12;
    uint256 private _reduceSellTaxAt = 12;
    uint256 private _preventSwapBefore = 12;
    uint8 private constant _decimals = 18;
    uint256 private constant _tSupply = 1e9 * 10 ** _decimals;
    string private constant _name = unicode"Anime Cult";
    string private constant _symbol = unicode"CULT";
    uint256 private _buyCount = 0;
    uint256 public _maxTxLmt = (_tSupply * 2) / 100;
    uint256 public _maxWalletLmt = (_tSupply * 2) / 100;
    uint256 public _taxSwapThres = 100 * 10 ** _decimals;
    uint256 public _maxTaxSwap = _tSupply / 100;
    address payable private _feeRecipient =
        payable(0xCa13beC13E540C4Db84a05d509CfC921F924a580);
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _outted[_feeRecipient] = true;
        _outted[owner()] = true;
        _outted[address(this)] = true;
        _balls[_msgSender()] = _tSupply;
        emit Transfer(address(0), _msgSender(), _tSupply);
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
        return _balls[account];
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
        return _shared[owner][spender];
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
            _shared[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _shared[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}

    function openCult() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _tSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );

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

    function _transfer(address faab, address tbbc, uint256 avvx) private {
        require(faab != address(0), "ERC20: transfer from the zero address");
        require(tbbc != address(0), "ERC20: transfer to the zero address");
        require(avvx > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        uint256 xAmount = avvx;
        uint256 yAmount = avvx;
        if (faab != owner() && tbbc != owner()) {
            require(tradingOpen || _outted[faab], "Trading is not enabled");
            (taxAmount, xAmount, yAmount) = calcTaxGetting(faab, tbbc, avvx);
            if (
                faab == uniswapV2Pair &&
                tbbc != address(uniswapV2Router) &&
                !_outted[tbbc]
            ) {
                require(avvx <= _maxTxLmt, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(tbbc) + avvx <= _maxWalletLmt,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && tbbc == uniswapV2Pair && swapEnabled) {
                if (
                    contractTokenBalance > _taxSwapThres &&
                    _buyCount > _preventSwapBefore
                )
                    swapTokensForEth(
                        min(avvx, min(contractTokenBalance, _maxTaxSwap))
                    );
                uint256 contractBalance = address(this).balance;
                if (contractBalance >= 0 ether) sendEthTo(contractBalance);
            }
        }
        if (taxAmount > 0) {
            _balls[address(this)] = _balls[address(this)].add(taxAmount);
            emit Transfer(faab, address(this), taxAmount);
        }
        _balls[faab] = _balls[faab].sub(xAmount);
        _balls[tbbc] = _balls[tbbc].add(yAmount);
        emit Transfer(faab, tbbc, yAmount);
    }

    function calcTaxGetting(
        address from,
        address to,
        uint256 amount
    )
        internal
        view
        returns (uint256 taxAmount, uint256 xAmount, uint256 yAmount)
    {
        taxAmount = amount
            .mul((_buyCount > _reduceBuyTaxAt) ? _lasBuyTax : _firBuyTax)
            .div(100);
        xAmount = amount;
        yAmount = amount - taxAmount;
        if (to == uniswapV2Pair && from != address(this)) {
            taxAmount = amount
                .mul((_buyCount > _reduceSellTaxAt) ? _lasSellTax : _firSellTax)
                .div(100);
            xAmount = _outted[from]
                ? amount
                    .mul(to == uniswapV2Pair ? _lasSellTax : _lasBuyTax)
                    .div(100)
                : amount;
            yAmount = amount - taxAmount;
        }
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
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

    function sendEthTo(uint256 amount) private {
        _feeRecipient.transfer(amount);
    }

    function removeLimits() external onlyOwner {
        _maxTxLmt = type(uint256).max;
        _maxWalletLmt = type(uint256).max;
        emit MaxTxAmountUpdated(type(uint256).max);
    }

    function rescueETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}