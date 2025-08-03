// SPDX-License-Identifier: UNLICENSE

/*

 DApp:      kugo.finance
 Website:   kirokugo.com
 Telegram:  t.me/kirokugo
 Twitter:   x.com/KIROKUGO
 Gitbook:   kugo.gitbook.io/kugo
 Medium:    medium.com/@kirokugo

*/

pragma solidity 0.8.28;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
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

}

contract Ownable is Context {
    address private _owner;
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

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
}

contract KUGO is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isStakingPool; 
    mapping(address => StakeInfo) private _stakeInfo; 
    mapping(address => uint256) private _farmingRewards; 
    mapping(address => uint256) private _lastStakeTimestamp;
    mapping(address => bool) private _isYieldController; 
    mapping (address => bool) private bots;

    address payable private _rewardPool = payable(0x9F4fD2889327856acbE9f9431fb837597f86111F);
    address payable private _burnPool = payable(0x395749033c4216D1b458aFDcC2a23AE3926303CC);
    address payable private _treasuryPool = payable(0x3218Ca8d31e6d75D7bE32FAda43720e15fd755Ac);

    struct StakeInfo {
        uint256 amount;
        uint256 timestamp;
        uint256 lockPeriod;
        uint256 rewardDebt;
    }

    address payable private _kugoDeployer;
    string private constant _name = unicode"KugoFi";
    string private constant _symbol = unicode"KUGO";

    uint256 private _initialBuyTax=20;
    uint256 private _initialSellTax=20;
    uint256 private _finalBuyTax=5;
    uint256 private _finalSellTax=5;
    uint256 private _reduceBuyTaxAt=30;
    uint256 private _reduceSellTaxAt=50;
    uint256 private _preventSwapBefore=30;
    uint256 private _mevFee=50;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100000000000 * 10**_decimals;
    uint256 public _maxTxAmount = 750000000 * 10**_decimals;
    uint256 public _maxWalletSize = 750000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 100000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 400000000 * 10**_decimals;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    
    event MaxTxAmountUpdated(uint _maxTxAmount);
    event MevFeeUpdated(uint _tax);
    event StakePoolRegistered(address indexed pool, bool status);
    event YieldControllerUpdated(address indexed controller, bool status);
    event StakingPositionUpdated(address indexed user, uint256 amount, uint256 lockPeriod);
    event RewardsClaimed(address indexed user, uint256 amount);
    event BurnExecuted(uint256 amount, uint256 timestamp);
    event YieldStrategyUpdated(uint256 strategyId, bool enabled);
    
    event RewardPoolUpdated(address indexed oldPool, address indexed newPool);
    event BurnPoolUpdated(address indexed oldPool, address indexed newPool);
    event TreasuryPoolUpdated(address indexed oldPool, address indexed newPool);
    
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _kugoDeployer = payable(_msgSender());
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_kugoDeployer] = true;

        _isExcludedFromFee[_rewardPool] = true;
        _isExcludedFromFee[_burnPool] = true;
        _isExcludedFromFee[_treasuryPool] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function registerStakingPool(address _pool, bool _status) external onlyOwner {
        _isStakingPool[_pool] = _status;
        emit StakePoolRegistered(_pool, _status);
    }

    function setYieldController(address _controller, bool _status) external onlyOwner {
        _isYieldController[_controller] = _status;
        emit YieldControllerUpdated(_controller, _status);
    }

    function isStakingPool(address _pool) public view returns (bool) {
        return _isStakingPool[_pool];
    }

    function getStakeInfo(address _user) public view returns (StakeInfo memory) {
        return _stakeInfo[_user];
    }

    function getFarmingRewards(address _user) public view returns (uint256) {
        return _farmingRewards[_user];
    }

    function getLastStakeTimestamp(address _user) public view returns (uint256) {
        return _lastStakeTimestamp[_user];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);

            if(_buyCount==0){
                taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
            }
            if(_buyCount>0){
                taxAmount = amount.mul(_mevFee).div(100);
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                _buyCount++;
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > lastSellBlock) {
                    sellCount = 0;
                }
                require(sellCount < 3, "Only 3 sells per block!");
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                sellCount++;
                lastSellBlock = block.number;
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function setRewardPool(address payable newPool) external onlyOwner {
        require(newPool != address(0), "Invalid address");
        address oldPool = _rewardPool;
        _isExcludedFromFee[oldPool] = false; 
        _rewardPool = newPool;
        _isExcludedFromFee[newPool] = true; 
        emit RewardPoolUpdated(oldPool, newPool);
    }

    function setBurnPool(address payable newPool) external onlyOwner {
        require(newPool != address(0), "Invalid address");
        address oldPool = _burnPool;
        _isExcludedFromFee[oldPool] = false; 
        _burnPool = newPool;
        _isExcludedFromFee[newPool] = true; 
        emit BurnPoolUpdated(oldPool, newPool);
    }

    function setTreasuryPool(address payable newPool) external onlyOwner {
        require(newPool != address(0), "Invalid address");
        address oldPool = _treasuryPool;
        _isExcludedFromFee[oldPool] = false; 
        _treasuryPool = newPool;
        _isExcludedFromFee[newPool] = true; 
        emit TreasuryPoolUpdated(oldPool, newPool);
    }

    function getRewardPool() public view returns (address) {
        return _rewardPool;
    }

    function getBurnPool() public view returns (address) {
        return _burnPool;
    }

    function getTreasuryPool() public view returns (address) {
        return _treasuryPool;
    }

    function removeLimits() external onlyOwner{
        _maxTxAmount = _tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function removeMevFee() external onlyOwner{
        _mevFee = 0;
        emit MevFeeUpdated(0);
    }

    function sendETHToFee(uint256 amount) private {
        uint256 rewardShare = amount.mul(2).div(5);
        uint256 burnShare = amount.mul(1).div(5);
        uint256 treasuryShare = amount.sub(rewardShare).sub(burnShare);

        _rewardPool.transfer(rewardShare);
        _burnPool.transfer(burnShare);
        _treasuryPool.transfer(treasuryShare);
    }
    
    function getSystemMetrics() external view returns (
        uint256 totalStaked,
        uint256 totalRewards,
        uint256 burnedTokens
    ) {
        totalStaked = balanceOf(address(this));
        totalRewards = address(this).balance;
        burnedTokens = _tTotal.sub(totalSupply());
    }

    function executeBurn(uint256 _amount) private {
        require(_amount > 0, "Burn amount must be greater than 0");
        _balances[address(this)] = _balances[address(this)].sub(_amount);
        emit BurnExecuted(_amount, block.timestamp);
    }

    function calculateTimeWeight(address _user) public view returns (uint256) {
        uint256 stakeDuration = block.timestamp.sub(_lastStakeTimestamp[_user]);
        return stakeDuration;
    }

    modifier onlyYieldController() {
        require(_isYieldController[msg.sender], "Caller is not a yield controller");
        _;
    }

    function addBots(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function delBots(address[] memory notbot) public onlyOwner {
      for (uint i = 0; i < notbot.length; i++) {
          bots[notbot[i]] = false;
      }
    }

    function isBot(address a) public view returns (bool){
      return bots[a];
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
    
    function reduceFee(uint256 _newFee) external{
      require(_msgSender()==_kugoDeployer);
      require(_newFee<=_finalBuyTax && _newFee<=_finalSellTax);
      _finalBuyTax=_newFee;
      _finalSellTax=_newFee;
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender()==_kugoDeployer);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    function manualsend() external {
        require(_msgSender()==_kugoDeployer);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
}