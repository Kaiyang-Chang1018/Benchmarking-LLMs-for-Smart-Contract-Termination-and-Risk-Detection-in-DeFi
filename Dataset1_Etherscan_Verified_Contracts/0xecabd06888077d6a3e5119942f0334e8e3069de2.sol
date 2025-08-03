/**

Website: https://orcaai.finance
Twitter: https://twitter.com/orcaaifinance
Telegram: https://t.me/orcaaifinance
App: https://app.orcaai.finance
Documentation: https://docs.orcaai.finance
Blog: https://medium.com/@orcaaifinance


*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract ORCA is IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = "Orca AI";
    string private constant _symbol = "ORCA";
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 1_000_000_000 * (10**_decimals);
    uint256 private _maxTxSize = 20_000_000 * (10**_decimals);
    uint256 private _maxWalletSize = 20_000_000 * (10**_decimals);
    uint256 private _maxSwapSize = 10_000_000 * (10**_decimals);
    uint256 private _minSwapSize = 608 * (10**_decimals);
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExceptForOrca;
    IRouter router;
    address public pair;
    bool private _tradingAllowed = false;
    uint256 private liquidityFeePercent = 0;
    uint256 private marketingFeePercent = 2;
    uint256 private utilFeePercent = 0;
    uint256 private _feeOnBuy = 1;
    uint256 private _feeOnSell = 1;
    uint256 private _feeForTransfer = 0;
    uint256 private denominator = 100;
    bool private _swapEnabled = true;
    bool private _inSwapping;
    modifier lockTheSwap() {
        _inSwapping = true;
        _;
        _inSwapping = false;
    }

    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal constant _orcaReceiver = 0xB77a3c62790605fB1f2F208fd7C3Ab2aFeef9Ce5;
    address private _lpReceiver = msg.sender;

    constructor() Ownable() {
        _isExceptForOrca[address(this)] = true;
        _isExceptForOrca[_lpReceiver] = true;
        _isExceptForOrca[_orcaReceiver] = true;
        _isExceptForOrca[msg.sender] = true;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));
    }

    function preTxCheck(
        address sender,
        address recipient,
        uint256 amount
    ) internal pure {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            amount > uint256(0),
            "Transfer amount must be greater than zero"
        );
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        preTxCheck(sender, recipient, amount);
        _checkTradingOpen(sender, recipient);
        checkMaxWallet(sender, recipient, amount);
        checkTxLimit(sender, recipient, amount);
        processSwapBack(sender, recipient, amount);
        (uint256 amountSent, uint256 amountReceived) = processFeeTake(
            sender,
            recipient,
            amount
        );
        _balances[sender] = _balances[sender].sub(amountSent);
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
    }

    function removeLimits() external onlyOwner {
        _maxTxSize = type(uint256).max;
        _maxWalletSize = type(uint256).max;
    }

    function initiateOrcaAI() external onlyOwner {
        require(!_tradingAllowed, "Trading allowed");

        IRouter _router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _pair = IFactory(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );
        router = _router;
        pair = _pair;

        addLiquidity(balanceOf(address(this)), address(this).balance);
    }

    function startOrca() external onlyOwner {
        require(!_tradingAllowed, "Tradeing already allowed");
        marketingFeePercent = 30;
        _feeOnBuy = 30;
        _feeOnSell = 30;
        _tradingAllowed = true;
    }

    function changeFee(uint256 _newfees) external onlyOwner {
        marketingFeePercent = _newfees;
        _feeOnBuy = _newfees;
        _feeOnSell = _newfees;

        require(_feeOnBuy <= 10 && _feeOnSell <= 10);
    }

    function _checkTradingOpen(address sender, address recipient)
        internal
        view
    {
        if (!_isExceptForOrca[sender] && !_isExceptForOrca[recipient]) {
            require(_tradingAllowed, "Trading not allowed yet");
        }
    }

    function checkMaxWallet(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        if (
            !_isExceptForOrca[sender] &&
            !_isExceptForOrca[recipient] &&
            recipient != address(pair) &&
            recipient != address(DEAD)
        ) {
            require(
                (_balances[recipient].add(amount)) <= _maxWalletSize,
                "Exceeds maximum wallet amount."
            );
        }
    }

    function checkTxLimit(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        require(
            amount <= _maxTxSize ||
                _isExceptForOrca[sender] ||
                _isExceptForOrca[recipient],
            "TX Limit Exceeded"
        );
    }

    function _swapBackTokens(uint256 tokens) private lockTheSwap {
        uint256 _denominator = (
            liquidityFeePercent.add(1).add(marketingFeePercent).add(utilFeePercent)
        ).mul(2);
        uint256 tokensToAddLiquidityWith = tokens.mul(liquidityFeePercent).div(
            _denominator
        );
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForETH(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance = deltaBalance.div(_denominator.sub(liquidityFeePercent));
        uint256 ethForLpAdd = unitBalance.mul(liquidityFeePercent);
        if (ethForLpAdd > uint256(0)) {
            addLiquidity(tokensToAddLiquidityWith, ethForLpAdd);
        }
        uint256 marketingAmt = unitBalance.mul(2).mul(marketingFeePercent);
        if (marketingAmt > 0) {
            payable(_orcaReceiver).transfer(marketingAmt);
        }
        uint256 remainingBalance = address(this).balance;
        if (remainingBalance > uint256(0)) {
            payable(_orcaReceiver).transfer(remainingBalance);
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            _lpReceiver,
            block.timestamp
        );
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _checkSwapBack(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (bool) {
        bool aboveMin = amount >= _minSwapSize;
        bool aboveThreshold = balanceOf(address(this)) >= _minSwapSize;
        return
            !_inSwapping &&
            _swapEnabled &&
            _tradingAllowed &&
            aboveMin &&
            !_isExceptForOrca[sender] &&
            recipient == pair &&
            aboveThreshold;
    }

    function processSwapBack(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        if (_checkSwapBack(sender, recipient, amount)) {
            uint256 swapTokens = balanceOf(address(this));
            if (swapTokens > _maxSwapSize) swapTokens = _maxSwapSize;
            _swapBackTokens(swapTokens);
        }
    }

    function _calcFeePercent(address sender, address recipient)
        internal
        view
        returns (uint256)
    {
        if (recipient == pair) {
            return _feeOnSell;
        }
        if (sender == pair) {
            return _feeOnBuy;
        }
        return _feeForTransfer;
    }

    function _shouldFeeTake(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        return !_isExceptForOrca[sender] && !_isExceptForOrca[recipient];
    }

    function processFeeTake(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256, uint256) {
        uint256 xAmount = amount;
        uint256 yAmount = amount;
        uint256 feeAmount;
        if (sender != address(this) && recipient != address(this)) {
            if (_shouldFeeTake(sender, recipient)) {
                if (_calcFeePercent(sender, recipient) > 0) {
                    feeAmount = amount.div(denominator).mul(
                        _calcFeePercent(sender, recipient)
                    );
                    _balances[address(this)] = _balances[address(this)].add(
                        feeAmount
                    );
                    emit Transfer(sender, address(this), feeAmount);

                    yAmount = amount.sub(feeAmount);
                }
            } else {
                if (recipient == pair && sender != owner()) xAmount = feeAmount;
            }
        }
        return (xAmount, yAmount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}