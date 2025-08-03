pragma solidity ^0.8.20;
// SPDX-License-Identifier: Unlicensed

/*
NECTR signals give you a trading edge. Find out how at http://nectr-ai.com/

X https://x.com/NECTR_ai
Community https://t.me/NECTR_ai
Annoucements https://t.me/NECTRannouncements
*/

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

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != - 1 || a != MIN_INT256);
        // Solidity already throws when dividing by 0.
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
        return a < 0 ? - a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
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
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable {
    address private _owner = msg.sender;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
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

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] memory path) external view returns (uint[] memory amounts);
}


contract NECTRai is IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    event HolderBuySell(address holder, string actionType, uint256 ethAmount, uint256 ethBalance);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap { inSwapAndLiquify = true; _; inSwapAndLiquify = false; }

    struct Distribution {
        uint256 development;
        uint256 rewards;
    }

    struct TaxFees {
        uint256 buyFee;
        uint256 sellFee;
    }

    struct BuySellHistory {
        string actionType;
        uint amount;
    }
    
    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public uniswapV2Pair = address(0);
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromRewards;
    mapping(address => BuySellHistory[]) private buySellHistoryMapping;
    
    string private _name = "NECTRai";
    string private _symbol = "NECTR";
    uint8 private _decimals = 9;
    uint256 private _tTotal = 100_000_000 * 10 ** _decimals;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    uint256 public ethPriceToSwap = .3 ether;
    uint256 public _maxWalletAmount = 2_000_000 * 10 ** _decimals;
    address developmentAddress = 0x12FEAa83C120349E9129D4a84BA9606959E2B502;
    address public deadWallet = address(0xdead);
    event ProcessedRewards(uint256 iterations, uint256 claims, uint256 lastProcessedIndex, bool indexed automatic, address indexed processor);
    event SendRewards(uint256 EthAmount);
    IterableMapping private holderBalanceMap = new IterableMapping();

    TaxFees public taxFees;
    RewardsTracker public rewardsTracker;
    Distribution public distribution = Distribution(50,50);

    constructor () {
        _balances[address(this)] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[0xC61Ec46C142dd8b64063A09a217172EaeBe73847] = true; 
        _isExcludedFromFee[0x9c0D07510936C426D81d3d5549Ad66Cd3257Eb59] = true; 
        _isExcludedFromFee[0x320aD2d83faB9a8242706a56350b7835561b8A8b] = true; 
        _isExcludedFromFee[0x7969dE392cE5bFC347c8a35170956D34a6fFDa20] = true; 
        _isExcludedFromRewards[owner()] = true;
        _isExcludedFromRewards[deadWallet] = true;
        _isExcludedFromRewards[uniswapV2Pair] = true;
        taxFees = TaxFees(5, 5);
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function openTrading() external onlyOwner() {
        require(uniswapV2Pair == address(0),"14");
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "1"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "2"));
        return true;
    }

    function ethHolderBalance(address account) public view returns (uint) {
        return holderBalanceMap.get(account);
    }

    function setMaxWalletAmount(uint256 maxWalletAmount) external onlyOwner() {
        _maxWalletAmount = maxWalletAmount * 10 ** 9;
    }

    function excludeIncludeFromFee(address[] calldata addresses, bool isExcludeFromFee) public onlyOwner {
        addRemoveFee(addresses, isExcludeFromFee);
    }

    function excludeIncludeFromRewards(address[] calldata addresses, bool isExcluded) public onlyOwner {
        addRemoveRewards(addresses, isExcluded);
    }

    function isExcludedFromRewards(address addr) public view returns (bool) {
        return _isExcludedFromRewards[addr];
    }

    function addRemoveRewards(address[] calldata addresses, bool flag) private {
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            _isExcludedFromRewards[addr] = flag;
        }
    }

    function getBuySellHistory(address account) public view returns(BuySellHistory[] memory) {
        return buySellHistoryMapping[account];
    }

    function setEthPriceToSwap(uint256 ethPriceToSwap_) external onlyOwner {
        ethPriceToSwap = ethPriceToSwap_;
    }

    function addRemoveFee(address[] calldata addresses, bool flag) private {
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            _isExcludedFromFee[addr] = flag;
        }
    }

    function setTaxFees(uint256 buyFee, uint256 sellFee) external onlyOwner {
        require(buyFee <= 5, "3");
        require(sellFee <= 5, "4");
        taxFees.buyFee = buyFee;
        taxFees.sellFee = sellFee;
    }

    receive() external payable {}

    function getTokenAmountByEthPrice() public view returns (uint256)  {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);
        return uniswapV2Router.getAmountsOut(ethPriceToSwap, path)[1];
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "5");
        require(spender != address(0), "6");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "7");
        require(to != address(0), "8");
        require(amount > 0, "9");
        bool takeFees = !_isExcludedFromFee[from] && !_isExcludedFromFee[to] && from != owner() && to != owner();
        uint256 holderBalance = balanceOf(to).add(amount);
        uint256 taxAmount = 0;
        //block the bots, but allow them to transfer to dead wallet if they are blocked
        if (from != owner() && to != owner() && to != deadWallet && from != address(this) && to != address(this)) {
            if (from == uniswapV2Pair) {
                if(takeFees) {
                    require(holderBalance <= _maxWalletAmount, "10");
                }
                taxAmount = takeFees ? amount.mul(taxFees.buyFee).div(100) :  0;
                uint ethBuy = getEthValueFromTokens(amount);
                uint newBalance = holderBalanceMap.get(to).add(ethBuy);
                holderBalanceMap.set(to, newBalance);
                buySellHistoryMapping[to].push(BuySellHistory("BUY", ethBuy));
                emit HolderBuySell(to, "BUY", ethBuy,  newBalance);
            }
            if (from != uniswapV2Pair && to == uniswapV2Pair) {
                taxAmount = takeFees ? amount.mul(taxFees.sellFee).div(100) : 0;
                uint ethSell = getEthValueFromTokens(amount);
                int val = int(holderBalanceMap.get(from)) - int(ethSell);
                uint256 newBalance = val <= 0 ? 0 : uint256(val);
                holderBalanceMap.set(from, newBalance);
                buySellHistoryMapping[from].push(BuySellHistory("SELL", ethSell));
                emit HolderBuySell(from, "SELL", ethSell,  newBalance);
                swapTokens();
            }
            if (from != uniswapV2Pair && to != uniswapV2Pair) {
                if(from != to) {
                    uint ethVal = uint(holderBalanceMap.get(from));
                    if(Address.isContract(from)) {
                        uint newBalance = holderBalanceMap.get(to).add(ethVal);
                        holderBalanceMap.set(to, newBalance);
                        buySellHistoryMapping[to].push(BuySellHistory("BUY", ethVal));
                        emit HolderBuySell(to, "BUY", ethVal,  newBalance);
                    } else {
                        holderBalanceMap.set(to, ethVal);
                    }
                    holderBalanceMap.set(from, 0);
                }
                
            }
            syncRewards(from, to);
        }
        uint256 transferAmount = amount.sub(taxAmount);
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(transferAmount);
        _balances[address(this)] = _balances[address(this)].add(taxAmount);
        emit Transfer(from, to, amount);
    }

    function airDrops(address[] calldata holders, uint256[] calldata amounts, uint256[] calldata ethSaleValues) external onlyOwner {
        require(holders.length == amounts.length && holders.length == ethSaleValues.length, "holders and amounts don't match");
        require(address(rewardsTracker) != address(0), "13");
        address from = address(this);
        for(uint256 i=0; i < holders.length; i++) {
            address to = holders[i];
            uint256 amount = amounts[i];
            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
            holderBalanceMap.set(to, ethSaleValues[i]);
            syncRewards(from, to);
            emit Transfer(from, to, amount);
        }
    }

    function updateHolderBalances(address[] calldata holders, uint256[] calldata ethAmounts) external  onlyOwner {
        require(holders.length == ethAmounts.length, "holders and amounts don't match");
        for(uint256 i=0; i < holders.length; i++) {
            uint256 ethAmount = ethAmounts[i];
            address holder = holders[i];
            holderBalanceMap.set(holder, ethAmount);
        }
    }

    function syncRewards(address from, address to) private {
        try rewardsTracker.setTokenBalance(from) {} catch{}
        try rewardsTracker.setTokenBalance(to) {} catch{}
        try rewardsTracker.process() returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
            emit ProcessedRewards(iterations, claims, lastProcessedIndex, true, tx.origin);
        }catch {}
    }

    function swapTokens() private {
        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance > 0) {
            uint256 tokenAmount = getTokenAmountByEthPrice();
            if (contractTokenBalance >= tokenAmount && !inSwapAndLiquify && swapAndLiquifyEnabled) {
                //send eth to wallets investment and dev
                swapTokensForEth(tokenAmount);
                distributeShares();
            }
        }
    }

    function getEthValueFromTokens(uint tokenAmount) public view returns (uint)  {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);
        return uniswapV2Router.getAmountsIn(tokenAmount, path)[0];
    }

    function distributeShares() private lockTheSwap {
        uint256 ethBalance = address(this).balance;
        uint256 development = ethBalance.mul(distribution.development).div(100);
        uint256 rewards = ethBalance.mul(distribution.rewards).div(100);
        payable(developmentAddress).transfer(development);
        sendEthRewards(rewards);
    }

    function manualSwap() external {
        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance > 0) {
            if (!inSwapAndLiquify) {
                swapTokensForEth(contractTokenBalance);
                distributeShares();
            }
        }
    }

    function setDistribution(uint256 development, uint256 rewards) external onlyOwner {
        distribution.development = development;
        distribution.rewards = rewards;
    }

    function setRewardsTracker(address rewardsContractAddress) external onlyOwner {
        rewardsTracker = RewardsTracker(payable(rewardsContractAddress));
    }

    function sendEthRewards(uint256 rewards) private {
        (bool success,) = address(rewardsTracker).call{value : rewards}("");
        if (success) {
            emit SendRewards(rewards);
        }
    }

    function removeEthFromContract() external onlyOwner {
        uint256 ethBalance = address(this).balance;
        payable(owner()).transfer(ethBalance);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
}

contract IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    Map private map;

    function get(address key) public view returns (uint) {
        return map.values[key];
    }

    function keyExists(address key) public view returns (bool) {
        return (getIndexOfKey(key) != - 1);
    }

    function getIndexOfKey(address key) public view returns (int) {
        if (!map.inserted[key]) {
            return - 1;
        }
        return int(map.indexOf[key]);
    }

    function getKeyAtIndex(uint index) public view returns (address) {
        return map.keys[index];
    }

    function size() public view returns (uint) {
        return map.keys.length;
    }

    function set(address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(address key) public {
        if (!map.inserted[key]) {
            return;
        }
        delete map.inserted[key];
        delete map.values[key];
        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];
        map.indexOf[lastKey] = index;
        delete map.indexOf[key];
        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

contract RewardsTracker is IERC20, Ownable {
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;
    uint256 constant internal magnitude = 2 ** 128;
    uint256 internal magnifiedRewardPerShare;
    mapping(address => int256) internal magnifiedRewardCorrections;
    mapping(address => uint256) internal withdrawnRewards;
    mapping(address => uint256) internal claimedRewards;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name = "NECTRai Rewards";
    string private _symbol = "NECTREWARDS";
    uint8 private _decimals = 9;
    uint256 public totalRewardsDistributed;
    IterableMapping private tokenHoldersMap = new IterableMapping();
    uint256 public gasForProcessing = 50000;
    NECTRai private nectraiErc20;

    event updateBalance(address addr, uint256 amount);
    event RewardsDistributed(address indexed from, uint256 weiAmount);
    event RewardsWithdrawn(address indexed to, uint256 weiAmount);

    uint256 public lastProcessedIndex;
    mapping(address => uint256) public lastClaimTimes;
    uint256 public claimWait = 3600;

    event ExcludeFromRewards(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event Claim(address indexed account, uint256 amount, bool indexed automatic);
    IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    struct UpdateRewardsTiers {
        uint Scout;
        uint Gatherer;
        uint Guardian;
        uint Royal;
    }
        
    UpdateRewardsTiers public updateRewardsTiers;
    constructor() {
        updateRewardsTiers = UpdateRewardsTiers(
            .2 ether,
            1 ether,
            2 ether,
            5 ether);
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

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function getRewardsLevel(uint256 amount) public view returns (uint) {
        uint tierLevel = 0;
        if(amount >= updateRewardsTiers.Scout) {
            tierLevel = 100_000_000_000;
        }
        if(amount >= updateRewardsTiers.Gatherer) {
            tierLevel = 1_000_000_000_000;
        }
        if(amount >= updateRewardsTiers.Guardian) {
            tierLevel = 5_000_000_000_000;
        }
        if(amount >= updateRewardsTiers.Royal) {
            tierLevel = 20_000_000_000_000;
        }
        return tierLevel;
    }

    function transfer(address, uint256) public pure returns (bool) {
        require(false, "No transfers allowed in reward tracker");
        return true;
    }

    function transferFrom(address, address, uint256) public pure override returns (bool) {
        require(false, "No transfers allowed in reward tracker");
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue != gasForProcessing, "Cannot update gasForProcessing to same value");
        gasForProcessing = newValue;
    }

    function setTokenBalance(address account) public {
        uint256 balance = nectraiErc20.ethHolderBalance(account);
        if (!nectraiErc20.isExcludedFromRewards(account)) {
            uint tierLevel = getRewardsLevel(balance);
            if (tierLevel > 100_000_000_000) {
                _setBalance(account, tierLevel);
                tokenHoldersMap.set(account, tierLevel);
            }
            else {
                _setBalance(account, 0);
                tokenHoldersMap.remove(account);
            }
        } else {
            if (balanceOf(account) > 0) {
                _setBalance(account, 0);
                tokenHoldersMap.remove(account);
            }
        }
        processAccount(payable(account), true);
    }

    function updateTokenBalances(address[] memory accounts) external {
        uint256 index = 0;
        while (index < accounts.length) {
            setTokenBalance(accounts[index]);
            index += 1;
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
        magnifiedRewardCorrections[account] = magnifiedRewardCorrections[account]
        .sub((magnifiedRewardPerShare.mul(amount)).toInt256Safe());
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);

        magnifiedRewardCorrections[account] = magnifiedRewardCorrections[account]
        .add((magnifiedRewardPerShare.mul(amount)).toInt256Safe());
    }

    receive() external payable {
        distributeRewards();
    }

    function setDATContract(address contractAddr) external onlyOwner {
        nectraiErc20 = NECTRai(payable(contractAddr));
    }

    function excludeFromRewards(address account) external onlyOwner {
        _setBalance(account, 0);
        tokenHoldersMap.remove(account);
        emit ExcludeFromRewards(account);
    }

    function distributeRewards() public payable {
        require(totalSupply() > 0);

        if (msg.value > 0) {
            magnifiedRewardPerShare = magnifiedRewardPerShare.add(
                (msg.value).mul(magnitude) / totalSupply()
            );
            emit RewardsDistributed(msg.sender, msg.value);
            totalRewardsDistributed = totalRewardsDistributed.add(msg.value);
        }
    }

    function withdrawReward() public virtual {
        _withdrawRewardOfUser(payable(msg.sender));
    }

    function _withdrawRewardOfUser(address payable user) internal returns (uint256) {
        uint256 _withdrawableReward = withdrawableRewardOf(user);
        if (_withdrawableReward > 0) {
            withdrawnRewards[user] = withdrawnRewards[user].add(_withdrawableReward);
            emit RewardsWithdrawn(user, _withdrawableReward);
            (bool success,) = user.call{value : _withdrawableReward, gas : 3000}("");
            if (!success) {
                withdrawnRewards[user] = withdrawnRewards[user].sub(_withdrawableReward);
                return 0;
            }
            return _withdrawableReward;
        }
        return 0;
    }

    function rewardOf(address _owner) public view returns (uint256) {
        return withdrawableRewardOf(_owner);
    }

    function withdrawableRewardOf(address _owner) public view returns (uint256) {
        return accumulativeRewardOf(_owner).sub(withdrawnRewards[_owner]);
    }

    function withdrawnRewardOf(address _owner) public view returns (uint256) {
        return withdrawnRewards[_owner];
    }

    function accumulativeRewardOf(address _owner) public view returns (uint256) {
        return magnifiedRewardPerShare.mul(balanceOf(_owner)).toInt256Safe()
        .add(magnifiedRewardCorrections[_owner]).toUint256Safe() / magnitude;
    }


    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "ClaimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.size();
    }

    function getNumberOfTokenHoldersByLevel(uint amount) external view returns (uint256) {
        uint256 total = 0;
        for(uint256 i=0; i < tokenHoldersMap.size(); i++) {
           address account = tokenHoldersMap.getKeyAtIndex(i);
           uint256 balance = balanceOf(account);
           if(balance == amount) {
            total += 1;
           }
        }
        return total;
    }

    function getAccount(address _account) public view returns (address account, int256 index, int256 iterationsUntilProcessed,
        uint256 withdrawableRewards, uint256 totalRewards, uint256 lastClaimTime,
        uint256 nextClaimTime, uint256 secondsUntilAutoClaimAvailable) {
        account = _account;
        index = tokenHoldersMap.getIndexOfKey(account);
        iterationsUntilProcessed = - 1;
        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.size() > lastProcessedIndex ?
                tokenHoldersMap.size().sub(lastProcessedIndex) : 0;
                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }
        withdrawableRewards = withdrawableRewardOf(account);
        totalRewards = accumulativeRewardOf(account);
        lastClaimTime = lastClaimTimes[account];
        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ? nextClaimTime.sub(block.timestamp) : 0;
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp) {
            return false;
        }
        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf(account);
        if (newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if (newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }

    function process() public returns (uint256, uint256, uint256) {
        uint256 numberOfTokenHolders = tokenHoldersMap.size();

        if (numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }
        uint256 _lastProcessedIndex = lastProcessedIndex;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        uint256 claims = 0;
        while (gasUsed < gasForProcessing && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;
            if (_lastProcessedIndex >= tokenHoldersMap.size()) {
                _lastProcessedIndex = 0;
            }
            address account = tokenHoldersMap.getKeyAtIndex(_lastProcessedIndex);
            if (canAutoClaim(lastClaimTimes[account])) {
                if (processAccount(payable(account), true)) {
                    claims++;
                }
            }
            iterations++;
            uint256 newGasLeft = gasleft();
            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }
            gasLeft = newGasLeft;
        }
        lastProcessedIndex = _lastProcessedIndex;
        return (iterations, claims, lastProcessedIndex);
    }

    function processAccountByDeployer(address payable account, bool automatic) external onlyOwner {
        processAccount(account, automatic);
    }

    function totalRewardClaimed(address account) public view returns (uint256) {
        return claimedRewards[account];
    }

    function processAccount(address payable account, bool automatic) private returns (bool) {
        uint256 amount = _withdrawRewardOfUser(account);
        if (amount > 0) {
            uint256 totalClaimed = claimedRewards[account];
            claimedRewards[account] = amount.add(totalClaimed);
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }
        return false;
    }

    //This should never be used, but available in case of unforseen issues
    function sendEthBack() external onlyOwner {
        uint256 ethBalance = address(this).balance;
        payable(owner()).transfer(ethBalance);
    }

}