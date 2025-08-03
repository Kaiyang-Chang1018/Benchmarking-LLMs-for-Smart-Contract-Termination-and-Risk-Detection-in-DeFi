/*

    Yo, Matt Furie might be feeling some type of discomfort, seeing his baby Pepe turn into the ultimate DegenPepe. Born from the OG meme lord's sketches, Pepe's hitting the crypto streets as $DPEPE—bold, brash, and ready to moon! ??
    Pepe's sick of those trash-tier toilet tokens flooding the scene. It's time for a meme coin with some real juice. $DPEPE ain't just another pump; it's the legend Pepe, but with an extra sprinkle of degen magic. ?✨
    Matt Furie? Sweating for sure, but deep down he's gotta be chuckling. His lil' frog's gone full rebel mode, and it’s straight-up iconic. Join the chaos, get your wallets ready, and let's send $DPEPE to the stratosphere. This is the real deal, peeps—the meme to end all memes. Let's do Papa Matt proud!

    Ready to ape in? Check us out:
    WEB: https://www.degenpepe.info
    X: https://x.com/degenpepetoken
    TG: https://t.me/degenpepetoken

*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {return msg.sender;}
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {return _owner;}
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
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract DPEPE is Context, IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    address payable private _degenAdd;
    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 50;
    uint256 private _reduceSellTaxAt = 100;
    uint256 private _preventSwapBefore = 20;
    uint256 private _transferTax = 50;
    uint256 private _buyCount = 0;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420_690_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Degen Pepe";
    string private constant _symbol = unicode"DPEPE";
    uint256 public _maxTxAmount = 2 * (_tTotal / 100);
    uint256 public _maxWalletSize = 2 * (_tTotal / 100);
    uint256 public _taxSwapThreshold = 1 * (_tTotal / 1000);
    uint256 public _maxTaxSwap = 1 * (_tTotal / 100);

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    event LimitsRemoved(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    modifier onlyDegen() {
        require(_msgSender() == _degenAdd, "Caller is not degen");
        _;
    }

    constructor(address degenAdd) {
        _degenAdd = payable(degenAdd);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_degenAdd] = true;
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

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "Transfer from zero address");
        require(to != address(0), "Transfer to zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (from != owner() && to != owner() && from != _degenAdd && to != _degenAdd) {
            if (_buyCount == 0) {
                taxAmount = amount * ((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax) / 100;
            }
            if (_buyCount > 0) {
                taxAmount = amount * _transferTax / 100;
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_isExcludedFromFee[to]) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxAmount = amount * ((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax) / 100;
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount * ((_buyCount > _reduceSellTaxAt) ? _finalSellTax : _initialSellTax) / 100;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > lastSellBlock) {
                    sellCount = 0;
                }
                require(sellCount < 10, "Only 10 sells per block!");
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                sellCount++;
                lastSellBlock = block.number;
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] += taxAmount;
            emit Transfer(from, address(this), taxAmount);
        }
        _balances[from] -= amount;
        _balances[to] += amount - taxAmount;
        emit Transfer(from, to, amount - taxAmount);
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

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit LimitsRemoved(_tTotal);
    }

    function removeTransferTax() external onlyOwner {
        _transferTax = 0;
    }

    function sendETHToFee(uint256 amount) private {
        _degenAdd.transfer(amount);
    }

    function enableTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }

    receive() external payable {}

    function manualSwap() external onlyDegen {
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }

    function manualSend() external onlyDegen {
        uint256 amount = address(this).balance;
        require(amount > 0, "No ETH in contract");
        payable(msg.sender).transfer(amount);
    }

    function manualSendTokens(address tokenAddress) external onlyDegen {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No token in contract");
        token.transfer(msg.sender, balance);
    }
}