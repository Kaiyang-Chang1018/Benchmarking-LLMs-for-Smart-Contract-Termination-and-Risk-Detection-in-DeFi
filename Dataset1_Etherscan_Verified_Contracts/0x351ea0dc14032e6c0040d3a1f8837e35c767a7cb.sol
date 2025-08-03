// SPDX-License-Identifier: MIT

/*
Website: https://neigacoins.com
Telegram: https://t.me/BlackneiroETH
Twitter: https://twitter.com/BlackneiroETH
*/

pragma solidity 0.8.25;

abstract contract Context {
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract NEIGA is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isInExile;
    mapping (address => bool) public _mktPair;
    mapping (uint256 => uint256) private perBuyCounter;
    mapping(address => uint256) private prevTxHolderTimestamp;
    address payable private _taxVault;
    uint256 private _startingBlock = 0;
 
    uint256 private _initialBuyTaxRate=20;
    uint256 private _initialSellTaxRate=20;
    uint256 private _finalBuyTaxRate=0;
    uint256 private _finalSellTaxRate=0;

    uint256 private _buyTaxReduceAt=38;

    uint256 private _sellTaxReduceAt=38;
    uint256 private _preventSwapAction=38;
    uint256 private _purchaseCount=0;
    uint256 private _sellCounter = 0;
    uint256 private _previousSellBlock = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Black Neiro";
    string private constant _symbol = unicode"NEIGA";
    uint256 public _maxTransactionCap =   4206900000 * 10**_decimals;
    uint256 public _maxWalletCap = 4206900000 * 10**_decimals;
    uint256 public _taxSwapCap= 4200000000 * 10**_decimals;
    uint256 public _maxTaxSwapCap= 4206900000 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    bool private tradingOpen;
    bool public txInterval = true;
    uint256 public caUnitCount = 3;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool public caToggle = true;

    event MaxTxAmountUpdated(uint _maxTransactionCap);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {

        _taxVault = payable(0x09a3c315062A4da923017A6DE9eb2033727C3866);
        _balances[_msgSender()] = _tTotal;
        _isInExile[owner()] = true;
        _isInExile[address(this)] = true;
        _isInExile[address(uniswapV2Pair)] = true;
        
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

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    mapping (address => bool) public isInBlacklist;

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function removeFromBlockList(address account) external onlyOwner {
    isInBlacklist[account] = false;
    }

    function setMktPair(address addr) public onlyOwner {
        _mktPair[addr] = true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require (!isInBlacklist[from] && !isInBlacklist[to], "To/from address is blacklisted");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;

        if(block.number == _startingBlock) {
            if (!_mktPair[from] && from != address(this) && 
            from != address(uniswapV2Router) && 
            to != address(uniswapV2Router)) {
            
            if (!isInBlacklist[from]) {
                isInBlacklist[from] = true;
                }
            }
        }

        if (from != owner() && to != owner()) {
            taxAmount = amount.mul((_purchaseCount> _buyTaxReduceAt)? _finalBuyTaxRate: _initialBuyTaxRate).div(100);

            if(block.number == _startingBlock){
               require(perBuyCounter[block.number] < 52, "Exceeds buys on the first block.");
               perBuyCounter[block.number]++;
            }

            if(block.number > _startingBlock) {
                if (txInterval) {
                    if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                    require(prevTxHolderTimestamp[tx.origin] < block.number,"Only one transfer per block allowed.");
                    prevTxHolderTimestamp[tx.origin] = block.number;
                    }
                }
            }

            if (_mktPair[from] && to != address(uniswapV2Router) && ! _isInExile[to] ) {
                require(amount <= _maxTransactionCap, "Exceeds the _maxTransactionCap.");
                require(balanceOf(to) + amount <= _maxWalletCap, "Exceeds the maxWalletSize.");
                _purchaseCount++;
            }

            if (!_mktPair[to] && ! _isInExile[to]) {
                require(balanceOf(to) + amount <= _maxWalletCap, "Exceeds the maxWalletSize.");
            }

            if(_mktPair[to] && from!= address(this) ){
                taxAmount = amount.mul((_purchaseCount> _sellTaxReduceAt)? _finalSellTaxRate: _initialSellTaxRate).div(100);
            }

	    if (!_mktPair[from] && !_mktPair[to] && from!= address(this) ) {
                taxAmount = 0;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (caToggle && !inSwap && _mktPair[to] && swapEnabled && contractTokenBalance>_taxSwapCap && _purchaseCount>_preventSwapAction) {
                if (block.number > _previousSellBlock) {
                    _sellCounter = 0;
                }
                require(_sellCounter < caUnitCount, "CA balance sell");
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwapCap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                _sellCounter++;
                _previousSellBlock = block.number;
            }

            else if(!inSwap && _mktPair[to] && swapEnabled && contractTokenBalance>_taxSwapCap && _purchaseCount>_preventSwapAction) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwapCap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function removeFromBlockListwallets(address[] calldata addresses) public onlyOwner(){
        for (uint256 i; i < addresses.length; ++i) {
            isInBlacklist[addresses[i]] = false;
        }
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

    function addToBlockList(address[] calldata addresses) external onlyOwner {
       for (uint256 i; i < addresses.length; ++i) {
       isInBlacklist[addresses[i]] = true;
      }
    }

    function setMaxTaxSwapCap(bool enabled, uint256 amount) external onlyOwner {
        swapEnabled = enabled;
        _maxTaxSwapCap = amount;
    }

    function setcaUnitCount(uint256 amount) external onlyOwner {
        caUnitCount = amount;
    }
    
    function clearToggle(bool _status) external onlyOwner {
        caToggle = _status;
    }

    function txIntervalMode(bool _status) external onlyOwner {
        txInterval = _status;
    }

    function releaseStuckEth() external onlyOwner {
        payable(_taxVault).transfer(address(this).balance);
    }

    function retrieveAnyERC20Tokens(address _tokenAddr, uint _amount) external onlyOwner {
        IERC20(_tokenAddr).transfer(_taxVault, _amount);
    }

    function configureFeeWallet(address newTaxWallet) external onlyOwner {
        _taxVault = payable(newTaxWallet);
    }

    function exileAcc_Restriction() external onlyOwner{
        _maxTransactionCap = _tTotal;
        _maxWalletCap=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxVault.transfer(amount);
    }

    function enableTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _mktPair[address(uniswapV2Pair)] = true;
        _isInExile[address(uniswapV2Pair)] = true;
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
        _startingBlock = block.number;
    }

    receive() external payable {}
}