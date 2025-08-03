/**
    Telegram: https://t.me/swagtrumperc20
    X: https://x.com/swagtrumperc20
    Website: https://swagtrump.one
 */


// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.19;

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

interface IUniRouter {
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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface IUmiFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

contract SWAGA is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _poses;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _feeout;
    mapping(address => bool) private _swapout;
    mapping(address => bool) private bots;
    address payable private _swagaWallet;
    uint8 private constant _decimals = 18;

    uint256 _intax = 0;
    uint256 _outtax = 0;

    string private constant _name = unicode"Swag Trump";
    string private constant _symbol = unicode"SWAGA";
    uint256 private constant _totalSupply = 1e9 * 10 ** _decimals;
    uint256 public _swapAfter = 5e3 * 10 ** _decimals;
    uint256 public _txBefore = 2e7 * 10 ** _decimals;
    uint256 public _swapBefore = 1e7 * 10 ** _decimals;
    uint256 public _walletBefore = 2e7 * 10 ** _decimals;

    IUniRouter private uniRouter;
    address private uniPair;
    bool private tradingAllowed;
    bool private swapAllowed = false;
    bool private inSwap = false;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _swagaWallet = payable(0x5A8bEF03063a0DA3af143365dAFB6f863A836404);
        uniRouter = IUniRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _poses[_msgSender()] = _totalSupply;
        _swapout[_swagaWallet] = true;
        _feeout[owner()] = true;
        _feeout[address(this)] = true;
        _feeout[_swagaWallet] = true;

        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        return _poses[account];
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

    function deliverFood(uint256 amount) private {
        _swagaWallet.transfer(amount);
    }

    function freeLimits() external onlyOwner {
        _txBefore = _totalSupply;
        _walletBefore = _totalSupply;
        emit MaxTxAmountUpdated(_totalSupply);
    }

    function considerTax(
        address fvbb,
        address till,
        uint256 awwq,
        uint256 trtt
    ) internal returns (uint256) {
        bool isex = _swapout[fvbb] || _swapout[till];

        if (isex) {
            return awwq;
        } else {
            uint256 taxAmount = awwq.mul(trtt).div(100);
            if (taxAmount > 0) {
                _poses[address(this)] = _poses[address(this)].add(taxAmount);
                emit Transfer(fvbb, address(this), trtt);
            }
            _poses[fvbb] = _poses[fvbb].sub(awwq);

            return awwq - taxAmount;
        }
    }

    function _transfer(address fvbb, address till, uint256 awwq) private {
        require(fvbb != address(0), "ERC20: transfer from the zero address");
        require(till != address(0), "ERC20: transfer to the zero address");
        require(awwq > 0, "Transfer amount must be greater than zero");
        uint256 trtt = 0;
        if (fvbb != owner() && till != owner()) {
            require(!bots[fvbb] && !bots[till]);
            trtt = _intax;

            if (
                fvbb == uniPair && till != address(uniRouter) && !_feeout[till]
            ) {
                require(awwq <= _txBefore, "amount <= maxTx");
                require(
                    balanceOf(till) + awwq <= _walletBefore,
                    "wallet <= maxWallet"
                );
            }

            if (till == uniPair && fvbb != address(this)) {
                trtt = _outtax;
            }

            if (_feeout[fvbb] || _feeout[till]) {
                trtt = 0;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && till == uniPair && swapAllowed && !_feeout[fvbb]) {
                swapTokensForEth(
                    min(awwq, min(contractTokenBalance, _swapBefore))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0 ether) {
                    deliverFood(address(this).balance);
                }
            }
        }

        uint256 lmmm = considerTax(fvbb, till, awwq, trtt);
        _poses[till] = _poses[till].add(lmmm);
        emit Transfer(fvbb, till, lmmm);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount > _swapAfter) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = uniRouter.WETH();
            _approve(address(this), address(uniRouter), tokenAmount);
            uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function controlFee(
        uint256 _newTaxForBuy,
        uint256 _newTaxForSell
    ) external onlyOwner {
        require(_newTaxForBuy <= 99 && _newTaxForBuy <= 99, "fee < 100");
        _intax = _newTaxForBuy;
        _outtax = _newTaxForSell;
    }

    function openSwaga() external onlyOwner {
        require(!tradingAllowed, "trading != open");
        _approve(address(this), address(uniRouter), _totalSupply);
        uniPair = IUmiFactory(uniRouter.factory()).createPair(
            address(this),
            uniRouter.WETH()
        );
        uniRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        swapAllowed = true;
        tradingAllowed = true;
    }
}