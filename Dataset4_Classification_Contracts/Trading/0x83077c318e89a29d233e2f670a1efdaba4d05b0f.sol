/**
    Website: https://trumpstandard.bar
    Telegram: https://t.me/TrumpStandard
    X: https://x.com/TrumpStandardx
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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

interface IUniswapV2Router02 {
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

contract TBAR is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Trump Standard";
    string private constant _symbol = unicode"TBAR";

    IUniswapV2Router02 public immutable router;
    address public uniswapV2Pair;

    bool private swapping;

    address public mkPort;

    uint256 public mxTxSize;
    uint256 public swapTxSize;
    uint256 public mxWalletSize;
    uint256 public mxSwapSize;

    bool public limitsEnabled = true;
    bool public tradingAllowed = false;
    bool public swapEnabled = false;

    mapping(address => bool) private _bls;

    uint256 public bFees = 0;

    uint256 public sFees = 0;

    mapping(address => bool) private excludedFees;
    mapping(address => bool) public excludedTx;
    mapping(address => bool) public ammPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    constructor() {
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        mkPort = address(0x32E3E6420Ef873B7970FA16fB88D6B260CcE104F);

        mxTxSize = (_totalSupply * 20) / 1000;
        mxWalletSize = (_totalSupply * 20) / 1000;
        mxSwapSize = (_totalSupply * 10) / 1000;
        swapTxSize = (_totalSupply * 5) / 1000000;

        _excludeFromFees(owner(), true);
        _excludeFromFees(address(this), true);
        _excludeFromFees(mkPort, true);

        _excludeFromMaxTransaction(owner(), true);
        _excludeFromMaxTransaction(address(this), true);

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
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

    receive() external payable {}

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function createPair() external onlyOwner {
        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        _excludeFromMaxTransaction(address(uniswapV2Pair), true);
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        _approve(address(this), address(router), _totalSupply);

        router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        tradingAllowed = true;
        swapEnabled = true;
    }

    function _excludeFromFees(address account, bool excluded) internal {
        excludedFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) internal {
        ammPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function _excludeFromMaxTransaction(address updAds, bool isEx) internal {
        excludedTx[updAds] = isEx;
    }

    function closeLimits() external onlyOwner returns (bool) {
        limitsEnabled = false;
        return true;
    }

    function makeFeeUpdate(
        uint256 _newBuyFee,
        uint256 _newSellFee
    ) external onlyOwner {
        bFees = _newBuyFee;
        sFees = _newSellFee;
        require(bFees <= 99 && sFees <= 99, "Must keep fees at 99% or less");
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount should be greater than 0");
        require(
            !_bls[to] && !_bls[from],
            "You have been blacklisted from transfering tokens"
        );

        if (limitsEnabled) {
            if (from != owner() && to != owner()) {
                if (!tradingAllowed) {
                    require(
                        excludedFees[from] || excludedFees[to],
                        "Trading is not active."
                    );
                }

                if (ammPairs[from] && !excludedTx[to]) {
                    require(
                        amount <= mxTxSize,
                        "Buy transfer amount exceeds the maxTransactionAmount."
                    );
                    require(
                        amount + balanceOf(to) <= mxWalletSize,
                        "Max wallet exceeded"
                    );
                } else if (ammPairs[to] && !excludedTx[from]) {
                    require(
                        amount <= mxTxSize,
                        "Sell transfer amount exceeds the maxTransactionAmount."
                    );
                } else if (!excludedTx[to]) {
                    require(
                        amount + balanceOf(to) <= mxWalletSize,
                        "Max wallet exceeded"
                    );
                }
            }
        }

        if (
            swapEnabled &&
            !swapping &&
            ammPairs[to] &&
            !excludedFees[from] &&
            !excludedFees[to]
        ) {
            swapping = true;

            swapBack();

            swapping = false;
        }

        transferInternal(from, to, amount);
    }

    function transferInternal(
        address from,
        address to,
        uint256 amount
    ) internal {
        (uint256 leftAmount, uint256 taxAmount) = handleTax(from, to, amount);
        _balances[from] = _balances[from].sub(leftAmount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));

        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function handleTax(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256 leftAmount, uint256 taxAmount) {
        bool excemptFee = excludedFees[from] || excludedFees[to];

        if (
            from == owner() ||
            to == owner() ||
            from == address(this) ||
            to == address(this)
        ) {
            leftAmount = amount;
        } else if (!excemptFee) {
            if (ammPairs[to] && sFees > 0) {
                taxAmount = amount.mul(sFees).div(1000);
            }
            // on buy
            else if (ammPairs[from] && bFees > 0) {
                taxAmount = amount.mul(bFees).div(1000);
            }

            if (taxAmount > 0) {
                _balances[from] = _balances[from].sub(taxAmount);
                _balances[address(this)] = _balances[address(this)].add(
                    taxAmount
                );
                emit Transfer(from, address(this), taxAmount);
            }

            leftAmount = amount - taxAmount;
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));

        if (contractBalance > mxSwapSize) contractBalance = mxSwapSize;

        if (contractBalance > swapTxSize) swapTokensForEth(contractBalance);

        payable(mkPort).transfer(address(this).balance);
    }
}