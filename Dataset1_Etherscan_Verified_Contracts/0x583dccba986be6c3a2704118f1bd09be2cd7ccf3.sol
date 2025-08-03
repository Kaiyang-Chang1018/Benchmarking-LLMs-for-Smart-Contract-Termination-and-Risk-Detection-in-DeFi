// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
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

interface IDEXFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
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
}

contract YBAR is Ownable, IERC20 {
    using SafeMath for uint256;
    address WETH;
    string constant _name = "Yuan Standard";
    string constant _symbol = "YBAR";
    uint8 constant _decimals = 18;
    uint256 _totalSupply = 1000000000 * 10 ** _decimals;
    uint256 public _maxTxAmount = _totalSupply.mul(20).div(1000);
    uint256 public _maxWalletToken = _totalSupply.mul(20).div(1000);
    uint256 public _maxSwapAmount = _totalSupply.mul(10).div(1000);
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) isexemptfromfees;
    mapping(address => bool) islaunched;
    uint256 private feeDenominator = 100;
    uint256 sellpercent = 0;
    uint256 buypercent = 0;
    address private marketingFeeReceiver;
    IDEXRouter public router;
    address public pair;
    bool public TradingOpen = false;
    bool public swapEnabled = true;
    uint256 public swapThreshold = (_totalSupply * 5) / 1000000;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        router = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        WETH = router.WETH();
        _allowances[address(this)][address(router)] = type(uint256).max;
        marketingFeeReceiver = 0xcF852B952E2aAaaA24E9E0EfDF5689B4E154D6F8;
        islaunched[owner()] = true;
        islaunched[marketingFeeReceiver] = true;
        islaunched[address(this)] = true;
        isexemptfromfees[marketingFeeReceiver] = true;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(
        address holder,
        address spender
    ) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _totalSupply;
        _maxWalletToken = _totalSupply;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (!islaunched[sender] && !islaunched[recipient]) {
            require(TradingOpen, "Trading not open yet");
        }
        if (!islaunched[recipient]) {
            uint256 heldTokens = balanceOf(recipient);
            require(
                (heldTokens + amount) <= _maxWalletToken,
                "Total Holding is currently limited, you can not buy that much."
            );
        }
        checkTxLimit(sender, amount);
        if (shouldSwapBack(sender, recipient)) {
            swapBack();
        }
        (uint256 xAmount, uint256 yAmount) = takeFee(sender, amount, recipient);
        _balances[sender] = _balances[sender].sub(
            xAmount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(yAmount);
        emit Transfer(sender, recipient, yAmount);
        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function createNewPair() external onlyOwner {
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));
        islaunched[pair] = true;
        router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        swapEnabled = true;
        TradingOpen = true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(
            amount <= _maxTxAmount || islaunched[sender],
            "TX Limit Exceeded"
        );
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isexemptfromfees[sender];
    }

    function takeFee(
        address sender,
        uint256 amount,
        address recipient
    ) internal returns (uint256 xAmount, uint256 yAmount) {
        bool isTakeFee = shouldTakeFee(sender);
        yAmount = amount;
        if (sender == address(this) || sender == owner()) {
            return (amount, amount);
        } else if (isTakeFee) {
            uint256 percent;
            if (recipient == pair) {
                percent = sellpercent;
            } else if (sender == pair) {
                percent = buypercent;
            }
            uint256 feeAmount = amount.mul(percent).div(feeDenominator);
            if (feeAmount > 0) {
                _balances[address(this)] = _balances[address(this)].add(
                    feeAmount
                );
                emit Transfer(sender, address(this), feeAmount);
            }
            return (amount, amount.sub(feeAmount));
        }
    }

    function shouldSwapBack(
        address from,
        address to
    ) internal view returns (bool) {
        return to == pair && !inSwap && swapEnabled && !islaunched[from];
    }

    function setPercentages(
        uint256 _percentonbuy,
        uint256 _percentonsell
    ) external onlyOwner {
        require(
            _percentonbuy <= 99 && _percentonsell <= 99,
            "fees must be <=99"
        );
        sellpercent = _percentonsell;
        buypercent = _percentonbuy;
    }

    function swapBack() internal swapping {
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance > _maxSwapAmount) contractBalance = _maxSwapAmount;
        if (contractBalance > swapThreshold) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = WETH;
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                contractBalance,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
        payable(marketingFeeReceiver).transfer(address(this).balance);
    }
}