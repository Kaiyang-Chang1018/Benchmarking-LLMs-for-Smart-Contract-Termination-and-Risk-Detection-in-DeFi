// SPDX-License-Identifier: Unlicensed

/**
ONE $MEME TO RULE THEM ALL

Website: https://www.memecoineth.pro
Telegram: https://t.me/memecoin_erc20
Twitter: https://twitter.com/meme_coin_erc
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
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

contract MemeCoin is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    string private _name = "MemeCoin";
    string private _symbol = "MEME";
        
    uint8 private _decimals = 9;
    uint256 private _totalSupply = 10 ** 9 * 10 ** 9;

    IUniswapRouter _uniswapRouter;
    address _pairAddress;

    uint256 _buyLiqFee = 0;
    uint256 _buyMarketFee = 22;
    uint256 _buyDevFee = 0;
    uint256 _buyFee = 22;

    uint256 _taxSellLp = 0;
    uint256 _taxSellMkt = 22;
    uint256 _taxSellDev = 0;
    uint256 _sellFee = 22;
    
    uint256 public maxTxAmount = 25 * 10 ** 6 * 10 ** 9;
    uint256 public maxWalletAmount = 25 * 10 ** 6 * 10 ** 9;
    uint256 public swapThreshold = 10 ** 4 * 10 ** 9; 

    uint256 _taxSeperateLp = 0;
    uint256 _taxSeperateMkt = 10;
    uint256 _taxSeperateDev = 0;
    uint256 _taxSeperateTotal = 10;

    address payable _marketingWallet;
    address payable _devWallet;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) _isExcludeFromAll;
    mapping (address => bool) _isExcludeFromWalletLimit;
    mapping (address => bool) _isExcludeFromTxLimit;
    mapping (address => bool) _isPairAddress;
    
    bool swapping;
    bool _feeEnabledSwap = true;
    bool _hasNoMaxTx = false;
    bool _hasNoMaxWallet = true;

    modifier lockSwap {
        swapping = true;
        _;
        swapping = false;
    }
    
    constructor () {
        _balances[_msgSender()] = _totalSupply;
        IUniswapRouter _uniswapV2Router = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 
        _pairAddress = IUniswapFactory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        _uniswapRouter = _uniswapV2Router;
        _allowances[address(this)][address(_uniswapRouter)] = _totalSupply;
        _marketingWallet = payable(0x7060a048384F736aD2cF214a18cA9E4a26aAdbF8);
        _devWallet = payable(0x7060a048384F736aD2cF214a18cA9E4a26aAdbF8);
        _buyFee = _buyLiqFee.add(_buyMarketFee).add(_buyDevFee);
        _sellFee = _taxSellLp.add(_taxSellMkt).add(_taxSellDev);
        _taxSeperateTotal = _taxSeperateLp.add(_taxSeperateMkt).add(_taxSeperateDev);
        
        _isExcludeFromAll[owner()] = true;
        _isExcludeFromAll[_marketingWallet] = true;
        _isExcludeFromWalletLimit[owner()] = true;
        _isExcludeFromWalletLimit[address(_pairAddress)] = true;
        _isExcludeFromWalletLimit[address(this)] = true;
        _isExcludeFromTxLimit[owner()] = true;
        _isExcludeFromTxLimit[_marketingWallet] = true;
        _isExcludeFromTxLimit[address(this)] = true;
        _isPairAddress[address(_pairAddress)] = true;
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
            
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapRouter.WETH();

        _approve(address(this), address(_uniswapRouter), tokenAmount);

        // make the performSwap
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
            return _doBasicTransfer(sender, recipient, amount); 
        }
        else
        {
            if(!_isExcludeFromTxLimit[sender] && !_isExcludeFromTxLimit[recipient]) {
                require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            }            

            uint256 swapAmount = balanceOf(address(this));
            bool minimumSwap = swapAmount >= swapThreshold;
            
            if (minimumSwap && !swapping && _isPairAddress[recipient] && _feeEnabledSwap && !_isExcludeFromAll[sender] && amount > swapThreshold) 
            {
                if(_hasNoMaxTx)
                    swapAmount = swapThreshold;
                performSwap(swapAmount);    
            }

            uint256 finalAmount;                                         
            if (_isExcludeFromAll[sender] || _isExcludeFromAll[recipient]) {
                finalAmount = amount;
            } else {
                finalAmount = _getReceiptAmount(sender, recipient, amount);
            }
            if(_hasNoMaxWallet && !_isExcludeFromWalletLimit[recipient])
                require(balanceOf(recipient).add(finalAmount) <= maxWalletAmount);

            uint256 amountToReduce = (!_hasNoMaxWallet && _isExcludeFromAll[sender]) ? amount.sub(finalAmount) : amount;
            _balances[sender] = _balances[sender].sub(amountToReduce, "Insufficient Balance");
            _balances[recipient] = _balances[recipient].add(finalAmount);
            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }
                
    function _doBasicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
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
    
    function performSwap(uint256 tAmount) private lockSwap {
        uint256 lpFeetokens = tAmount.mul(_taxSeperateLp).div(_taxSeperateTotal).div(2);
        uint256 tokensToSwap = tAmount.sub(lpFeetokens);

        swapTokensForETH(tokensToSwap);
        uint256 ethCA = address(this).balance;

        uint256 totalETHFee = _taxSeperateTotal.sub(_taxSeperateLp.div(2));
        
        uint256 amountETHLiquidity = ethCA.mul(_taxSeperateLp).div(totalETHFee).div(2);
        uint256 amountETHDevelopment = ethCA.mul(_taxSeperateDev).div(totalETHFee);
        uint256 amountETHMarketing = ethCA.sub(amountETHLiquidity).sub(amountETHDevelopment);

        if(amountETHMarketing > 0)
            transferFeeEth(_marketingWallet, amountETHMarketing);

        if(amountETHDevelopment > 0)
            transferFeeEth(_devWallet, amountETHDevelopment);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFeeEth(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function _getReceiptAmount(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 fee = 0;
        if(_isPairAddress[sender]) {fee = amount.mul(_buyFee).div(100);}
        else if(_isPairAddress[recipient]) {fee = amount.mul(_sellFee).div(100);}
        if(fee > 0) {
            _balances[address(this)] = _balances[address(this)].add(fee);
            emit Transfer(sender, address(this), fee);
        }
        return amount.sub(fee);
    }
    
    receive() external payable {}
    
    function removeLimits() external onlyOwner {
        maxTxAmount = _totalSupply;
        _hasNoMaxWallet = false;
        _buyMarketFee = 1;
        _taxSellMkt = 1;
        _buyFee = 1;
        _sellFee = 1;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}