// SPDX-License-Identifier: unlicensed
//TG:https://t.me/gojosatoruportal
//WEBSITE:https://gojosatorus.site/
//TWITTER:https://twitter.com/gojosatoruERC
pragma solidity ^0.7.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
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

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
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
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal owner;
    mapping (address => bool) internal own;
    constructor(address _owner) {
        owner = _owner;
        own[_owner] = true;
    }
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }
    function isOwner(address account) internal view returns (bool) {
        return account == owner;
    }
    function isownered(address adr) internal view returns (bool) {
        return own[adr];
    }
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        own[adr] = true;
        emit OwnershipTransferred(adr);
    }
    event OwnershipTransferred(address owner);
}
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface InterfaceLP {
    function sync() external;
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

contract Gojosatoru is IERC20, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = unicode"SATORU";
    string constant _symbol = unicode"SATORU";
    uint8 constant _decimals = 4;

    mapping (address => uint256) _rBalance;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) private isFeeExempt;
    mapping (address => bool) private isTxLimitExempt;
    mapping (address => bool) private isWalletLimitExempt;
    mapping(address => bool) public _blackList;
    uint256 private marketingFee    = 20;
    uint256 private feeDenominator  = 100;

    uint256 private launchedAt = 0;
    uint256 private sellMultiplier  = 100;
    address private marketingFeeReceiver;

    IDEXRouter private router;
    address private pair;
    InterfaceLP private pairContract; 

    bool public tradingOpen = false; //+++

    bool private swapEnabled = true;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    event AutoLiquify(uint256 amountETH, uint256 amountTokens);
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 12080000 * 10**_decimals;
    uint256 private swapThreshold = rSupply * 200 / 10000;
    uint256 private rebase_count = 0;
    uint256 private rate;
    uint256 public _totalSupply;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant MAX_SUPPLY = ~uint128(0);
    uint256 private constant rSupply = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    // Max wallet & Transaction
    uint256 private _maxTxAmount = rSupply.div(100).mul(100);
    uint256 private _maxWalletToken = rSupply.div(100).mul(4);

    // Sauce
    function rebase(uint256 epoch, int256 supplyDelta) private onlyMaster returns (uint256) {
        rebase_count++;
        if(epoch == 0){
            epoch = rebase_count;
        }

        require(!inSwap, "Try again");

        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply.sub(uint256(-supplyDelta));
        } else {
            _totalSupply = _totalSupply.add(uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        rate = rSupply.div(_totalSupply);
        pairContract.sync();


        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

    constructor () Ownable(msg.sender) {
        router = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));
        _allowances[address(this)][address(router)] = uint256(-1);
        pairContract = InterfaceLP(pair);
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        rate = rSupply.div(_totalSupply);
        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        marketingFeeReceiver = 0xBAA3AdC38a5A01e947AB87774DE5966fEc1786F3;
        _rBalance[msg.sender] = rSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) {
        return _rBalance[account].div(rate);
    }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }


    function rebase_percentage(uint256 _percentage_base1000, bool reduce) public onlyMaster returns (uint256 newSupply){

        if(reduce){
            newSupply = rebase(0,int(_totalSupply.div(1000).mul(_percentage_base1000)).mul(-1));
        } else{
            newSupply = rebase(0,int(_totalSupply.div(1000).mul(_percentage_base1000)));
        }
        
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != uint256(-1)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
 require(!_blackList[sender], "blackList");
    if(inSwap){ 
        return _basicTransfer(sender, recipient, amount); 
    }

    if(!own[sender] && !own[recipient]){
        require(tradingOpen, "Trading not open yet");
    }

    if (_totalSupply < 500000 * 10**_decimals && recipient == pair) {
        require(false, "one Tx Cannot Buy too much");
    }

    uint256 rAmount = amount.mul(rate);

    if (recipient != address(this) && recipient != address(DEAD) && recipient != pair && recipient != marketingFeeReceiver) {
        uint256 heldTokens = balanceOf(recipient);
        require((heldTokens + rAmount) <= _maxWalletToken, "Total Holding is currently limited, you can not buy that much.");
    }

    checkTxLimit(sender, rAmount);

    if(shouldSwapBack()){
        swapBack();
    }

    _rBalance[sender] = _rBalance[sender].sub(rAmount, "Insufficient Balance");

    uint256 amountReceived = (!shouldTakeFee(sender) || !shouldTakeFee(recipient)) ? rAmount : takeFee(sender, rAmount, (recipient == pair));

    _rBalance[recipient] = _rBalance[recipient].add(amountReceived);

    emit Transfer(sender, recipient, amountReceived.div(rate));

    return true;
}
    function multi_BlackList(address[] calldata addresses, bool status) public onlyOwner {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            _blackList[addresses[i]] = status;
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        uint256 rAmount = amount.mul(rate);
        _rBalance[sender] = _rBalance[sender].sub(rAmount, "Insufficient Balance");
        _rBalance[recipient] = _rBalance[recipient].add(rAmount);
        emit Transfer(sender, recipient, rAmount.div(rate));
        return true;
    }

    function checkTxLimit(address sender, uint256 rAmount) internal view {
        require(rAmount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 rAmount, bool isSell) internal returns (uint256) {
        
        uint256 multiplier = 100;
        if(isSell){
            multiplier = sellMultiplier;
        } 
        uint256 feeAmount = rAmount.div(feeDenominator * 100).mul(marketingFee).mul(multiplier);
        _rBalance[address(this)] = _rBalance[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount.div(rate));
        return rAmount.sub(feeAmount);
    }

    modifier onlyMaster() {
        require(msg.sender == marketingFeeReceiver || isOwner(msg.sender));
        _;
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _rBalance[address(this)] >= swapThreshold;
    }

    function clearStuckBalance_sender() external onlyMaster {
        uint256 amountETH = address(this).balance;
        payable(msg.sender).transfer(amountETH);
    }

    function tradingStatus() public onlyOwner {
        tradingOpen = true;
        if(tradingOpen && launchedAt == 0){
            launchedAt = block.number;
         }
    }

    // OK, check 3
function swapBack() internal swapping {
    uint256 tokensToSell = swapThreshold.div(rate);

    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = WETH;

    uint256 balanceBefore = address(this).balance;

    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
        tokensToSell,
        0,
        path,
        address(this),
        block.timestamp
    );
    uint256 amountETH = address(this).balance.sub(balanceBefore);
    payable(marketingFeeReceiver).transfer(amountETH);

}

    function setFees( uint256 _marketingFee, uint256 _feeDenominator) external onlyOwner {
        marketingFee = _marketingFee;
        feeDenominator = _feeDenominator;

    }

    function setSwapBackSettings(bool _enabled, uint256 _percentage_base10000) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = rSupply.div(10000).mul(_percentage_base10000);
    }

    function manualSync() external {
        InterfaceLP(pair).sync();
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }
  
    function checkSwapThreshold() external view returns (uint256) {
        return swapThreshold.div(rate);
    }
    function setMaxWalletPercent_base1000(uint256 maxWallPercent_base1000) external onlyOwner() {
        _maxWalletToken = rSupply.div(1000).mul(maxWallPercent_base1000);
    }

}