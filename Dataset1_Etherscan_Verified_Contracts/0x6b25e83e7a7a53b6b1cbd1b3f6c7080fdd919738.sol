//SPDX-License-Identifier: MIT


/*

telegram : https://t.me/ironmuskk
twitter : https://twitter.com/Ironmuskerc

*/

pragma solidity ^0.8.0;

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

abstract contract OwnableL {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
    }
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }
    event OwnershipTransferred(address owner);
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
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
}

contract IRONMUSK is ERC20, OwnableL {
    using SafeMath for uint256;
    address routerAdress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; 
    address DEAD = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "IRONMUSK";
    string constant _symbol = "IRM";
    uint8 constant _decimals = 18;

    uint256 public _totalSupply = 1000000 * (10 ** _decimals);
    uint256 public _maxWalletAmount = (_totalSupply * 2) / 100; // 2%
    uint256 public _maxTxAmount = _totalSupply.mul(100).div(100); //100%

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) _auth;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;

    mapping  (address => bool) public isBlacklist;
    mapping (address => uint256) public antiMev;

    bool public activeBlacklist = true;

    uint256  buymarketingFee = 0;
    uint256  buydevFee = 0;
    uint256  buyliquidityFee = 0;
    uint256  buytotalFee = buydevFee + buymarketingFee + buyliquidityFee;

    uint256  sellmarketingFee = 0;
    uint256  selldevFee = 0;
    uint256  sellliquidityFee = 0;
    uint256  selltotalFee = selldevFee + sellmarketingFee + sellliquidityFee;

    uint256 public totalFee = buytotalFee + selltotalFee;
    
    uint256 feeDenominator = 100;

    bool public activeFees = true;

    address public buymarketingFeeReceiver = 0x55914093b3B578172b715acE067d8806aE7692DF;
    address public buydevFeeReceiver = 0xb841a53019ecE55E510183A7FDdafF81aAb4B0D4;

    IDEXRouter public router;
    address public pair;

    bool public swapEnabled = true;
    uint256 public swapThreshold = (_totalSupply * 2) / 2000; // 0.1%
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    modifier onlyAuth() {
        require(_auth[msg.sender], "not auth "); _;
    }

    constructor () OwnableL(msg.sender) {
        router = IDEXRouter(routerAdress);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        address _owner = owner;

        _auth[msg.sender] = true;

        isFeeExempt[_owner] = true;
        isFeeExempt[buymarketingFeeReceiver] = true;
        isTxLimitExempt[_owner] = true;
        isTxLimitExempt[buymarketingFeeReceiver] = true;
        isTxLimitExempt[DEAD] = true;

        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
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

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if (antiMev[sender] == block.number && recipient == pair && sender != owner && sender !=  address(this)) { 
            isBlacklist[sender] = true;
        }

        if (activeBlacklist) {
            require(!isBlacklist[sender], "Wallet blacklist");
        }

        bool buy = false;
        
        if (recipient != pair && recipient != DEAD) {
            require(isTxLimitExempt[recipient] || _balances[recipient] + amount <= _maxWalletAmount, "Transfer amount exceeds the bag size.");
            antiMev[recipient] = block.number;
            buy = true;
        }

        if (activeFees) {
            if(shouldSwapBack()){ swapBack(); }
        }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = amount;
        
        if (activeFees) {
            amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount, buy) : amount;
        }
        
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

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 amount, bool buy) internal returns (uint256) {

        if (buy){
            uint256 feeAmount = amount.mul(buytotalFee).div(feeDenominator);
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
            return amount.sub(feeAmount);
        }
        else {
            uint256 feeAmount = amount.mul(selltotalFee).div(feeDenominator);
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
            return amount.sub(feeAmount);
        }
        
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 contractTokenBalance = _balances[address(this)]; 

        uint256 amountToSwap = contractTokenBalance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        address[] memory path2 = new address[](2);
        path2[1] = address(this);
        path2[0] = router.WETH();

        uint256 balanceBefore = address(this).balance; 

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp 
        ); 

        uint256 amountETH = address(this).balance.sub(balanceBefore);

        uint256 buyamountETH = (amountETH * (buytotalFee * 100 / totalFee)) / 100; 
        uint256 sellamountETH = (amountETH * (selltotalFee * 100 / totalFee)) / 100; 

        uint256 amountETHDev = buyamountETH.mul(buydevFee).div(buytotalFee) + sellamountETH.mul(selldevFee).div(selltotalFee); 
        uint256 amountETHMarketing = buyamountETH.mul(buymarketingFee).div(buytotalFee) + sellamountETH.mul(sellmarketingFee).div(selltotalFee); 
        uint256 amountETHLiquidity = buyamountETH.mul(buyliquidityFee).div(buytotalFee) + sellamountETH.mul(sellliquidityFee).div(selltotalFee); 

        (bool DevSuccess, ) = payable(buydevFeeReceiver).call{value: amountETHDev, gas: 30000}("");
        require(DevSuccess, "receiver rejected ETH transfer");
        (bool MarketingSuccess, ) = payable(buymarketingFeeReceiver).call{value: amountETHMarketing, gas: 30000}("");
        require(MarketingSuccess, "receiver rejected ETH transfer");

        uint[] memory amounts = router.swapExactETHForTokens{value: amountETHLiquidity}(
            0,
            path2,
            pair,
            block.timestamp
        );

         _balances[address(this)] = _balances[address(this)].add(amounts[1]);
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
    }

    function clearStuckBalance() external {
        payable(buydevFeeReceiver).transfer(address(this).balance);
    }

    function setWalletLimit(uint256 amountPercent) external onlyOwner {
        _maxWalletAmount = (_totalSupply * amountPercent ) / 100;
    }

    function setFee(uint256 _buydevFee, uint256 _buymarketingFee, uint256 _buyliquidityFee, uint256 _selldevFee, uint256 _sellmarketingFee, uint256 _sellliquidityFee) external onlyOwner {
        buydevFee = _buydevFee;
        buymarketingFee = _buymarketingFee;
        buyliquidityFee = _buyliquidityFee;
        buytotalFee = buydevFee + buymarketingFee + buyliquidityFee;

        selldevFee = _selldevFee;
        sellmarketingFee = _sellmarketingFee;
        sellliquidityFee = _sellliquidityFee;
        selltotalFee = selldevFee + sellmarketingFee + sellliquidityFee;

        totalFee = buytotalFee + selltotalFee;
    }

    function addBlacklist(address user) external onlyOwner {
        isBlacklist[user] = true;
    }

    function removeBlacklist(address user) external onlyAuth {
        isBlacklist[user] = false;
    }

    function setActiveBlacklist(bool _activeBlacklist) external onlyAuth {
        activeBlacklist = _activeBlacklist;
    }

    function setActiveFees(bool _activeFees) external onlyOwner {
        activeFees = _activeFees;
    }

    function setTreshold(uint256 _swapThreshold) external onlyOwner {
        swapThreshold = _swapThreshold;
    }

    event AutoLiquify(uint256 amountETH, uint256 amountBOG);
}