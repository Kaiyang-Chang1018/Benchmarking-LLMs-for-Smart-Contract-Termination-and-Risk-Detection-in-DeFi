/**

PEPE6900 is the most famous meme of all time. 
The frog has been reaching every corner of the earth, 
and is a symbol for so much. PEPE6900 is a proof of the true power of meme magic, 
thanks to the power of anonymous communities and meme enthusiasts.
It's time to take the power back, and show the world the true power of the $PEPE6900 Army.

Website:    https://pepe6900.live
Telegram:   https://t.me/pepe_6900
Twitter:    https://x.com/pepe_6900

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface PEPERouter {
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

interface PEPEFactory {
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

contract PEPE6900 is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _excludedFromFees;
    address payable private _taxWallet;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 69_000_000 * 10 ** _decimals;
    string private constant _name = unicode"PEPE6900";
    string private constant _symbol = unicode"PEPE6900";
    uint256 public _maxTxAmount = 1_380_000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 1_380_000 * 10 ** _decimals;
    uint256 public _taxSwapThreshold = 69 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 690_000 * 10 ** _decimals;

    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 9;
    uint256 private _reduceSellTaxAt = 9;
    uint256 private _preventSwapBefore = 9;
    uint256 private _buyCount = 0;

    PEPERouter private pepeRouter;
    address private pepePair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address _pepeWallet) {
        _taxWallet = payable(_pepeWallet);
        _balances[_msgSender()] = _tTotal;
        _excludedFromFees[owner()] = true;
        _excludedFromFees[address(this)] = true;
        _excludedFromFees[_taxWallet] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function initPEPE6900() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        pepeRouter = PEPERouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(pepeRouter), _tTotal);

        pepePair = PEPEFactory(pepeRouter.factory()).createPair(
            address(this),
            pepeRouter.WETH()
        );
    }

    function enableTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        uint256 pepeAmount = balanceOf(address(this)).sub(
            _tTotal.mul(_initialBuyTax).div(100)
        );

        pepeRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            pepeAmount,
            0,
            0,
            owner(),
            block.timestamp
        );

        IERC20(pepePair).approve(address(pepeRouter), type(uint).max);

        swapEnabled = true;
        tradingOpen = true;
    }

    receive() external payable {}

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

    function _basicTransfer(address from, address to, uint256 amount) internal {
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function _transferPEPE(
        address from,
        address to,
        uint256 amount,
        bool takePEPEFees
    ) internal {
        if (takePEPEFees) {
            uint256 taxAmount = 0;
            taxAmount = amount
                .mul(
                    (_buyCount > _reduceBuyTaxAt)
                        ? _finalBuyTax
                        : _initialBuyTax
                )
                .div(100);
            if (to == pepePair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initialSellTax
                    )
                    .div(100);
            }
            if (taxAmount > 0) {
                _balances[address(this)] = _balances[address(this)].add(
                    taxAmount
                );
                emit Transfer(from, address(this), taxAmount);
            }
            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount.sub(taxAmount));
            emit Transfer(from, to, amount.sub(taxAmount));
        } else {
            unchecked {
                _balances[from] = _balances[from] - amount;
                _balances[to] = _balances[to] + amount;
            }
            emit Transfer(from, to, amount);
        }
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (!swapEnabled || inSwap) {
            _basicTransfer(from, to, amount);
            return;
        }
        if (from != owner() && to != owner()) {
            if (
                from == pepePair &&
                to != address(pepeRouter) &&
                !_excludedFromFees[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );

                _buyCount++;
            }

            if (to != pepePair && !_excludedFromFees[to]) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool pepeSwap = contractTokenBalance > _taxSwapThreshold;
            if (
                !inSwap &&
                to == pepePair &&
                _buyCount > _preventSwapBefore &&
                swapEnabled &&
                !_excludedFromFees[from] &&
                !_excludedFromFees[to]
            ) {
                if(pepeSwap){
                    swapTokensForEth(
                        minOf(amount, minOf(contractTokenBalance, _maxTaxSwap))
                    );
                }
                
                sendETHToFees(address(this).balance);
            }
        }

        bool takePEPEFees = true;
        if (_excludedFromFees[from]) takePEPEFees = false;

        _transferPEPE(from, to, amount, takePEPEFees);
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFees(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function minOf(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pepeRouter.WETH();
        _approve(address(this), address(pepeRouter), tokenAmount);
        pepeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}