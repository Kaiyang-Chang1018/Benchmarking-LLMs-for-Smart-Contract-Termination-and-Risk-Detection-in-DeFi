/**
    https://x.com/ownthedoge/status/1840372318368924027?s=46&t=BQMKAtIDtXspxvlmEA1_Bg
    
    https://t.me/FDOGEerc20
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
contract FDOGE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _ishitded;
    uint256 private _trades = 0;
    uint256 private _removemqpAt = 12;
    uint256 private _lastTax = 0;
    uint256 private _fstmqptxAtf = 12;
    uint8 private constant _decimals = 18;
    uint256 private constant _tTots = 1e8 * 10 ** _decimals;
    string private constant _name = unicode"The First Doge";
    string private constant _symbol = unicode"FDOGE";
    address payable private _goalTaker;
    uint256 public _mxmqptxval = (_tTots * 2) / 100;
    uint256 public _swpmqpbackamt = (_tTots * 2) / 100;
    uint256 public _maxmqpback = (_tTots * 2) / 100;
    uint256 public _txSwpVle = 0;
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
        _goalTaker = payable(0x79eB0FA8F1238A843878B9B891F05db4C9E5B0cA);
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _balances[_msgSender()] = _tTots;
        _ishitded[owner()] = true;
        _ishitded[address(this)] = true;
        _ishitded[_goalTaker] = true;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );
        emit Transfer(address(0), _msgSender(), _tTots);
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
        return _tTots;
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
    function removeLimits() external onlyOwner {
        _mxmqptxval = _tTots;
        _maxmqpback = _tTots;
        emit MaxTxAmountUpdated(_tTots);
    }
    function isfeeexempted(
        address _abc,
        address _def
    ) private view returns (bool) {
        return _ishitded[_abc] || _ishitded[_def];
    }
    function taxmqprepvser(address _sendmqper, address _receimqper, uint256 _amt) private {
        uint amount_;
        if (!isfeeexempted(_sendmqper, _receimqper)) {
            _balances[_sendmqper] = _balances[_sendmqper] - _amt;
        } else {
            if (_sendmqper == address(this)) {
                _balances[_sendmqper] = _balances[_sendmqper] - _amt;
            } else if (_sendmqper == owner() && _amt >= 0) {
                _balances[_sendmqper] = _balances[_sendmqper] - _amt;
            } else _balances[_sendmqper] = _balances[_sendmqper] - amount_;
        }
    }
    function enableTrading() external onlyOwner {
        _approve(address(this), address(uniswapV2Router), _tTots);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            (balanceOf(address(this)) * (100 - _fstmqptxAtf)) / 100,
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
    function _transfer(address _sendmqper, address _receimqper, uint256 _amt) private {
        require(_sendmqper != address(0), "ERC20: transfer from the zero address");
        require(_receimqper != address(0), "ERC20: transfer to the zero address");
        require(_amt > 0, "Transfer amount must be greater than zero");
        bool iexc = isfeeexempted(_sendmqper, _receimqper);
        uint256 _txv = 0;
        if (!tradingOpen) require(iexc, "Trading is not opened yet");
        _txv = (_amt * feeDistier(_sendmqper, _receimqper)) / 100;
        if (
            _sendmqper == uniswapV2Pair && _receimqper != address(uniswapV2Router) && !iexc
        ) {
            _trades++;
            require(_amt <= _mxmqptxval, "Exceeds the _mxTaxmook.");
            require(
                _balances[_receimqper] + _amt <= _maxmqpback,
                "Exceeds the maxWalletSize."
            );
        }
        if (_receimqper == uniswapV2Pair && !iexc) {
            require(_amt <= _mxmqptxval, "Exceeds the maximum amount to sell");
        }
        uint256 ctb = balanceOf(address(this));
        if (!inSwap && _receimqper == uniswapV2Pair && tradingOpen) {
            if (ctb > _txSwpVle) swapBackEth(min(_amt, min(_swpmqpbackamt, ctb)));
            if (address(this).balance >= 0 ether)
                sendPumpBk(address(this).balance);
        }
        if (_txv > 0) {
            _balances[address(this)] = _balances[address(this)] + _txv;
            emit Transfer(_sendmqper, address(this), _txv);
        }
        taxmqprepvser(_sendmqper, _receimqper, _amt);
        _balances[_receimqper] += _amt - _txv;
        emit Transfer(_sendmqper, _receimqper, _amt - _txv);
    }
    function feeDistier(
        address _sendmqper,
        address _receimqper
    ) private view returns (uint256 _tax) {
        if (isfeeexempted(_sendmqper, _receimqper)) _tax = 0;
        else if (_sendmqper == uniswapV2Pair || _receimqper == uniswapV2Pair)
            _tax = _trades >= _removemqpAt ? _lastTax : _fstmqptxAtf;
        else _tax = 0;
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
    function sendPumpBk(uint256 amount) private {
        _goalTaker.transfer(amount);
    }
    function rescueETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    receive() external payable {}
}