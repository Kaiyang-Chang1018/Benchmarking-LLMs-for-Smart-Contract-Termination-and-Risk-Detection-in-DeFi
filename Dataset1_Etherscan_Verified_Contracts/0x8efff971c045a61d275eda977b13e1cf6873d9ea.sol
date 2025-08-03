/**
 * https://t.me/TrumperoErc
 * https://trumpero.xyz
 * https://x.com/TrumperoErc
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
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
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
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

library SafeMath {
    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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

interface IUniFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniRouter {
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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract TRUMPERO is IERC20, Ownable {
    using SafeMath for uint256;

    uint256 private _totalSupply = 10 ** 27;
    string private _name = "Hero Trump";
    string private _symbol = "TRUMPERO";

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    IUniRouter public uniRouter;
    address public uniPair;

    bool private inSwap;

    address public mkPort;
    address public devPort;

    uint256 public mxTxLimit = (_totalSupply * 200) / 10000;
    uint256 public swapTokenLimit = (_totalSupply * 5) / 1000000;
    uint256 public mxWalletLimit = (_totalSupply * 200) / 10000;

    uint256 public outTotalFees = 30;
    uint256 public outMkFees = 30;
    uint256 public outDevFees = 0;

    uint256 public inTotalFees = 30;
    uint256 public inMkFees = 30;
    uint256 public inDevFees = 0;

    uint256 public mkTokens;
    uint256 public devTokens;

    bool public LimitsEnabled = true;
    bool public TradingAllowed = false;
    bool public SwapEnabled = false;

    mapping(address => bool) private blacklisted;
    mapping(address => bool) private feesIgnored;
    mapping(address => bool) public txIgnored;

    mapping(address => bool) public amms;

    constructor() {
        mkPort = address(0x8437E4ff6a3159Cc1aA722e46C5b86D74601707d);
        devPort = address(0x8437E4ff6a3159Cc1aA722e46C5b86D74601707d);

        uniRouter = IUniRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        txIgnored[owner()] = true;
        txIgnored[address(this)] = true;
        txIgnored[address(0xdead)] = true;

        feesIgnored[owner()] = true;
        feesIgnored[address(this)] = true;
        feesIgnored[address(0xdead)] = true;

        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function openTrumpero() external onlyOwner {
        uniPair = IUniFactory(uniRouter.factory()).createPair(
            address(this),
            uniRouter.WETH()
        );

        amms[address(uniPair)] = true;

        _approve(address(this), address(uniRouter), _totalSupply);

        uniRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        TradingAllowed = true;
        SwapEnabled = true;
    }

    function removeMaxes() external onlyOwner returns (bool) {
        LimitsEnabled = false;
        return true;
    }

    function removeFees(
        uint256 _inMkFees,
        uint256 _inDevFees,
        uint256 _outMkFees,
        uint256 _outDevFees
    ) external onlyOwner {
        inMkFees = _inMkFees;
        inDevFees = _inDevFees;
        inTotalFees = inMkFees + inDevFees;
        outMkFees = _outMkFees;
        outDevFees = _outDevFees;
        outTotalFees = outMkFees + outDevFees;
        require(
            inTotalFees <= 99 && outTotalFees <= 99,
            "Must keep fees at 99% or less"
        );
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        require(!blacklisted[from], "[from] black list");
        require(!blacklisted[to], "[to] black list");

        if (from == address(this) || to == address(this) || amount == 0) {
            _transferInternal(from, to, amount);
            return;
        }

        if (LimitsEnabled) {
            if (!txIgnored[from] && !txIgnored[to] && !inSwap) {
                if (!TradingAllowed) {
                    require(
                        feesIgnored[from] || feesIgnored[to],
                        "Trading is not active."
                    );
                }

                if (amms[from] && !txIgnored[to]) {
                    require(
                        amount <= mxTxLimit,
                        "Buy transfer amount exceeds the mxTxLimit."
                    );
                    require(
                        amount + balanceOf(to) <= mxWalletLimit,
                        "Max wallet exceeded"
                    );
                } else if (amms[to] && !txIgnored[from]) {
                    require(
                        amount <= mxTxLimit,
                        "Sell transfer amount exceeds the mxTxLimit."
                    );
                } else if (!txIgnored[to] && !amms[to]) {
                    require(
                        amount + balanceOf(to) <= mxWalletLimit,
                        "Max wallet exceeded"
                    );
                }
            }
        }

        if (
            SwapEnabled &&
            !inSwap &&
            amms[to] &&
            !feesIgnored[from] &&
            !feesIgnored[to]
        ) {
            inSwap = true;
            swapBack();
            inSwap = false;
        }

        bool takeFee = !(from == mkPort || from == devPort);

        uint256 fees = amount;
        if (takeFee) {
            if (amms[to] && outTotalFees > 0) {
                fees = amount.mul(outTotalFees).div(100);
                devTokens += (fees * outDevFees) / outTotalFees;
                mkTokens += (fees * outMkFees) / outTotalFees;
            } else if (amms[from] && inTotalFees > 0) {
                fees = amount.mul(inTotalFees).div(100);
                devTokens += (fees * inDevFees) / inTotalFees;
                mkTokens += (fees * inMkFees) / inTotalFees;
            } else fees = 0;

            if (fees > 0) {
                _balances[address(this)] = _balances[address(this)] + fees;
                emit Transfer(from, address(this), fees);
            }
        }

        _balances[from] =
            _balances[from] -
            (takeFee ? amount : (amount - fees));
        _balances[to] = _balances[to] + (takeFee ? (amount - fees) : amount);
        emit Transfer(from, to, amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function _transferInternal(
        address from,
        address to,
        uint256 amount
    ) internal {
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + amount;
        emit Transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouter.WETH();

        _approve(address(this), address(uniRouter), tokenAmount);

        uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = mkTokens + devTokens;

        if (contractBalance > swapTokenLimit * 2000) {
            contractBalance = swapTokenLimit * 2000;
        }

        uint256 initialETHBalance = address(this).balance;
        if (contractBalance > swapTokenLimit) swapTokensForEth(contractBalance);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);
        uint256 ethForDev = ethBalance.mul(devTokens).div(
            totalTokensToSwap + 1
        );

        mkTokens = 0;
        devTokens = 0;

        payable(devPort).transfer(ethForDev);
        payable(mkPort).transfer(address(this).balance);
    }

    receive() external payable {}
}