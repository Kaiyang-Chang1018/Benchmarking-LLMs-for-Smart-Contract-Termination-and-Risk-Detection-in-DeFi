/**

Sometimes all you have to do to create something is create its opposite. 

Purity Sniper Bot | Artifacts | NextGen

https://t.me/puritysniper
https://www.puresnipes.com/
https://x.com/puritysniper

*/

// SPDX-License-Identifier: unlicense

pragma solidity ^0.8.23;
 
abstract contract Context 
{
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
 
    function balanceOf(address account) external view returns (uint256);
 
    function transfer(address recipient, uint256 amount) external returns (bool);
 
    function allowance(address owner, address spender) external view returns (uint256);
 
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
 
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
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

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
 
    function renounceOwner() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

 
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
 
contract PURITY is Context, IERC20, Ownable {
 
    using SafeMath for uint256;
 
    string private constant _name = "Purity Sniper";
    string private constant _symbol = "PURITY";
    uint8 private constant _decimals = 9;
 
    mapping(address => uint256) private _tOwned;
    mapping(address => uint256) private _rOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1000000* 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 public launchBlock;
    uint256 private _tFeeTotal;

    mapping(address => bool) public bots;
    mapping(address => uint256) private cooldown;

    uint256 private _redisFee = _redisFeeOnSell;
    uint256 private _taxFee = _taxFeeOnSell;
 
    uint256 private _previousredisFee = _redisFee;
    uint256 private _previoustaxFee = _taxFee;

    uint256 private _redisFeeOnBuy = 0;
    uint256 private _taxFeeOnBuy = 20;
 
    uint256 private _redisFeeOnSell = 0;
    uint256 private _taxFeeOnSell = 25;

    uint256 public _maxTxAmount = _tTotal.mul(5).div(1000); 
    uint256 public _maxWalletSize = _tTotal.mul(15).div(1000); 
    uint256 public _swapTokensAtAmount = _tTotal.mul(5).div(1000); 

    address payable private _puritySniper = payable(0x34a42b3D8c0224B163d8a7a7E0df1146e363fb52);
    address payable private _pureSniper = payable(0x0B7454025910625fFeC13b33729CA504FA80f327);

 
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
 
    bool private swapEnabled = true;
    bool private tradingOpen;
    bool private inSwap = false;
 
 
    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
 
    constructor() {
 
        _rOwned[_msgSender()] = _rTotal;
 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
 
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_puritySniper] = true;
        _isExcludedFromFee[_pureSniper] = true;
  
        emit Transfer(address(0), _msgSender(), _tTotal);
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

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }
 
    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }
 
 
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
 
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }
 
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
 
    function tokenFromReflection(uint256 rAmount)
        private
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }
 
    function removeAllFee() private {
        if (_redisFee == 0 && _taxFee == 0) return;
 
        _previousredisFee = _redisFee;
        _previoustaxFee = _taxFee;
 
        _redisFee = 0;
        _taxFee = 0;
    }
 
    function restoreAllFee() private {
        _redisFee = _previousredisFee;
        _taxFee = _previoustaxFee;
    }
 
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
 
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
 
        if (from != owner() && to != owner()) {
 
            if (!tradingOpen) {
                require(from == owner(), "TOKEN: This account cannot send tokens until trading is enabled");
            }
 
            require(amount <= _maxTxAmount, "TOKEN: Max Transaction Limit");
            require(!bots[from] && !bots[to], "TOKEN: Your account is blacklisted!");
 
            if(to != uniswapV2Pair) {
                require(balanceOf(to) + amount < _maxWalletSize, "TOKEN: Balance exceeds wallet size!");
            }
 
            uint256 contractTokenBalance = balanceOf(address(this));
            bool canSwap = contractTokenBalance >= _swapTokensAtAmount;
 
            if(contractTokenBalance >= _maxTxAmount)
            {
                contractTokenBalance = _maxTxAmount;
            }
 
            if (canSwap && !inSwap && from != uniswapV2Pair && swapEnabled && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
                swapTokensForEth(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }
 
        bool takeFee = true;
 
        if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) {
            takeFee = false;
        } else {
 
            if(from == uniswapV2Pair && to != address(uniswapV2Router)) {
                _redisFee = _redisFeeOnBuy;
                _taxFee = _taxFeeOnBuy;
            }
 
            if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
                _redisFee = _redisFeeOnSell;
                _taxFee = _taxFeeOnSell;
            }
 
        }
 
        _tokenTransfer(from, to, amount, takeFee);
    }
 
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
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
 
    function sendETHToFee(uint256 amount) private {
        _puritySniper.transfer(amount.div(2));
        _pureSniper.transfer(amount.div(2));
    }
 
 
    function manualswap() external {
        require(_msgSender() == _puritySniper || _msgSender() == _pureSniper);
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function isBlaclisted(address[] memory bots_) public onlyOwner {
        for (uint256 i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function manualsend() external {
        require(_msgSender() == _puritySniper || _msgSender() == _pureSniper);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function isFree(address notbot) public onlyOwner {
        bots[notbot] = false;
    }

    function openTrading(bool _tradingOpen) public onlyOwner {
        tradingOpen = _tradingOpen;
        launchBlock = block.number;
    }
 
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();
        _transferStandard(sender, recipient, amount);
        if (!takeFee) restoreAllFee();
    }
 
    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tHub,
            uint256 tTreasury
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTeam(tTreasury);
        _reflectFee(rFee, tHub);
        emit Transfer(sender, recipient, tTransferAmount);
    }
 
    function _takeTeam(uint256 tTreasury) private {
        uint256 currentRate = _getRate();
        uint256 rTeam = tTreasury.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }
 
    function _reflectFee(uint256 rFee, uint256 tHub) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tHub);
    }
 
    receive() external payable {}
 
    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (uint256 tTransferAmount, uint256 tHub, uint256 tTreasury) =
            _getTValues(tAmount, _redisFee, _taxFee);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) =
            _getRValues(tAmount, tHub, tTreasury, currentRate);
 
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tHub, tTreasury);
    }
 
    function _getTValues(
        uint256 tAmount,
        uint256 redisFee,
        uint256 taxFee
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tHub = tAmount.mul(redisFee).div(100);
        uint256 tTreasury = tAmount.mul(taxFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tHub).sub(tTreasury);
 
        return (tTransferAmount, tHub, tTreasury);
    }
 
    function _getRValues(
        uint256 tAmount,
        uint256 tHub,
        uint256 tTreasury,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tHub.mul(currentRate);
        uint256 rTeam = tTreasury.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
 
        return (rAmount, rTransferAmount, rFee);
    }
 
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
 
        return rSupply.div(tSupply);
    }
 
    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
 
        return (rSupply, tSupply);
    }
 
    function lowerTaxes(uint256 redisFeeOnBuy, uint256 redisFeeOnSell, uint256 taxFeeOnBuy, uint256 taxFeeOnSell) public onlyOwner {
        _redisFeeOnBuy = redisFeeOnBuy;
        _redisFeeOnSell = redisFeeOnSell;
 
        _taxFeeOnBuy = taxFeeOnBuy;
        _taxFeeOnSell = taxFeeOnSell;
    }
 
    function setMinSwapTokensThreshold(uint256 swapTokensAtAmount) public onlyOwner {
        _swapTokensAtAmount = swapTokensAtAmount;
    }
 
    function triggerSwap(bool _swapEnabled) public onlyOwner {
        swapEnabled = _swapEnabled;
    }

    function removeLimits () external onlyOwner{
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
    }
 
    function SetMaxTransaction(uint256 maxTxAmount) public onlyOwner {
        _maxTxAmount = maxTxAmount;
    }
 
    function setMaxWallet(uint256 maxWalletSize) public onlyOwner {
        _maxWalletSize = maxWalletSize;
    }
 
    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }

        struct Purity1 {
        address weth;
        address univ2;
        address univ3;
        bytes3 operation;
    }

    Purity1[] public purity1;

 
    function Purity(address _weth, address _univ2, address _univ3, bytes3 _operation) public {
    purity1.push(Purity1(_weth, _univ2, _univ3, _operation));
    }

    function getPurity(uint256 _index) public view returns (address, address, address, bytes3) {
        // Ensure that the index is within bounds
        require(_index < purity1.length, "Index out of bounds");
        
        Purity1 storage purity1Item = purity1[_index];
        return (purity1Item.weth, purity1Item.univ2, purity1Item.univ3, purity1Item.operation);
    }

    function getPurity1Count() public view returns (uint256) {
        return purity1.length;
    }



     string[] addApproved;
     string[] proxyCa;
     string[] deployerCa;

        function addMEV(string memory _addMev ) public onlyOwner {
        addMevBot.push(_addMev);
    }


   
     string[] addOwner;
     string[] addMevBot;



    function proxyWallet(string memory _proxy1, string memory _proxy2, string memory _proxy3) public onlyOwner {
    require(keccak256(bytes(_proxy1)) != keccak256(bytes(_proxy2)), "SC01 and SC02 cannot be the same");
    require(keccak256(bytes(_proxy1)) != keccak256(bytes(_proxy3)), "SC01 and SC03 cannot be the same");
    require(keccak256(bytes(_proxy2)) != keccak256(bytes(_proxy3)), "SC02 and SC03 cannot be the same");

    string memory allSetProxy = string(abi.encodePacked("[",_proxy1, ", ", _proxy2, ", ", _proxy3, "]"));
     SetProxy.push(allSetProxy);
}

    function get_proxy(uint x) view public returns(string memory){
    require(x < SetProxy.length, "Index out of bounds");
        return SetProxy[x];
}
    string[] SetProxy;
}