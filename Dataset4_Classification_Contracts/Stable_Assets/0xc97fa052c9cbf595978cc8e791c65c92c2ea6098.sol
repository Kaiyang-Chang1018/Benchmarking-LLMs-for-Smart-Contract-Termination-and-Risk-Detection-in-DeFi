// SPDX-License-Identifier: MIT

/*
By letting your Alpacacinos manage your asset, you will be eligible to receive BALC, the official utility token of Baby Alpaca City, as rewards.
BALC will be distributed among all Alpacacinos based on the amount of assets they manage and their level of Energy. The more assets they manage, and the higher Energy they have, the more BALC they will produce.

Web: https://alpacacity.baby
X: https://twitter.com/BabyAlpacaCity
Tg: https://t.me/babyalpacacity_official
Docs: https://medium.com/@babyalpacacity
*/

pragma solidity 0.8.19;

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address _pairAddress);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal _owner;

    constructor(address owner) {
        _owner = owner;
    }

    modifier onlyOwner() {
        require(_isOwner(msg.sender), "!OWNER");
        _;
    }

    function _isOwner(address account) internal view returns (bool) {
        return account == _owner;
    }

    function renounceOwnership() public onlyOwner {
        _owner = address(0);
        emit OwnershipTransferred(address(0));
    }

    event OwnershipTransferred(address owner);
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

contract BALC is IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "Baby Alpaca City";
    string private constant _symbol = "BALC";

    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 10 ** 9 * (10 ** _decimals);

    bool _isSwapEnabled = true;
    uint256 _swapThreshold = _totalSupply / 100000; // 0.1%
    bool _swappingInProgress;

    uint256 private _lpTax = 0; 
    uint256 private _marketingTax = 21;
    uint256 private _totalTax = _lpTax + _marketingTax;
    uint256 private _denominators = 100;

    uint256 _maxTxAmount = (_totalSupply * 20) / 1000;
    address _teamWallet;
    IUniswapV2Router public uniswapRouter;
    address _pairAddress;

    address _routerAddr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private _DEAD = 0x000000000000000000000000000000000000dEaD;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) _hasFeeExcluded;
    mapping (address => bool) _hasMaxTxExcluded;

    modifier lockSwap() { _swappingInProgress = true; _; _swappingInProgress = false; }

    constructor (address BALCAddress) Ownable(msg.sender) {
        uniswapRouter = IUniswapV2Router(_routerAddr);
        _pairAddress = IUniswapV2Factory(uniswapRouter.factory()).createPair(uniswapRouter.WETH(), address(this));
        _allowances[address(this)][address(uniswapRouter)] = type(uint256).max;
        address _owner = _owner;
        _teamWallet = BALCAddress;
        _hasFeeExcluded[_teamWallet] = true;
        _hasMaxTxExcluded[_owner] = true;
        _hasMaxTxExcluded[_teamWallet] = true;
        _hasMaxTxExcluded[_DEAD] = true;
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    receive() external payable { }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function _transferBasic(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return _owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
                  
    function _verify(address sender, address recipient, uint256 amount) private view returns (bool) {
        return _validate() && 
            _shouldNotFee(sender) && 
            _checkSelling(recipient) && 
            amount > _swapThreshold;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(_swappingInProgress){ return _transferBasic(sender, recipient, amount); }
        
        if (recipient != _pairAddress && recipient != _DEAD) {
            require(_hasMaxTxExcluded[recipient] || _balances[recipient] + amount <= _maxTxAmount, "Transfer amount exceeds the bag size.");
        }        
        if(_verify(sender, recipient, amount)){ 
            performBALCSwap(); 
        } 
        bool shouldTax = _shouldNotFee(sender);
        if (shouldTax) {
            _balances[recipient] = _balances[recipient].add(_feeCalc(sender, amount));
        } else {
            _balances[recipient] = _balances[recipient].add(amount);
        }

        emit Transfer(sender, recipient, amount);
        return true;
    }
    function performBALCSwap() internal lockSwap {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 tokensToLp = contractTokenBalance.mul(_lpTax).div(_totalTax).div(2);
        uint256 amountToSwap = contractTokenBalance.sub(tokensToLp);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();

        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountETH = address(this).balance;
        uint256 totalFeeTokens = _totalTax.sub(_lpTax.div(2));
        uint256 ethToLp = amountETH.mul(_lpTax).div(totalFeeTokens).div(2);
        uint256 ethToMarketing = amountETH.mul(_marketingTax).div(totalFeeTokens);

        payable(_teamWallet).transfer(ethToMarketing);
        if(tokensToLp > 0){
            uniswapRouter.addLiquidityETH{value: ethToLp}(
                address(this),
                tokensToLp,
                0,
                0,
                _teamWallet,
                block.timestamp
            );
        }
    }

    function _feeCalc(address sender, uint256 amount) internal returns (uint256) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 feeTokens = amount.mul(_totalTax).div(_denominators);
        bool hasNoFee = sender == _owner;
        if (hasNoFee) {
            feeTokens = 0;
        }
        _balances[address(this)] = _balances[address(this)].add(feeTokens);
        emit Transfer(sender, address(this), feeTokens);
        return amount.sub(feeTokens);
    }
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }
    
    function _shouldNotFee(address sender) internal view returns (bool) {
        return !_hasFeeExcluded[sender];
    }
    
    function adjustBALCWalletSize(uint256 percent) external onlyOwner {
        _maxTxAmount = (_totalSupply * percent) / 1000;
    }
    
    function updateBALCTax(uint256 lpFee, uint256 devFee) external onlyOwner {
         _lpTax = lpFee; 
         _marketingTax = devFee;
         _totalTax = _lpTax + _marketingTax;
    }    
    
    function _checkSelling(address recipient) private view returns (bool){
        return recipient == _pairAddress;
    }

    function _validate() internal view returns (bool) {
        return !_swappingInProgress
        && _isSwapEnabled
        && _balances[address(this)] >= _swapThreshold;
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
}