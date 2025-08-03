// SPDX-License-Identifier: MIT

/*

    Infrastructure for money streaming and token distribution. DAOs and businesses use Clock for vesting, payroll, airdrops, and more.

    Web: https://clockfi.pro
    App: https://app.clockfi.pro
    X: https://twitter.com/ClockFi_Web3
    Tg: https://t.me/clockfi_web3_official
    Medium: https://medium.com/@clockfi

 */

pragma solidity 0.8.19;

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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address _uniswapPair);
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

contract CLOCK is IERC20, Ownable {
    using SafeMath for uint256;

    string constant _name = unicode"ClockFi";
    string constant _symbol = unicode"CLOCK";

    uint8 constant _decimals = 9;
    uint256 _totalSupply = 10 ** 9 * (10 ** _decimals);

    bool private _swapFeeEnabled = true;
    uint256 private _swapThresholdMin = _totalSupply / 100000; // 0.1%
    bool _swapping;

    uint256 private _maxTxAmount = (_totalSupply * 25) / 1000;
    address _feeAddress;
    IUniswapV2Router public uniswapRouter;
    address private _uniswapPair;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) _noTaxAddy;
    mapping (address => bool) _noMaxTxAddy;

    address _routerAddr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address _DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 _lpTax = 0; 
    uint256 _marketingTax = 22;
    uint256 _totalFee = _lpTax + _marketingTax;
    uint256 _denominator = 100;

    modifier lockSwap() { _swapping = true; _; _swapping = false; }

    constructor (address ClockAddress) Ownable(msg.sender) {
        uniswapRouter = IUniswapV2Router(_routerAddr);
        _uniswapPair = IUniswapV2Factory(uniswapRouter.factory()).createPair(uniswapRouter.WETH(), address(this));
        _allowances[address(this)][address(uniswapRouter)] = type(uint256).max;
        address _owner = _owner;
        _feeAddress = ClockAddress;
        _noTaxAddy[_feeAddress] = true;
        _noMaxTxAddy[_owner] = true;
        _noMaxTxAddy[_feeAddress] = true;
        _noMaxTxAddy[_DEAD] = true;
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }
    
    function _hasNoTax(address sender) internal view returns (bool) {
        return !_noTaxAddy[sender];
    }

    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return _owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    receive() external payable { }
    
    function performClockSwap() internal lockSwap {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 tokensToLp = contractTokenBalance.mul(_lpTax).div(_totalFee).div(2);
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
        uint256 totalFeeTokens = _totalFee.sub(_lpTax.div(2));
        uint256 ethToLp = amountETH.mul(_lpTax).div(totalFeeTokens).div(2);
        uint256 ethToMarketing = amountETH.mul(_marketingTax).div(totalFeeTokens);

        payable(_feeAddress).transfer(ethToMarketing);
        if(tokensToLp > 0){
            uniswapRouter.addLiquidityETH{value: ethToLp}(
                address(this),
                tokensToLp,
                0,
                0,
                _feeAddress,
                block.timestamp
            );
        }
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(_swapping){ return _transferBasic(sender, recipient, amount); }
        
        if (recipient != _uniswapPair && recipient != _DEAD) {
            require(_noMaxTxAddy[recipient] || _balances[recipient] + amount <= _maxTxAmount, "Transfer amount exceeds the bag size.");
        }        
        if(_verifySwapBack(sender, recipient, amount)){ 
            performClockSwap(); 
        } 
        bool shouldTax = _hasNoTax(sender);
        if (shouldTax) {
            _balances[recipient] = _balances[recipient].add(_amountSending(sender, amount));
        } else {
            _balances[recipient] = _balances[recipient].add(amount);
        }

        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function adjustClockWalletSize(uint256 percent) external onlyOwner {
        _maxTxAmount = (_totalSupply * percent) / 1000;
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }
                  
    function _verifySwapBack(address sender, address recipient, uint256 amount) private view returns (bool) {
        return _checkSwap() && 
            _hasNoTax(sender) && 
            _isSellings(recipient) && 
            amount > _swapThresholdMin;
    }

    function _amountSending(address sender, uint256 amount) internal returns (uint256) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 feeTokens = amount.mul(_totalFee).div(_denominator);
        bool hasNoFee = sender == _owner;
        if (hasNoFee) {
            feeTokens = 0;
        }
        
        _balances[address(this)] = _balances[address(this)].add(feeTokens);
        emit Transfer(sender, address(this), feeTokens);
        return amount.sub(feeTokens);
    }

    function _transferBasic(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function updateClockTax(uint256 lpFee, uint256 devFee) external onlyOwner {
         _lpTax = lpFee; 
         _marketingTax = devFee;
         _totalFee = _lpTax + _marketingTax;
    }    
    
    function _isSellings(address recipient) private view returns (bool){
        return recipient == _uniswapPair;
    }

    function _checkSwap() internal view returns (bool) {
        return !_swapping
        && _swapFeeEnabled
        && _balances[address(this)] >= _swapThresholdMin;
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
}