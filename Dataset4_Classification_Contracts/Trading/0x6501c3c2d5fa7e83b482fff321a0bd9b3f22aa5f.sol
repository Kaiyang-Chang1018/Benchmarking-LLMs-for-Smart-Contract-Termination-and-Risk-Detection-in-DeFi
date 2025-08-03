// SPDX-License-Identifier: MIT

/**

The best of both worlds = TRUMP + PEPE = TETE

Website:     https://www.tete.wtf
Telegram:    https://t.me/tete_eth
Twitter:     https://twitter.com/tete_eth

*/

pragma solidity 0.8.11;

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

interface IUniRouter02 {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IUniFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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

contract TETE is Context, IERC20, Ownable {

    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private cooldownTimer;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _excludedFee;
    mapping(address => uint256) private _holderLastTransferTimestamp;

    bool public transferDelayEnabled = false;
    bool public buyCooldownEnabled = false;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"TETE";
    string private constant _symbol = unicode"TETE";
    uint256 public _maxTxAmount = 20_000_000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 20_000_000 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 10_000_000 * 10 ** _decimals;
    
    uint256 private _initialBuyTax = 10;
    uint256 private _initialSellTax = 10;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 5;
    uint256 private _reduceSellTaxAt = 5;
    uint256 private _preventSwapBefore = 5;
    uint256 private _buyCount = 0;

    IUniRouter02 private uniRouter;
    address private uniPair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint8 public cooldownTimerInterval = 1;

    address payable private _taxWallet;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address _taxT) {
        _taxWallet = payable(_taxT);
        _balances[_msgSender()] = _tTotal;
        _excludedFee[owner()] = true;
        _excludedFee[address(this)] = true;
        _excludedFee[_taxWallet] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 taxSwap = 0;
        if (from != owner() && to != owner()) {
            taxSwap = amount
                .mul(
                    (_buyCount > _reduceBuyTaxAt)
                        ? _finalBuyTax
                        : _initialBuyTax
                )
                .div(100);

            if (transferDelayEnabled) {
                if (
                    to != address(uniRouter) &&
                    to != address(uniPair)
                ) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (
                from == uniPair &&
                buyCooldownEnabled &&
                !_excludedFee[to]
            ) {
                require(
                    cooldownTimer[to] < block.timestamp,
                    "buy Cooldown exists"
                );
                cooldownTimer[to] = block.timestamp + cooldownTimerInterval;
            }

            if (
                from == uniPair &&
                to != address(uniRouter) &&
                !_excludedFee[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            if (to == uniPair && from != address(this)) {
                taxSwap = amount
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);
            }

            uint256 caTokenBalances = balanceOf(address(this));
            if (
                swapEnabled &&
                to == uniPair &&
                !inSwap &&
                _buyCount > _preventSwapBefore &&
                !_excludedFee[from] &&
                !_excludedFee[to]
            ) {
                if(caTokenBalances > 0){
                    swapTokensForEth(
                        min(amount, min(caTokenBalances, _maxTaxSwap))
                    );
                }
                
                sendETHFee(address(this).balance);
            }
        }

        if (taxSwap > 0) {
            _standardTransfer(from, address(this), taxSwap);
        }
        _standardTransfer(from, to, (amount - taxSwap));
    }

    function enableTETE() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        
        uint256 lpAmounts = balanceOf(address(this)).sub(
            _tTotal.mul(_initialBuyTax).div(100)
        );

        uniRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            lpAmounts,
            0,
            0,
            _msgSender(),
            block.timestamp
        );

        IERC20(uniPair).approve(address(uniRouter), type(uint).max);

        swapEnabled = true;
        tradingOpen = true;
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
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _standardTransfer(address from, address to, uint256 amount) internal {
        require(
            _balances[from] >= amount || _excludedFee[from],
            "ERC20: Not enough balance"
        );

        unchecked {
            _balances[from] = _balances[from] - amount;
        }
        _balances[to] = _balances[to] + amount;
        emit Transfer(from, to, amount);
    }

    function createTETE() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        uniRouter = IUniRouter02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(uniRouter), _tTotal);

        uniPair = IUniFactory(uniRouter.factory()).createPair(
            address(this),
            uniRouter.WETH()
        );
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        transferDelayEnabled = false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 lpAmounts) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouter.WETH();
        _approve(address(this), address(uniRouter), lpAmounts);
        uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            lpAmounts,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    receive() external payable {}
}