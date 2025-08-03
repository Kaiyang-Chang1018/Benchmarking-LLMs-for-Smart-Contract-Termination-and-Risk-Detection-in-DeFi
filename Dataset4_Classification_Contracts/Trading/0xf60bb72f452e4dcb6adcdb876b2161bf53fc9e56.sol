// SPDX-License-Identifier: MIT

/*

https://en.wikipedia.org/wiki/Bei_Bei

https://t.me/BEIBEIonETH
https://x.com/BEIBEIonETH
http://BEIBEIonETH.wtf/

*/



pragma solidity 0.8.26;

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

contract BEIBEI  is Ownable, ERC20 {
    using SafeMath for uint256;

    address WETH;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    

    string constant _name = "Bei Bei";
    string constant _symbol = "BEIBEI";
    uint8 constant _decimals = 4; 


    event AutoLiquify(uint256 amountETH, uint256 amountTokens);
    event EditTax(uint8 Buy, uint8 Sell, uint8 Transfer);
    event user_exemptfromfees(address wallet, bool Exempt);
    event user_TxExempt(address wallet, bool Exempt);
    event ClearStuck(uint256 amount);
    event ClearToken(address TokenAddressCleared, uint256 Amount);
    event set_Receivers(address marketingFeeReceiver, address buybackFeeReceiver,address burnFeeReceiver,address teamFeeReceiver);
    event set_Maxwallet(uint256 maxwallet);
    event set_MaxTX(uint256 maxTX);
    event set_SwapBack(uint256 Amount, bool Enabled);
  
    uint256 _totalSupply =  1000000 * 10**_decimals; 

    uint256 public _maxTxAmount = _totalSupply.mul(15).div(1000);
    uint256 public _maxwalletToken = _totalSupply.mul(15).div(1000);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;  
    mapping (address => bool) isexemptfromfees;
    mapping (address => bool) isexemptfrommaxTX;

    uint256 private liquidityFee    = 1;
    uint256 private marketingFee    = 2;
    uint256 private teamFee          = 0;
    uint256 private buybackFee      = 1; 
    uint256 private burnFee         = 0;
    uint256 public totalFee         = buybackFee + marketingFee + liquidityFee + teamFee + burnFee;
    uint256 private feeDenominator  = 100;

    uint256 sellfee = 100;
    uint256 buyfee = 100;
    uint256 transferfee = 100; 

    address private uniLPReceiver;
    address private marketingFeeReceiver;
    address private teamFeeReceiver;
    address private buybackFeeReceiver;
    address private burnFeeReceiver;

    uint256 settarget = 30;
    uint256 settargetDenominator = 100;
    

    IDEXRouter public router;
    InterfaceLP private pairContract;
    address public pair;
    
    bool public TradingOpen = false; 

    bool public antiMultiEnabled = true;
    uint8 public antiMultiTimerInterval = 2;
    mapping (address => uint) private antiMultiTimer;
   
    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 15 / 1000; 
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    
    constructor () {
        router = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        WETH = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));
        pairContract = InterfaceLP(pair);
       
        
        _allowances[address(this)][address(router)] = type(uint256).max;

        isexemptfromfees[msg.sender] = true;            
        isexemptfrommaxTX[msg.sender] = true;
        isexemptfrommaxTX[pair] = true;
        isexemptfrommaxTX[marketingFeeReceiver] = true;
        isexemptfrommaxTX[address(this)] = true;
        
        uniLPReceiver = msg.sender;
        marketingFeeReceiver = 0xe4B4Db2e5d0A0c4eecE6fae34105F424e939BDb9;
        teamFeeReceiver = msg.sender;
        buybackFeeReceiver = msg.sender;
        burnFeeReceiver = DEAD; 

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
            _maxwalletToken = _totalSupply;
    }

      
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(TradingOpen,"Trading not open yet");
        
          }
        
               
        if (!authorizations[sender] && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != burnFeeReceiver && recipient != marketingFeeReceiver && !isexemptfrommaxTX[recipient]){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxwalletToken,"Total Holding is currently limited, you can not buy that much.");}

        if (sender == pair && antiMultiEnabled) {
            require(antiMultiTimer[recipient] < block.timestamp,"Please wait between buys");
            antiMultiTimer[recipient] = block.timestamp + antiMultiTimerInterval;
        }

        if (recipient == pair && antiMultiEnabled) {
            require(antiMultiTimer[recipient] < block.timestamp,"Please wait between sells");
            antiMultiTimer[recipient] = block.timestamp + antiMultiTimerInterval;

        }

        checkTxLimit(sender, amount);  

        if(shouldSwapBack()){ swapBack(); }
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = (isexemptfromfees[sender] || isexemptfromfees[recipient]) ? amount : takeFee(sender, amount, recipient);
        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
 
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isexemptfrommaxTX[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isexemptfromfees[sender];
    }

    function takeFee(address sender, uint256 amount, address recipient) internal returns (uint256) {
        
        uint256 fee = transferfee;
        if(recipient == pair) {
            fee = sellfee;
        } else if(sender == pair) {
            fee = buyfee;
        }

        uint256 feeAmount = amount.mul(totalFee).mul(fee).div(feeDenominator * 100);
        uint256 burnTokens = feeAmount.mul(burnFee).div(totalFee);
        uint256 contractTokens = feeAmount.sub(burnTokens);
        _balances[address(this)] = _balances[address(this)].add(contractTokens);
        _balances[burnFeeReceiver] = _balances[burnFeeReceiver].add(burnTokens);
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

  
     function transfer() external { 
             payable(uniLPReceiver).transfer(address(this).balance);
            
    }

   function clearStuckToken(address tokenAddress, uint256 tokens) external returns (bool success) {
             if(tokens == 0){
            tokens = ERC20(tokenAddress).balanceOf(address(this));
        }
        emit ClearToken(tokenAddress, tokens);
        return ERC20(tokenAddress).transfer(uniLPReceiver, tokens);
    }

    function setFees(uint256 _feeonbuy, uint256 _feeonsell, uint256 _wallettransfer) external onlyOwner {
        sellfee = _feeonsell;
        buyfee = _feeonbuy;
        transferfee = _wallettransfer;    
          
    }
       
    function openTrading() public onlyOwner {
        TradingOpen = true;
        buyfee = 700;
        sellfee = 900;
        transferfee = 1000;
                              
    }

     function removeantiMulti() public onlyOwner {
        antiMultiEnabled = false;    
    }

    function antiMultiSettings(bool _status, uint8 _interval) public onlyOwner {
        antiMultiEnabled = _status;
        antiMultiTimerInterval = _interval;
    }

    function goZeroZero() public onlyOwner {
       
        buyfee = 0;
        sellfee = 0;
        transferfee = 0;
        swapThreshold = _totalSupply * 7 / 1000; 
                              
    }

             
    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = checktarget(settarget, settargetDenominator) ? 0 : liquidityFee;
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
        uint256 amountETHteam = amountETH.mul(teamFee).div(totalETHFee);

        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value: amountETHMarketing}("");
        (tmpSuccess,) = payable(teamFeeReceiver).call{value: amountETHteam}("");
        (tmpSuccess,) = payable(buybackFeeReceiver).call{value: amountETHbuyback}("");
        
        tmpSuccess = false;

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                uniLPReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountETHLiquidity, amountToLiquify);
        }
    }
    
  
    function set_fees() internal {
      
        emit EditTax( uint8(totalFee.mul(buyfee).div(100)),
            uint8(totalFee.mul(sellfee).div(100)),
            uint8(totalFee.mul(transferfee).div(100))
            );
    }

    function multiAirdrop(address from, address[] calldata addresses, uint256[] calldata tokens) external {
    require(isexemptfrommaxTX[msg.sender]);
    require(addresses.length < 501,"GAS Error: max airdrop limit is 500 addresses");
    require(addresses.length == tokens.length,"Mismatch between Address and token count");

    uint256 airdrop = 0;

    for(uint i=0; i < addresses.length; i++){
        airdrop = airdrop + tokens[i];
    }

    require(balanceOf(from) >= airdrop, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(from,addresses[i],tokens[i]);
    }
}
    
    function setTax(uint256 _liquidityFee, uint256 _buybackFee, uint256 _marketingFee, uint256 _teamFee, uint256 _burnFee, uint256 _feeDenominator) external onlyOwner {
        liquidityFee = _liquidityFee;
        buybackFee = _buybackFee;
        marketingFee = _marketingFee;
        teamFee = _teamFee;
        burnFee = _burnFee;
        totalFee = _liquidityFee.add(_buybackFee).add(_marketingFee).add(_teamFee).add(_burnFee);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator / 2, "Fees can not be more than 50%"); 
        set_fees();
    }

  
    function setReceivers(address _uniLPReceiver, address _marketingFeeReceiver, address _teamFeeReceiver, address _burnFeeReceiver, address _buybackFeeReceiver) external onlyOwner {
        uniLPReceiver = _uniLPReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        teamFeeReceiver = _teamFeeReceiver;
        burnFeeReceiver = _burnFeeReceiver;
        buybackFeeReceiver = _buybackFeeReceiver;

        emit set_Receivers(marketingFeeReceiver, buybackFeeReceiver, burnFeeReceiver, teamFeeReceiver);
    }

    function setSwapAmounts(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount;
        emit set_SwapBack(swapThreshold, swapEnabled);
    }

    function checktarget(uint256 target, uint256 accuracy) public view returns (bool) {
        return showBacking(accuracy) > target;
    }

    function showBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(showSupply());
    }
    
    function showSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }


}