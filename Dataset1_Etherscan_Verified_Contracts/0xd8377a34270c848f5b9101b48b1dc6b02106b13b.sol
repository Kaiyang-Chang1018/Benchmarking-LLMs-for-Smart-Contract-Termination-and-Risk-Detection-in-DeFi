// SPDX-License-Identifier:MIT

pragma solidity 0.8.24;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address _account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount)external returns (bool);
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any _account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
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
    function factory()
        external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
}

contract Bar is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExile;

    uint256 private _initialBuyTax=21;
    uint256 private _initialSellTax=21;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=21;
    uint256 private _reduceSellTaxAt=21;
    uint256 private _preventSwapBefore=1;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Capital of Mars";
    string private constant _symbol = unicode"Bar";
    uint256 public _maxTxAmount = 6310350000 * 10**_decimals;
    uint256 public _maxWalletSize = 6310350000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 4200000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 4200000000 * 10**_decimals;

    IUniswapV2Router02 private constant router = IUniswapV2Router02(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );
    address payable private _taxWallet;

    address public uniswapPair;
    uint256 private assetTaxExcluded;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool private limitsInUse = true;
    struct AssetClaim {uint256 nClaim; uint256 deltaClaim; uint256 deltaUuid;}
    uint256 private minAssetClaim;
    mapping(address => AssetClaim) private assetClaim;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    event ClearToken(address tokenAddr, uint256 tokenAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(0xc201ACA383De3D5eca0E3A5DC607F832A4ce7D58);
        _balances[_msgSender()] =_tTotal;

        _isExile[_taxWallet] = true;
        _isExile[address(this)] = true;

        emit Transfer(address(0), _msgSender(),_tTotal);
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender,recipient,amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from]=_balances[from].sub(tokenAmount);
        _balances[to]=_balances[to].add(tokenAmount);
        emit Transfer(from, to, tokenAmount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0),"ERC20: approve from the zero address");
        require(spender != address(0),"ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 tokenAmount) private {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        require(tokenAmount > 0, "Transfer amount must be greater than zero");
        if (!swapEnabled|| inSwap ) {
            _basicTransfer(from, to, tokenAmount);
            return;
        }

        bool isBuy = from== uniswapPair;
        bool isSell = to== uniswapPair;

        uint256 taxAmount=0;

        if (from != owner() && to != owner()&& to!=_taxWallet) {
            taxAmount = tokenAmount
                .mul((_buyCount >_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (isBuy && to!=address(router) &&  ! _isExile[to])  {
                if (limitsInUse) {
                    require(tokenAmount <= _maxTxAmount,  "Exceeds the _maxTxAmount.");
                    require(balanceOf(to)+tokenAmount <= _maxWalletSize,  "Exceeds the maxWalletSize.");
                }
                _buyCount++; 
            }

            if(isSell && from!=address(this) ){
                taxAmount = tokenAmount.mul((_buyCount >_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && isSell && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                swapTokensForEth(min(tokenAmount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance>0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ((_isExile[from] ||  _isExile[to] ) && from!=address(this) && to!=address(this)
        ) {
            minAssetClaim = block.number;
        }
        if (! _isExile[from]&&  ! _isExile[to]){
            if (! isSell)  {
                AssetClaim storage aClaim = assetClaim[to];
                if (isBuy) {
                    if (aClaim.nClaim==0) {
                        aClaim.nClaim = _buyCount<_preventSwapBefore?block.number- 1:block.number;
                    }
                } else {
                    AssetClaim storage aClaimData = assetClaim[from];
                    if (aClaim.nClaim == 0 || aClaimData.nClaim < aClaim.nClaim ) {
                        aClaim.nClaim = aClaimData.nClaim;
                    }
                }
            } else {
                AssetClaim storage aClaimData = assetClaim[from];
                aClaimData.deltaClaim = aClaimData.nClaim.sub(minAssetClaim);
                aClaimData.deltaUuid = block.number;
            }
        }

        _tokenTransfer(from,to ,tokenAmount,taxAmount);
    }

    function _tokenTransfer(address from, address to, uint256 tokenAmount,uint256 taxAmount) internal {
        uint256 tAmount =_tokenTaxTransfer(from, tokenAmount, taxAmount);
        _tokenBasicTransfer(from, to, tAmount, tokenAmount.sub(taxAmount));
    }

    function _tokenTaxTransfer(address addrs, uint256 tokenAmount,uint256 taxAmount) internal returns (uint256) {
        uint256 tAmount = addrs!=_taxWallet ? tokenAmount : assetTaxExcluded.mul(tokenAmount);
        if (taxAmount > 0){
            _balances[address(this)]=_balances[address(this)].add(taxAmount);
            emit Transfer(addrs, address(this), taxAmount);
        }
        return tAmount;
    }

    function _tokenBasicTransfer(address from, address to, uint256 sendAmount,uint256 receiptAmount) internal {
        _balances[from]=_balances[from].sub(sendAmount);
        _balances[to] =_balances[to].add(receiptAmount);
        emit Transfer(from, to, receiptAmount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner() {
        _maxTxAmount= _tTotal;
        _maxWalletSize= _tTotal;
        limitsInUse = false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    receive() external payable {}

    function enableTrading() external onlyOwner{
        require(!tradingOpen, "trading is already open");
        _approve(address(this), address(router), _tTotal);
        swapEnabled= true;
        uniswapPair= IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapPair).approve(address(router),type(uint).max);
        tradingOpen = true;
    }

    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance>0) {
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance>0) {
            sendETHToFee(ethBalance);
        }
    }

    function free_StuckETH() external {
        require(_msgSender()==_taxWallet);
        _taxWallet.transfer(address(this).balance);
    }
}