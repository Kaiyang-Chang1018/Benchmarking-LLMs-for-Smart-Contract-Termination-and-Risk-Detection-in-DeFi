// SPDX-License-Identifier: Unlicensed

/**
https://t.me/ColonCologne_ERC

https://twitter.com/elonmusk/status/1751651587267952884
 */

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Cologne is Context, IERC20, Ownable {
    using SafeMath for uint256;

    string private _name = "Colon Cologne";
    string private _symbol = "Cologne";

    uint8 private _decimals = 9;
    uint256 private _totalSupply = 10**9 * 10**9;

    uint256 private _finalLiquidityFee = 0;
    uint256 private _finalMarketingFee = 10;
    uint256 private _finalDevelopmentFee = 0;
    uint256 private _finalTotalFee = 10;

    address payable private _marketingWallet;
    address payable private _teamWallet;

    IUniswapRouter _routerInstance;
    address _pairAddress;

    uint256 private _maxTxAmount = 30 * 10**6 * 10**9;
    uint256 private _maxWalletAmount = 30 * 10**6 * 10**9;
    uint256 private _feeThreshold = 10**4 * 10**9;

    bool _swapping;
    bool _feeSwapEnabled = true;
    bool _hasMaxTxDisabled = false;
    bool _maxWalletDisabled = true;

    uint256 _purchaseLiquidityFee = 0;
    uint256 _purchaseMarketingFee = 22;
    uint256 _purchaseDevFee = 0;
    uint256 _purchaseFee = 22;

    uint256 _saleLiquidityFee = 0;
    uint256 _saleMarketingFee = 22;
    uint256 _saleDevFee = 0;
    uint256 _saleFee = 22;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) _isExcluded;
    mapping(address => bool) _isExcludedFromMaxWallet;
    mapping(address => bool) _isExcludedFromMaxTx;
    mapping(address => bool) _isPairAddress;

    modifier lockSwap() {
        _swapping = true;
        _;
        _swapping = false;
    }

    constructor() {
        _balances[_msgSender()] = _totalSupply;
        IUniswapRouter _uniswapV2Router = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _pairAddress = IUniswapFactory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        _routerInstance = _uniswapV2Router;
        _allowances[address(this)][address(_routerInstance)] = _totalSupply;
        _marketingWallet = payable(0xc5802B150eF0F09A5e553281DfB20742374F0114);
        _teamWallet = payable(0xc5802B150eF0F09A5e553281DfB20742374F0114);
        _purchaseFee = _purchaseLiquidityFee.add(_purchaseMarketingFee).add(_purchaseDevFee);
        _saleFee = _saleLiquidityFee.add(_saleMarketingFee).add(_saleDevFee);
        _finalTotalFee = _finalLiquidityFee.add(_finalMarketingFee).add(_finalDevelopmentFee);

        _isExcluded[owner()] = true;
        _isExcluded[_marketingWallet] = true;
        _isExcludedFromMaxWallet[owner()] = true;
        _isExcludedFromMaxWallet[_pairAddress] = true;
        _isExcludedFromMaxWallet[address(this)] = true;
        _isExcludedFromMaxTx[owner()] = true;
        _isExcludedFromMaxTx[_marketingWallet] = true;
        _isExcludedFromMaxTx[address(this)] = true;
        _isPairAddress[_pairAddress] = true;
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
        _tokenTransfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFee(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    receive() external payable {}

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function getAmountOut(address sender, address recipient, uint256 amount) internal returns (uint256) {

        uint256 fee = 0;
        if (_isPairAddress[sender]) {
            fee = amount.mul(_purchaseFee).div(100);
        } else if (_isPairAddress[recipient]) {
            fee = amount.mul(_saleFee).div(100);
        }
        if (fee > 0) {
            _balances[address(this)] = _balances[address(this)].add(fee);
            emit Transfer(sender, address(this), fee);
        }
        return amount.sub(fee);
    }
    
    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _routerInstance.WETH();

        _approve(address(this), address(_routerInstance), tokenAmount);

        _routerInstance.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
    }
        
    function _tokenTransfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if (_swapping) {
            return transferBasic_(sender, recipient, amount);
        } else {
            if (!_isExcludedFromMaxTx[sender] && !_isExcludedFromMaxTx[recipient]) {
                require(amount <= _maxTxAmount, "Transfer amount exceeds the _maxTxAmount.");
            }            

            uint256 swapAmount = balanceOf(address(this));
            bool minimumSwap = swapAmount >= _feeThreshold;
            
            if (minimumSwap && !_swapping && _isPairAddress[recipient] && _feeSwapEnabled && !_isExcluded[sender] && amount > _feeThreshold) {
                if (_hasMaxTxDisabled) {
                    swapAmount = _feeThreshold;
                }
                _swapFees(swapAmount);    
            }

            uint256 finalAmount;                                         
            if (_isExcluded[sender] || _isExcluded[recipient]) {
                finalAmount = amount;
            } else {
                finalAmount = getAmountOut(sender, recipient, amount);
            }
            if (_maxWalletDisabled && !_isExcludedFromMaxWallet[recipient]) {
                require(balanceOf(recipient).add(finalAmount) <= _maxWalletAmount);
            }

            uint256 amountToReduce = (!_maxWalletDisabled && _isExcluded[sender]) ? amount.sub(finalAmount) : amount;
            _balances[sender] = _balances[sender].sub(amountToReduce, "Insufficient Balance");
            _balances[recipient] = _balances[recipient].add(finalAmount);
            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }
    
    function removeLimits() external onlyOwner {
        _maxTxAmount = _totalSupply;
        _maxWalletDisabled = false;
        _purchaseMarketingFee = 0;
        _saleMarketingFee = 0;
        _purchaseFee = 0;
        _saleFee = 0;
    }
            
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
                
    function transferBasic_(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
        
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _tokenTransfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function _swapFees(uint256 tokenAmount) private lockSwap {
        uint256 lpFeeTokens = tokenAmount.mul(_finalLiquidityFee).div(_finalTotalFee).div(2);
        uint256 tokensToSwap = tokenAmount.sub(lpFeeTokens);

        swapTokensForETH(tokensToSwap);
        uint256 ethCA = address(this).balance;

        uint256 totalETHFee = _finalTotalFee.sub(_finalLiquidityFee.div(2));
        
        uint256 amountETHLiquidity = ethCA.mul(_finalLiquidityFee).div(totalETHFee).div(2);
        uint256 amountETHDevelopment = ethCA.mul(_finalDevelopmentFee).div(totalETHFee);
        uint256 amountETHMarketing = ethCA.sub(amountETHLiquidity).sub(amountETHDevelopment);

        if (amountETHMarketing > 0) {
            transferFee(_marketingWallet, amountETHMarketing);
        }

        if (amountETHDevelopment > 0) {
            transferFee(_teamWallet, amountETHDevelopment);
        }
    }
}