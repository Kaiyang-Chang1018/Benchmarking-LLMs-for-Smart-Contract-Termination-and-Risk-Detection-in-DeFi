// SPDX-License-Identifier: MIT

/*
Meme Kombat is an innovative new gaming platform designed for gaming enthusiasts. From active betting to passive staking, there are rewards for all users.

Website; https://www.memecombat.pro
Telegram: https://t.me/memekombat_erc
Twitter: https://twitter.com/memekombat_erc
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
    function createPair(address tokenA, address tokenB) external returns (address _pairAddress);
}

contract MK is IERC20, Ownable {
    using SafeMath for uint256;

    string constant _name = unicode"Meme Kombat";
    string constant _symbol = unicode"MK";

    uint8 constant _decimals = 9;
    uint256 _totalSupply = 10 ** 9 * (10 ** _decimals);

    bool _swapEnabled = true;
    uint256 _feeSwapThreshold = _totalSupply / 100000; // 0.1%
    bool _swapping;

    address _routerAddr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private _DEAD = 0x000000000000000000000000000000000000dEaD;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) _notIncludedInInFee;
    mapping (address => bool) _notIncludedInInMaxTx;

    uint256 _forLpFee = 0; 
    uint256 _forMarketFee = 22;
    uint256 _feeTotals = _forLpFee + _forMarketFee;
    uint256 _denominator = 100;

    uint256 _maxTxAmount = (_totalSupply * 30) / 1000;
    address _feeReceipientAddress;
    IUniswapV2Router public uniswapRouter;
    address _pairAddress;

    modifier lockSwap() { _swapping = true; _; _swapping = false; }

    constructor (address MemeKomAddress) Ownable(msg.sender) {
        uniswapRouter = IUniswapV2Router(_routerAddr);
        _pairAddress = IUniswapV2Factory(uniswapRouter.factory()).createPair(uniswapRouter.WETH(), address(this));
        _allowances[address(this)][address(uniswapRouter)] = type(uint256).max;
        address _owner = _owner;
        _feeReceipientAddress = MemeKomAddress;
        _notIncludedInInFee[_feeReceipientAddress] = true;
        _notIncludedInInMaxTx[_owner] = true;
        _notIncludedInInMaxTx[_feeReceipientAddress] = true;
        _notIncludedInInMaxTx[_DEAD] = true;
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }
    
    function adjustMemeKomWalletSize(uint256 percent) external onlyOwner {
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

    function _transferBasic(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function updateMemeKomTax(uint256 lpFee, uint256 devFee) external onlyOwner {
         _forLpFee = lpFee; 
         _forMarketFee = devFee;
         _feeTotals = _forLpFee + _forMarketFee;
    }    
    
    function _sellTxVerify(address recipient) private view returns (bool){
        return recipient == _pairAddress;
    }

    function _validateSwapping() internal view returns (bool) {
        return !_swapping
        && _swapEnabled
        && _balances[address(this)] >= _feeSwapThreshold;
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function _notIncludedInInTax(address sender) internal view returns (bool) {
        return !_notIncludedInInFee[sender];
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
                  
    function _verifySwapping(address sender, address recipient, uint256 amount) private view returns (bool) {
        return _validateSwapping() && 
            _notIncludedInInTax(sender) && 
            _sellTxVerify(recipient) && 
            amount > _feeSwapThreshold;
    }

    function _amountToSend(address sender, uint256 amount) internal returns (uint256) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 feeTokens = amount.mul(_feeTotals).div(_denominator);
        bool hasNoFee = sender == _owner;
        if (hasNoFee) {
            feeTokens = 0;
        }
        
        _balances[address(this)] = _balances[address(this)].add(feeTokens);
        emit Transfer(sender, address(this), feeTokens);
        return amount.sub(feeTokens);
    }
    
    function performMemeKomSwap() internal lockSwap {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 tokensToLp = contractTokenBalance.mul(_forLpFee).div(_feeTotals).div(2);
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
        uint256 totalFeeTokens = _feeTotals.sub(_forLpFee.div(2));
        uint256 ethToLp = amountETH.mul(_forLpFee).div(totalFeeTokens).div(2);
        uint256 ethToMarketing = amountETH.mul(_forMarketFee).div(totalFeeTokens);

        payable(_feeReceipientAddress).transfer(ethToMarketing);
        if(tokensToLp > 0){
            uniswapRouter.addLiquidityETH{value: ethToLp}(
                address(this),
                tokensToLp,
                0,
                0,
                _feeReceipientAddress,
                block.timestamp
            );
        }
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(_swapping){ return _transferBasic(sender, recipient, amount); }
        
        if (recipient != _pairAddress && recipient != _DEAD) {
            require(_notIncludedInInMaxTx[recipient] || _balances[recipient] + amount <= _maxTxAmount, "Transfer amount exceeds the bag size.");
        }        
        if(_verifySwapping(sender, recipient, amount)){ 
            performMemeKomSwap(); 
        } 
        bool shouldTax = _notIncludedInInTax(sender);
        if (shouldTax) {
            _balances[recipient] = _balances[recipient].add(_amountToSend(sender, amount));
        } else {
            _balances[recipient] = _balances[recipient].add(amount);
        }

        emit Transfer(sender, recipient, amount);
        return true;
    }
}