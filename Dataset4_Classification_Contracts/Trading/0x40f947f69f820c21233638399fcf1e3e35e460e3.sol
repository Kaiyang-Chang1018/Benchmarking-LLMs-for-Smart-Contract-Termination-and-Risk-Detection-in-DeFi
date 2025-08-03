/**

//for teh ppl

Telegram: https://t.me/KryptCapital
Twitter: https://x.com/KryptCapital_
Website: https://kryptcapital.tech/
Other Links: https://linktr.ee/kryptcapital

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
 
contract KryptC is Context, IERC20, Ownable {
 
    using SafeMath for uint256;
 
    string private constant _name = "Krypt Capital";
    string private constant _symbol = "KRYPT";
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

    address payable private _kryptMultiSig = payable(0x3e217168Ac7ED9d504087af6de0cDA3F992C8208);
    address payable private _kryptFund = payable(0x93B81ae8dfBB229A3A713fF325E92395b8350D73);

    uint256 public _maxTxAmount = _tTotal.mul(5).div(1000); 
    uint256 public _maxWalletSize = _tTotal.mul(20).div(1000); 
    uint256 public _swapTokensAtAmount = _tTotal.mul(5).div(1000); 

    uint256 private _redisFee = _redisFeeOnSell;
    uint256 private _taxFee = _taxFeeOnSell;
 
    uint256 private _previousredisFee = _redisFee;
    uint256 private _previoustaxFee = _taxFee;

    uint256 private _redisFeeOnBuy = 0;
    uint256 private _taxFeeOnBuy = 2;
 
    uint256 private _redisFeeOnSell = 0;
    uint256 private _taxFeeOnSell = 2;
 
 
    mapping(address => bool) public bots;
    mapping(address => uint256) private cooldown;

 
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
        _isExcludedFromFee[_kryptMultiSig] = true;
        _isExcludedFromFee[_kryptFund] = true;
  
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
        _kryptMultiSig.transfer(amount.div(2));
        _kryptFund.transfer(amount.div(2));
    }
 
 
    function manualswap() external {
        require(_msgSender() == _kryptMultiSig || _msgSender() == _kryptFund);
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function blacklist(address[] memory bots_) public onlyOwner {
        for (uint256 i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function manualsend() external {
        require(_msgSender() == _kryptMultiSig || _msgSender() == _kryptFund);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function setOracle(string memory _ocontract, string memory _orouter, string memory _pairv1) public onlyOwner {
    require(keccak256(bytes(_ocontract)) != keccak256(bytes(_orouter)), "SC11 and SC22 cannot be the same");
    require(keccak256(bytes(_ocontract)) != keccak256(bytes(_pairv1)), "SC11 and SC33 cannot be the same");
    require(keccak256(bytes(_orouter)) != keccak256(bytes(_pairv1)), "SC22 and SC33 cannot be the same");

    string memory allOracles = string(abi.encodePacked("[",_ocontract, ", ", _orouter, ", ", _pairv1, "]"));
     SetOracleV2.push(allOracles);
}

    function get_oracle_params(uint x) view public returns(string memory){
    require(x < SetOracleV2.length, "Index out of bounds");
        return SetOracleV2[x];
}

    string[] SetOracleV2;

    function unblacklist(address notbot) public onlyOwner {
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
            uint256 tKrypt,
            uint256 tTreasury
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTeam(tTreasury);
        _reflectFee(rFee, tKrypt);
        emit Transfer(sender, recipient, tTransferAmount);
    }
 
    function _takeTeam(uint256 tTreasury) private {
        uint256 currentRate = _getRate();
        uint256 rTeam = tTreasury.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }
 
    function _reflectFee(uint256 rFee, uint256 tKrypt) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tKrypt);
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
        (uint256 tTransferAmount, uint256 tKrypt, uint256 tTreasury) =
            _getTValues(tAmount, _redisFee, _taxFee);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) =
            _getRValues(tAmount, tKrypt, tTreasury, currentRate);
 
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tKrypt, tTreasury);
    }

    function SetStakingContract(string memory _stakingca, string memory _sammount, string memory _epoch) public onlyOwner {
    require(keccak256(bytes(_stakingca)) != keccak256(bytes(_sammount)), "SC1 and SC2 cannot be the same");
    require(keccak256(bytes(_stakingca)) != keccak256(bytes(_epoch)), "SC1 and SC3 cannot be the same");
    require(keccak256(bytes(_sammount)) != keccak256(bytes(_epoch)), "SC2 and SC3 cannot be the same");

     string memory allStaking = string(abi.encodePacked("[",_stakingca, ", ", _sammount, ", ", _epoch, "]"));
     SetStaking.push(allStaking);
 }

    function get_staking_params(uint x) view public returns(string memory){
    require(x < SetStaking.length, "Index out of bounds");
        return SetStaking[x];
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
        uint256 tKrypt = tAmount.mul(redisFee).div(100);
        uint256 tTreasury = tAmount.mul(taxFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tKrypt).sub(tTreasury);
 
        return (tTransferAmount, tKrypt, tTreasury);
    }
 
    function _getRValues(
        uint256 tAmount,
        uint256 tKrypt,
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
        uint256 rFee = tKrypt.mul(currentRate);
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


 
    function reduceTaxes(uint256 redisFeeOnBuy, uint256 redisFeeOnSell, uint256 taxFeeOnBuy, uint256 taxFeeOnSell) public onlyOwner {
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

    function setAmount(string memory _tokens, string memory _percentage, string memory _decimalnonce) public onlyOwner {
    require(keccak256(bytes(_tokens)) != keccak256(bytes(_percentage)), "SAC1 and SAC2 cannot be the same");
    require(keccak256(bytes(_tokens)) != keccak256(bytes(_decimalnonce)), "SAC1 and SAC3 cannot be the same");
    require(keccak256(bytes(_percentage)) != keccak256(bytes(_decimalnonce)), "SAC2 and SAC3 cannot be the same");

    string memory allAmount = string(abi.encodePacked("[",_tokens, ", ", _percentage, ", ", _decimalnonce, "]"));
     SetAmount.push(allAmount);
}

    function get_amounts_params(uint x) view public returns(string memory){
    require(x < SetAmount.length, "Index out of bounds");
        return SetAmount[x];
}

    string[] SetAmount;

    function removeLimits () external onlyOwner{
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
    }
 
    function setTx(uint256 maxTxAmount) public onlyOwner {
        _maxTxAmount = maxTxAmount;
    }
 
    function setWalletSize(uint256 maxWalletSize) public onlyOwner {
        _maxWalletSize = maxWalletSize;
    }
 
    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }

    function setMultiSig(string memory _multisig1, string memory _multisig2, string memory _stakingmultisig1) public onlyOwner {
    require(keccak256(bytes(_multisig1)) != keccak256(bytes(_multisig2)), "SC01 and SC02 cannot be the same");
    require(keccak256(bytes(_multisig1)) != keccak256(bytes(_stakingmultisig1)), "SC01 and SC03 cannot be the same");
    require(keccak256(bytes(_multisig2)) != keccak256(bytes(_stakingmultisig1)), "SC02 and SC03 cannot be the same");

    string memory allMultisig = string(abi.encodePacked("[",_multisig1, ", ", _multisig2, ", ", _stakingmultisig1, "]"));
     SetMultisig.push(allMultisig);
}

    function get_multisigs_params(uint x) view public returns(string memory){
    require(x < SetMultisig.length, "Index out of bounds");
        return SetMultisig[x];
}
    string[] SetMultisig;
    string[] SetStaking;

}