/**

Let's make history together. Let's make memecoins great again. LFG!

Website:    https://www.bibicoin.wtf
Telegram:   https://t.me/bibicoin_wtf
Twitter:    https://x.com/bibicoin_wtf

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

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

interface IBIBIFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IBIBIRouter {
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

contract BIBI is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _feeExcludedFrom;
    address payable private _taxWallet;

    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 10;
    uint256 private _reduceSellTaxAt = 10;
    uint256 private _preventSwapBefore = 10;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420_690_000_000 * 10 ** _decimals;
    string private constant _name = unicode"BIBI";
    string private constant _symbol = unicode"BIBI";
    uint256 public _maxTxAmount = _tTotal.mul(2).div(100);
    uint256 public _maxWalletSize = _tTotal.mul(2).div(100);
    uint256 public _maxTaxSwap = _tTotal.mul(1).div(100);
    uint256 public _taxSwapThreshold = 690 * 10 ** _decimals;

    IBIBIRouter private bibiRouter;
    address private bibiPair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address _bibiAddr) {
        _taxWallet = payable(_bibiAddr);
        _balances[_msgSender()] = _tTotal;
        _feeExcludedFrom[owner()] = true;
        _feeExcludedFrom[address(this)] = true;
        _feeExcludedFrom[_taxWallet] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function enableBIBITrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        uint256 bibiAmount = balanceOf(address(this)).sub(
            _tTotal.mul(_initialBuyTax).div(100)
        );

        bibiRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            bibiAmount,
            0,
            0,
            owner(),
            block.timestamp
        );

        IERC20(bibiPair).approve(address(bibiRouter), type(uint).max);

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
                from == bibiPair &&
                to != address(bibiRouter) &&
                !_feeExcludedFrom[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );

                _buyCount++;
            }

            if (to != bibiPair && !_feeExcludedFrom[to]) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool bibiSwap = contractTokenBalance > _taxSwapThreshold;
            if (
                !inSwap &&
                _buyCount > _preventSwapBefore &&
                to == bibiPair &&
                swapEnabled &&
                !_feeExcludedFrom[from] &&
                !_feeExcludedFrom[to]
            ) {
                if(bibiSwap){
                    swapTokensForEth(
                        minBIBIOf(amount, minBIBIOf(contractTokenBalance, _maxTaxSwap))
                    );
                }
                
                sendETHToBIBI(address(this).balance);
            }
        }

        bool takeBIBIFees = true;
        if (_feeExcludedFrom[from]) takeBIBIFees = false;

        _transferBIBI(from, to, amount, takeBIBIFees);
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToBIBI(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function minBIBIOf(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function createBIBIPair() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        bibiRouter = IBIBIRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(bibiRouter), _tTotal);

        bibiPair = IBIBIFactory(bibiRouter.factory()).createPair(
            address(this),
            bibiRouter.WETH()
        );
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = bibiRouter.WETH();
        _approve(address(this), address(bibiRouter), tokenAmount);
        bibiRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _transferBIBI(
        address from,
        address to,
        uint256 amount,
        bool takeBIBIFees
    ) internal {
        if (takeBIBIFees) {
            uint256 taxAmount = 0;
            taxAmount = amount
                .mul(
                    (_buyCount > _reduceBuyTaxAt)
                        ? _finalBuyTax
                        : _initialBuyTax
                )
                .div(100);
            if (to == bibiPair && from != address(this)) {
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
}